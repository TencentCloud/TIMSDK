#include "HttpReportRequest.h"
#include "log.h"
#include "Base.h"

#include <assert.h>
#include <sstream>

#define DEFAULT_ELK_HOST "https://ilivelog.qcloud.com"

HttpReportRequest::HttpReportRequest()
    : m_httpClient(L"User-Agent")
    , m_taskQueue()
{

}

HttpReportRequest::~HttpReportRequest()
{

}

void HttpReportRequest::close()
{
    m_taskQueue.quit();
    m_httpClient.http_close();
    m_taskQueue.wait();
}

HttpReportRequest & HttpReportRequest::instance()
{
    static HttpReportRequest instance;
    return instance;
}

void HttpReportRequest::setProxy(const std::string& ip, unsigned short port)
{
    m_httpClient.setProxy(ip, port);
}

void HttpReportRequest::reportELK(const std::string & reportJson)
{
    m_taskQueue.post(true, [=]() {
        std::wstring contentLength = format(L"Content-Length: %lu", reportJson.size());

        std::wstring url = Ansi2Wide(DEFAULT_ELK_HOST);

        std::vector<std::wstring> headers;
        headers.push_back(L"Content-Type: application/json; charset=utf-8");
        headers.push_back(contentLength);

        LOGNF("Request ready");
        std::string respData;
        DWORD ret = m_httpClient.http_post(url, headers, reportJson, respData);
        LOGNF("jsonStr: %s, ret: %lu, respData: %s", Ansi2Wide(reportJson).c_str(), ret, UTF82Wide(respData).c_str());
    });
}
