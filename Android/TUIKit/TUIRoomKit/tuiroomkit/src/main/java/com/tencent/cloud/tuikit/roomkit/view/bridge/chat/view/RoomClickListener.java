package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter.RoomPresenter;
import com.tencent.cloud.tuikit.roomkit.common.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;

import java.util.Map;

public class RoomClickListener extends TUIExtensionEventListener {
    @Override
    public void onClicked(Map<String, Object> param) {
        if (BusinessSceneUtil.canJoinRoom()) {
            RoomPresenter.getInstance().createRoom();
        } else {
            RoomToast.toastLongMessage(
                    TUILogin.getAppContext().getResources().getString(R.string.tuiroomkit_can_not_join_room_tip));
        }
    }
}
