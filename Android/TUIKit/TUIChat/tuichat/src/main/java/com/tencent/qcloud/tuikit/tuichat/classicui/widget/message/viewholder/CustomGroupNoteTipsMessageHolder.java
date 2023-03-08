package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.View;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomGroupNoteTipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.HashMap;
import java.util.Map;

public class CustomGroupNoteTipsMessageHolder extends MessageBaseHolder{
    public CustomGroupNoteTipsMessageHolder(View itemView) {
        super(itemView);
    }

    public static final String TAG = CustomGroupNoteTipsMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        Object resIDObject = TUICore.callService(TUIConstants.TUIGroupNote.SERVICE_NAME, TUIConstants.TUIGroupNote.METHOD_GET_GROUP_NOTE_TIPS_MESSAGE_LAYOUT, null);
        int resID = 0;
        if (resIDObject != null) {
            resID = (Integer) resIDObject;
        }

        return resID;
    }

    @Override
    public void layoutViews(TUIMessageBean msg, int position) {
        super.layoutViews(msg, position);

        if (msg != null && msg instanceof CustomGroupNoteTipsMessageBean) {
            CustomGroupNoteTipsMessageBean customGroupNoteTipsMessageBean = (CustomGroupNoteTipsMessageBean) msg;
            CustomGroupNoteTipsMessageBean.CustomGroupNoteTipsMessage customGroupNoteTipsMessage = customGroupNoteTipsMessageBean.getCustomGroupNoteTipsMessage();
            if (customGroupNoteTipsMessage == null) {
                return;
            }

            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIChat.V2TIMMESSAGE, msg.getV2TIMMessage());
            param.put(TUIConstants.TUIChat.PLUGIN_ITEM_VIEW, itemView);
            param.put(TUIConstants.TUIChat.PLUGIN_BEAN_OBJECT, ((CustomGroupNoteTipsMessageBean) msg).getGroupNoteTipsBeanObject());
            IUIKitCallback<Object> pluginCallback = new IUIKitCallback<Object>() {
                @Override
                public void onSuccess(Object pluginObject) {
                    if (pluginObject != null) {
                        ((CustomGroupNoteTipsMessageBean) msg).setGroupNoteTipsBeanObject(pluginObject);
                    }
                }
            };
            param.put(TUIConstants.TUIChat.CALL_BACK, pluginCallback);
            TUICore.notifyEvent(TUIConstants.TUIGroupNote.EVENT_KEY_GROUP_NOTE_MESSAGE_LAYOUT, TUIConstants.TUIGroupNote.EVENT_SUB_KEY_REFRESH_GROUP_NOTE_TIPS_MESSAGE_LAYOUT, param);
        }
    }
}
