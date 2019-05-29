#ifndef UNICODE
#define UNICODE
#endif

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0600
#endif

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <Windows.h>
#include <http.h>
#include <assert.h>
#include <stdio.h>

#include "HttpServer.h"

/**************************************************************************/

//
// Macros.
//
#define INITIALIZE_HTTP_RESPONSE( resp, status, reason )    \
    do                                                      \
    {                                                       \
        RtlZeroMemory( (resp), sizeof(*(resp)) );           \
        (resp)->StatusCode = (status);                      \
        (resp)->pReason = (reason);                         \
        (resp)->ReasonLength = (USHORT) strlen(reason);     \
    } while (FALSE)

#define ADD_KNOWN_HEADER(Response, HeaderId, RawValue)               \
    do                                                               \
    {                                                                \
        (Response).Headers.KnownHeaders[(HeaderId)].pRawValue =      \
                                                          (RawValue);\
        (Response).Headers.KnownHeaders[(HeaderId)].RawValueLength = \
            (USHORT) strlen(RawValue);                               \
    } while(FALSE)

#define ALLOC_MEM(cb) HeapAlloc(GetProcessHeap(), 0, (cb))

#define FREE_MEM(ptr) HeapFree(GetProcessHeap(), 0, (ptr))


static std::string logFormat(const char* pszFormat, ...)
{
    char buffer[MAX_PATH * 4] = { 0 };  // 注意缓冲区溢出

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

HttpServer::HttpServer(IHttpServerCallback* callback)
    : m_callback(callback)
    , m_reqQueue(NULL)
    , m_thread()
    , m_urls()
{
    assert(m_callback);
}

HttpServer::~HttpServer()
{
    close();

    if (m_thread && m_thread->joinable())
    {
        m_thread->join();
    }
}

DWORD HttpServer::listen(const std::vector<std::wstring>& urls)
{
    m_callback->onLog(HSLOG_INFO_LEVEL, "Http server listen");

    if (m_thread)
    {
        assert(false == m_thread);  // 不支持重入
        m_callback->onLog(HSLOG_ERROR_LEVEL, "Do not support reentry");
        return ERROR_INVALID_ACCESS;
    }

    if (0 == urls.size())
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, "Do not support reentry");
        return ERROR_INVALID_PARAMETER;
    }

    ULONG ret = ::HttpInitialize(HTTPAPI_VERSION_1, HTTP_INITIALIZE_SERVER, NULL);
    if (NO_ERROR != ret)
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, logFormat("HttpInitialize failed: %lu", ret));
        return ret;
    }

    ret = ::HttpCreateHttpHandle(&m_reqQueue, 0);
    if (NO_ERROR != ret)
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, logFormat("HttpCreateHttpHandle failed: %lu", ret));
        return ret;
    }

    //
    // The command line arguments represent URIs that to 
    // listen on. Call HttpAddUrl for each URI.
    //
    // The URI is a fully qualified URI and must include the
    // terminating (/) character.
    //
    for (std::vector<std::wstring>::const_iterator it = urls.begin(); urls.end() != it; ++it)
    {
        ret = ::HttpAddUrl(m_reqQueue, it->c_str(), NULL);
        if (NO_ERROR != ret)
        {
            m_callback->onLog(HSLOG_ERROR_LEVEL, logFormat("HttpAddUrl failed: %lu", ret));
        }
    }

    m_thread.reset(new std::thread(&HttpServer::handle, this));
    if (false == m_thread)
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, "Create thread failed");
        return ERROR_OUTOFMEMORY;
    }

    return ERROR_SUCCESS;
}

void HttpServer::close()
{
    m_callback->onLog(HSLOG_INFO_LEVEL, "Http server close");

    if (NULL != m_reqQueue)
    {
        for (std::vector<std::wstring>::iterator it = m_urls.begin(); m_urls.end() != it; ++it)
        {
            ::HttpRemoveUrl(m_reqQueue, it->c_str());
        }

        ::CloseHandle(m_reqQueue);
        m_reqQueue = NULL;

        HttpTerminate(HTTP_INITIALIZE_SERVER, NULL);
    }
}

void HttpServer::handle()
{
    DWORD bytesRead = 0;
    PHTTP_REQUEST pRequest = NULL;
    PCHAR pRequestBuffer = NULL;
    ULONG RequestBufferLength = 0;

    //
    // Allocate a 2 KB buffer. This size should work for most 
    // requests. The buffer size can be increased if required. Space
    // is also required for an HTTP_REQUEST structure.
    //
    RequestBufferLength = sizeof(HTTP_REQUEST) + 2048;
    pRequestBuffer = (PCHAR)ALLOC_MEM(RequestBufferLength);

    if (pRequestBuffer == NULL)
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, "Out of memory");
        return;
    }

    pRequest = (PHTTP_REQUEST)pRequestBuffer;

    //
    // Wait for a new request. This is indicated by a NULL 
    // request ID.
    //
    HTTP_REQUEST_ID requestId = 0;
    HTTP_SET_NULL_ID(&requestId);

    while (true)
    {
        RtlZeroMemory(pRequest, RequestBufferLength);

        DWORD ret = ::HttpReceiveHttpRequest(
            m_reqQueue,         // Req Queue
            requestId,          // Req ID
            0,                  // Flags
            pRequest,           // HTTP request buffer
            RequestBufferLength,// req buffer length
            &bytesRead,         // bytes received
            NULL                // LPOVERLAPPED
        );

        if (NO_ERROR == ret)
        {
            switch (pRequest->Verb)
            {
            case HttpVerbGET:
            {
                //m_callback->onLog(HSLOG_INFO_LEVEL, logFormat("Got a GET request for %ws",
                //    pRequest->CookedUrl.pFullUrl));

                DWORD statusCode = 200;
                std::string respDataUTF8("");
                m_callback->onGetRequest(pRequest->CookedUrl.pAbsPath, statusCode, respDataUTF8);
                ret = response(m_reqQueue, pRequest, statusCode, "OK", respDataUTF8.c_str());
            }
                break;
            case HttpVerbPOST:
            {
                m_callback->onLog(HSLOG_INFO_LEVEL, logFormat("Got a POST request for %ws",
                    pRequest->CookedUrl.pFullUrl));

                // todo

                assert(false);
            }
                break;
            default:
            {
                m_callback->onLog(HSLOG_INFO_LEVEL, logFormat("Got a POST request for %ws, verb: %d",
                    pRequest->CookedUrl.pFullUrl, pRequest->Verb));

                ret = response(m_reqQueue, pRequest, 503, "Not Implemented", NULL);
            }
                break;
            }

            if (NO_ERROR != ret)
            {
                break;
            }

            //
            // Reset the Request ID to handle the next request.
            //
            HTTP_SET_NULL_ID(&requestId);
        }
        else if (ERROR_MORE_DATA == ret)
        {
            //
            // The input buffer was too small to hold the request
            // headers. Increase the buffer size and call the 
            // API again. 
            //
            // When calling the API again, handle the request
            // that failed by passing a RequestID.
            //
            // This RequestID is read from the old buffer.
            //
            requestId = pRequest->RequestId;

            //
            // Free the old buffer and allocate a new buffer.
            //
            RequestBufferLength = bytesRead;
            FREE_MEM(pRequestBuffer);
            pRequestBuffer = (PCHAR)ALLOC_MEM(RequestBufferLength);

            if (pRequestBuffer == NULL)
            {
                m_callback->onLog(HSLOG_ERROR_LEVEL, "Out of memory");
                break;
            }

            pRequest = (PHTTP_REQUEST)pRequestBuffer;

        }
        else if (ERROR_CONNECTION_INVALID == ret && !HTTP_IS_NULL_ID(&requestId))
        {
            // The TCP connection was corrupted by the peer when
            // attempting to handle a request with more buffer. 
            // Continue to the next request.
            HTTP_SET_NULL_ID(&requestId);
        }
        else
        {
            break;
        }
    }

    if (pRequestBuffer)
    {
        FREE_MEM(pRequestBuffer);
        pRequestBuffer = NULL;
    }
}

DWORD HttpServer::response(HANDLE hReqQueue, void* request, USHORT statusCode, const char* pReason, const char* pEntityString)
{
    PHTTP_REQUEST pRequest = reinterpret_cast<PHTTP_REQUEST>(request);

    //
    // Initialize the HTTP response structure.
    //
    HTTP_RESPONSE resp;
    INITIALIZE_HTTP_RESPONSE(&resp, statusCode, pReason);

    //
    // Add a known header.
    //
    ADD_KNOWN_HEADER(resp, HttpHeaderContentType, "text/html");

    HTTP_DATA_CHUNK dataChunk;
    if (pEntityString)
    {
        // 
        // Add an entity chunk.
        //
        dataChunk.DataChunkType = HttpDataChunkFromMemory;
        dataChunk.FromMemory.pBuffer = const_cast<char*>(pEntityString);
        dataChunk.FromMemory.BufferLength =
            (ULONG)strlen(pEntityString);

        resp.EntityChunkCount = 1;
        resp.pEntityChunks = &dataChunk;
    }

    // 
    // Because the entity body is sent in one call, it is not
    // required to specify the Content-Length.
    //
    DWORD bytesSent = 0;
    DWORD ret = HttpSendHttpResponse(
        hReqQueue,           // ReqQueueHandle
        pRequest->RequestId, // Request ID
        0,                   // Flags
        &resp,               // HTTP response
        NULL,                // pReserved1
        &bytesSent,          // bytes sent  (OPTIONAL)
        NULL,                // pReserved2  (must be NULL)
        0,                   // Reserved3   (must be 0)
        NULL,                // LPOVERLAPPED(OPTIONAL)
        NULL                 // pReserved4  (must be NULL)
    );
    if (NO_ERROR != ret)
    {
        m_callback->onLog(HSLOG_ERROR_LEVEL, logFormat("HttpSendHttpResponse failed: %lu", ret));
        return ret;
    }

    return ret;
}
