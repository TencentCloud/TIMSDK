/*
* Module:   网络音频包UDT自定义数据回调
*
* Function: 给客户回调发送前、接收后的 UDT 自定义数据
*
*/
#ifndef LITEAV_ITRTCAUDIOPACKETLISTENER_H
#define LITEAV_ITRTCAUDIOPACKETLISTENER_H

#include <stdio.h>
#include "TXLiteAVBuffer.h"

namespace liteav {
    struct TRTCAudioPacket {
        const char *userId;
        liteav::TXLiteAVBuffer* extraData;
    };

    class ITRTCAudioPacketListener {
    public:
        virtual ~ITRTCAudioPacketListener() {}
        /*网络层接收到音频数据包*/
        virtual bool onRecvAudioPacket(TRTCAudioPacket &data) { return false; }
        /*网络层即将发送的音频数据包*/
        virtual bool onSendAudioPacket(TRTCAudioPacket &data) { return false; }
    };
}


#endif //LITEAV_ITRTCAUDIOPACKETLISTENER_H
