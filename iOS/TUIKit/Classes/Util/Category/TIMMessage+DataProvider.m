//
//  TIMMessage+DataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TIMMessage+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIMessageDataProviderServiceProtocol.h"

@implementation TIMMessage (DataProvider)

-(id)cellDataFromElem:(TIMElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getCellData:self fromElem:elem];
}


- (NSString *)getDisplayString
{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getDisplayString:self];
}

- (TUITextMessageCellData *) textCellDataFromElem:(TIMTextElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getTextCellData:self fromElem:elem];
}

- (TUIFaceMessageCellData *) faceCellDataFromElem:(TIMFaceElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getFaceCellData:self fromElem:elem];
}

- (TUIImageMessageCellData *) imageCellDataFromElem:(TIMImageElem *) elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getImageCellData:self fromElem:elem];
}

- (TUIVoiceMessageCellData *) voiceCellDataFromElem:(TIMSoundElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getVoiceCellData:self fromElem:elem];
}

- (TUIVideoMessageCellData *) videoCellDataFromElem:(TIMVideoElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getVideoCellData:self fromElem:elem];
}

- (TUIFileMessageCellData *) fileCellDataFromElem:(TIMFileElem *)elem{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getFileCellData:self fromElem:elem];
}
- (TUISystemMessageCellData *) revokeCellData{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getRevokeCellData:self];
}

@end
