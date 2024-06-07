package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service;

import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;

public interface IFloatChatMessage {

    void sendBarrage(TUIFloatChat barrage, BarrageSendCallBack callBack);

    void setDelegate(BarrageMessageDelegate delegate);

    interface BarrageMessageDelegate {
        void onReceivedBarrage(TUIFloatChat barrage);
    }

    interface BarrageSendCallBack {
        void onSuccess(TUIFloatChat barrage);

        void onFailed(int code, String msg);
    }
}
