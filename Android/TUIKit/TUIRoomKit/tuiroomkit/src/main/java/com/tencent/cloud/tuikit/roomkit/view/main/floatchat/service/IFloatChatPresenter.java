package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service;


import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.IFloatChatDisplayView;

public interface IFloatChatPresenter {

    void initDisplayView(IFloatChatDisplayView view);

    void destroyPresenter();

    void sendBarrage(TUIFloatChat barrage, IFloatChatMessage.BarrageSendCallBack callback);

    void receiveBarrage(TUIFloatChat barrage);

}
