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

    //HANDLE hSingleMetux = ::CreateMutex(NULL, FALSE, TEXT("IMApp_Metux_V1.0.0.1"));
    //if (GetLastError() == ERROR_ALREADY_EXISTS) {
    //    CIMWnd::MsgBoxEx("info", "IMApp has started");
    //    CloseHandle(hSingleMetux);
    //    return 0;
    //}

    ::OleInitialize(NULL);
    ::CoInitialize(NULL);
    const char* version = TIMGetSDKVersion();

    SdkAppInfo appinfo;
    appinfo.sdkappid = "12345678";  //写入您在腾讯云控制台云通信的应用SDKAPPID
    AccountInfo account;
    account.userid = "user1";       //写入测试账号identifier
    account.usersig = "user1sig";   //写入上述第三步生成的usersig
    appinfo.accounts.push_back(account);
    account.userid = "user2";
    account.usersig = "user2sig";
    appinfo.accounts.push_back(account);
    account.userid = "user3";
    account.usersig = "user3sig";
    appinfo.accounts.push_back(account);
    account.userid = "user4";
    account.usersig = "user4sig";
    appinfo.accounts.push_back(account);

    CIMWnd& wnd = CIMWnd::GetInst();
    wnd.Init(appinfo);
    wnd.Create(NULL, _T("IMApp"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
    wnd.CenterWindow();
    wnd.ShowModal();
    ::CoUninitialize();
    ::OleUninitialize();
    LOGNF("WinMain:: App quit end");
    return 0;
}
