#include "HttpClient.h"

#include <assert.h>
#include <memory>
#include "curl/curl.h"
#include "Base.h"

/**************************************************************************/

#define USER_CURL 1

struct RequestSink
{
    std::string* reqData;
    size_t sendSize;
};

struct ResponseSink
{
    std::string* respData;
    std::vector<std::string>* respHeaders;
};

static size_t onRequest(void *ptr, size_t size, size_t nmemb, void *stream)
{
    RequestSink* reqSink = reinterpret_cast<RequestSink*>(stream);
    std::string* reqData = reqSink->reqData;

    size_t sendSize = reqSink->sendSize;
    size_t actualSize = reqData->size() - sendSize;
    if (actualSize > 4096)
    {
        actualSize = 4096;
    }

    memcpy_s(ptr, size * nmemb, &((*reqData)[sendSize]), actualSize);
    reqSink->sendSize += actualSize;

    return actualSize;
}

static size_t onResponse(void *ptr, size_t size, size_t nmemb, void *stream)
{
    ResponseSink* respSink = reinterpret_cast<ResponseSink*>(stream);
    std::string* respData = respSink->respData;

    respData->append((char*)ptr, size * nmemb);

    return (size * nmemb);
}

static size_t onHeaderCallback(char *buffer, size_t size, size_t nitems, void *userdata)
{
    std::string str(buffer, size * nitems);
    size_t index = str.rfind('\r');

    std::string header = str.substr(0, index);
    if (false == header.empty())
    {
        ResponseSink* respSink = reinterpret_cast<ResponseSink*>(userdata);
        respSink->respHeaders->push_back(header.substr(0, index));
    }

    return (size * nitems);
}

HttpClient::HttpClient(const std::wstring& user_agent)
    : m_user_agent(user_agent)
    , m_hSession(NULL)
    , m_hConnect(NULL)
    , m_hRequest(NULL)
    , m_proxyIP("")
    , m_proxyPort(1080)
{

}

HttpClient::~HttpClient()
{
    http_close();
}


size_t req_reply(void *ptr, size_t size, size_t nmemb, void *stream)
{
    std::string *str = (std::string*)stream;
    (*str).append((char*)ptr, size * nmemb);
    return (size * nmemb);
}

void HttpClient::setProxy(const std::string& ip, unsigned short port)
{
    m_proxyIP = ip;
    m_proxyPort = port;
}

DWORD HttpClient::http_get(const std::wstring& url
    , const std::vector<std::wstring>& headers, std::string& resp_data)
{
#ifndef USER_CURL
    DWORD ret = request(url, L"GET", headers, std::string(), resp_data);
    http_close();
    return ret;
#else

    std::string url_temp = Wide2UTF8(url);
    CURL* curl = curl_easy_init();

    CURLcode res = CURLE_OK;
    if (curl)
    {
        std::vector<std::string> respHeaders;
        ResponseSink sink = { &resp_data, &respHeaders };

        // set params  
        curl_easy_setopt(curl, CURLOPT_URL, url_temp.c_str()); // url
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, onResponse);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&sink);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, onHeaderCallback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, (void *)&sink);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 5000);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5000);

        if (false == m_proxyIP.empty())
        {
            curl_easy_setopt(curl, CURLOPT_PROXY, m_proxyIP.c_str());
            curl_easy_setopt(curl, CURLOPT_PROXYPORT, m_proxyPort);
            curl_easy_setopt(curl, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5_HOSTNAME);
        }

        struct curl_slist *headerlist = NULL;
        size_t headerlength = headers.size();
        for (int i = 0; i < headerlength; i++)
        {
            headerlist = curl_slist_append(headerlist, Wide2UTF8(headers[i]).c_str());
        }

        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
        // start req  
        res = curl_easy_perform(curl);

        curl_slist_free_all(headerlist);
    }

    if (NULL != curl)
    {
        curl_easy_cleanup(curl);
        curl = NULL;
    }

    return res;
#endif // !USER_CURL
}

DWORD HttpClient::http_post(const std::wstring& url
    , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{

#ifndef USER_CURL
    DWORD ret = request(url, L"POST", headers, body, resp_data);
    http_close();
    return ret;
#else

    std::string url_temp = Wide2UTF8(url);
    CURL* curl = curl_easy_init();

    CURLcode res = CURLE_OK;
    if (curl)
    {
        RequestSink reqSink = { const_cast<std::string*>(&body), 0 };

        std::vector<std::string> respHeaders;
        ResponseSink respSink = { &resp_data, &respHeaders };

        // set params  
        curl_easy_setopt(curl, CURLOPT_POST, 1); // post req
        curl_easy_setopt(curl, CURLOPT_URL, url_temp.c_str()); // url
        curl_easy_setopt(curl, CURLOPT_READFUNCTION, onRequest); // 调用重写的读文件流函数
        curl_easy_setopt(curl, CURLOPT_READDATA, (void *)&reqSink); // 往read_file()函数中传入用户自定义的数据类型
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (curl_off_t)body.size());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, onResponse);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&respSink);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, onHeaderCallback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, (void *)&respSink);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 5000);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5000);

        if (false == m_proxyIP.empty())
        {
            curl_easy_setopt(curl, CURLOPT_PROXY, m_proxyIP.c_str());
            curl_easy_setopt(curl, CURLOPT_PROXYPORT, m_proxyPort);
            curl_easy_setopt(curl, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5_HOSTNAME);
        }

        struct curl_slist *headerlist = NULL;
        size_t headerlength = headers.size();
        for (int i = 0; i < headerlength; i++)
        {
            headerlist = curl_slist_append(headerlist, Wide2UTF8(headers[i]).c_str());
        }

        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);

        // start req  
        res = curl_easy_perform(curl);

        curl_slist_free_all(headerlist);
    }

    if (NULL != curl)
    {
        curl_easy_cleanup(curl);
        curl = NULL;
    }

    return res;
#endif
}

DWORD HttpClient::http_put(const std::wstring& url
    , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{
    DWORD ret = request(url, L"PUT", headers, body, resp_data);
    http_close();

    return ret;
}

void HttpClient::http_close()
{
    if (m_hRequest)
    {
        WinHttpCloseHandle(m_hRequest);
        m_hRequest = NULL;
    }

    if (m_hConnect)
    {
        WinHttpCloseHandle(m_hConnect);
        m_hConnect = NULL;
    }

    if (m_hSession)
    {
        WinHttpCloseHandle(m_hSession);
        m_hSession = NULL;
    }
}

DWORD HttpClient::request(const std::wstring& url, const std::wstring& method
    , const std::vector<std::wstring>& headers, const std::string& body, std::string& resp_data)
{
    assert(NULL == m_hSession && NULL == m_hConnect && NULL == m_hRequest);

    std::wstring host_name;
    std::wstring url_path;
    URL_COMPONENTS url_comp = { 0 };
    url_comp.dwStructSize = sizeof(url_comp);

    host_name.resize(url.size());
    url_path.resize(url.size());

    url_comp.lpszHostName = const_cast<wchar_t*>(host_name.data());
    url_comp.dwHostNameLength = host_name.size();
    url_comp.lpszUrlPath = const_cast<wchar_t*>(url_path.data());
    url_comp.dwUrlPathLength = url_path.size();
    if (FALSE == ::WinHttpCrackUrl(url.c_str(), static_cast<DWORD>(url.size()), 0, &url_comp))
    {
        return ::GetLastError();
    }

    m_hSession = ::WinHttpOpen(m_user_agent.c_str()
        , WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (NULL == m_hSession)
    {
        return ::GetLastError();
    }

    m_hConnect = ::WinHttpConnect(m_hSession, host_name.c_str(), url_comp.nPort, 0);
    if (NULL == m_hConnect)
    {
        return ::GetLastError();
    }

    DWORD flags = (INTERNET_SCHEME_HTTP == url_comp.nScheme ? 0 : WINHTTP_FLAG_SECURE);
    m_hRequest = ::WinHttpOpenRequest(m_hConnect, method.c_str(), url_path.c_str(),
        NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, flags);
    if (NULL == m_hRequest)
    {
        return ::GetLastError();
    }

    for (std::vector<std::wstring>::const_iterator it = headers.begin(); headers.end() != it; ++it)
    {
        ::WinHttpAddRequestHeaders(m_hRequest, it->c_str(), (ULONG)-1L, WINHTTP_ADDREQ_FLAG_ADD | WINHTTP_ADDREQ_FLAG_COALESCE);
    }

    if (0 == method.compare(L"GET"))
    {
        ::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
            0, WINHTTP_NO_REQUEST_DATA, 0,
            0, 0);
    }
    else if (0 == method.compare(L"POST"))
    {
        const void* body_data = reinterpret_cast<const void*>(body.c_str());
        ::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
            0, const_cast<void*>(body_data), body.size(),
            body.size(), 0);
    }
    else if (0 == method.compare(L"PUT"))
    {
        const void* body_data = reinterpret_cast<const void*>(body.c_str());
        ::WinHttpSendRequest(m_hRequest, WINHTTP_NO_ADDITIONAL_HEADERS,
            0, const_cast<void*>(body_data), body.size(),
            body.size(), 0);
    }

    if (ERROR_SUCCESS != ::GetLastError())
    {
        return ::GetLastError();
    }

    if (FALSE == ::WinHttpReceiveResponse(m_hRequest, NULL))
    {
        return ::GetLastError();
    }

    WCHAR status_code[16] = { 0 };
    DWORD buffer_length = _countof(status_code);
    if (FALSE == ::WinHttpQueryHeaders(m_hRequest, WINHTTP_QUERY_STATUS_CODE
        , WINHTTP_HEADER_NAME_BY_INDEX, status_code, &buffer_length
        , WINHTTP_NO_HEADER_INDEX))
    {
        return ::GetLastError();
    }

    DWORD size = 0;
    while (TRUE == ::WinHttpQueryDataAvailable(m_hRequest, &size))
    {
        if (0 == size)
        {
            break;
        }

        std::unique_ptr<char[]> buffer(new char[size]);
        if (NULL == buffer.get())
        {
            break;
        }

        DWORD lpdwNumberOfBytesRead = 0;
        if (TRUE == ::WinHttpReadData(m_hRequest, buffer.get(), size, &lpdwNumberOfBytesRead))
        {
            resp_data.append(buffer.get(), static_cast<size_t>(lpdwNumberOfBytesRead));
        }
        else
        {
            return ::GetLastError();
        }
    }

    const WCHAR ok_status_code[] = { L'2', L'0', L'0', L'\0' };
    if (0 != ::_wcsicmp(ok_status_code, status_code))
    {
        return EcHttpCodeError;
    }

    return ERROR_SUCCESS;
}
