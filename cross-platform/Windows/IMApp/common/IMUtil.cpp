#include "IMUtil.h"
#include <time.h>
#include <windows.h>
#include "log.h"

void vec2str(const std::vector<uint8_t> &vec_data, std::string &str_data) {
    for (std::vector<uint8_t>::size_type i = 0; i < vec_data.size(); i++) {
        if (0 == vec_data[i]) {
            break;
        }
        str_data.push_back(vec_data[i]);
    }
}
std::string genRandomNumString(int length)
{
    int flag, i;
    std::string calStr = "12345678901234567890";
    if (length <= 0 || length > 20)
        return calStr;

    srand((unsigned)time(NULL));

    for (i = 0; i < length; i++)
    {
        flag = 2;//= rand() % 3;          
        switch (flag)
        {
            //case 0: retStr[i] = 'A' + rand() % 26; break;
            //case 1: retStr[i] = 'a' + rand() % 26; break;              
        case 2: calStr[i] = '0' + rand() % 10; break;
        default: calStr[i] = 'x'; break;
        }
    }

    return calStr.substr(0, length);
}

std::wstring getAppDirectory()
{
    wchar_t szCurrentDirectory[MAX_PATH] = { 0 };
    DWORD dwCurDirPathLen;
    dwCurDirPathLen = ::GetModuleFileNameW(NULL, szCurrentDirectory, MAX_PATH);
    std::wstring appPath;
    appPath = szCurrentDirectory;
    int pos = appPath.find_last_of(L'\\');
    int size = appPath.size();
    std::wstring _appFilePath = appPath.erase(pos, size);
    _appFilePath += L"\\";
    return _appFilePath;
}
#define STRING_FMT_MAX_LENGHT 0x2000
void FmtV(std::string &out_str, const char* fmt, va_list ap) {
    std::string tmp(STRING_FMT_MAX_LENGHT, 0);
    _vsnprintf_s((char*)tmp.c_str(), STRING_FMT_MAX_LENGHT - 1, STRING_FMT_MAX_LENGHT, fmt, ap);
    out_str = tmp.c_str();
}

std::string Fmt(const char* szFmt, ...) {
    if (!szFmt) {
        return "";
    }

    std::string tmp;
    va_list ap;
    va_start(ap, szFmt);
    FmtV(tmp, szFmt, ap);
    va_end(ap);

    return tmp.c_str();
}

std::string GetLastErrStr(const char* msg) {
    std::string ret;
    if (msg) {
        ret = msg;
        ret = ret + " ";
    }
    DWORD dwLastError = GetLastError();
    LPVOID lpMsgBuf = NULL;
    FormatMessageA(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dwLastError,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPSTR)&lpMsgBuf,
        0,
        NULL);
    if (NULL != lpMsgBuf) {
        ret = Fmt("%s(%d)%s", ret.c_str(), dwLastError, (char*)lpMsgBuf);
        LocalFree(lpMsgBuf);
    }
    return ret;
}