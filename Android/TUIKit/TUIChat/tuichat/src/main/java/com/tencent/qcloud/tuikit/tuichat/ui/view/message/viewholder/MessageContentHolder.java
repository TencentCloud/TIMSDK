package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.component.gatherimage.UserIconView;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;

import java.util.ArrayList;
import java.util.List;

public abstract class MessageContentHolder extends MessageBaseHolder {

    public UserIconView leftUserIcon;
    public UserIconView rightUserIcon;
    public TextView usernameText;
    public LinearLayout msgContentLinear;
    public ProgressBar sendingProgress;
    public ImageView statusImage;
    public TextView isReadText;
    public TextView unreadAudioText;

    public boolean isForwardMode = false;
    public boolean isMultiSelectMode = false;

    private List<TUIMessageBean> mDataSource = new ArrayList<>();

    protected ChatPresenter presenter;

    public MessageContentHolder(View itemView) {
        super(itemView);

        leftUserIcon = itemView.findViewById(R.id.left_user_icon_view);
        rightUserIcon = itemView.findViewById(R.id.right_user_icon_view);
        usernameText = itemView.findViewById(R.id.user_name_tv);
        msgContentLinear = itemView.findViewById(R.id.msg_content_ll);
        statusImage = itemView.findViewById(R.id.message_status_iv);
        sendingProgress = itemView.findViewById(R.id.message_sending_pb);
        isReadText = itemView.findViewById(R.id.is_read_tv);
        unreadAudioText = itemView.findViewById(R.id.audio_unread);
    }

    public void setPresenter(ChatPresenter chatPresenter) {
        this.presenter = chatPresenter;
    }

    public void setDataSource(List<TUIMessageBean> dataSource) {
        if (dataSource == null || dataSource.isEmpty()) {
            mDataSource = null;
        }

        List<TUIMessageBean> mediaSource = new ArrayList<>();
        for(TUIMessageBean messageBean : dataSource) {
            int type = messageBean.getMsgType();
            if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE || type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                mediaSource.add(messageBean);
            }
        }
        mDataSource = mediaSource;
    }

    public List<TUIMessageBean> getDataSource() {
        return mDataSource;
    }

    @Override
    public void layoutViews(final TUIMessageBean msg, final int position) {
        super.layoutViews(msg, position);

        if (isForwardMode) {
            leftUserIcon.setVisibility(View.VISIBLE);
            rightUserIcon.setVisibility(View.GONE);
        } else {
            //// 头像设置
            if (msg.isSelf()) {
                leftUserIcon.setVisibility(View.GONE);
                rightUserIcon.setVisibility(View.VISIBLE);
            } else {
                leftUserIcon.setVisibility(View.VISIBLE);
                rightUserIcon.setVisibility(View.GONE);
            }
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
            int radius = ScreenUtil.dip2px(4);
            leftUserIcon.setRadius(radius);
            rightUserIcon.setRadius(radius);
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

        // 转发模式下显示用户名
        if (isForwardMode) {
            usernameText.setVisibility(View.VISIBLE);
        } else {
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
        }
        if (properties.getNameFontColor() != 0) {
            usernameText.setTextColor(properties.getNameFontColor());
        }
        if (properties.getNameFontSize() != 0) {
            usernameText.setTextSize(properties.getNameFontSize());
        }
        // 聊天界面设置头像和昵称
        if (!TextUtils.isEmpty(msg.getNameCard())) {
            usernameText.setText(msg.getNameCard());
        } else if (!TextUtils.isEmpty(msg.getFriendRemark())) {
            usernameText.setText(msg.getFriendRemark());
        } else if (!TextUtils.isEmpty(msg.getNickName())) {
            usernameText.setText(msg.getNickName());
        } else {
            usernameText.setText(msg.getSender());
        }

        if (!TextUtils.isEmpty(msg.getFaceUrl())) {
            List<Object> urllist = new ArrayList<>();
            urllist.add(msg.getFaceUrl());
            if (isForwardMode) {
                leftUserIcon.setIconUrls(urllist);
            } else {
                if (msg.isSelf()) {
                    rightUserIcon.setIconUrls(urllist);
                } else {
                    leftUserIcon.setIconUrls(urllist);
                }
            }
        } else {
            rightUserIcon.setIconUrls(null);
            leftUserIcon.setIconUrls(null);
        }

        if (isForwardMode) {
            sendingProgress.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL
                        || msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS
                        || msg.isPeerRead()) {
                    sendingProgress.setVisibility(View.GONE);
                } else {
                    sendingProgress.setVisibility(View.VISIBLE);
                }
            } else {
                sendingProgress.setVisibility(View.GONE);
            }
        }

        if (isForwardMode) {
            msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_other_bg);
            statusImage.setVisibility(View.GONE);
        } else {
            //// 聊天气泡设置
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgContentFrame.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_self_bg);
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgContentFrame.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                    msgContentFrame.setLayoutParams(msgContentFrame.getLayoutParams());
                } else {
                    msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_other_bg);
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
                leftUserIcon.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        onItemClickListener.onUserIconLongClick(view, position, msg);
                        return true;
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
            if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                statusImage.setVisibility(View.VISIBLE);
                msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onMessageLongClick(msgContentFrame, position, msg);
                        }
                    }
                });
                statusImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onSendFailBtnClick(statusImage, position, msg);
                        }
                    }
                });
            } else {
                msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onMessageClick(msgContentFrame, position, msg);
                        }
                    }
                });
                statusImage.setVisibility(View.GONE);
            }
        }

        int padding = msgContentFrame.getResources().getDimensionPixelSize(R.dimen.chat_item_padding_bottom);
        msgContentFrame.setPadding(padding, padding, padding, padding);

        if (isForwardMode) {
            msgContentLinear.removeView(msgContentFrame);
            msgContentLinear.addView(msgContentFrame);
        } else {
            // 左右边的消息需要调整一下内容的位置，使已读标签位置显示正确
            if (msg.isSelf()) {
                msgContentLinear.removeView(msgContentFrame);
                msgContentLinear.addView(msgContentFrame);
            } else {
                msgContentLinear.removeView(msgContentFrame);
                msgContentLinear.addView(msgContentFrame, 0);
            }
        }

        if (rightGroupLayout != null) {
            rightGroupLayout.setVisibility(View.VISIBLE);
        }
        msgContentLinear.setVisibility(View.VISIBLE);

        if (isForwardMode) {
            isReadText.setVisibility(View.GONE);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            //// 对方已读标识的设置
            if (TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead()) {
                if (msg.isSelf() && TUIMessageBean.MSG_STATUS_SEND_SUCCESS == msg.getStatus()) {
                    if (msg.isGroup()) {
                        isReadText.setVisibility(View.GONE);
                    } else {
                        isReadText.setVisibility(View.VISIBLE);
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

        }
        //// 由子类设置指定消息类型的views
        layoutVariableViews(msg, position);
    }

    public abstract void layoutVariableViews(final TUIMessageBean msg, final int position);
}
