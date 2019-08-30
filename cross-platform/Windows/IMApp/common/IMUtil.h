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



