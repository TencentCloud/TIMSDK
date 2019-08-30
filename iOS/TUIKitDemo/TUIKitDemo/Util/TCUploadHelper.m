//
//  UploadImageHelper.m
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCUploadHelper.h"
#import "TCUtil.h"
#import <QCloudCore/QCloudCore.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudAuthentationHeadV5Creator.h"
#import "TCLoginModel.h"
#import "TCUserInfoModel.h"

#define kTCHeadUploadCosKey             @"head_icon"

@interface TCUploadHelper () <QCloudSignatureProvider>
{
    QCloudAuthentationHeadV5Creator* _creator;
}

@end

@implementation TCUploadHelper


static TCUploadHelper *_shareInstance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        _shareInstance = [[TCUploadHelper alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self setupCOSXMLShareService];
    }
    return self;
}

- (void) setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];

    TCUserInfoData *infoData = [[TCUserInfoModel sharedInstance] getUserProfile];
    configuration.appID =  infoData.appid;
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];

    endpoint.regionName = infoData.region;
    configuration.endpoint = endpoint;

    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:kTCHeadUploadCosKey];
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:kTCHeadUploadCosKey];
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{

    if (_creator != nil) {
        QCloudSignature* signature =  [_creator signatureForData:urlRequst];
        continueBlock(signature, nil);
    }
}

- (void)upload:(NSString*)userId image:(UIImage *)image completion:(void (^)(int errCode, NSString *imageSaveUrl))completion
{
    if (!image)
    {
        if (completion)
        {
            completion(-30001, nil);
        }
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *imageData = UIImageJPEGRepresentation(image, 0.3);

        // 以时间戳为文件名(毫秒为单位，跟Android保持一致)
        NSString *photoName = [[NSString alloc] initWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970] * 1000];
        NSString *pathSave = [TCUtil getFileCachePath:photoName];

        BOOL succ = [imageData writeToFile:pathSave atomically:YES];
        if (succ)
        {
            //获取sign

            [self getCOSSign:^(int errCode) {
                if (200 == errCode)
                {
                    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
                    upload.body = [NSURL fileURLWithPath:pathSave];
                    upload.bucket = [[TCUserInfoModel sharedInstance] getUserProfile].bucket;
                    upload.object = [NSUUID UUID].UUIDString;

                    [upload setFinishBlock:^(QCloudUploadObjectResult *result, NSError * error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                if (error) {
                                    completion((int)error.code, error.localizedDescription);
                                } else {
                                    NSString * resultString = [result qcloud_modelToJSONString];
                                    NSDictionary * data = [TCUtil jsonSring2Dictionary:resultString];
                                    if (data != nil) {
                                        completion(0, [data objectForKey:@"Location"]);
                                    } else {
                                        completion(-1, resultString);
                                    }

                                }
                            }
                        });
                    }];

                    [[QCloudCOSTransferMangerService costransfermangerServiceForKey:kTCHeadUploadCosKey] UploadObject:upload];
                }
                else
                {
                    if (completion)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(errCode, nil);
                        });
                    }
                }
            }];


        }
        else
        {
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(-30002, nil);
                });
            }

        }
    });

}

- (void)getCOSSign:(void (^)(int errCode))handler
{
    [[TCLoginModel sharedInstance] getCosSign:^(int errCode, NSString *msg, NSDictionary *resultDict) {
        if (errCode != 200)
        {
            DebugLog(@"getCOSSign failed");
            handler(errCode);
        }
        else
        {
            NSString* strSignKey = nil;
            NSString* strKeyTime = nil;
            if (resultDict && [resultDict objectForKey:@"signKey"])
            {
                strSignKey = resultDict[@"signKey"];
            }
            if (resultDict && [resultDict objectForKey:@"keyTime"])
            {
                strKeyTime = resultDict[@"keyTime"];
            }


            if (_creator == nil) {
                _creator = [[QCloudAuthentationHeadV5Creator alloc] initWithSignKey:[[TCUserInfoModel sharedInstance] getUserProfile].secretId  signKey:strSignKey keyTime:strKeyTime];
            } else {
                [_creator setSignKey:[[TCUserInfoModel sharedInstance] getUserProfile].secretId signKey:strSignKey keyTime:strKeyTime];
            }
            handler(errCode);
        }
    }];

//    NSDictionary* dictParam = @{@"Action" : @"GetCOSSignV2"};
//    [TCUtil asyncSendHttpRequest:dictParam handler:^(int result, NSDictionary *resultDict) {
//        if (result != 0)
//        {
//            DebugLog(@"getCOSSign failed");
//            handler(result);
//        }
//        else
//        {
//            NSString* strSignKey = nil;
//            NSString* strKeyTime = nil;
//            if (resultDict && [resultDict objectForKey:@"signKey"])
//            {
//                strSignKey = resultDict[@"signKey"];
//            }
//            if (resultDict && [resultDict objectForKey:@"keyTime"])
//            {
//                strKeyTime = resultDict[@"keyTime"];
//            }
//
//
//            if (_creator == nil) {
//                _creator = [[QCloudAuthentationHeadV5Creator alloc] initWithSignKey:kTCCOSSecretId signKey:strSignKey keyTime:strKeyTime];
//            } else {
//                [_creator setSignKey:kTCCOSSecretId signKey:strSignKey keyTime:strKeyTime];
//            }
//            handler(result);
//        }
//    }];
}

@end
