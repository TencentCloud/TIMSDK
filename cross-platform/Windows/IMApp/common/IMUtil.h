#pragma once
#include <string>
#include <vector>


std::string genRandomNumString(int length); //length > 0 && length <= 20
std::wstring getAppDirectory();

std::string GetLastErrStr(const char* msg = NULL);
std::string Fmt(const char* szFmt, ...);
void FmtV(std::string &out_str, const char* fmt, va_list ap);


#ifdef UNICODE
typedef std::wstring TString;
#else
typedef std::string TString;
#endif

// ASCII <----> UNICODE
bool Str2WStr(const std::string strAscii, std::wstring &wstUnicode);
std::wstring Str2WStr(const std::string strAscii);

bool WStr2Str(const std::wstring wstUnicode, std::string & strAscii);
std::string WStr2Str(const std::wstring wstUnicode);

// Str <----> TStr
bool Str2TStr(const std::string strData, TString &tstData);
TString Str2TStr(const std::string strData);

bool TStr2Str(const TString tstData, std::string &strData);
std::string TStr2Str(const TString tstData);

//TStr <----> WStr
bool WStr2TStr(const std::wstring strData, TString &tstData);
TString WStr2TStr(const std::wstring strData);

bool TStr2WStr(const TString tstData, std::wstring &strData);
std::wstring TStr2WStr(const TString tstData);

std::string Ascii2Utf8(std::string &strAscii);

