#ifndef __HttpReportRequest_H__
#define __HttpReportRequest_H__

#include "HttpClient.h"
#include "TaskQueue.h"
#include "json.h"
#include <string>

class HttpReportRequest
{
public:
    HttpReportRequest();
    ~HttpReportRequest();

    void close();

    static HttpReportRequest& instance();

    void setProxy(const std::string& ip, unsigned short port);

    void reportELK(const std::string& reportJson);

private:
    HttpClient m_httpClient;
    TaskQueue m_taskQueue;
};


#endif /* __HttpReportRequest_H__ */
