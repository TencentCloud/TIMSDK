package com.tencent.qcloud.tim.demo.helper;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IBaseAction;
import com.tencent.qcloud.tim.uikit.base.IBaseInfo;
import com.tencent.qcloud.tim.uikit.base.IBaseViewHolder;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.TUIConversationControllerListener;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageCustomHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;

import java.util.List;

public class HelloChatController implements TUIChatControllerListener {
    private static final String TAG = HelloChatController.class.getSimpleName();

    @Override
    public List<IBaseAction> onRegisterMoreActions() {
        return null;
    }

    @Override
    public IBaseInfo createCommonInfoFromTimMessage(V2TIMMessage timMessage) {
        if (timMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            V2TIMCustomElem customElem = timMessage.getCustomElem();
            if (customElem == null || customElem.getData() == null) {
                return null;
            }
            CustomHelloMessage helloMessage = null;
            try {
                helloMessage = new Gson().fromJson(new String(customElem.getData()), CustomHelloMessage.class);
            } catch (Exception e) {
                DemoLog.w(TAG, "invalid json: " + new String(customElem.getData()) + " " + e.getMessage());
            }
            if (helloMessage != null && TextUtils.equals(helloMessage.businessID, TUIKitConstants.BUSINESS_ID_CUSTOM_HELLO)) {
                MessageInfo messageInfo = new HelloMessageInfo();
                messageInfo.setMsgType(HelloMessageInfo.MSG_TYPE_HELLO);
                MessageInfoUtil.setMessageInfoCommonAttributes(messageInfo, timMessage);
                Context context = TUIKit.getAppContext();
                if (context != null) {
                    messageInfo.setExtra(context.getString(R.string.custom_msg));
                }
                return messageInfo;
            }
        }
        return null;
    }

    @Override
    public IBaseViewHolder createCommonViewHolder(ViewGroup parent, int viewType) {
        if (viewType != HelloMessageInfo.MSG_TYPE_HELLO) {
            return null;
        }
        if (parent == null) {
            return null;
        }
        LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
        View contentView = inflater.inflate(R.layout.message_adapter_item_content, parent, false);
        return new HelloViewHolder(contentView);
    }

    @Override
    public boolean bindCommonViewHolder(IBaseViewHolder baseViewHolder, IBaseInfo baseInfo, int position) {
        if (baseViewHolder instanceof ICustomMessageViewGroup && baseInfo instanceof HelloMessageInfo) {
            ICustomMessageViewGroup customHolder = (ICustomMessageViewGroup) baseViewHolder;
            MessageInfo msg = (MessageInfo) baseInfo;
            new CustomMessageDraw().onDraw(customHolder, msg, position);
            return true;
        }
        return false;
    }

    static class HelloMessageInfo extends MessageInfo {
        public static final int MSG_TYPE_HELLO = 100002;
    }

    static class HelloViewHolder extends MessageCustomHolder{

        public HelloViewHolder(View itemView) {
            super(itemView);
        }
    }

    public static class HelloConversationController implements TUIConversationControllerListener {

        @Override
        public CharSequence getConversationDisplayString(IBaseInfo baseInfo) {
            if (baseInfo instanceof HelloChatController.HelloMessageInfo) {
                return DemoApplication.instance().getString(R.string.welcome_tip);
            }
            return null;
        }
    }

    public static class CustomMessageDraw implements IOnCustomMessageDrawListener {

        /**
         * 自定义消息渲染时，会调用该方法，本方法实现了自定义消息的创建，以及交互逻辑
         *
         * @param parent 自定义消息显示的父View，需要把创建的自定义消息view添加到parent里
         * @param info   消息的具体信息
         */
        @Override
        public void onDraw(ICustomMessageViewGroup parent, MessageInfo info, int position) {
            // 获取到自定义消息的json数据
            if (info.getTimMessage().getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
                return;
            }
            V2TIMCustomElem elem = info.getTimMessage().getCustomElem();
            // 自定义的json数据，需要解析成bean实例
            CustomHelloMessage data = null;
            try {
                data = new Gson().fromJson(new String(elem.getData()), CustomHelloMessage.class);
            } catch (Exception e) {
                DemoLog.w(TAG, "invalid json: " + new String(elem.getData()) + " " + e.getMessage());
            }
            if (data == null) {
                DemoLog.e(TAG, "No Custom Data: " + new String(elem.getData()));
            } else if (data.version == TUIKitConstants.JSON_VERSION_1
                    || (data.version == TUIKitConstants.JSON_VERSION_4 && data.businessID.equals(TUIKitConstants.BUSINESS_ID_CUSTOM_HELLO))) {
                if (parent instanceof MessageBaseHolder) {
                    CustomHelloTIMUIController.onDraw(parent, data, position, ((MessageBaseHolder) parent).getOnItemClickListener(), info);
                }
            } else {
                DemoLog.w(TAG, "unsupported version: " + data);
            }
        }
    }

}

