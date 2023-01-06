package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.gatherimage.UserIconView;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.SelectTextHelper;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.ChatFlowReactView;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.Date;
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
    public TextView messageDetailsTimeTv;
    private FrameLayout translationContentFrameLayout;
    private ImageView translationLoadingImage;
    private LinearLayout translationResultLayout;
    private RotateAnimation translationRotateAnimation;

    public boolean isForwardMode = false;
    public boolean isReplyDetailMode = false;
    public boolean isMultiSelectMode = false;

    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    protected SelectTextHelper selectableTextHelper;

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
        messageDetailsTimeTv = itemView.findViewById(R.id.msg_detail_time_tv);
        translationContentFrameLayout = itemView.findViewById(R.id.translate_content_fl);
        LayoutInflater.from(itemView.getContext()).inflate(R.layout.translation_contant_layout, translationContentFrameLayout);
        translationLoadingImage = translationContentFrameLayout.findViewById(R.id.translate_loading_iv);
        translationResultLayout = translationContentFrameLayout.findViewById(R.id.translate_result_ll);
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

    public void resetSelectableText() {
        if (selectableTextHelper != null) {
            selectableTextHelper.reset();
        }
    }

    @Override
    public void layoutViews(final TUIMessageBean msg, final int position) {
        super.layoutViews(msg, position);

        if (isForwardMode || isReplyDetailMode) {
            leftUserIcon.setVisibility(View.VISIBLE);
            rightUserIcon.setVisibility(View.GONE);
        } else {
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
            leftUserIcon.setDefaultImageResId(TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_user_icon));
            rightUserIcon.setDefaultImageResId(TUIThemeManager.getAttrResId(rightUserIcon.getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_user_icon));
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

        if (isForwardMode || isReplyDetailMode) {
            usernameText.setVisibility(View.VISIBLE);
        } else {
            if (msg.isSelf()) {
                if (properties.getRightNameVisibility() == 0) {
                    usernameText.setVisibility(View.GONE);
                } else {
                    usernameText.setVisibility(properties.getRightNameVisibility());
                }
            } else {
                if (properties.getLeftNameVisibility() == 0) {
                    if (msg.isGroup()) {
                        usernameText.setVisibility(View.VISIBLE);
                    } else {
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
            if (isForwardMode || isReplyDetailMode) {
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

        if (isForwardMode || isReplyDetailMode) {
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

        if (isForwardMode || isReplyDetailMode) {
            msgArea.setBackgroundResource(TUIThemeManager.getAttrResId(itemView.getContext(), R.attr.chat_bubble_other_bg));
            statusImage.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(TUIThemeManager.getAttrResId(itemView.getContext(), R.attr.chat_bubble_self_bg));
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(TUIThemeManager.getAttrResId(itemView.getContext(), R.attr.chat_bubble_other_bg));
                }
            }

            if (onItemClickListener != null) {
                msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        onItemClickListener.onMessageLongClick(v, position, msg);
                        return true;
                    }
                });

                msgArea.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        onItemClickListener.onMessageLongClick(msgArea, position, msg);
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

        if (isForwardMode || isReplyDetailMode) {
            setGravity(true);
            msgContentLinear.removeView(msgAreaAndReply);
            msgContentLinear.addView(msgAreaAndReply);
        } else {
            if (msg.isSelf()) {
                setGravity(false);
                msgContentLinear.removeView(msgAreaAndReply);
                msgContentLinear.addView(msgAreaAndReply);
            } else {
                setGravity(true);
                msgContentLinear.removeView(msgAreaAndReply);
                msgContentLinear.addView(msgAreaAndReply, 0);
            }
        }

        if (rightGroupLayout != null) {
            rightGroupLayout.setVisibility(View.VISIBLE);
        }
        msgContentLinear.setVisibility(View.VISIBLE);

        // clear isReadText status
        isReadText.setTextColor(isReadText.getResources().getColor(R.color.text_gray1));
        isReadText.setOnClickListener(null);

        if (isForwardMode || isReplyDetailMode) {
            isReadText.setVisibility(View.GONE);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            if (TUIChatConfigs.getConfigs().getGeneralConfig().isShowRead()) {
                if (msg.isSelf() && TUIMessageBean.MSG_STATUS_SEND_SUCCESS == msg.getStatus()) {
                    if (!msg.isNeedReadReceipt()) {
                        isReadText.setVisibility(View.GONE);
                    } else {
                        showReadText(msg);
                    }
                } else {
                    isReadText.setVisibility(View.GONE);
                }
            }
            unreadAudioText.setVisibility(View.GONE);
        }

        if (isReplyDetailMode) {
            chatTimeText.setVisibility(View.GONE);
        }

        setReplyContent(msg);
        setReactContent(msg);
        if (presenter.isNeedShowTranslation()) {
            setTranslationContent(msg, position);
        }
        setMessageAreaPadding();

        layoutVariableViews(msg, position);
    }

    protected void setMessageAreaPadding() {
        // after setting background, the padding will be reset
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_top_bottom);;
        msgArea.setPadding(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);
    }

    protected void setGravity(boolean isStart) {
        int gravity = isStart ? Gravity.START : Gravity.END;
        msgAreaAndReply.setGravity(gravity);
        ViewGroup.LayoutParams layoutParams = msgContentFrame.getLayoutParams();
        if (layoutParams instanceof FrameLayout.LayoutParams) {
            ((FrameLayout.LayoutParams) layoutParams).gravity = gravity;
        } else if (layoutParams instanceof LinearLayout.LayoutParams) {
            ((LinearLayout.LayoutParams) layoutParams).gravity = gravity;
        }
        msgContentFrame.setLayoutParams(layoutParams);
    }

    private void setReplyContent(TUIMessageBean messageBean) {
        MessageRepliesBean messageRepliesBean = messageBean.getMessageRepliesBean();
        if (messageRepliesBean != null && messageRepliesBean.getRepliesSize() > 0) {
            TextView replyNumText = msgReplyDetailLayout.findViewById(R.id.reply_num);
            replyNumText.setText(replyNumText.getResources().getString(R.string.chat_reply_num, messageRepliesBean.getRepliesSize()));
            msgReplyDetailLayout.setVisibility(View.VISIBLE);
            msgReplyDetailLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onReplyDetailClick(messageBean);
                    }
                }
            });
        } else {
            msgReplyDetailLayout.setVisibility(View.GONE);
            msgReplyDetailLayout.setOnClickListener(null);
        }
        if (!isReplyDetailMode) {
            messageDetailsTimeTv.setVisibility(View.GONE);
        } else {
            messageDetailsTimeTv.setText(DateTimeUtil.getTimeFormatText(new Date(messageBean.getMessageTime() * 1000)));
            messageDetailsTimeTv.setVisibility(View.VISIBLE);
            msgReplyDetailLayout.setVisibility(View.GONE);
        }
    }

    private void setReactContent(TUIMessageBean messageBean) {
        MessageReactBean messageReactBean = messageBean.getMessageReactBean();
        if (messageReactBean != null && messageReactBean.getReactSize() > 0) {
            reactView.setVisibility(View.VISIBLE);
            reactView.setData(messageReactBean);
            reactView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(v, 0, messageBean);
                    }
                    return true;
                }
            });
            if (!isForwardMode) {
                reactView.setReactOnClickListener(new ChatFlowReactView.ReactOnClickListener() {
                    @Override
                    public void onClick(String emojiId) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onReactOnClick(emojiId, messageBean);
                        }
                    }
                });
            } else {
                reactView.setOnLongClickListener(null);
            }
        } else {
            reactView.setVisibility(View.GONE);
            reactView.setOnLongClickListener(null);
        }
        if (!messageBean.isSelf() || isForwardMode || isReplyDetailMode) {
            reactView.setThemeColorId(TUIThemeManager.getAttrResId(reactView.getContext(), R.attr.chat_react_other_text_color));
        } else {
            reactView.setThemeColorId(0);
        }
    }

    private void showReadText(TUIMessageBean msg) {
        if (msg.isGroup()) {
            isReadText.setVisibility(View.VISIBLE);
            if (msg.isAllRead()) {
                isReadText.setText(R.string.has_all_read);
            } else if (msg.isUnread()) {
                isReadText.setTextColor(isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                isReadText.setText(R.string.unread);
                isReadText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startShowUnread(msg);
                    }
                });
            } else {
                long readCount = msg.getReadCount();
                if (readCount > 0) {
                    isReadText.setText(isReadText.getResources().getString(R.string.someone_has_read, readCount));
                    isReadText.setTextColor(isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                    isReadText.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            startShowUnread(msg);
                        }
                    });
                }
            }
        } else {
            isReadText.setVisibility(View.VISIBLE);
            if (msg.isPeerRead()) {
                isReadText.setText(R.string.has_read);
            } else {
                isReadText.setText(R.string.unread);
                isReadText.setTextColor(isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                isReadText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        startShowUnread(msg);
                    }
                });
            }
        }
    }

    public abstract void layoutVariableViews(final TUIMessageBean msg, final int position);

    public void onRecycled() {
        if (selectableTextHelper != null) {
            selectableTextHelper.destroy();
        }
    }

    public void startShowUnread(TUIMessageBean messageBean) {
        Bundle bundle = new Bundle();
        bundle.putSerializable(TUIChatConstants.MESSAGE_BEAN, messageBean);
        bundle.putSerializable(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
        TUICore.startActivity("MessageReceiptDetailActivity", bundle);
    }

    protected void setSelectableTextHelper(TUIMessageBean msg, TextView textView, int position, boolean isEmoji) {
        if (selectableTextHelper != null) {
            selectableTextHelper.destroy();
        }
        selectableTextHelper = new SelectTextHelper
                .Builder(textView)
                .setCursorHandleColor(TUIChatService.getAppContext().getResources().getColor(R.color.font_blue))
                .setCursorHandleSizeInDp(18)
                .setSelectedColor(TUIChatService.getAppContext().getResources().getColor(R.color.test_blue))
                .setSelectAll(true)
                .setIsEmoji(isEmoji)
                .setScrollShow(false)
                .setSelectedAllNoPop(true)
                .setMagnifierShow(false)
                .build();

        selectableTextHelper.setSelectListener(new SelectTextHelper.OnSelectListener() {
            @Override
            public void onClick(View v) {
            }

            @Override
            public void onLongClick(View v) {
            }

            @Override
            public void onTextSelected(CharSequence content) {
                String selectedText = content.toString();
                msg.setSelectText(selectedText);
                TUIChatLog.d("TextMessageHolder", "onTextSelected selectedText = " + selectedText);
                if (onItemClickListener != null) {
                    onItemClickListener.onTextSelected(msgArea, position, msg);
                }
            }

            @Override
            public void onDismiss() {
                msg.setSelectText(msg.getExtra());
            }

            @Override
            public void onClickUrl(String url) {
            }

            @Override
            public void onSelectAllShowCustomPop() {
            }

            @Override
            public void onReset() {
                msg.setSelectText(null);
                msg.setSelectText(msg.getExtra());
            }

            @Override
            public void onDismissCustomPop() {
            }

            @Override
            public void onScrolling() {
            }
        });
    }

    protected void setTranslationContent(TUIMessageBean msg, int position) {
        int translationStatus = msg.getTranslationStatus();
        if (translationStatus == TUIMessageBean.MSG_TRANSLATE_STATUS_SHOWN) {
            translationContentFrameLayout.setVisibility(View.VISIBLE);
            stopTranslationLoading();
            translationResultLayout.setVisibility(View.VISIBLE);
            TextView translationText = translationContentFrameLayout.findViewById(R.id.translate_tv);
            if (properties.getChatContextFontSize() != 0) {
                translationText.setTextSize(properties.getChatContextFontSize());
            }
            FaceManager.handlerEmojiText(translationText, msg.getTranslation(), false);
            translationContentFrameLayout.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onTranslationLongClick(view, position, msg);
                    }
                    return true;
                }
            });
        } else if (translationStatus == TUIMessageBean.MSG_TRANSLATE_STATUS_LOADING) {
            translationContentFrameLayout.setVisibility(View.VISIBLE);
            startTranslationLoading();
            translationResultLayout.setVisibility(View.GONE);
            translationContentFrameLayout.setOnLongClickListener(null);
        } else {
            stopTranslationLoading();
            translationContentFrameLayout.setVisibility(View.GONE);
            translationContentFrameLayout.setOnLongClickListener(null);
        }
    }

    private void startTranslationLoading() {
        translationLoadingImage.setVisibility(View.VISIBLE);
        translationRotateAnimation = new RotateAnimation(0, 360, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f);
        translationRotateAnimation.setRepeatCount(-1);
        translationRotateAnimation.setDuration(1000);
        translationRotateAnimation.setInterpolator(new LinearInterpolator());
        translationLoadingImage.startAnimation(translationRotateAnimation);
    }

    private void stopTranslationLoading() {
        translationLoadingImage.clearAnimation();
        translationLoadingImage.setVisibility(View.GONE);
    }

}
