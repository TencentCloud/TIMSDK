//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMVoiceConverter : NSObject

+ (int)isMP3File:(NSString *)filePath;

+ (int)isAMRFile:(NSString *)filePath;

+ (int)amrToWav:(NSString *)amrPath wavSavePath:(NSString *)savePath;

+ (int)wavToAmr:(NSString *)wavPath amrSavePath:(NSString *)savePath;

@end
