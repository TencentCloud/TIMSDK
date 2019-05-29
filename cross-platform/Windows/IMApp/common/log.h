#pragma once
#include <string>
#include <vector>
#define USE_DBG

#ifdef USE_DBG
namespace logger {
typedef enum  {
    LOGGER_NORMAL,
    LOGGER_WARNING,
    LOGGER_ERROR,
    LOGGER_INFO,
    LOGGER_DEBUG,
    LOGGER_KEY_PROCEDURE,

    LOGGER_MAX_LEVEL,
}LogLevel;
void SetLogState(std::string prefix = "LOG", bool filename = false,  bool lineno = false, bool time = true,  bool funcname = true,  bool threadid = true, bool mutilline = true, LogLevel curlevel = LOGGER_MAX_LEVEL);

void DebugOutA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const std::string &out_str);
void DebugOutA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const char* out_str);
void DebugOutFA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const char* out_fmt, ...);

}
#define LOGEF(szFmt, ...)   logger::DebugOutFA(logger::LOGGER_ERROR,   __FILE__, __LINE__, __FUNCTION__, szFmt, ##__VA_ARGS__);
#define LOGWF(szFmt, ...)   logger::DebugOutFA(logger::LOGGER_WARNING, __FILE__, __LINE__, __FUNCTION__, szFmt, ##__VA_ARGS__);
#define LOGNF(szFmt, ...)   logger::DebugOutFA(logger::LOGGER_NORMAL,  __FILE__, __LINE__, __FUNCTION__, szFmt, ##__VA_ARGS__);
#define LOGF LOGNF

#define LOGE(szMsg)         logger::DebugOutA(logger::LOGGER_ERROR,    __FILE__, __LINE__, __FUNCTION__, szMsg);
#define LOGW(szMsg)         logger::DebugOutA(logger::LOGGER_WARNING,  __FILE__, __LINE__, __FUNCTION__, szMsg);
#define LOGN(szMsg)         logger::DebugOutA(logger::LOGGER_NORMAL,   __FILE__, __LINE__, __FUNCTION__, szMsg);
#define LOGSTATE(a)         (logger::SetLogState) a

#else
#define LOGEF(szFmt, ...)
#define LOGWF(szFmt, ...)
#define LOGNF(szFmt, ...)
#define LOGF LOGNF

#define LOGE(szMsg)
#define LOGW(szMsg)
#define LOGN(szMsg)  

#define LOGSTATE(a)
#endif