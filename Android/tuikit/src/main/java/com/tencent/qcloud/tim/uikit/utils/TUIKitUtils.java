package com.tencent.qcloud.tim.uikit.utils;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.liteav.model.CallModel;

public class TUIKitUtils {

    public static boolean isComingCall(V2TIMMessage msg) {
        if (msg == null) {
            return false;
        }
        V2TIMCustomElem elem = msg.getCustomElem();
        if (elem == null) {
            return false;
        }
        byte[] bytes = elem.getData();
        if (bytes == null) {
            return false;
        }
        CallModel call = null;
        try {
            call = new Gson().fromJson(new String(bytes), CallModel.class);
        } catch (JsonSyntaxException e) {
            e.printStackTrace();
        }
        if (call == null) {
            return false;
        }
        if (call.version == TUIKitConstants.version
                && call.action == CallModel.VIDEO_CALL_ACTION_DIALING) {
            return true;
        }

        return false;
    }
}
