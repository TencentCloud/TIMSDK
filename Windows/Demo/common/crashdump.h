/**************************************************************************
    Copyright:      Copyright ? 1998 - 2017 Tencent. All Rights Reserved
    Created:        2017-2-17 11:28:50
    Filename:       crashdump.h

    Description:
***************************************************************************/

#ifndef __CRASHDUMP_H__
#define __CRASHDUMP_H__

#include <Windows.h>
#include <Dbghelp.h>

/**************************************************************************/

class CrashDump
{
public:
    explicit CrashDump();
    ~CrashDump();
private:
    static LONG WINAPI UnhandledExceptionFilter(struct _EXCEPTION_POINTERS* pExceptionInfo);
private:
    LPTOP_LEVEL_EXCEPTION_FILTER        m_oldExceptionFilter;
};

/**************************************************************************/
#endif /* __CRASHDUMP_H__ */
