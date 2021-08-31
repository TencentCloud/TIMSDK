#ifndef _BASE_H_
#define _BASE_H_

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <string>
#include <memory>
#include <stdio.h>
#include <assert.h>

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
    TypeName(const TypeName&);               \
    void operator=(const TypeName&)

static std::wstring UTF82Wide(const std::string& strUTF8)
{
    int nWide = ::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), NULL, 0);

    std::unique_ptr<wchar_t[]> buffer(new wchar_t[nWide + 1]);
    if (!buffer)
    {
        return L"";
    }

    ::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), buffer.get(), nWide);
    buffer[nWide] = L'\0';

    return buffer.get();
}

static std::wstring Ansi2Wide(const std::string& strAnsi)
{
    int nWide = ::MultiByteToWideChar(CP_ACP, 0, strAnsi.c_str(), strAnsi.size(), NULL, 0);

    std::unique_ptr<wchar_t[]> buffer(new wchar_t[nWide + 1]);
    if (!buffer)
    {
        return L"";
    }

    ::MultiByteToWideChar(CP_ACP, 0, strAnsi.c_str(), strAnsi.size(), buffer.get(), nWide);
    buffer[nWide] = L'\0';

    return buffer.get();
}

static std::string Wide2UTF8(const std::wstring strWide)
{
    int nUTF8 = ::WideCharToMultiByte(CP_UTF8, 0, strWide.c_str(), strWide.size(), NULL, 0, NULL, NULL);

    std::unique_ptr<char[]> buffer(new char[nUTF8 + 1]);
    if (!buffer)
    {
        return "";
    }

    ::WideCharToMultiByte(CP_UTF8, 0, strWide.c_str(), strWide.size(), buffer.get(), nUTF8, NULL, NULL);
    buffer[nUTF8] = '\0';

    return buffer.get();
}

static std::string Wide2Ansi(const std::wstring strWide)
{
    int nAnsi = ::WideCharToMultiByte(CP_ACP, 0, strWide.c_str(), strWide.size(), NULL, 0, NULL, NULL);

    std::unique_ptr<char[]> buffer(new char[nAnsi + 1]);
    if (!buffer)
    {
        return "";
    }

    ::WideCharToMultiByte(CP_ACP, 0, strWide.c_str(), strWide.size(), buffer.get(), nAnsi, NULL, NULL);
    buffer[nAnsi] = '\0';

    return buffer.get();
}

static std::string Ansi2UTF8(const std::string& strAnsi)
{
    return Wide2UTF8(Ansi2Wide(strAnsi));
}

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

static std::string format(const char* pszFormat, ...)
{
    char buffer[MAX_PATH] = { 0 };

    va_list ap;
    va_start(ap, pszFormat);
    int nCount = ::vsprintf_s(buffer, _countof(buffer), pszFormat, ap);
    va_end(ap);

    if (nCount < 0)
    {
        assert(false);
        return pszFormat;
    }

    return buffer;
}

#endif  // _BASE_H_
