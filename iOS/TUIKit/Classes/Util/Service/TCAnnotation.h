#import <Foundation/Foundation.h>

#ifndef TCServiceSectName

#define TCServiceSectName "TCServices"

#endif

#define TCServiceDATA(sectname) __attribute((used, section("__DATA," #sectname " ")))

#define TCServiceRegister(servicename, impl) \
    class TCAnnotation;                  \
    char *k##servicename##_service TCServiceDATA(TCServices) = "[\"" #servicename "\",\"" #impl "\", 100 ]";

#define TCServiceRegisterHigh(servicename, impl) \
    class TCAnnotation;                  \
    char *k##servicename##_service TCServiceDATA(TCServices) = "[\"" #servicename "\",\"" #impl "\", 200 ]";

#define TCServiceRegisterLow(servicename, impl) \
    class TCAnnotation;                  \
    char *k##servicename##_service TCServiceDATA(TCServices) = "[\"" #servicename "\",\"" #impl "\", 10 ]";

@interface TCAnnotation : NSObject

@end
