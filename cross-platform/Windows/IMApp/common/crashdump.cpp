/**************************************************************************
    Copyright:      Copyright ? 1998 - 2017 Tencent. All Rights Reserved
    Created:        2017-2-17 11:28:54
    Filename:       CrashDump.cpp

    Description:
***************************************************************************/

#include "CrashDump.h"

#include <ctime>
#include <string>
#include <sstream>
#include <assert.h>

#include <DbgHelp.h>
#include <shellapi.h>

typedef BOOL(WINAPI *getUserModeExceptionProc)(LPDWORD);
typedef BOOL(WINAPI *setUserModeExceptionProc)(DWORD);

typedef BOOL(WINAPI *MINIDUMPWRITEDUMP) (
    HANDLE hProcess,
    DWORD ProcessId,
    HANDLE hFile,
    MINIDUMP_TYPE DumpType,
    PMINIDUMP_EXCEPTION_INFORMATION ExceptionParam,
    PMINIDUMP_USER_STREAM_INFORMATION UserStreamParam,
    PMINIDUMP_CALLBACK_INFORMATION CallbackParam
    );

static std::wstring format(const wchar_t* pszFormat, ...)
{
    wchar_t buffer[MAX_PATH] = { 0 };

    va_list ap;
    va_start(ap, pszFormat);
    int nCount = ::vswprintf_s(buffer, _countof(buffer), pszFormat, ap);
    va_end(ap);

    if (nCount < 0)
    {
        assert(false);
        return pszFormat;
    }

    return buffer;
}

/**************************************************************************/

CrashDump::CrashDump()
    : m_oldExceptionFilter(NULL)
{
    // 堆异常
    BOOL bRet = ::HeapSetInformation(NULL, HeapEnableTerminationOnCorruption, NULL, 0);
    ::OutputDebugStringW(format(L"HeapSetInformation, bRet: <%lu, %lu>.\n", bRet, ::GetLastError()).c_str());

    // DEP策略
    bRet = ::SetProcessDEPPolicy(PROCESS_DEP_ENABLE | PROCESS_DEP_DISABLE_ATL_THUNK_EMULATION);
    ::OutputDebugStringW(format(L"SetProcessDEPPolicy, bRet: <%lu, %lu>.\n", bRet, ::GetLastError()).c_str());

    //standard app-wide unhandled exception filter
    m_oldExceptionFilter = ::SetUnhandledExceptionFilter(UnhandledExceptionFilter);

    //fix for exceptions being swallowed inside callbacks (see KB976038)
    HMODULE hKernel32 = GetModuleHandle(TEXT("KERNEL32"));
    if (NULL == hKernel32)
    {
        ::OutputDebugStringW(L"GetModuleHandle faled.\n");
    }
    else
    {
        DWORD dwFlags = 0;
        getUserModeExceptionProc procGetProcessUserModeExceptionPolicy;
        setUserModeExceptionProc procSetProcessUserModeExceptionPolicy;

        procGetProcessUserModeExceptionPolicy = (getUserModeExceptionProc)::GetProcAddress(hKernel32, "GetProcessUserModeExceptionPolicy");
        procSetProcessUserModeExceptionPolicy = (setUserModeExceptionProc)::GetProcAddress(hKernel32, "SetProcessUserModeExceptionPolicy");

        if (procGetProcessUserModeExceptionPolicy && procSetProcessUserModeExceptionPolicy)
        {
            if (procGetProcessUserModeExceptionPolicy(&dwFlags))
            {
                bRet = procSetProcessUserModeExceptionPolicy(dwFlags & ~1);
                ::OutputDebugStringW(format(L"GetProcessUserModeExceptionPolicy, bRet: %lu.\n", bRet).c_str());
            }

            ::OutputDebugStringW(format(L"SetProcessUserModeExceptionPolicy, bRet: %lu, dwFlags: %lu.\n", bRet, dwFlags).c_str());
        }
    }
}

CrashDump::~CrashDump()
{
    if (NULL != m_oldExceptionFilter)
    {
        ::SetUnhandledExceptionFilter(m_oldExceptionFilter);
    }
}

LONG WINAPI CrashDump::UnhandledExceptionFilter(struct _EXCEPTION_POINTERS* pExceptionInfo)
{
    //always break into a debugger if one is present
    if (::IsDebuggerPresent())
    {
        ::OutputDebugStringW(L"IsDebuggerPresent return TRUE.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    //exception codes < 0x80000000 are typically informative only and not crash worthy
    //0xe06d7363 indicates a c++ exception was thrown, let's just hope it was caught.
    //this is no longer needed since we're an unhandled handler vs a vectored handler

    /*if (exceptionInfo->ExceptionRecord->ExceptionCode < 0x80000000 || exceptionInfo->ExceptionRecord->ExceptionCode == 0xe06d7363 ||
    exceptionInfo->ExceptionRecord->ExceptionCode == 0x800706b5)
    return EXCEPTION_CONTINUE_SEARCH;*/

    //uh oh, we're crashing inside ourselves... this is really bad!
    static BOOL inExceptionHandler = FALSE;
    if (inExceptionHandler)
    {
        ::OutputDebugStringW(L"Current function has crashed.Shit.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    inExceptionHandler = TRUE;

    WCHAR fullPath[MAX_PATH] = { 0 };
    DWORD pathLength = ::GetModuleFileNameW(NULL, fullPath, MAX_PATH);
    if (0 == pathLength)
    {
        ::OutputDebugStringW(L"GetModuleFileNameW failed.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    LPCWSTR lastSlash = ::wcsrchr(fullPath, L'\\');
    if (NULL == lastSlash)
    {
        ::OutputDebugStringW(L"wcsrchr return wrong.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    std::wstring exeDirPath(fullPath, lastSlash - fullPath + 1);

    WCHAR filePath[MAX_PATH] = { 0 };
    for (int i = 0; ; ++i)  // 避免同名
    {
        SYSTEMTIME sys_time = { 0 };
        ::GetLocalTime(&sys_time);

        ::swprintf_s(filePath, _countof(filePath) - 1, L"%s%04u_%02u_%02u_%02u_%02u_%02u_%d.dmp"
            , exeDirPath.c_str()
            , sys_time.wYear, sys_time.wMonth, sys_time.wDay
            , sys_time.wHour, sys_time.wMinute, sys_time.wSecond, i);

        if (::GetFileAttributes(filePath) == INVALID_FILE_ATTRIBUTES)
        {
            break;
        }
    }

    HANDLE hFile = ::CreateFileW(filePath, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (INVALID_HANDLE_VALUE == hFile)
    {
        ::OutputDebugStringW(L"CreateFileW failed.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    //load dbghelp dynamically
    HMODULE hDbgHelp = LoadLibraryW(L"DBGHELP");
    if (!hDbgHelp)
    {
        ::OutputDebugStringW(L"LoadLibraryW DBGHELP failed.\n");

        return EXCEPTION_CONTINUE_SEARCH;
    }

    MINIDUMPWRITEDUMP fnMiniDumpWriteDump = (MINIDUMPWRITEDUMP)::GetProcAddress(hDbgHelp, "MiniDumpWriteDump");
    if (!fnMiniDumpWriteDump)
    {
        ::OutputDebugStringW(L"GetProcAddress MiniDumpWriteDump failed.\n");

        ::FreeLibrary(hDbgHelp);

        return EXCEPTION_CONTINUE_SEARCH;
    }

    MINIDUMP_TYPE dumpFlags = (MINIDUMP_TYPE)(MiniDumpWithIndirectlyReferencedMemory | MiniDumpWithUnloadedModules | MiniDumpWithProcessThreadData);

    MINIDUMP_EXCEPTION_INFORMATION miniInfo = {0};
    miniInfo.ClientPointers = TRUE;
    miniInfo.ExceptionPointers = pExceptionInfo;
    miniInfo.ThreadId = ::GetCurrentThreadId();

    //generate a minidump if possible
    if (fnMiniDumpWriteDump(::GetCurrentProcess(), ::GetCurrentProcessId(), hFile, dumpFlags, &miniInfo, NULL, NULL))
    {
        WCHAR buffer[MAX_PATH] = { 0 };
        ::swprintf_s(buffer, _countof(buffer) - 1, L"Process has crashed.\nMinidump was saved to: \n\\%s\n", filePath);
        ::OutputDebugStringW(buffer);

        ::MessageBoxW(NULL, buffer, NULL, MB_ICONERROR | MB_OK);
    }
    else
    {
        ::OutputDebugStringW(format(L"Minidump was saved failed: %hu.\n", ::GetLastError()).c_str());

        ::MessageBoxW(NULL, format(L"Minidump was saved failed: %hu.\n", ::GetLastError()).c_str(), NULL, MB_ICONERROR | MB_OK);
    }

    ::FreeLibrary(hDbgHelp);
    ::CloseHandle(hFile);

    //we really shouldn't be returning here, if we're at the bottom of the VEH chain this is a pretty legitimate crash
    //and if we return we could end up invoking a second crash handler or other weird / annoying things
    //ExitProcess(exceptionInfo->ExceptionRecord->ExceptionCode);
    return EXCEPTION_CONTINUE_SEARCH;
}

/**************************************************************************/
