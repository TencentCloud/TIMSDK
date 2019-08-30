#ifndef __HTTPCLIENT_H__
#define __HTTPCLIENT_H__


#include <string>
#include <vector>
#include <windows.h>
#include <winhttp.h>
/**************************************************************************/

enum HttpErrorCode
{
    EcHttpCodeError = 1
};

class HttpClient
{
public:
    explicit HttpClient(const std::wstring& user_agent);
    ~HttpClient();

    void setProxy(const std::string& ip, unsigned short port);

    DWORD http_get(const std::wstring& url
        , const std::vector<std::wstring>& headers, std::string& resp_data);
    DWORD http_post(const std::wstring& url
        , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data);
    DWORD http_put(const std::wstring& url
        , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data);
    void  http_close();
private:
    DWORD request(const std::wstring& url, const std::wstring& method
        , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data);
private:
    std::wstring m_user_agent;
    HINTERNET m_hSession;
    HINTERNET m_hConnect;
    HINTERNET m_hRequest;

    std::string m_proxyIP;
    unsigned short m_proxyPort;
};

#endif /* __HTTPCLIENT_H__ */
