package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
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
import com.tencent.qcloud.tuikit.timcommon.component.UnreadCountTextView;
import com.tencent.qcloud.tuikit.timcommon.config.minimalistui.TUIConfigMinimalist;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class MessageContentHolder extends MessageBaseHolder {
    protected static final int READ_STATUS_UNREAD = 1;
    protected static final int READ_STATUS_PART_READ = 2;
    protected static final int READ_STATUS_ALL_READ = 3;
    protected static final int READ_STATUS_HIDE = 4;
    protected static final int READ_STATUS_SENDING = 5;

    public ImageView leftUserIcon;
    public ImageView rightUserIcon;
    public TextView usernameText;
    public LinearLayout msgContentLinear;
    public ImageView messageStatusImage;
    public ImageView fileStatusImage;
    public UnreadCountTextView unreadAudioText;
    public LinearLayout extraInfoArea;
    protected FrameLayout bottomContentFrameLayout;

    public boolean isForwardMode = false;
    public boolean isMessageDetailMode = false;
    public boolean isMultiSelectMode = false;
    public boolean isOptimize = true;
    public boolean isShowSelfAvatar = false;
    protected boolean isShowAvatar = true;

    protected TimeInLineTextLayout timeInLineTextLayout;
    protected MinimalistMessageLayout rootLayout;
    protected ReplyPreviewView replyPreviewView;

    private List<TUIMessageBean> mDataSource = new ArrayList<>();

    // Whether to display the bottom content. The merged-forwarded message details activity does not display the bottom content.
    protected boolean isNeedShowBottom = true;
    protected boolean isShowRead = false;
    private Fragment fragment;
    private RecyclerView recyclerView;

    public MessageContentHolder(View itemView) {
        super(itemView);
        rootLayout = (MinimalistMessageLayout) itemView;
        leftUserIcon = itemView.findViewById(R.id.left_user_icon_view);
        rightUserIcon = itemView.findViewById(R.id.right_user_icon_view);
        usernameText = itemView.findViewById(R.id.user_name_tv);
        msgContentLinear = itemView.findViewById(R.id.msg_content_ll);
        messageStatusImage = itemView.findViewById(R.id.message_status_iv);
        fileStatusImage = itemView.findViewById(R.id.file_status_iv);
        unreadAudioText = itemView.findViewById(R.id.unread_audio_text);
        replyPreviewView = itemView.findViewById(R.id.msg_reply_preview);
        extraInfoArea = itemView.findViewById(R.id.extra_info_area);
        bottomContentFrameLayout = itemView.findViewById(R.id.bottom_content_fl);
    }

    public void setFragment(Fragment fragment) {
        this.fragment = fragment;
    }

    public void setRecyclerView(RecyclerView recyclerView) {
        this.recyclerView = recyclerView;
    }

    public void setDataSource(List<TUIMessageBean> dataSource) {
        if (dataSource == null || dataSource.isEmpty()) {
            mDataSource = null;
        }

        List<TUIMessageBean> mediaSource = new ArrayList<>();
        for (TUIMessageBean messageBean : dataSource) {
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
        Context context = itemView.getContext();
        if (context instanceof Activity) {
            if (((Activity) context).isDestroyed()) {
                return;
            }
        }

        super.layoutViews(msg, position);
        setLayoutAlignment(msg);
        setIsShowAvatar(msg, position);
        setMessageGravity();
        setUserNameText(msg);
        setMessageBubbleBackground();
        setMessageStatusImage(msg);
        setMessageTimeVisibility();
        setAvatarVisibility();
        setEventListener(msg);

        msgContentLinear.setVisibility(View.VISIBLE);

        if (!isForwardMode && !isMessageDetailMode) {
            setTimeInLineStatus(msg);
            setShowReadStatusClickListener(msg);
        }
        if (timeInLineTextLayout != null && timeInLineTextLayout.getTextView() != null) {
            if (isMultiSelectMode) {
                timeInLineTextLayout.getTextView().setActivated(false);
            } else {
                timeInLineTextLayout.getTextView().setActivated(true);
            }
        }

        if (timeInLineTextLayout != null) {
            timeInLineTextLayout.setTimeText(DateTimeUtil.getHMTimeString(new Date(msg.getMessageTime() * 1000)));
        }

        extraInfoArea.setVisibility(View.GONE);
        setReplyContent(msg);
        setReactContent(msg);
        if (isNeedShowBottom) {
            setBottomContent(msg);
        }
        setMessageBubbleDefaultPadding();
        if (floatMode) {
            itemView.setPaddingRelative(0, 0, 0, 0);
            leftUserIcon.setVisibility(View.GONE);
            rightUserIcon.setVisibility(View.GONE);
            usernameText.setVisibility(View.GONE);
            replyPreviewView.setVisibility(View.GONE);
            reactionArea.setVisibility(View.GONE);
        }
        if (isMessageDetailMode) {
            replyPreviewView.setVisibility(View.GONE);
        }

        optimizePadding(position, msg);
        loadAvatar(msg);
        layoutVariableViews(msg, position);
    }

    private void setEventListener(TUIMessageBean msg) {
        if (!isForwardMode && !isMessageDetailMode) {
            if (onItemClickListener != null) {
                msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        onItemClickListener.onMessageLongClick(msgArea, msg);
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

            if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
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
    }

    private void setMessageTimeVisibility() {
        if (isForwardMode || floatMode) {
            chatTimeText.setVisibility(View.GONE);
        }
    }

    private void setLayoutAlignment(TUIMessageBean msg) {
        if (isForwardMode || isMessageDetailMode) {
            isLayoutOnStart = true;
        } else {
            if (msg.isSelf()) {
                isLayoutOnStart = false;
            } else {
                isLayoutOnStart = true;
            }
        }

        if (isForwardMode || isMessageDetailMode) {
            rootLayout.setIsStart(true);
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
        rootLayout.setIsStart(isLayoutOnStart);
    }

    private void setUserNameText(TUIMessageBean msg) {
        if (isForwardMode || isMessageDetailMode) {
            usernameText.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                usernameText.setVisibility(View.GONE);
            } else {
                if (msg.isGroup()) {
                    usernameText.setVisibility(View.GONE);
                } else {
                    usernameText.setVisibility(View.GONE);
                }
            }
        }

        usernameText.setText(msg.getUserDisplayName());
    }

    public void setIsShowAvatar(TUIMessageBean msg, int position) {
        isShowAvatar = true;
        if (mAdapter == null) {
            return;
        }
        if (isMessageDetailMode || !isOptimize) {
            return;
        }
        TUIMessageBean nextMessage = mAdapter.getItem(position + 1);
        if (nextMessage != null) {
            if (TextUtils.equals(msg.getSender(), nextMessage.getSender())) {
                boolean longPeriod = nextMessage.getMessageTime() - msg.getMessageTime() >= 5 * 60;
                if (!isShowAvatar(nextMessage) && nextMessage.getStatus() != TUIMessageBean.MSG_STATUS_REVOKE && !longPeriod) {
                    isShowAvatar = false;
                }
            }
        }
    }

    public void setMessageBubbleBackground() {
        if (!TUIConfigMinimalist.isEnableMessageBubbleStyle()) {
            setMessageBubbleBackground(null);
            return;
        }
        Drawable sendBubble = TUIConfigMinimalist.getSendBubbleBackground();
        Drawable receiveBubble = TUIConfigMinimalist.getReceiveBubbleBackground();
        Drawable sendLastBubble = TUIConfigMinimalist.getSendLastBubbleBackground();
        Drawable receiveLastBubble = TUIConfigMinimalist.getReceiveLastBubbleBackground();
        if (isShowAvatar) {
            if (isLayoutOnStart) {
                if (receiveLastBubble != null) {
                    setMessageBubbleBackground(receiveLastBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_stroke_border_left);
                }
            } else {
                if (sendLastBubble != null) {
                    setMessageBubbleBackground(sendLastBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_fill_border_right);
                }
            }
        } else {
            if (isLayoutOnStart) {
                if (receiveBubble != null) {
                    setMessageBubbleBackground(receiveBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_stroke_border);
                }
            } else {
                if (sendBubble != null) {
                    setMessageBubbleBackground(sendBubble);
                } else {
                    setMessageBubbleBackground(R.drawable.chat_message_popup_fill_border);
                }
            }
        }
    }

    public void setMessageStatusImage(TUIMessageBean msg) {
        if (isForwardMode || isMessageDetailMode || floatMode) {
            messageStatusImage.setVisibility(View.GONE);
        } else {
            if (msg.hasRiskContent()) {
                messageStatusImage.setVisibility(View.VISIBLE);
            } else if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                messageStatusImage.setVisibility(View.VISIBLE);
                messageStatusImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onSendFailBtnClick(messageStatusImage, msg);
                        }
                    }
                });
            } else {
                messageStatusImage.setVisibility(View.GONE);
            }
        }
    }

    public void setBottomContent(TUIMessageBean msg) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, msg);
        param.put(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW, recyclerView);
        param.put(TUIConstants.TUIChat.FRAGMENT, fragment);

        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessageBottom.MINIMALIST_EXTENSION_ID, bottomContentFrameLayout, param);
    }

    private void loadAvatar(TUIMessageBean msg) {
        Drawable drawable = TUIConfigMinimalist.getDefaultAvatarImage();
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
        int avatarSize = TUIConfigMinimalist.getMessageListAvatarSize();
        if (avatarSize == TUIConfigMinimalist.UNDEFINED) {
            avatarSize = ScreenUtil.dip2px(32);
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

        int radius = ScreenUtil.dip2px(100);
        if (TUIConfigMinimalist.getMessageListAvatarRadius() != TUIConfigMinimalist.UNDEFINED) {
            radius = TUIConfigMinimalist.getMessageListAvatarRadius();
        }
        ImageView renderedView;
        if (isLayoutOnStart) {
            renderedView = leftUserIcon;
        } else {
            renderedView = rightUserIcon;
        }

        RequestBuilder<Drawable> errorRequestBuilder = Glide.with(itemView.getContext())
                .load(TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon))
                .placeholder(TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon))
                .transform(new RoundedCorners(radius));

        Glide.with(itemView.getContext())
                .load(faceUrl)
                .transform(new RoundedCorners(radius))
                .error(errorRequestBuilder)
                .into(renderedView);
    }

    private void setAvatarVisibility() {
        if (isShowAvatar) {
            if (isLayoutOnStart) {
                leftUserIcon.setVisibility(View.VISIBLE);
                rightUserIcon.setVisibility(View.GONE);
            } else {
                leftUserIcon.setVisibility(View.GONE);
                if (isShowSelfAvatar) {
                    rightUserIcon.setVisibility(View.VISIBLE);
                } else {
                    rightUserIcon.setVisibility(View.GONE);
                }
            }
        } else {
            leftUserIcon.setVisibility(View.INVISIBLE);
            if (isShowSelfAvatar) {
                rightUserIcon.setVisibility(View.INVISIBLE);
            } else {
                rightUserIcon.setVisibility(View.GONE);
            }
        }
    }

    private void optimizePadding(int position, TUIMessageBean messageBean) {
        if (mAdapter == null) {
            return;
        }
        if (isMessageDetailMode || !isOptimize) {
            return;
        }

        TUIMessageBean nextMessage = mAdapter.getItem(position + 1);
        int horizontalPadding = ScreenUtil.dip2px(16);
        int verticalPadding = ScreenUtil.dip2px(25f);
        if (!isShowAvatar) {
            horizontalPadding = ScreenUtil.dip2px(16);
            verticalPadding = ScreenUtil.dip2px(2);
        }
        if (nextMessage != null) {
            rootLayout.setPaddingRelative(horizontalPadding, 0, horizontalPadding, verticalPadding);
        } else {
            rootLayout.setPaddingRelative(horizontalPadding, 0, horizontalPadding, ScreenUtil.dip2px(5));
        }
        optimizeMessageContent(isShowAvatar);
    }

    protected void optimizeMessageContent(boolean isShowAvatar) {}

    private void setMessageGravity() {
        if (isLayoutOnStart) {
            msgContentLinear.setGravity(Gravity.START | Gravity.BOTTOM);
            extraInfoArea.setGravity(Gravity.START);
        } else {
            msgContentLinear.setGravity(Gravity.END | Gravity.BOTTOM);
            extraInfoArea.setGravity(Gravity.END);
        }
    }

    private void setTimeInLineStatus(TUIMessageBean msg) {
        if (isShowRead) {
            if (msg.isSelf()) {
                if (TUIMessageBean.MSG_STATUS_SEND_SUCCESS == msg.getStatus()) {
                    if (!msg.isNeedReadReceipt()) {
                        setReadStatus(READ_STATUS_HIDE);
                    } else {
                        processReadStatus(msg);
                    }
                } else if (TUIMessageBean.MSG_STATUS_SENDING == msg.getStatus()) {
                    setReadStatus(READ_STATUS_SENDING);
                } else {
                    setReadStatus(READ_STATUS_HIDE);
                }
            } else {
                setReadStatus(READ_STATUS_HIDE);
            }
        }
    }

    protected void setOnTimeInLineTextClickListener(TUIMessageBean messageBean) {
        timeInLineTextLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(msgArea, messageBean);
                }
            }
        });
        timeInLineTextLayout.getTextView().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(msgArea, messageBean);
                }
            }
        });
        timeInLineTextLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageLongClick(msgArea, messageBean);
                }
                return true;
            }
        });
        timeInLineTextLayout.getTextView().setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageLongClick(msgArea, messageBean);
                }
                return true;
            }
        });
    }

    protected void setReadStatus(int readStatus) {
        if (timeInLineTextLayout != null) {
            int statusIconResID = 0;
            switch (readStatus) {
                case READ_STATUS_UNREAD: {
                    statusIconResID = R.drawable.chat_minimalist_message_status_send_no_read;
                    break;
                }
                case READ_STATUS_PART_READ: {
                    statusIconResID = R.drawable.chat_minimalist_message_status_send_part_read;
                    break;
                }
                case READ_STATUS_ALL_READ: {
                    statusIconResID = R.drawable.chat_minimalist_message_status_send_all_read;
                    break;
                }
                case READ_STATUS_SENDING: {
                    statusIconResID = R.drawable.chat_minimalist_status_loading_anim;
                    break;
                }
                default: {
                }
            }
            timeInLineTextLayout.setStatusIcon(statusIconResID);
        }
    }

    protected void setMessageBubbleDefaultPadding() {
        // after setting background, the padding will be reset
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(R.dimen.chat_minimalist_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(R.dimen.chat_minimalist_message_area_padding_top_bottom);
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
        msgContentFrame.setLayoutParams(layoutParams);
    }

    private void setReplyContent(TUIMessageBean messageBean) {
        MessageRepliesBean messageRepliesBean = messageBean.getMessageRepliesBean();
        if (messageRepliesBean != null && messageRepliesBean.getRepliesSize() > 0) {
            extraInfoArea.setVisibility(View.VISIBLE);
            replyPreviewView.setVisibility(View.VISIBLE);
            replyPreviewView.setMessageRepliesBean(messageRepliesBean);
            replyPreviewView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onReplyDetailClick(messageBean);
                    }
                }
            });
        } else {
            replyPreviewView.setVisibility(View.GONE);
        }
    }

    private void setReactContent(TUIMessageBean messageBean) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.MESSAGE, messageBean);
        param.put(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE,
            TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.VIEW_TYPE_MINIMALIST);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessageReactPreviewExtension.EXTENSION_ID, reactionArea, param);
    }

    private void processReadStatus(TUIMessageBean msg) {
        if (msg.isGroup()) {
            if (msg.isAllRead()) {
                setReadStatus(READ_STATUS_ALL_READ);
            } else if (msg.isUnread()) {
                setReadStatus(READ_STATUS_UNREAD);
            } else {
                long readCount = msg.getReadCount();
                if (readCount > 0) {
                    setReadStatus(READ_STATUS_PART_READ);
                }
            }
        } else {
            if (msg.isPeerRead()) {
                setReadStatus(READ_STATUS_ALL_READ);
            } else {
                setReadStatus(READ_STATUS_UNREAD);
            }
        }
    }

    private void setShowReadStatusClickListener(TUIMessageBean messageBean) {
        if (timeInLineTextLayout != null) {
            timeInLineTextLayout.setOnStatusAreaClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageReadStatusClick(v, messageBean);
                    }
                }
            });
            timeInLineTextLayout.setOnStatusAreaLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, messageBean);
                    }
                    return true;
                }
            });

            timeInLineTextLayout.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, messageBean);
                    }
                    return true;
                }
            });
        }
    }

    public abstract void layoutVariableViews(final TUIMessageBean msg, final int position);

    public void onRecycled() {
        super.onRecycled();
    }

    public void setNeedShowBottom(boolean needShowBottom) {
        isNeedShowBottom = needShowBottom;
    }

    public void setShowRead(boolean showRead) {
        isShowRead = showRead;
    }
}
