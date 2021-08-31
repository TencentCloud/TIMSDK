#ifndef __HTTPSERVER_H__
#define __HTTPSERVER_H__

#include <vector>
#include <memory>
#include <thread>
#include <string>

/**************************************************************************/

enum HSLogLevel
{
    HSLOG_TRACK_LEVEL = 0,
    HSLOG_INFO_LEVEL = 1,
    HSLOG_WARNING_LEVEL = 2,
    HSLOG_ERROR_LEVEL = 3,
};

class IHttpServerCallback
{
public:
    virtual ~IHttpServerCallback() {}
    virtual void onGetRequest(const std::wstring& absPath, DWORD& statusCode, std::string& respDataUTF8) = 0;
    virtual void onLog(HSLogLevel level, const std::string& content) = 0;
    virtual void onClose(ULONGLONG requestId) = 0;
};

class HttpServer
{
public:
    explicit HttpServer(IHttpServerCallback* callback);
    ~HttpServer();

    DWORD listen(const std::vector<std::wstring>& urls);
    void close();
private:
    void handle();

    DWORD response(HANDLE hReqQueue, void* request, USHORT StatusCode, const char* pReason, const char* pEntityString);
private:
    IHttpServerCallback* m_callback;
    HANDLE m_reqQueue;
    std::unique_ptr<std::thread> m_thread;
    std::vector<std::wstring> m_urls;
};

#endif /* __HTTPSERVER_H__ */
