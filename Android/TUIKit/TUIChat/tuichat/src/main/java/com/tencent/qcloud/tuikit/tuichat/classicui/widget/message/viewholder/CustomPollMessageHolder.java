package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.View;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomPollMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.HashMap;
import java.util.Map;

public class CustomPollMessageHolder extends MessageContentHolder{
    public CustomPollMessageHolder(View itemView) {
        super(itemView);
    }

    public static final String TAG = CustomPollMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        Object resIDObject = TUICore.callService(TUIConstants.TUIPoll.SERVICE_NAME, TUIConstants.TUIPoll.METHOD_GET_POLL_MESSAGE_LAYOUT, null);
        int resID = 0;
        if (resIDObject != null) {
            resID = (Integer) resIDObject;
        }

        return resID;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (msg.isSelf()) {
            if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                msgArea.setBackground(properties.getRightBubble().getConstantState().newDrawable());
            } else {
                msgArea.setBackgroundResource(R.drawable.chat_bubble_self_transparent_bg);
            }
        } else {
            if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                msgArea.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
            } else {
                msgArea.setBackgroundResource(R.drawable.chat_bubble_other_transparent_bg);
            }
        }

        int paddingHorizontal = 0;
        int paddingVertical = 0;
        msgArea.setPadding(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);

        if (msg != null && msg instanceof CustomPollMessageBean) {
            CustomPollMessageBean customPollMessageBean = (CustomPollMessageBean) msg;
            CustomPollMessageBean.CustomPollMessage customPollMessage = customPollMessageBean.getCustomPollMessage();
            if (customPollMessage == null) {
                return;
            }

            Map<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIChat.V2TIMMESSAGE, msg.getV2TIMMessage());
            param.put(TUIConstants.TUIChat.PLUGIN_ITEM_VIEW, itemView);
            param.put(TUIConstants.TUIChat.PLUGIN_BEAN_OBJECT, ((CustomPollMessageBean) msg).getPollBeanObject());
            IUIKitCallback<Object> pluginCallback = new IUIKitCallback<Object>() {
                @Override
                public void onSuccess(Object pluginObject) {
                    if (pluginObject != null) {
                        ((CustomPollMessageBean) msg).setPollBeanObject(pluginObject);
                    }
                }
            };
            param.put(TUIConstants.TUIChat.CALL_BACK, pluginCallback);
            TUICore.notifyEvent(TUIConstants.TUIPoll.EVENT_KEY_POLL_MESSAGE_LAYOUT, TUIConstants.TUIPoll.EVENT_SUB_KEY_REFRESH_POLL_MESSAGE_LAYOUT, param);
        }
    }
}
