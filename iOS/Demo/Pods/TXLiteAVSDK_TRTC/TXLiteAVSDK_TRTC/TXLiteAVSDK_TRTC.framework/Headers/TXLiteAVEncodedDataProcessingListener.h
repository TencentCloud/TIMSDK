/*
* Module:   live 编码数据回调
*
* Function: 回调推流端编码完，和 播放端解码前的数据
*
*/


#ifndef TXLiteAVEncodedDataProcessingListener_h
#define TXLiteAVEncodedDataProcessingListener_h

#include <stdio.h>
#include "TXLiteAVBuffer.h"

namespace liteav {

struct TXLiteAVEncodedData {
    const char * userId; // didEncodeVideo 和 didEncodeAudio 回调时，此字段为null；
    int streamType; // 视频流类型，参考 TRTCVideoStreamType，audio时，此字段为0
    const liteav::TXLiteAVBuffer * originData; // 原始数据
    liteav::TXLiteAVBuffer * processedData; // 写回处理后的数据
};

class ITXLiteAVEncodedDataProcessingListener {
public:
    virtual ~ITXLiteAVEncodedDataProcessingListener() {}
    
    /**
     * 回调编码完的视频数据。
     *  @note videoData.userId = nullptr
     */
    virtual bool didEncodeVideo(TXLiteAVEncodedData & videoData) { return false; }
    
    /**
    * 回调解码前的视频数据。
    *  @note videoData.userId 表示对应的user，当userId 为 nullptr时，表示此时先接收到数据了，对应的userId还未完成同步。获取到userId之后会回调正确的userId
    */
    virtual bool willDecodeVideo(TXLiteAVEncodedData & videoData) { return false; }

    /**
     * 回调编码完的音频数据。
     *  @note audioData.userId = nullptr
     */
    virtual bool didEncodeAudio(TXLiteAVEncodedData & audioData) { return false; }
    
    /**
    * 回调解码前的音频数据。
    *  @note audioData.userId 表示对应的user，当userId 为 nullptr时，表示此时先接收到数据了，对应的userId还未完成同步。获取到userId之后会回调正确的userId
    */
    virtual bool willDecodeAudio(TXLiteAVEncodedData & audioData) { return false; }
};
}

#endif /* TXLiteAVEncodedDataProcessingListener_h */
