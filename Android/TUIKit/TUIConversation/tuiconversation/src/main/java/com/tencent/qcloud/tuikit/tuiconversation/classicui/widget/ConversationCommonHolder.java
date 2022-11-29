package com.tencent.qcloud.tuikit.tuiconversation.classicui.widget;

import android.graphics.Color;
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
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.UnreadCountTextView;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;

import java.util.Date;
import java.util.HashMap;

public class ConversationCommonHolder extends ConversationBaseHolder {

    public ConversationIconView conversationIconView;
    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected UnreadCountTextView unreadText;
    protected TextView atInfoText;
    protected ImageView disturbView;
    protected CheckBox multiSelectCheckBox;
    protected RelativeLayout messageStatusLayout;
    public ImageView messageSending;
    public ImageView messageFailed;
    private boolean isForwardMode = false;
    protected View userStatusView;
    private boolean showFoldedStyle = true;

    public ConversationCommonHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        conversationIconView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
        atInfoText = rootView.findViewById(R.id.conversation_at_msg);
        disturbView = rootView.findViewById(R.id.not_disturb);
        multiSelectCheckBox = rootView.findViewById(R.id.select_checkbox);
        messageStatusLayout = rootView.findViewById(R.id.message_status_layout);
        messageFailed = itemView.findViewById(R.id.message_status_failed);
        messageSending = itemView.findViewById(R.id.message_status_sending);
        userStatusView = itemView.findViewById(R.id.user_status);
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public void setShowFoldedStyle(boolean showFoldedStyle) {
        this.showFoldedStyle = showFoldedStyle;
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        if (conversation.isTop() && !isForwardMode) {
            leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.conversation_item_top_color));
        } else {
            leftItemLayout.setBackgroundColor(Color.WHITE);
        }

        if (showFoldedStyle && conversation.isMarkFold()) {
            titleText.setText(R.string.folded_group_chat);
            timelineText.setVisibility(View.GONE);
        } else {
            titleText.setText(conversation.getTitle());
        }
        messageText.setText("");
        timelineText.setText("");
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
        if (draftInfo != null) {
            messageText.setText(draftText);
            timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(draftInfo.getDraftTime() * 1000)));
        } else {
            HashMap<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIChat.V2TIMMESSAGE, conversation.getLastMessage());
            String lastMsgDisplayString = (String) TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_GET_DISPLAY_STRING, param);
            // 获取要显示的字符
            // Get the characters to display
            if (lastMsgDisplayString != null) {
                messageText.setText(Html.fromHtml(lastMsgDisplayString));
                messageText.setTextColor(rootView.getResources().getColor(R.color.list_bottom_text_bg));
            }
            if (conversation.getLastMessage() != null) {
                timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(conversation.getLastMessageTime() * 1000)));
            }
        }

        if (conversation.isShowDisturbIcon()) {
            if ((showFoldedStyle && conversation.isMarkFold())) {
                if (conversation.isMarkLocalUnread()) {
                    unreadText.setVisibility(View.VISIBLE);
                    unreadText.setText("");
                } else {
                    unreadText.setVisibility(View.GONE);
                }
            } else {
                if (conversation.getUnRead() == 0) {
                    if (conversation.isMarkUnread()) {
                        unreadText.setVisibility(View.VISIBLE);
                        unreadText.setText("");
                    } else {
                        unreadText.setVisibility(View.GONE);
                    }
                } else {
                    unreadText.setVisibility(View.VISIBLE);
                    unreadText.setText("");

                    if (messageText.getText() != null) {
                        String text = messageText.getText().toString();
                        messageText.setText("[" + conversation.getUnRead() + rootView.getContext().getString(R.string.message_num) + "] " + text);
                    }
                }
            }
        } else if (conversation.getUnRead() > 0) {
            unreadText.setVisibility(View.VISIBLE);
            if (conversation.getUnRead() > 99) {
                unreadText.setText("99+");
            } else {
                unreadText.setText("" + conversation.getUnRead());
            }
        } else {
            if (conversation.isMarkUnread()) {
                unreadText.setVisibility(View.VISIBLE);
                unreadText.setText("1");
            } else {
                unreadText.setVisibility(View.GONE);
            }
        }

        if (draftInfo != null) {
            atInfoText.setVisibility(View.VISIBLE);
            atInfoText.setText(R.string.drafts);
            atInfoText.setTextColor(Color.RED);

            messageStatusLayout.setVisibility(View.GONE);
            messageFailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
        } else {
            if (conversation.getAtInfoText().isEmpty()) {
                atInfoText.setVisibility(View.GONE);
            } else {
                atInfoText.setVisibility(View.VISIBLE);
                atInfoText.setText(conversation.getAtInfoText());
                atInfoText.setTextColor(Color.RED);
            }

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

        conversationIconView.setRadius(mAdapter.getItemAvatarRadius());
        if (mAdapter.getItemDateTextSize() != 0) {
            timelineText.setTextSize(mAdapter.getItemDateTextSize());
        }
        if (mAdapter.getItemBottomTextSize() != 0) {
            messageText.setTextSize(mAdapter.getItemBottomTextSize());
        }
        if (mAdapter.getItemTopTextSize() != 0) {
            titleText.setTextSize(mAdapter.getItemTopTextSize());
        }
        if (!mAdapter.hasItemUnreadDot()) {
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
            atInfoText.setVisibility(View.GONE);
            messageStatusLayout.setVisibility(View.GONE);
            messageFailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
        }

        if (!conversation.isGroup() && TUIConversationConfig.getInstance().isShowUserStatus()) {
            userStatusView.setVisibility(View.VISIBLE);
            if (conversation.getStatusType() == V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE) {
                userStatusView.setBackgroundResource(TUIThemeManager.getAttrResId(rootView.getContext(), com.tencent.qcloud.tuicore.R.attr.user_status_online));
            } else {
                userStatusView.setBackgroundResource(TUIThemeManager.getAttrResId(rootView.getContext(), com.tencent.qcloud.tuicore.R.attr.user_status_offline));
            }
        } else {
            userStatusView.setVisibility(View.GONE);
        }
    }
}
