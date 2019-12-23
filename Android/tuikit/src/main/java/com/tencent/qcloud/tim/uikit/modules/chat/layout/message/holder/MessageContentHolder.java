package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.gatherimage.UserIconView;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.ArrayList;
import java.util.List;

public abstract class MessageContentHolder extends MessageEmptyHolder {

    public UserIconView leftUserIcon;
    public UserIconView rightUserIcon;
    public TextView usernameText;
    public LinearLayout msgContentLinear;
    public ProgressBar sendingProgress;
    public ImageView statusImage;
    public TextView isReadText;
    public TextView unreadAudioText;

    public MessageContentHolder(View itemView) {
        super(itemView);
        rootView = itemView;

        leftUserIcon = itemView.findViewById(R.id.left_user_icon_view);
        rightUserIcon = itemView.findViewById(R.id.right_user_icon_view);
        usernameText = itemView.findViewById(R.id.user_name_tv);
        msgContentLinear = itemView.findViewById(R.id.msg_content_ll);
        statusImage = itemView.findViewById(R.id.message_status_iv);
        sendingProgress = itemView.findViewById(R.id.message_sending_pb);
        isReadText = itemView.findViewById(R.id.is_read_tv);
        unreadAudioText = itemView.findViewById(R.id.audio_unread);
    }

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
            leftUserIcon.setDefaultImageResId(R.drawable.default_head);
            rightUserIcon.setDefaultImageResId(R.drawable.default_head);
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
            if (properties.getRightNameVisibility() == 0) {
                usernameText.setVisibility(View.GONE);
            } else {
                usernameText.setVisibility(properties.getRightNameVisibility());
            }
        } else {
            if (properties.getLeftNameVisibility() == 0) {
                if (msg.isGroup()) { // 群聊默认显示对方的昵称
                    usernameText.setVisibility(View.VISIBLE);
                } else { // 单聊默认不显示对方昵称
                    usernameText.setVisibility(View.GONE);
                }
            } else {
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
        TIMUserProfile profile = TIMFriendshipManager.getInstance().queryUserProfile(msg.getFromUser());
        if (profile == null) {
            usernameText.setText(msg.getFromUser());
        } else {
            if (TextUtils.isEmpty(msg.getGroupNameCard())) {
                usernameText.setText(!TextUtils.isEmpty(profile.getNickName()) ? profile.getNickName() : msg.getFromUser());
            } else {
                usernameText.setText(msg.getGroupNameCard());
            }
            if (!TextUtils.isEmpty(profile.getFaceUrl()) && !msg.isSelf()) {
                List<Object> urllist = new ArrayList<>();
                urllist.add(profile.getFaceUrl());
                leftUserIcon.setIconUrls(urllist);
                urllist.clear();
            }
        }
        TIMUserProfile selfInfo = TIMFriendshipManager.getInstance().queryUserProfile(TIMManager.getInstance().getLoginUser());
        if (selfInfo != null && msg.isSelf()) {
            if (!TextUtils.isEmpty(selfInfo.getFaceUrl())) {
                List<Object> urllist = new ArrayList<>();
                urllist.add(selfInfo.getFaceUrl());
                rightUserIcon.setIconUrls(urllist);
                urllist.clear();
            }
        }

        if (msg.isSelf()) {
            if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL
                    || msg.getStatus() == MessageInfo.MSG_STATUS_SEND_SUCCESS
                    || msg.isPeerRead()) {
                sendingProgress.setVisibility(View.GONE);
            } else {
                sendingProgress.setVisibility(View.VISIBLE);
            }
        } else {
            sendingProgress.setVisibility(View.GONE);
        }

        //// 聊天气泡设置
        if (msg.isSelf()) {
            if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                msgContentFrame.setBackground(properties.getRightBubble().getConstantState().newDrawable());
            } else {
                msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_myself);
            }
        } else {
            if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                msgContentFrame.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                msgContentFrame.setLayoutParams(msgContentFrame.getLayoutParams());
            } else {
                msgContentFrame.setBackgroundResource(R.drawable.chat_other_bg);
            }
        }

        //// 聊天气泡的点击事件处理
        if (onItemClickListener != null) {
            msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    onItemClickListener.onMessageLongClick(v, position, msg);
                    return true;
                }
            });
            leftUserIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onItemClickListener.onUserIconClick(view, position, msg);
                }
            });
            rightUserIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onItemClickListener.onUserIconClick(view, position, msg);
                }
            });
        }

        //// 发送状态的设置
        if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL) {
            statusImage.setVisibility(View.VISIBLE);
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgContentFrame, position, msg);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(null);
            statusImage.setVisibility(View.GONE);
        }

        //// 左右边的消息需要调整一下内容的位置
        if (msg.isSelf()) {
            msgContentLinear.removeView(msgContentFrame);
            msgContentLinear.addView(msgContentFrame);
        } else {
            msgContentLinear.removeView(msgContentFrame);
            msgContentLinear.addView(msgContentFrame, 0);
        }
        msgContentLinear.setVisibility(View.VISIBLE);

        //// 对方已读标识的设置
        if (TUIKitConfigs.getConfigs().getGeneralConfig().isShowRead()) {
            if (msg.isSelf()) {
                if (msg.isGroup()) {
                    isReadText.setVisibility(View.GONE);
                } else {
                    isReadText.setVisibility(View.VISIBLE);
                    LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) isReadText.getLayoutParams();
                    params.gravity = Gravity.CENTER_VERTICAL;
                    isReadText.setLayoutParams(params);
                    if (msg.isPeerRead()) {
                        isReadText.setText(R.string.has_read);
                    } else {
                        isReadText.setText(R.string.unread);
                    }
                }
            } else {
                isReadText.setVisibility(View.GONE);
            }
        }

        //// 音频已读
        unreadAudioText.setVisibility(View.GONE);

        //// 由子类设置指定消息类型的views
        layoutVariableViews(msg, position);
    }

    public abstract void layoutVariableViews(final MessageInfo msg, final int position);
}
