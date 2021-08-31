package com.tencent.qcloud.tim.uikit.modules.forward.message;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IBaseViewHolder;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageEmptyHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageForwardHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.ArrayList;
import java.util.List;

public abstract class ForwardMessageBaseHolder extends MessageContentHolder {


    public ForwardMessageBaseHolder(View itemView) {
        super(itemView);
        rootView = itemView;
    }


    @Override
    public void layoutViews(final MessageInfo msg, final int position) {
        super.layoutViews(msg, position);

        //// 头像设置
        if (msg.isSelf()) {
            leftUserIcon.setVisibility(View.GONE);
            rightUserIcon.setVisibility(View.VISIBLE);
        } else {
            leftUserIcon.setVisibility(View.VISIBLE);
            rightUserIcon.setVisibility(View.GONE);
        }
        if (properties.getAvatar() != 0) {
            leftUserIcon.setDefaultImageResId(properties.getAvatar());
            rightUserIcon.setDefaultImageResId(properties.getAvatar());
        } else {
            leftUserIcon.setDefaultImageResId(R.drawable.default_user_icon);
            rightUserIcon.setDefaultImageResId(R.drawable.default_user_icon);
        }
        if (properties.getAvatarRadius() != 0) {
            leftUserIcon.setRadius(properties.getAvatarRadius());
            rightUserIcon.setRadius(properties.getAvatarRadius());
        } else {
            leftUserIcon.setRadius(5);
            rightUserIcon.setRadius(5);
        }
        if (properties.getAvatarSize() != null && properties.getAvatarSize().length == 2) {
            ViewGroup.LayoutParams params = leftUserIcon.getLayoutParams();
            params.width = properties.getAvatarSize()[0];
            params.height = properties.getAvatarSize()[1];
            leftUserIcon.setLayoutParams(params);

            params = rightUserIcon.getLayoutParams();
            params.width = properties.getAvatarSize()[0];
            params.height = properties.getAvatarSize()[1];
            rightUserIcon.setLayoutParams(params);
        }
        leftUserIcon.invokeInformation(msg);
        rightUserIcon.invokeInformation(msg);

        //// 用户昵称设置
        if (msg.isSelf()) { // 默认不显示自己的昵称
            if (false) {
                usernameText.setVisibility(View.GONE);
            } else {
                usernameText.setVisibility(properties.getRightNameVisibility());
            }
        } else {
            if (false) {
                if (msg.isGroup()) { // 群聊默认显示对方的昵称
                    usernameText.setVisibility(View.VISIBLE);
                } else { // 单聊默认不显示对方昵称
                    usernameText.setVisibility(View.GONE);
                }
            } else {
                usernameText.setVisibility(View.VISIBLE);
                usernameText.setVisibility(properties.getLeftNameVisibility());
            }
        }
        if (properties.getNameFontColor() != 0) {
            usernameText.setTextColor(properties.getNameFontColor());
        }
        if (properties.getNameFontSize() != 0) {
            usernameText.setTextSize(properties.getNameFontSize());
        }
        // 聊天界面设置头像和昵称
        V2TIMMessage timMessage = msg.getTimMessage();
        if (!TextUtils.isEmpty(timMessage.getNameCard())) {
            usernameText.setText(timMessage.getNameCard());
        } else if (!TextUtils.isEmpty(timMessage.getFriendRemark())) {
            usernameText.setText(timMessage.getFriendRemark());
        } else if (!TextUtils.isEmpty(timMessage.getNickName())) {
            usernameText.setText(timMessage.getNickName());
        } else {
            usernameText.setText(timMessage.getSender());
        }

        if (!TextUtils.isEmpty(timMessage.getFaceUrl())) {
            List<Object> urllist = new ArrayList<>();
            urllist.add(timMessage.getFaceUrl());
            if (msg.isSelf()) {
                rightUserIcon.setIconUrls(urllist);
            } else {
                leftUserIcon.setIconUrls(urllist);
            }
        }

        if (msg.isSelf()) {
            if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL
                    || msg.getStatus() == MessageInfo.MSG_STATUS_SEND_SUCCESS
                    || msg.isPeerRead()) {
                sendingProgress.setVisibility(View.GONE);
            } else {
                sendingProgress.setVisibility(View.GONE);
            }
        } else {
            sendingProgress.setVisibility(View.GONE);
        }

        //// 聊天气泡设置
        msgContentFrame.setBackgroundResource(R.drawable.chat_left_live_group_bg);

        //// 左右边的消息需要调整一下内容的位置
        if (msg.isSelf()) {
            msgContentLinear.removeView(msgContentFrame);
            msgContentLinear.addView(msgContentFrame);
        } else {
            msgContentLinear.removeView(msgContentFrame);
            msgContentLinear.addView(msgContentFrame, 0);
        }
        msgContentLinear.setVisibility(View.VISIBLE);

        usernameText.setVisibility(View.VISIBLE);
        statusImage.setVisibility(View.GONE);
        sendingProgress.setVisibility(View.GONE);
        isReadText.setVisibility(View.GONE);
        unreadAudioText.setVisibility(View.GONE);

        //// 由子类设置指定消息类型的views
        layoutVariableViews(msg, position);
    }


    public static class ForwardFactory {

        public static RecyclerView.ViewHolder getInstance(ViewGroup parent, RecyclerView.Adapter adapter, int viewType) {

            LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
            RecyclerView.ViewHolder holder = null;
            View view = null;

            // 具体消息holder
            view = inflater.inflate(R.layout.forward_message_adapter_item_content, parent, false);
            switch (viewType) {
                case MessageInfo.MSG_TYPE_TEXT:
                    holder = new ForwardMessageTextHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_IMAGE:
                case MessageInfo.MSG_TYPE_VIDEO:
                case MessageInfo.MSG_TYPE_CUSTOM_FACE:
                    holder = new ForwardMessageImageHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_AUDIO:
                    holder = new ForwardMessageAudioHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_FILE:
                    holder = new ForwardMessageFileHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_MERGE:
                    holder = new MessageForwardHolder(view);
                    break;
                default:{
                    for(TUIChatControllerListener chatListener : TUIKitListenerManager.getInstance().getTUIChatListeners()) {
                        IBaseViewHolder viewHolder = chatListener.createCommonViewHolder(parent, viewType);
                        if (viewHolder instanceof RecyclerView.ViewHolder) {
                            holder = (RecyclerView.ViewHolder) viewHolder;
                            break;
                        }
                    }
                    break;
                }
            }
            if (holder instanceof MessageEmptyHolder) {
                ((MessageEmptyHolder) holder).setAdapter(adapter);
            }

            return holder;
        }
    }
}
