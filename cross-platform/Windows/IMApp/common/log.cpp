#include "log.h"
#include "IMUtil.h"
#include <windows.h>


#ifdef USE_DBG
namespace logger {

static FILE* file = NULL;
void onExitClean() {
    if (NULL != file) {
        ::fclose(file);
        file = NULL;
    }
}
static const char *sLogLevel[] = {
    "Info",
    "Warn",
    "Error",
    "Info",
    "Debug",
    "Key_Procedure",
    "Max",
};

#define STRING_FMT_MAX_LENGHT 0x2000
#define RAND_STRING_LEN 0x8
static LogLevel log_curlevel_ = LOGGER_MAX_LEVEL;
static bool log_filename_ = false;               //是否输出文件名
static bool log_lineno = true;                 //是否输出行号
static bool log_funcname_ = true;           //是否输出函数名
static bool log_mutilline_ = true;              //多行加过滤字
static bool log_time_ = true;                   //是否打印时间
static bool log_threadid_ = true;               //是否打印线程ID
static std::string log_prefix_ = "LIVE";

void SetLogState(std::string prefix/* = "LOG"*/,
               bool filename/* = false*/, 
               bool lineno/* = false*/,
               bool time/* = true*/, 
               bool funcname/* = true*/, 
               bool threadid/* = true*/,
               bool mutilline/* = true*/,
               LogLevel curlevel/* = LOGGER_MAX_LEVEL*/
               ) {
    log_prefix_ = prefix;
    log_filename_ = filename;
    log_lineno = lineno;
    log_time_ = time;
    log_funcname_ = funcname;
    log_threadid_ = threadid;
    log_mutilline_ = mutilline;
    log_curlevel_ = curlevel;
}

std::string GetNowTime(const char* split_time = ":") {
    SYSTEMTIME sys;
    GetLocalTime(&sys);
    return Fmt("%02d%s%02d%s%02d.%03d", sys.wHour, split_time, sys.wMinute, split_time, sys.wSecond, sys.wMilliseconds);
}

void DebugOutA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const char* out_str) {
    if (log_curlevel_ != LOGGER_MAX_LEVEL && level != log_curlevel_) {
        return;
    }
    std::string str_msg = "";
    if (NULL != out_str) {
        str_msg = out_str;
    }

    DebugOutA(level, file_name, line, func_name, str_msg);
}

void DebugOutFA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const char* out_fmt, ...) {
    if (log_curlevel_ != LOGGER_MAX_LEVEL && level != log_curlevel_) {
        return;
    }

    if (NULL == out_fmt) {
        DebugOutA(level, file_name, line, func_name, "NULL == out_fmt");
        return;
    }

    std::string strTmp = "";
    va_list ap;
    va_start(ap, out_fmt);
    FmtV(strTmp, out_fmt, ap);
    va_end(ap);

    DebugOutA(level, file_name, line, func_name, strTmp);
}
void GetStrLines(std::string out_str, std::vector<std::string>& stV);
void DebugOutA(LogLevel level, const char* file_name, uint32_t line, const char * func_name, const std::string &out_str) {
    if (log_curlevel_ != LOGGER_MAX_LEVEL && level != log_curlevel_) {
        return;
    }
    std::string str_msg;
    if (log_time_) {
        str_msg += Fmt("[%s] ", GetNowTime().c_str());
    }

    if (log_threadid_) {
        str_msg += Fmt("[%05d] ", GetCurrentThreadId());
    }

    if (log_filename_ && file_name) {
        str_msg += "[";
        str_msg += file_name;
        str_msg += "] ";
    }

    if (log_lineno && line) {
        str_msg += Fmt("[%04d] ", line);
    }
    str_msg = str_msg + sLogLevel[level];
    str_msg = str_msg + " ";
    if (log_funcname_ && func_name) {
        str_msg += "[";
        str_msg += func_name;
        str_msg += "] ";
    }

    if (NULL == file) {
        std::atexit(onExitClean);
        //file = _CreateFile();
    }

    if (NULL != file)
    {
        //::fputs(szLog, file);
        ::fflush(file);
    }

    if (false == log_mutilline_) {
        str_msg = "[" + log_prefix_ + "] " + str_msg + out_str + "\r\n";
        OutputDebugStringA(str_msg.c_str());
        return;
    }

    //多行输出
    std::vector<std::string> stV;
    GetStrLines(out_str, stV);
    for (std::string::size_type i = 0; i < stV.size(); i++) {
        str_msg = "[" + log_prefix_ + "] " + str_msg + stV[i] + "\r\n";
        OutputDebugStringA(str_msg.c_str());

    }
}

void GetStrLines(std::string out_str, std::vector<std::string>& stV) {
    //多行输出
    std::string stSub;
    for (std::string::size_type i = 0; i < out_str.length();) {
        if (out_str[i] == 0) {
            break;
        }
        if (('\r' == out_str[i]) && ('\n' == out_str[i + 1])) {
            stV.push_back(stSub);
            i = i + 2;
            stSub = "";
            continue;
        }
        if ('\n' == out_str[i]) {
            stV.push_back(stSub);
            i = i + 1;
            stSub = "";
            continue;
        }
        stSub.push_back(out_str[i]);
        i = i + 1;
    }
    if (stSub != "") {
        stV.push_back(stSub);
    }
}

}

#endif