package com.tencent.qcloud.tuikit.timcommon.classicui.widget.message;

import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
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
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.UserIconView;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonLog;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public abstract class MessageContentHolder<T extends TUIMessageBean> extends MessageBaseHolder<T> {
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

    public boolean isForwardMode = false;
    public boolean isReplyDetailMode = false;
    public boolean isMultiSelectMode = false;

    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    protected SelectTextHelper selectableTextHelper;
    // 是否显示翻译的内容。合并转发的消息详情界面不用展示翻译内容。
    // Whether to display the translated content. The merged-forwarded message details activity does not display the translated content.
    protected boolean isNeedShowTranslation = true;
    protected boolean isShowRead = false;
    private BaseFragment fragment;
    private RecyclerView recyclerView;

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

    public void resetSelectableText() {
        if (selectableTextHelper != null) {
            selectableTextHelper.reset();
        }
    }

    @Override
    public void layoutViews(final T msg, final int position) {
        super.layoutViews(msg, position);

        setUserIcon(msg);
        setUserName(msg);
        loadAvatar(msg);
        setSendingProgress(msg);

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
            setOnClickListener(msg, position);
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

        if (isReplyDetailMode) {
            chatTimeText.setVisibility(View.GONE);
        }

        setReplyContent(msg);
        setReactContent(msg);
        if (isNeedShowTranslation) {
            setTranslationContent(msg);
        }

        setMessageAreaPadding();

        layoutVariableViews(msg, position);
    }

    private void setOnClickListener(T msg, int position) {
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

    private void setSendingProgress(T msg) {

        if (isForwardMode || isReplyDetailMode) {
            sendingProgress.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL || msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS || msg.isPeerRead()) {
                    sendingProgress.setVisibility(View.GONE);
                } else {
                    sendingProgress.setVisibility(View.VISIBLE);
                }
            } else {
                sendingProgress.setVisibility(View.GONE);
            }
        }
    }

    private void setUserName(T msg) {

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
        if (properties.getAvatar() != 0) {
            leftUserIcon.setDefaultImageResId(properties.getAvatar());
            rightUserIcon.setDefaultImageResId(properties.getAvatar());
        } else {
            leftUserIcon.setDefaultImageResId(
                TUIThemeManager.getAttrResId(leftUserIcon.getContext(), R.attr.core_default_user_icon));
            rightUserIcon.setDefaultImageResId(
                TUIThemeManager.getAttrResId(rightUserIcon.getContext(), R.attr.core_default_user_icon));
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

    private void setTranslationContent(TUIMessageBean msg) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, msg);
        param.put(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW, recyclerView);
        param.put(TUIConstants.TUIChat.FRAGMENT, fragment);

        TUICore.raiseExtension(TUIConstants.TUITranslationPlugin.Extension.TranslationView.CLASSIC_EXTENSION_ID, translationContentFrameLayout, param);
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
            if (isForwardMode || isReplyDetailMode) {
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
    }

    protected void setMessageAreaPadding() {
        // after setting background, the padding will be reset
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(R.dimen.chat_message_area_padding_top_bottom);
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
                    isReadText.setText(isReadText.getResources().getString(R.string.someone_has_read, readCount));
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
        if (selectableTextHelper != null) {
            selectableTextHelper.destroy();
        }
    }

    public void onReadStatusClick(View view, TUIMessageBean messageBean) {
        if (onItemClickListener != null) {
            onItemClickListener.onMessageReadStatusClick(view, messageBean);
        }
    }

    protected void setSelectableTextHelper(TUIMessageBean msg, TextView textView, int position, boolean isEmoji) {
        if (selectableTextHelper != null) {
            selectableTextHelper.destroy();
        }
        selectableTextHelper = new SelectTextHelper.Builder(textView)
                                   .setCursorHandleColor(TIMCommonService.getAppContext().getResources().getColor(R.color.font_blue))
                                   .setCursorHandleSizeInDp(18)
                                   .setSelectedColor(TIMCommonService.getAppContext().getResources().getColor(R.color.test_blue))
                                   .setSelectAll(true)
                                   .setIsEmoji(isEmoji)
                                   .setScrollShow(false)
                                   .setSelectedAllNoPop(true)
                                   .setMagnifierShow(false)
                                   .build();

        selectableTextHelper.setSelectListener(new SelectTextHelper.OnSelectListener() {
            @Override
            public void onClick(View v) {}

            @Override
            public void onLongClick(View v) {}

            @Override
            public void onTextSelected(CharSequence content) {
                String selectedText = content.toString();
                msg.setSelectText(selectedText);
                TIMCommonLog.d("TextMessageHolder", "onTextSelected selectedText = " + selectedText);
                if (onItemClickListener != null) {
                    onItemClickListener.onTextSelected(msgArea, position, msg);
                }
            }

            @Override
            public void onDismiss() {
                msg.setSelectText(msg.getExtra());
            }

            @Override
            public void onClickUrl(String url) {}

            @Override
            public void onSelectAllShowCustomPop() {}

            @Override
            public void onReset() {
                msg.setSelectText(null);
                msg.setSelectText(msg.getExtra());
            }

            @Override
            public void onDismissCustomPop() {}

            @Override
            public void onScrolling() {}
        });
    }

    public void setNeedShowTranslation(boolean needShowTranslation) {
        isNeedShowTranslation = needShowTranslation;
    }

    public void setShowRead(boolean showRead) {
        isShowRead = showRead;
    }
}
