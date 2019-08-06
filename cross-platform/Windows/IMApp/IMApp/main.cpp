#include "IMWnd.h"
#include <olectl.h>
#include <objbase.h>
#include <windows.h>
#include <TlHelp32.h>
#include "../common/log.h"
#include "../common/crashdump.h"
#include "UIlib.h"
#include "MsgBox.h"

#pragma comment(lib, "ws2_32.lib")

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPSTR /*lpCmdLine*/, int nCmdShow) {
    LOGNF("WinMain:: App run begin");
    CrashDump dump;
    CPaintManagerUI::SetInstance(hInstance);
    // 资源路径
    CDuiString strResourcePath = CPaintManagerUI::GetInstancePath();
    strResourcePath += _T("imskin");
    CPaintManagerUI::SetResourcePath(strResourcePath.GetData());

//     HANDLE hSingleMetux = ::CreateMutex(NULL, FALSE, TEXT("IMApp_Metux_V1.0.0.1"));
//     if (GetLastError() == ERROR_ALREADY_EXISTS) {
//         CIMWnd::MsgBoxEx("info", "IMApp has started");
//         CloseHandle(hSingleMetux);
//         return 0;
//     }

    ::OleInitialize(NULL);
    ::CoInitialize(NULL);
    const char* version = TIMGetSDKVersion();


    CIMWnd& wnd = CIMWnd::GetInst();
    wnd.Init();
    wnd.Create(NULL, _T("IMApp"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
    wnd.CenterWindow();
    wnd.ShowModal();
    ::CoUninitialize();
    ::OleUninitialize();
    LOGNF("WinMain:: App quit end");
    return 0;
}
