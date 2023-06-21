package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.RotateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.UnreadCountTextView;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.UserIconView;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public abstract class MessageContentHolder extends MessageBaseHolder {
    protected static final int READ_STATUS_UNREAD = 1;
    protected static final int READ_STATUS_PART_READ = 2;
    protected static final int READ_STATUS_ALL_READ = 3;
    protected static final int READ_STATUS_HIDE = 4;
    protected static final int READ_STATUS_SENDING = 5;

    public UserIconView leftUserIcon;
    public UserIconView rightUserIcon;
    public TextView usernameText;
    public LinearLayout msgContentLinear;
    public ImageView messageStatusImage;
    public ImageView fileStatusImage;
    public UnreadCountTextView unreadAudioText;
    public LinearLayout extraInfoArea;
    protected FrameLayout translationContentFrameLayout;
    private ImageView translationLoadingImage;
    protected LinearLayout translationResultLayout;
    private RotateAnimation translationRotateAnimation;

    public boolean isForwardMode = false;
    public boolean isMessageDetailMode = false;
    public boolean isMultiSelectMode = false;
    public boolean isOptimize = true;
    public boolean isShowSelfAvatar = false;

    protected TimeInLineTextLayout timeInLineTextLayout;
    protected MinimalistMessageLayout rootLayout;
    protected ReplyPreviewView replyPreviewView;

    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    // 是否显示翻译的内容。合并转发的消息详情界面不用展示翻译内容。
    // Whether to display the translated content. The merged-forwarded message details activity does not display the translated content.
    protected boolean isNeedShowTranslation = true;
    protected boolean isShowRead = false;
    private BaseFragment fragment;
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
        translationContentFrameLayout = itemView.findViewById(R.id.translate_content_fl);
    }

    public void setFragment(BaseFragment fragment) {
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
        super.layoutViews(msg, position);

        if (isForwardMode || isMessageDetailMode) {
            isShowStart = true;
        } else {
            if (msg.isSelf()) {
                isShowStart = false;
            } else {
                isShowStart = true;
            }
        }

        setMessageGravity(msg);

        if (isForwardMode || isMessageDetailMode) {
            usernameText.setVisibility(View.GONE);
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
                        usernameText.setVisibility(View.GONE);
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

        if (isForwardMode) {
            chatTimeText.setVisibility(View.GONE);
        }

        if (isForwardMode || isMessageDetailMode) {
            msgArea.setBackgroundResource(R.drawable.chat_message_popup_stroke_border_left);
            messageStatusImage.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_fill_border_right);
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_stroke_border_left);
                }
            }

            if (onItemClickListener != null) {
                msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        onItemClickListener.onMessageLongClick(msgArea, position, msg);
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
                messageStatusImage.setVisibility(View.VISIBLE);

                messageStatusImage.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onSendFailBtnClick(messageStatusImage, position, msg);
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
                messageStatusImage.setVisibility(View.GONE);
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
        setGravity(isShowStart);
        rootLayout.setIsStart(isShowStart);

        msgContentLinear.setVisibility(View.VISIBLE);

        if (!isForwardMode && !isMessageDetailMode) {
            setTimeInLineStatus(msg);
            setShowReadStatusClickListener(msg);
        }

        if (timeInLineTextLayout != null) {
            timeInLineTextLayout.setTimeText(DateTimeUtil.getHMTimeString(new Date(msg.getMessageTime() * 1000)));
        }

        extraInfoArea.setVisibility(View.GONE);
        setReplyContent(msg);
        setReactContent(msg);
        if (isNeedShowTranslation) {
            setTranslationContent(msg);
        }
        setMessageAreaPadding();
        if (floatMode) {
            itemView.setPadding(0, 0, 0, 0);
            leftUserIcon.setVisibility(View.GONE);
            rightUserIcon.setVisibility(View.GONE);
            usernameText.setVisibility(View.GONE);
            messageStatusImage.setVisibility(View.GONE);
            replyPreviewView.setVisibility(View.GONE);
            reactView.setVisibility(View.GONE);
            chatTimeText.setVisibility(View.GONE);
        }
        if (isMessageDetailMode) {
            replyPreviewView.setVisibility(View.GONE);
        }

        optimizeAvatarAndPadding(position, msg);
        loadAvatar(msg);
        layoutVariableViews(msg, position);
    }

    public void setTranslationContent(TUIMessageBean msg) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, msg);
        param.put(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW, recyclerView);
        param.put(TUIConstants.TUIChat.FRAGMENT, fragment);

        TUICore.raiseExtension(TUIConstants.TUITranslationPlugin.Extension.TranslationView.MINIMALIST_EXTENSION_ID, translationContentFrameLayout, param);
    }

    private void loadAvatar(TUIMessageBean msg) {
        if (msg.isUseMsgReceiverAvatar()) {
            String userId = "";
            if (TextUtils.equals(msg.getSender(), V2TIMManager.getInstance().getLoginUser())) {
                userId = msg.getUserId();
            } else {
                userId = V2TIMManager.getInstance().getLoginUser();
            }
            List<String> idList = new ArrayList<>();
            idList.add(userId);
            V2TIMManager.getInstance().getUsersInfo(idList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                @Override
                public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                    V2TIMUserFullInfo userInfo = v2TIMUserFullInfos.get(0);
                    if (userInfo == null) {
                        setupAvatar("", msg.isSelf());
                    } else {
                        setupAvatar(userInfo.getFaceUrl(), msg.isSelf());
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    setupAvatar("", msg.isSelf());
                }
            });
        } else {
            setupAvatar(msg.getFaceUrl(), msg.isSelf());
        }
    }

    private void setupAvatar(String faceUrl, boolean right) {
        if (!TextUtils.isEmpty(faceUrl)) {
            List<Object> urllist = new ArrayList<>();
            urllist.add(faceUrl);
            if (isForwardMode || isMessageDetailMode) {
                leftUserIcon.setIconUrls(urllist);
            } else {
                if (right) {
                    rightUserIcon.setIconUrls(urllist);
                } else {
                    leftUserIcon.setIconUrls(urllist);
                }
            }
        } else {
            rightUserIcon.setIconUrls(null);
            leftUserIcon.setIconUrls(null);
        }

        if (isShowSelfAvatar) {
            rightUserIcon.setVisibility(View.VISIBLE);
        } else {
            rightUserIcon.setVisibility(View.GONE);
        }
    }

    protected boolean isNeedChangedBackground() {
        return true;
    }

    private void optimizeAvatarAndPadding(int position, TUIMessageBean messageBean) {
        if (mAdapter == null) {
            return;
        }
        if (isMessageDetailMode || !isOptimize) {
            return;
        }
        TUIMessageBean nextMessage = mAdapter.getItem(position + 1);
        boolean isShowAvatar = true;
        boolean needChangedBackground = isNeedChangedBackground();
        if (nextMessage != null) {
            if (TextUtils.equals(messageBean.getSender(), nextMessage.getSender())) {
                boolean longPeriod = nextMessage.getMessageTime() - messageBean.getMessageTime() >= 5 * 60;
                if (!isShowAvatar(nextMessage) && nextMessage.getStatus() != TUIMessageBean.MSG_STATUS_REVOKE && !longPeriod) {
                    isShowAvatar = false;
                }
            }
        }

        int horizontalPadding = ScreenUtil.dip2px(16);
        int verticalPadding = ScreenUtil.dip2px(25f);
        if (isShowAvatar) {
            if (isShowStart) {
                leftUserIcon.setVisibility(View.VISIBLE);
                rightUserIcon.setVisibility(View.INVISIBLE);
                if (needChangedBackground) {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_stroke_border_left);
                }
            } else {
                leftUserIcon.setVisibility(View.INVISIBLE);
                rightUserIcon.setVisibility(View.VISIBLE);
                if (needChangedBackground) {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_fill_border_right);
                }
            }
        } else {
            if (needChangedBackground) {
                if (isShowStart) {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_stroke_border);
                } else {
                    msgArea.setBackgroundResource(R.drawable.chat_message_popup_fill_border);
                }
            }
            horizontalPadding = ScreenUtil.dip2px(16);
            verticalPadding = ScreenUtil.dip2px(2);
            leftUserIcon.setVisibility(View.INVISIBLE);
            rightUserIcon.setVisibility(View.INVISIBLE);
        }
        rootLayout.setPadding(horizontalPadding, 0, horizontalPadding, verticalPadding);
        optimizeMessageContent(isShowAvatar);
    }

    protected void optimizeMessageContent(boolean isShowAvatar) {}

    private void setMessageGravity(TUIMessageBean messageBean) {
        if (isForwardMode || isMessageDetailMode) {
            leftUserIcon.setVisibility(View.VISIBLE);
            rightUserIcon.setVisibility(View.GONE);
        } else {
            if (messageBean.isSelf()) {
                msgContentLinear.setGravity(Gravity.END);
                leftUserIcon.setVisibility(View.GONE);
                rightUserIcon.setVisibility(View.VISIBLE);
                extraInfoArea.setGravity(Gravity.END);
            } else {
                msgContentLinear.setGravity(Gravity.START);
                leftUserIcon.setVisibility(View.VISIBLE);
                rightUserIcon.setVisibility(View.GONE);
                extraInfoArea.setGravity(Gravity.START);
            }
        }
        if (properties.getAvatar() != 0) {
            leftUserIcon.setDefaultImageResId(properties.getAvatar());
            rightUserIcon.setDefaultImageResId(properties.getAvatar());
        } else {
            leftUserIcon.setDefaultImageResId(
                TUIThemeManager.getAttrResId(leftUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon));
            rightUserIcon.setDefaultImageResId(
                TUIThemeManager.getAttrResId(rightUserIcon.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon));
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

    protected void setMessageAreaPadding() {
        // after setting background, the padding will be reset
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(R.dimen.chat_minimalist_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(R.dimen.chat_minimalist_message_area_padding_top_bottom);
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
        MessageReactBean messageReactBean = messageBean.getMessageReactBean();
        if (messageReactBean != null && messageReactBean.getReactSize() > 0) {
            reactView.setVisibility(View.VISIBLE);
            reactView.setData(messageReactBean);
            reactView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, 0, messageBean);
                    }
                    return true;
                }
            });

            reactView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onReactOnClick(null, messageBean);
                    }
                }
            });

            if (isForwardMode) {
                reactView.setOnLongClickListener(null);
            }
        } else {
            reactView.setVisibility(View.GONE);
            reactView.setOnLongClickListener(null);
        }
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
            if (messageBean.isSelf()) {
                timeInLineTextLayout.setOnStatusAreaClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onItemClickListener != null) {
                            onItemClickListener.onMessageReadStatusClick(v, messageBean);
                        }
                    }
                });
            } else {
                timeInLineTextLayout.setOnStatusAreaClickListener(null);
            }
            timeInLineTextLayout.setOnStatusAreaLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, 0, messageBean);
                    }
                    return true;
                }
            });

            timeInLineTextLayout.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, 0, messageBean);
                    }
                    return true;
                }
            });
        }
    }

    public abstract void layoutVariableViews(final TUIMessageBean msg, final int position);

    public void onRecycled() {}

    public void setNeedShowTranslation(boolean needShowTranslation) {
        isNeedShowTranslation = needShowTranslation;
    }

    public void setShowRead(boolean showRead) {
        isShowRead = showRead;
    }
}
