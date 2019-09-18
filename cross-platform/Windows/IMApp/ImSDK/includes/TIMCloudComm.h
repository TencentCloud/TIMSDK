#ifndef SDK_TIM_CLOUD_COMM_HEADER_
#define SDK_TIM_CLOUD_COMM_HEADER_

#include <sys/types.h>

#ifndef _MSC_VER
// stdint.h is part of C99 but MSVC doesn't have it.
#include <stdint.h>         // For intptr_t.
#endif

/* define int types*/
#if defined(__GNUC__)

#ifndef    _STDINT_H

/* FreeBSD has these C99 int types defined in /sys/inttypes.h already */
#ifndef _SYS_TYPES_H
typedef     signed char         int8_t;
typedef     signed short        int16_t;
typedef     signed int          int32_t;
typedef     signed long long    int64_t;
typedef     unsigned char       uint8_t;
typedef     unsigned short      uint16_t;
typedef     unsigned int        uint32_t;
typedef     unsigned long long  uint64_t;
#else
typedef     u_int8_t            uint8_t;
typedef     u_int16_t           uint16_t;
typedef     u_int32_t           uint32_t;
typedef     u_int64_t           uint64_t;
#endif  // _SYS_TYPES_H

#endif  // _STDINT_H

#elif defined(_MSC_VER)
typedef     signed char         int8_t;
typedef     signed short        int16_t;
typedef     signed int          int32_t;
typedef     signed __int64      int64_t;
typedef     unsigned char       uint8_t;
typedef     unsigned short      uint16_t;
typedef     unsigned int        uint32_t;
typedef     unsigned __int64    uint64_t;

/* the following definitions are from VS2010's stdint.h */
#ifndef _INTPTR_T_DEFINED
#define _INTPTR_T_DEFINED
#ifdef _WIN64
typedef __int64 intptr_t;
#else /* _WIN64 */
typedef  int intptr_t;
#endif /* _WIN64 */
#endif /* _INTPTR_T_DEFINED */

#ifndef _UINTPTR_T_DEFINED
#define _UINTPTR_T_DEFINED
#ifdef _WIN64
typedef unsigned __int64 uintptr_t;
#else /* _WIN64 */
typedef  unsigned int uintptr_t;
#endif /* _WIN64 */
#endif /* _UINTPTR_T_DEFINED */

#endif // COMPILER_GCC/COMPILER_MSVC


#ifndef __cplusplus

/* Even in pure C, we still need a standard boolean typedef */
#ifndef bool
typedef unsigned char bool;
#endif
#ifndef true
#define true (1)
#endif
#ifndef false
#define false (0)
#endif

#endif /* !__cplusplus */

#ifdef _WIN32
#if defined(TIM_EXPORTS) 
#define TIM_DECL __declspec(dllexport)
#else
#define TIM_DECL __declspec(dllimport)
#endif

#else 

#if defined(TIM_EXPORTS)
#define TIM_DECL __attribute__ ((visibility ("default")))
#else 
#define TIM_DECL __attribute__ ((visibility ("hidden")))
#endif

#endif


#endif //SDK_TIM_CLOUD_COMM_HEADER_
