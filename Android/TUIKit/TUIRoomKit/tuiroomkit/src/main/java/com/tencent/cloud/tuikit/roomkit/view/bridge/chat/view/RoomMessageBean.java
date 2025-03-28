package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public class RoomMessageBean extends TUIMessageBean {
    public String mDisPlayStr;

    @Override
    public String onGetDisplayString() {
        return mDisPlayStr;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        mDisPlayStr = v2TIMMessage.getNickName() + TUILogin.getAppContext()
                .getString(R.string.tuiroomkit_room_msg_display_suffix);
    }
}
