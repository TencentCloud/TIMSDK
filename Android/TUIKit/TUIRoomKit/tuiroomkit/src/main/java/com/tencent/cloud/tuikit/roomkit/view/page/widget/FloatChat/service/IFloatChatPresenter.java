package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service;

import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.IFloatChatDisplayView;

public interface IFloatChatPresenter {

    void initDisplayView(IFloatChatDisplayView view);

    void destroyPresenter();

    void sendBarrage(TUIFloatChat barrage, IFloatChatMessage.BarrageSendCallBack callback);

    void receiveBarrage(TUIFloatChat barrage);

}
