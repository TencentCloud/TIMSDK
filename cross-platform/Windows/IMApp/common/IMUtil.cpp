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

bool Mutil2WStr(std::vector<unsigned char> &vecBuf, std::wstring &wstOut, int nCode) {
    bool bRet = false;

    do {
        if (vecBuf.size() == 0) {
            LOGE("vecBuf.size() == 0");
            break;
        }
        int nLen = MultiByteToWideChar(nCode, 0, (LPSTR)vecBuf.data(), vecBuf.size(), NULL, 0);
        if (nLen <= 0) {
            LOGEF("MultiByteToWideChar Failure!err:%s", GetLastErrStr().c_str());
            break;
        }
        std::wstring wst_temp;
        wst_temp.resize(nLen + 1, 0);
        int nLen2 = MultiByteToWideChar(nCode, 0, (LPSTR)vecBuf.data(), vecBuf.size(), (LPWSTR)wst_temp.c_str(), nLen);
        if (nLen2 != nLen) {
            LOGEF("MultiByteToWideChar Failure!err:%s", GetLastErrStr().c_str());
            break;
        }
        wstOut = wst_temp.c_str();
        bRet = true;
    } while (false);

    return bRet;
}

bool WStr2Mutil(const std::wstring &wstOut, std::vector<unsigned char> &vecBuf, int nCode) {
    bool bRet = false;
    do {
        if (wstOut.size() == 0) {
            LOGE("wstOut.size() == 0");
            break;
        }

        int nLen = WideCharToMultiByte(nCode, 0, (LPWSTR)wstOut.data(), wstOut.size(), NULL, 0, NULL, NULL);
        if (nLen <= 0) {
            LOGEF("WideCharToMultiByte Failure!err:%s", GetLastErrStr().c_str());
            break;
        }
        vecBuf.resize(nLen, 0);
        int nLen2 = WideCharToMultiByte(nCode, 0, (LPWSTR)wstOut.data(), wstOut.size(), (LPSTR)(vecBuf.data()), nLen, NULL, NULL);
        if (nLen2 != nLen) {
            vecBuf.clear();
            LOGEF("WideCharToMultiByte Failure!err:%s", GetLastErrStr().c_str());
            break;
        }

        bRet = true;
    } while (false);

    return bRet;
}


void str2vec(const std::string str_data, std::vector<uint8_t> &vec_data) {
    for (std::string::size_type i = 0; i < str_data.length(); i++) {
        vec_data.push_back(str_data[i]);
    }
}

std::vector<uint8_t> str2vec(const std::string str_data) {
    std::vector<uint8_t> vec_data;
    str2vec(str_data, vec_data);
    return vec_data;
}

bool Str2WStr(const std::string strAscii, std::wstring &wstUnicode) {
    bool bRet = false;
    if (0 == strAscii.length()) {
        return true;
    }
    do {
        std::vector<unsigned char> vecBuf;
        str2vec(strAscii, vecBuf);
        if (false == Mutil2WStr(vecBuf, wstUnicode, CP_ACP)) {
            LOGE("Call WStrToMutil Failure!");
            break;
        }
        if (0 == wstUnicode.length()) {
            LOGE("wstUnicode.length == 0");
            break;
        }

        bRet = false;
    } while (false);

    return bRet;
}


bool WStr2Str(const std::wstring wstUnicode, std::string & strAscii) {
    bool bRet = false;
    if (0 == wstUnicode.length()) {
        return true;
    }
    do {
        std::vector<unsigned char> vecBuf;
        if (false == WStr2Mutil(wstUnicode, vecBuf, CP_ACP)) {
            LOGE("Call WStrToMutil Failure!(%s)");
            break;
        }
        vec2str(vecBuf, strAscii);
        if (0 == strAscii.length()) {
            LOGE("strAscii.length == 0");
            break;
        }

        bRet = true;
    } while (false);

    return bRet;
}
std::wstring Str2WStr(const std::string strAscii) {
    std::wstring wstUnicode = L"";
    Str2WStr(strAscii, wstUnicode);
    return wstUnicode;
}

std::string WStr2Str(const std::wstring wstUnicode) {
    std::string strAscii = "";
    WStr2Str(wstUnicode, strAscii);
    return strAscii;
}
bool Str2TStr(const std::string strData, TString &tstData) {
#ifdef UNICODE
    return Str2WStr(strData, tstData);
#else
    tstData = strData;
    return true;
#endif
}

TString Str2TStr(const std::string strData) {
#ifdef UNICODE
    return Str2WStr(strData);
#else
    return strData;
#endif
}

bool TStr2Str(const TString tstData, std::string &strData) {
#ifdef UNICODE
    return WStr2Str(tstData, strData);
#else
    strData = tstData;
    return true;
#endif
}
std::string TStr2Str(const TString tstData) {
#ifdef UNICODE
    return WStr2Str(tstData);
#else
    return tstData;
#endif
}

//TStr <----> WStr
bool WStr2TStr(const std::wstring strData, TString &tstData) {
#ifdef UNICODE
    tstData = strData;
    return true;
#else
    return WStr2Str(strData, tstData);
#endif
}
TString WStr2TStr(const std::wstring strData) {
#ifdef UNICODE
    return strData;
#else
    return WStr2Str(strData);
#endif
}

bool TStr2WStr(const TString tstData, std::wstring &strData) {
#ifdef UNICODE
    strData = tstData;
    return true;
#else
    return Str2WStr(tstData, strData);
#endif
}
std::wstring TStr2WStr(const TString tstData) {
#ifdef UNICODE
    return tstData;
#else
    return Str2WStr(tstData);
#endif
}


bool Ascii2Utf8(std::string strAscii, std::string &strUtf8) {
    strUtf8 = "";
    if (strAscii.length() == 0) {
        return true;
    }
    bool bRet = false;
    do {
        std::wstring wstTmp;
        int nLen = MultiByteToWideChar(CP_ACP, 0, (LPSTR)strAscii.data(), strAscii.size(), NULL, 0);
        if (nLen <= 0) {
            LOGEF("MultiByteToWideChar Failure!%d", GetLastError());
            break;
        }
        wstTmp.resize(nLen, 0);
        int nLen2 = MultiByteToWideChar(CP_ACP, 0, (LPSTR)strAscii.data(), strAscii.size(), (LPWSTR)wstTmp.c_str(), nLen);
        if (nLen2 != nLen) {
            LOGEF("MultiByteToWideChar Failure!%d", GetLastError());
            break;
        }

        nLen = WideCharToMultiByte(CP_UTF8, 0, (LPWSTR)wstTmp.data(), wstTmp.size(), NULL, 0, NULL, NULL);
        if (nLen <= 0) {
            LOGEF("WideCharToMultiByte Failure!%d", GetLastError());
            break;
        }
        std::string utf8_tmp;
        utf8_tmp.resize(nLen + 1, 0);
        nLen2 = WideCharToMultiByte(CP_UTF8, 0, (LPWSTR)wstTmp.data(), wstTmp.size(), (LPSTR)(utf8_tmp.data()), nLen, NULL, NULL);
        if (nLen2 != nLen) {
            LOGEF("WideCharToMultiByte Failure!%d", GetLastError());
            break;
        }
        strUtf8 = utf8_tmp.c_str();
        bRet = true;
    } while (false);

    return bRet;
}
std::string Ascii2Utf8(std::string &strAscii) {
    std::string strUtf8;
    Ascii2Utf8(strAscii, strUtf8);
    return strUtf8;
}