package com.tencent.qcloud.tuikit.timcommon.classicui.widget.message;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.config.classicui.TUIConfigClassic;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public abstract class MessageContentHolder<T extends TUIMessageBean> extends MessageBaseHolder<T> {

    public ImageView leftUserIcon;
    public ImageView rightUserIcon;
    public TextView leftUserNameText;
    public LinearLayout msgContentLinear;
    public View riskContentLine;
    public TextView riskContentText;
    public ProgressBar sendingProgress;
    public ImageView statusImage;
    public TextView isReadText;
    public TextView unreadAudioText;
    public TextView messageDetailsTimeTv;
    private FrameLayout bottomContentFrameLayout;
    private View bottomFailedIv;

    public boolean isForwardMode = false;
    public boolean isReplyDetailMode = false;
    public boolean isMultiSelectMode = false;

    private List<TUIMessageBean> mForwardDataSource = new ArrayList<>();
    protected SelectionHelper selectionHelper;

    // Whether to display the bottom content. The merged-forwarded message details activity does not display the bottom content.
    protected boolean isNeedShowBottomLayout = true;
    protected boolean isShowRead = false;
    private Fragment fragment;
    private RecyclerView recyclerView;
    protected boolean hasRiskContent = false;
    protected boolean isLayoutOnStart = true;

    public MessageContentHolder(View itemView) {
        super(itemView);
        leftUserIcon = itemView.findViewById(R.id.left_user_icon_view);
        rightUserIcon = itemView.findViewById(R.id.right_user_icon_view);
        leftUserNameText = itemView.findViewById(R.id.left_user_name_tv);
        msgContentLinear = itemView.findViewById(R.id.msg_content_ll);
        riskContentLine = itemView.findViewById(R.id.risk_content_line);
        riskContentText = itemView.findViewById(R.id.risk_content_text);
        statusImage = itemView.findViewById(R.id.message_status_iv);
        sendingProgress = itemView.findViewById(R.id.message_sending_pb);
        sendingProgress.getIndeterminateDrawable().mutate();
        isReadText = itemView.findViewById(R.id.is_read_tv);
        unreadAudioText = itemView.findViewById(R.id.audio_unread);
        messageDetailsTimeTv = itemView.findViewById(R.id.msg_detail_time_tv);
        bottomContentFrameLayout = itemView.findViewById(R.id.bottom_content_fl);
        bottomFailedIv = itemView.findViewById(R.id.bottom_failed_iv);
    }

    public void setFragment(Fragment fragment) {
        this.fragment = fragment;
    }

    public void setRecyclerView(RecyclerView recyclerView) {
        this.recyclerView = recyclerView;
    }

    public RecyclerView getRecyclerView() {
        return this.recyclerView;
    }

    public void setForwardDataSource(List<TUIMessageBean> dataSource) {
        if (dataSource == null || dataSource.isEmpty()) {
            mForwardDataSource = null;
        }

        List<TUIMessageBean> mediaSource = new ArrayList<>();
        for (TUIMessageBean messageBean : dataSource) {
            int type = messageBean.getMsgType();
            if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE || type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                mediaSource.add(messageBean);
            }
        }
        mForwardDataSource = mediaSource;
    }

    public List<TUIMessageBean> getForwardDataSource() {
        return mForwardDataSource;
    }

    @Override
    public void layoutViews(final T msg, final int position) {
        Context context = itemView.getContext();
        if (context instanceof Activity) {
            if (((Activity) context).isDestroyed()) {
                return;
            }
        }

        hasRiskContent = msg.hasRiskContent();
        super.layoutViews(msg, position);
        setLayoutAlignment(msg);
        setUserIcon(msg);
        setUserName(msg);
        loadAvatar(msg);
        setSendingProgress(msg);
        setStatusImage(msg);
        setMessageBubbleBackground();
        setOnClickListener(msg, position);

        if (rightGroupLayout != null) {
            rightGroupLayout.setVisibility(View.VISIBLE);
        }
        msgContentLinear.setVisibility(View.VISIBLE);

        setReadStatus(msg);

        if (isReplyDetailMode) {
            chatTimeText.setVisibility(View.GONE);
        }

        setReplyContent(msg);
        setReactContent(msg);
        if (isNeedShowBottomLayout) {
            setBottomContent(msg);
        }
        bottomFailedIv.setVisibility(View.GONE);
        if (hasRiskContent) {
            bottomContentFrameLayout.setBackgroundResource(R.drawable.chat_message_bottom_area_risk_bg);
            if (bottomContentFrameLayout.getVisibility() == View.VISIBLE) {
                bottomFailedIv.setVisibility(View.VISIBLE);
            }
            riskContentLine.setVisibility(View.VISIBLE);
        } else {
            riskContentLine.setVisibility(View.GONE);
            bottomContentFrameLayout.setBackgroundResource(R.drawable.chat_message_bottom_area_bg);
        }

        setMessageBubbleDefaultPadding();
        layoutVariableViews(msg, position);
    }

    private void setReadStatus(T msg) {
        // clear isReadText status
        isReadText.setTextColor(isReadText.getResources().getColor(R.color.text_gray1));
        isReadText.setOnClickListener(null);

        if (isForwardMode || isReplyDetailMode) {
            isReadText.setVisibility(View.GONE);
            unreadAudioText.setVisibility(View.GONE);
        } else {
            if (isShowRead) {
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
    }

    private void setLayoutAlignment(TUIMessageBean msg) {
        if (isForwardMode || isReplyDetailMode) {
            isLayoutOnStart = true;
        } else {
            if (msg.isSelf()) {
                isLayoutOnStart = false;
            } else {
                isLayoutOnStart = true;
            }
        }
        if (isForwardMode || isReplyDetailMode) {
            msgContentLinear.removeView(msgAreaAndReply);
            msgContentLinear.addView(msgAreaAndReply);
        } else {
            if (msg.isSelf()) {
                msgContentLinear.removeView(msgAreaAndReply);
                msgContentLinear.addView(msgAreaAndReply);
            } else {
                msgContentLinear.removeView(msgAreaAndReply);
                msgContentLinear.addView(msgAreaAndReply, 0);
            }
        }
        setGravity(isLayoutOnStart);
    }

    private void setMessageBubbleBackground() {
        if (!TUIConfigClassic.isEnableMessageBubbleStyle()) {
            setMessageBubbleBackground(null);
            return;
        }

        Drawable sendBubble = TUIConfigClassic.getSendBubbleBackground();
        Drawable receiveBubble = TUIConfigClassic.getReceiveBubbleBackground();
        Drawable sendErrorBubble = TUIConfigClassic.getSendErrorBubbleBackground();
        Drawable receiveErrorBubble = TUIConfigClassic.getReceiveErrorBubbleBackground();

        if (hasRiskContent) {
            if (!isLayoutOnStart) {
                if (sendErrorBubble != null) {
                    setMessageBubbleBackground(sendErrorBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_risk_content_border_right);
                }
            } else {
                if (receiveErrorBubble != null) {
                    setMessageBubbleBackground(receiveErrorBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_risk_content_border_left);
                }
            }
        } else {
            setRiskContent(null);
            if (isLayoutOnStart) {
                if (receiveBubble != null) {
                    setMessageBubbleBackground(receiveBubble);
                } else {
                    setMessageBubbleBackground(TUIThemeManager.getAttrResId(itemView.getContext(), R.attr.chat_bubble_other_bg));
                }
            } else {
                if (sendBubble != null) {
                    setMessageBubbleBackground(sendBubble);
                } else {
                    setMessageBubbleBackground(TUIThemeManager.getAttrResId(itemView.getContext(), R.attr.chat_bubble_self_bg));
                }
            }
        }
    }

    protected void setStatusImage(T msg) {
        statusImage.setVisibility(View.GONE);
        if (hasRiskContent) {
            statusImage.setVisibility(View.VISIBLE);
        } else {
            if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                statusImage.setVisibility(View.VISIBLE);
                statusImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onSendFailBtnClick(statusImage, msg);
                        }
                    }
                });
            }
        }
    }

    protected void setRiskContent(String riskContent) {
        if (TextUtils.isEmpty(riskContent)) {
            riskContentLine.setVisibility(View.GONE);
            riskContentText.setVisibility(View.GONE);
        } else {
            riskContentLine.setVisibility(View.VISIBLE);
            riskContentText.setVisibility(View.VISIBLE);
            riskContentText.setText(riskContent);
        }
    }

    private void setOnClickListener(T msg, int position) {
        if (onItemClickListener != null) {
            msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    onItemClickListener.onMessageLongClick(v, msg);
                    return true;
                }
            });

            msgArea.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    onItemClickListener.onMessageLongClick(msgArea, msg);
                    return true;
                }
            });

            leftUserIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onItemClickListener.onUserIconClick(view, msg);
                }
            });
            leftUserIcon.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    onItemClickListener.onUserIconLongClick(view, msg);
                    return true;
                }
            });
            rightUserIcon.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onItemClickListener.onUserIconClick(view, msg);
                }
            });
        }

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgContentFrame, msg);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(msgContentFrame, msg);
                    }
                }
            });
        }
    }

    private void setSendingProgress(T msg) {
        if (isForwardMode || isReplyDetailMode) {
            hideSendingProgress();
        } else {
            if (msg.isSelf()) {
                if (msg.isSending()) {
                    showSendingProgress();
                } else {
                    hideSendingProgress();
                }
            } else {
                hideSendingProgress();
            }
        }
    }

    protected void showSendingProgress() {
        sendingProgress.setVisibility(View.VISIBLE);
        Drawable drawable = sendingProgress.getIndeterminateDrawable();
        if (drawable instanceof Animatable) {
            ((Animatable) drawable).start();
        }
    }

    protected void hideSendingProgress() {
        sendingProgress.setVisibility(View.GONE);
    }

    @SuppressLint("WrongConstant")
    private void setUserName(T msg) {
        if (isForwardMode || isReplyDetailMode) {
            leftUserNameText.setVisibility(View.VISIBLE);
        } else {
            if (isLayoutOnStart) {
                if (TUIConfigClassic.getReceiveNickNameVisibility() != TUIConfigClassic.UNDEFINED) {
                    leftUserNameText.setVisibility(TUIConfigClassic.getReceiveNickNameVisibility());
                } else {
                    if (msg.isGroup()) {
                        leftUserNameText.setVisibility(View.VISIBLE);
                    } else {
                        leftUserNameText.setVisibility(View.GONE);
                    }
                }
            } else {
                leftUserNameText.setVisibility(View.GONE);
            }
        }
        if (TUIConfigClassic.getReceiveNickNameColor() != TUIConfigClassic.UNDEFINED) {
            leftUserNameText.setTextColor(TUIConfigClassic.getReceiveNickNameColor());
        }

        if (TUIConfigClassic.getReceiveNickNameFontSize() != TUIConfigClassic.UNDEFINED) {
            leftUserNameText.setTextSize(TUIConfigClassic.getReceiveNickNameFontSize());
        }

        leftUserNameText.setText(msg.getUserDisplayName());
    }

    private void setUserIcon(T msg) {
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
    }

    private void setBottomContent(TUIMessageBean msg) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, msg);
        param.put(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW, recyclerView);
        param.put(TUIConstants.TUIChat.FRAGMENT, fragment);

        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID, bottomContentFrameLayout, param);
    }

    private void loadAvatar(TUIMessageBean msg) {
        Drawable drawable = TUIConfigClassic.getDefaultAvatarImage();
        if (drawable != null) {
            setupAvatar(drawable);
            return;
        }

        if (msg.isUseMsgReceiverAvatar() && mAdapter != null) {
            String cachedFaceUrl = mAdapter.getUserFaceUrlCache().getCachedFaceUrl(msg.getSender());
            if (cachedFaceUrl == null) {
                List<String> idList = new ArrayList<>();
                idList.add(msg.getSender());
                V2TIMManager.getInstance().getUsersInfo(idList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                    @Override
                    public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                        if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.isEmpty()) {
                            return;
                        }
                        V2TIMUserFullInfo userInfo = v2TIMUserFullInfos.get(0);
                        String faceUrl = userInfo.getFaceUrl();
                        if (TextUtils.isEmpty(userInfo.getFaceUrl())) {
                            faceUrl = "";
                        }
                        mAdapter.getUserFaceUrlCache().pushFaceUrl(userInfo.getUserID(), faceUrl);
                        mAdapter.onItemRefresh(msg);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        setupAvatar("");
                    }
                });
            } else {
                setupAvatar(cachedFaceUrl);
            }
        } else {
            setupAvatar(msg.getFaceUrl());
        }
    }

    private void setupAvatar(Object faceUrl) {
        int avatarSize = TUIConfigClassic.getMessageListAvatarSize();
        if (avatarSize == TUIConfigClassic.UNDEFINED) {
            avatarSize = ScreenUtil.dip2px(41);
        }
        ViewGroup.LayoutParams params = leftUserIcon.getLayoutParams();
        params.width = avatarSize;
        if (leftUserIcon.getVisibility() == View.INVISIBLE) {
            params.height = 1;
        } else {
            params.height = avatarSize;
        }
        leftUserIcon.setLayoutParams(params);

        params = rightUserIcon.getLayoutParams();
        params.width = avatarSize;
        if (rightUserIcon.getVisibility() == View.INVISIBLE) {
            params.height = 1;
        } else {
            params.height = avatarSize;
        }
        rightUserIcon.setLayoutParams(params);

        int radius = ScreenUtil.dip2px(4);
        if (TUIConfigClassic.getMessageListAvatarRadius() != TUIConfigClassic.UNDEFINED) {
            radius = TUIConfigClassic.getMessageListAvatarRadius();
        }

        ImageView renderedView;
        if (isLayoutOnStart) {
            renderedView = leftUserIcon;
        } else {
            renderedView = rightUserIcon;
        }

        RequestBuilder<Drawable> errorRequestBuilder =
            Glide.with(itemView.getContext())
                .load(TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon))
                .placeholder(TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon))
                .transform(new RoundedCorners(radius));

        Glide.with(itemView.getContext()).load(faceUrl).transform(new RoundedCorners(radius)).error(errorRequestBuilder).into(renderedView);
    }

    protected void setMessageBubbleDefaultPadding() {
        // after setting background, the padding will be reset
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_top_bottom);
        msgArea.setPaddingRelative(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);
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
        msgArea.setGravity(gravity);
        msgContentFrame.setLayoutParams(layoutParams);
    }

    private void setReplyContent(TUIMessageBean messageBean) {
        MessageRepliesBean messageRepliesBean = messageBean.getMessageRepliesBean();
        if (messageRepliesBean != null && messageRepliesBean.getRepliesSize() > 0) {
            TextView replyNumText = msgReplyDetailLayout.findViewById(R.id.reply_num);
            replyNumText.setText(String.format(Locale.US, replyNumText.getResources().getString(R.string.chat_reply_num), messageRepliesBean.getRepliesSize()));
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
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.MESSAGE, messageBean);
        param.put(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE,
            TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE_CLASSIC);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.EXTENSION_ID, reactionArea, param);
    }

    private void showReadText(TUIMessageBean msg) {
        if (hasRiskContent) {
            isReadText.setVisibility(View.GONE);
            return;
        }
        if (msg.isGroup()) {
            isReadText.setVisibility(View.VISIBLE);
            if (msg.isAllRead()) {
                isReadText.setText(R.string.has_all_read);
            } else if (msg.isUnread()) {
                isReadText.setTextColor(
                    isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                isReadText.setText(R.string.unread);
                isReadText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onReadStatusClick(v, msg);
                    }
                });
            } else {
                long readCount = msg.getReadCount();
                if (readCount > 0) {
                    isReadText.setText(String.format(Locale.US, isReadText.getResources().getString(R.string.someone_has_read), readCount));
                    isReadText.setTextColor(
                        isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                    isReadText.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            onReadStatusClick(v, msg);
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
                isReadText.setTextColor(
                    isReadText.getResources().getColor(TUIThemeManager.getAttrResId(isReadText.getContext(), R.attr.chat_read_receipt_text_color)));
                isReadText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onReadStatusClick(v, msg);
                    }
                });
            }
        }
    }

    public abstract void layoutVariableViews(final T msg, final int position);

    public void onRecycled() {
        super.onRecycled();
        if (selectionHelper != null) {
            selectionHelper.destroy();
        }
    }

    public void onReadStatusClick(View view, TUIMessageBean messageBean) {
        if (onItemClickListener != null) {
            onItemClickListener.onMessageReadStatusClick(view, messageBean);
        }
    }

    protected void setSelectionHelper(TUIMessageBean msg, TextView textView, int position) {
        if (selectionHelper == null) {
            selectionHelper = new SelectionHelper();
        }
        selectionHelper.setTextView(textView);
        if (isMultiSelectMode || isForwardMode) {
            selectionHelper.setFrozen(true);
        } else {
            selectionHelper.setFrozen(false);
        }
        selectionHelper.setSelectListener(new SelectionHelper.OnSelectListener() {
            @Override
            public void onTextSelected(CharSequence content) {
                String selectedText = "";
                if (!TextUtils.isEmpty(content)) {
                    selectedText = content.toString();
                    msg.setSelectText(selectedText);
                    SelectionHelper.setSelected(selectionHelper);
                    if (onItemClickListener != null) {
                        onItemClickListener.onTextSelected(msgArea, position, msg);
                    }
                }
            }

            @Override
            public void onDismiss() {
                msg.setSelectText(msg.getExtra());
            }

            @Override
            public void onClickUrl(String url) {}

            @Override
            public void onShowPop() {}

            @Override
            public void onDismissPop() {}

        });
    }

    public void setNeedShowBottomLayout(boolean needShowBottomLayout) {
        isNeedShowBottomLayout = needShowBottomLayout;
    }

    public void setShowRead(boolean showRead) {
        isShowRead = showRead;
    }
}
