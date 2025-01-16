package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.UnreadCountTextView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.swipe.SwipeLayout;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.config.minimalistui.TUIConversationConfigMinimalist;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

import java.util.Date;
import java.util.HashMap;

public class ConversationCommonHolder extends ConversationBaseHolder {
    public ConversationIconView conversationIconView;
    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected UnreadCountTextView unreadText;
    protected UnreadCountTextView conversationNotDisturbUnread;
    protected ImageView disturbView;
    protected CheckBox multiSelectCheckBox;
    protected RelativeLayout messageStatusLayout;
    public ImageView messageSending;
    public ImageView messageFailed;
    private boolean isForwardMode = false;
    protected View userStatusView;

    protected TextView atAllTv;
    protected TextView atMeTv;
    protected TextView draftTv;
    protected TextView riskTv;
    private boolean showFoldedStyle = true;
    protected TextView foldGroupNameTv;
    protected TextView foldGroupNameDivider;
    protected SwipeLayout swipeLayout;
    protected RelativeLayout markReadView;
    protected RelativeLayout moreView;
    protected TextView markReadTextView;
    protected TextView notDisplayView;
    protected ImageView markReadIconView;
    private ConversationInfo currentConversation;

    public ConversationCommonHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        conversationIconView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
        conversationNotDisturbUnread = rootView.findViewById(R.id.conversation_not_disturb_unread);
        atMeTv = rootView.findViewById(R.id.conversation_at_me);
        atAllTv = rootView.findViewById(R.id.conversation_at_all);
        draftTv = rootView.findViewById(R.id.conversation_draft);
        riskTv = rootView.findViewById(R.id.conversation_risk);
        foldGroupNameTv = rootView.findViewById(R.id.fold_group_name);
        foldGroupNameDivider = rootView.findViewById(R.id.fold_group_name_divider);
        disturbView = rootView.findViewById(R.id.not_disturb);
        multiSelectCheckBox = rootView.findViewById(R.id.select_checkbox);
        messageStatusLayout = rootView.findViewById(R.id.message_status_layout);
        messageFailed = itemView.findViewById(R.id.message_status_failed);
        messageSending = itemView.findViewById(R.id.message_status_sending);
        userStatusView = itemView.findViewById(R.id.user_status);
        swipeLayout = itemView.findViewById(R.id.swipe);
        markReadView = itemView.findViewById(R.id.mark_read);
        moreView = itemView.findViewById(R.id.more_view);
        markReadTextView = itemView.findViewById(R.id.mark_read_text);
        notDisplayView = itemView.findViewById(R.id.not_display);
        markReadIconView = itemView.findViewById(R.id.mark_read_image);
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public void setShowFoldedStyle(boolean showFoldedStyle) {
        this.showFoldedStyle = showFoldedStyle;
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        currentConversation = conversation;

        initTitleAndTime(conversation);
        setLastMessageAndStatus(conversation);

        conversationIconView.setRadius(ScreenUtil.dip2px(40));
        if (!mAdapter.hasItemUnreadDot()) {
            conversationNotDisturbUnread.setVisibility(View.GONE);
            unreadText.setVisibility(View.GONE);
        }

        conversationIconView.setShowFoldedStyle(showFoldedStyle);
        conversationIconView.setConversation(conversation);

        if (conversation.isShowDisturbIcon() && !isForwardMode) {
            if (showFoldedStyle && conversation.isMarkFold()) {
                disturbView.setVisibility(View.GONE);
            } else {
                disturbView.setVisibility(View.VISIBLE);
            }
        } else {
            disturbView.setVisibility(View.GONE);
        }

        if (isForwardMode) {
            messageText.setVisibility(View.GONE);
            timelineText.setVisibility(View.GONE);
            unreadText.setVisibility(View.GONE);
            messageStatusLayout.setVisibility(View.GONE);
            messageFailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
            atAllTv.setVisibility(View.GONE);
            atMeTv.setVisibility(View.GONE);
            draftTv.setVisibility(View.GONE);
            riskTv.setVisibility(View.GONE);
        }

        if (!conversation.isGroup() && TUIConversationConfigMinimalist.isShowUserOnlineStatusIcon()) {
            if (conversation.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE) {
                userStatusView.setVisibility(View.VISIBLE);
            } else {
                userStatusView.setVisibility(View.GONE);
            }
        } else {
            userStatusView.setVisibility(View.GONE);
        }
        applyCustomConfig();
    }

    private void applyCustomConfig() {
        if (currentConversation.isTop() && !isForwardMode) {
            Drawable pinnedCellBackground = TUIConversationConfigMinimalist.getPinnedCellBackground();
            if (pinnedCellBackground != null) {
                leftItemLayout.setBackground(pinnedCellBackground);
            } else {
                leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.conversation_item_top_color));
            }
        } else {
            Drawable cellBackground = TUIConversationConfigMinimalist.getCellBackground();
            if (cellBackground != null) {
                leftItemLayout.setBackground(cellBackground);
            } else {
                leftItemLayout.setBackgroundColor(Color.WHITE);
            }
        }
        if (!TUIConversationConfigMinimalist.isShowCellUnreadCount()) {
            unreadText.setVisibility(View.GONE);
            conversationNotDisturbUnread.setVisibility(View.GONE);
        }
        if (!TUIConversationConfigMinimalist.isShowUserOnlineStatusIcon()) {
            userStatusView.setVisibility(View.GONE);
        }
        if (TUIConversationConfigMinimalist.getCellTitleLabelFontSize() != TUIConversationConfigMinimalist.UNDEFINED) {
            titleText.setTextSize(TUIConversationConfigMinimalist.getCellTitleLabelFontSize());
        }
        if (TUIConversationConfigMinimalist.getCellSubtitleLabelFontSize() != TUIConversationConfigMinimalist.UNDEFINED) {
            messageText.setTextSize(TUIConversationConfigMinimalist.getCellSubtitleLabelFontSize());
        }
        if (TUIConversationConfigMinimalist.getCellTimeLabelFontSize() != TUIConversationConfigMinimalist.UNDEFINED) {
            timelineText.setTextSize(TUIConversationConfigMinimalist.getCellTimeLabelFontSize());
        }
        if (TUIConversationConfigMinimalist.getAvatarCornerRadius() != TUIConversationConfigMinimalist.UNDEFINED) {
            conversationIconView.setRadius(TUIConversationConfigMinimalist.getAvatarCornerRadius());
        }

    }

    private void setLastMessageAndStatus(ConversationInfo conversation) {
        DraftInfo draftInfo = conversation.getDraft();
        String draftText = "";
        if (draftInfo != null) {
            Gson gson = new Gson();
            HashMap draftJsonMap;
            draftText = draftInfo.getDraftText();
            try {
                draftJsonMap = gson.fromJson(draftInfo.getDraftText(), HashMap.class);
                if (draftJsonMap != null) {
                    draftText = (String) draftJsonMap.get("content");
                }
            } catch (JsonSyntaxException e) {
                TUIConversationLog.e("ConversationCommonHolder", " getDraftJsonMap error ");
            }
        }

        atAllTv.setVisibility(View.GONE);
        atMeTv.setVisibility(View.GONE);
        draftTv.setVisibility(View.GONE);
        riskTv.setVisibility(View.GONE);
        if (draftInfo != null) {
            messageText.setText(FaceManager.emojiJudge(draftText));
            timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(draftInfo.getDraftTime() * 1000)));
        } else {
            if (TUIConversationUtils.hasRiskContent(conversation.getLastMessage())) {
                riskTv.setVisibility(View.VISIBLE);
            } else {
                TUIMessageBean lasTUIMessageBean = conversation.getLastTUIMessageBean();
                if (lasTUIMessageBean != null) {
                    String displayString = ConversationPresenter.getMessageDisplayString(lasTUIMessageBean);
                    messageText.setText(Html.fromHtml(displayString));
                    messageText.setTextColor(rootView.getResources().getColor(R.color.list_bottom_text_bg));
                }
                if (conversation.getLastMessage() != null) {
                    timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(conversation.getLastMessageTime() * 1000)));
                }
            }
        }

        if (conversation.isShowDisturbIcon()) {
            unreadText.setVisibility(View.GONE);
            if ((showFoldedStyle && conversation.isMarkFold())) {
                if (conversation.isMarkLocalUnread()) {
                    conversationNotDisturbUnread.setVisibility(View.VISIBLE);
                } else {
                    conversationNotDisturbUnread.setVisibility(View.GONE);
                }
            } else {
                if (conversation.getUnRead() == 0) {
                    if (conversation.isMarkUnread()) {
                        conversationNotDisturbUnread.setVisibility(View.VISIBLE);
                    } else {
                        conversationNotDisturbUnread.setVisibility(View.GONE);
                    }
                } else {
                    conversationNotDisturbUnread.setVisibility(View.VISIBLE);

                    if (messageText.getText() != null) {
                        String text = messageText.getText().toString();
                        messageText.setText("[" + conversation.getUnRead() + " " + rootView.getContext().getString(R.string.message_num) + "] " + text);
                    }
                }
            }
        } else if (conversation.getUnRead() > 0) {
            conversationNotDisturbUnread.setVisibility(View.GONE);
            unreadText.setVisibility(View.VISIBLE);
            if (conversation.getUnRead() > 99) {
                unreadText.setText("99+");
            } else {
                unreadText.setText("" + conversation.getUnRead());
            }
        } else {
            conversationNotDisturbUnread.setVisibility(View.GONE);
            if (conversation.isMarkUnread()) {
                unreadText.setVisibility(View.VISIBLE);
                unreadText.setText("1");
            } else {
                unreadText.setVisibility(View.GONE);
            }
        }
        if (conversation.getAtType() == ConversationInfo.AT_TYPE_AT_ME) {
            atMeTv.setVisibility(View.VISIBLE);
        } else if (conversation.getAtType() == ConversationInfo.AT_TYPE_AT_ALL) {
            atAllTv.setVisibility(View.VISIBLE);
        } else if (conversation.getAtType() == ConversationInfo.AT_TYPE_AT_ALL_AND_ME) {
            atAllTv.setVisibility(View.VISIBLE);
            atMeTv.setVisibility(View.VISIBLE);
        }
        if (draftInfo != null) {
            draftTv.setVisibility(View.VISIBLE);
            messageStatusLayout.setVisibility(View.GONE);
            messageFailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
        } else {
            V2TIMMessage lastMessage = conversation.getLastMessage();
            if (lastMessage != null) {
                int status = lastMessage.getStatus();
                if (status == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                    messageStatusLayout.setVisibility(View.VISIBLE);
                    messageFailed.setVisibility(View.VISIBLE);
                    messageSending.setVisibility(View.GONE);
                } else if (status == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                    messageStatusLayout.setVisibility(View.VISIBLE);
                    messageFailed.setVisibility(View.GONE);
                    messageSending.setVisibility(View.VISIBLE);
                } else {
                    messageStatusLayout.setVisibility(View.GONE);
                    messageFailed.setVisibility(View.GONE);
                    messageSending.setVisibility(View.GONE);
                }
            } else {
                messageStatusLayout.setVisibility(View.GONE);
                messageFailed.setVisibility(View.GONE);
                messageSending.setVisibility(View.GONE);
            }
        }
    }

    private void initTitleAndTime(ConversationInfo conversation) {
        if (showFoldedStyle && conversation.isMarkFold()) {
            titleText.setText(R.string.folded_group_chat);
            timelineText.setVisibility(View.GONE);
            foldGroupNameTv.setVisibility(View.VISIBLE);
            foldGroupNameDivider.setVisibility(View.VISIBLE);
            foldGroupNameTv.setText(conversation.getTitle());
        } else {
            titleText.setText(conversation.getTitle());
            foldGroupNameTv.setVisibility(View.GONE);
            foldGroupNameDivider.setVisibility(View.GONE);
        }

        messageText.setText("");
        timelineText.setText("");
    }
}
