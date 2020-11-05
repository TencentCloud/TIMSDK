#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>
#import "TCServiceManager.h"
#import "TCAnnotation.h"

NSArray<NSString *>* TCReadConfiguration(char *sectionName,const struct mach_header *mhp);
static void tc_dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    //register services
    NSArray<NSString *> *services = TCReadConfiguration(TCServiceSectName,mhp);
    for (NSString *map in services) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSArray class]] && [json count]) {

                NSString *protocol = json[0];
                NSString *clsName  = json[1];
                int priority = [json[2] intValue];

                if (protocol && clsName) {
                    [[TCServiceManager shareInstance] registerService:NSProtocolFromString(protocol) implClass:NSClassFromString(clsName) withPriority:priority];
                }

            }
        }
    }

}
__attribute__((constructor))
void tc_initProphet() {
    _dyld_register_func_for_add_image(tc_dyld_callback);
}

NSArray<NSString *>* TCReadConfiguration(char *sectionName,const struct mach_header *mhp)
{
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size/sizeof(void*);
    for(int idx = 0; idx < counter; ++idx){
        char *string = (char*)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;

        NSLog(@"config = %@", str);
        if(str) [configs addObject:str];
    }

    return configs;


}

@implementation TCAnnotation

@end
