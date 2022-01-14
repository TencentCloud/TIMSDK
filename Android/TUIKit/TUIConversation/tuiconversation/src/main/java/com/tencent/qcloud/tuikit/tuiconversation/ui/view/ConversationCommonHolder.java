package com.tencent.qcloud.tuikit.tuiconversation.ui.view;

import android.graphics.Color;
import android.text.Html;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.UnreadCountTextView;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuiconversation.util.TUIConversationLog;

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
    public ProgressBar messageSending;
    public ImageView messagefailed;
    private boolean isForwardMode = false;

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
        messagefailed = itemView.findViewById(R.id.message_status_failed);
        messageSending = itemView.findViewById(R.id.message_status_sending);
    }

    public void setForwardMode(boolean forwardMode) {
        isForwardMode = forwardMode;
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        if (conversation.isTop() && !isForwardMode) {
            leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.conversation_item_top_color));
        } else {
            leftItemLayout.setBackgroundColor(Color.WHITE);
        }

        titleText.setText(conversation.getTitle());
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
            // 如果最后一条消息是自定义消息, 获取要显示的字符
            if (lastMsgDisplayString != null) {
                messageText.setText(Html.fromHtml(lastMsgDisplayString));
                messageText.setTextColor(rootView.getResources().getColor(R.color.list_bottom_text_bg));
            }
            if (conversation.getLastMessage() != null) {
                timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(conversation.getLastMessageTime() * 1000)));
            }
        }

        if (conversation.isShowDisturbIcon()) {
            if (conversation.getUnRead() > 0) {
                unreadText.setVisibility(View.VISIBLE);
                unreadText.setText("");

                if (messageText.getText() != null) {
                    String text = messageText.getText().toString();
                    messageText.setText("[" + conversation.getUnRead() + rootView.getContext().getString(R.string.message_num) + "] " + text);
                }
            } else {
                unreadText.setVisibility(View.GONE);
            }
        }else if (conversation.getUnRead() > 0) {
            unreadText.setVisibility(View.VISIBLE);
            if (conversation.getUnRead() > 99) {
                unreadText.setText("99+");
            } else {
                unreadText.setText("" + conversation.getUnRead());
            }
        } else {
            unreadText.setVisibility(View.GONE);
        }

        if (draftInfo != null) {
            atInfoText.setVisibility(View.VISIBLE);
            atInfoText.setText(R.string.drafts);
            atInfoText.setTextColor(Color.RED);
        } else {
            if (conversation.getAtInfoText().isEmpty()) {
                atInfoText.setVisibility(View.GONE);
            } else {
                atInfoText.setVisibility(View.VISIBLE);
                atInfoText.setText(conversation.getAtInfoText());
                atInfoText.setTextColor(Color.RED);
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

        conversationIconView.setConversation(conversation);

        if (conversation.isShowDisturbIcon() && !isForwardMode) {
            disturbView.setVisibility(View.VISIBLE);
        } else {
            disturbView.setVisibility(View.GONE);
        }

        V2TIMMessage lastMessage = conversation.getLastMessage();
        if (lastMessage != null) {
            int status = lastMessage.getStatus();
            if (status == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                messageStatusLayout.setVisibility(View.VISIBLE);
                messagefailed.setVisibility(View.VISIBLE);
                messageSending.setVisibility(View.GONE);
            } else if (status == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                messageStatusLayout.setVisibility(View.VISIBLE);
                messagefailed.setVisibility(View.GONE);
                messageSending.setVisibility(View.VISIBLE);
            } else {
                messageStatusLayout.setVisibility(View.GONE);
                messagefailed.setVisibility(View.GONE);
                messageSending.setVisibility(View.GONE);
            }
        } else {
            messageStatusLayout.setVisibility(View.GONE);
            messagefailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
        }

        if (isForwardMode) {
            messageText.setVisibility(View.GONE);
            timelineText.setVisibility(View.GONE);
            unreadText.setVisibility(View.GONE);
            atInfoText.setVisibility(View.GONE);
            messageStatusLayout.setVisibility(View.GONE);
            messagefailed.setVisibility(View.GONE);
            messageSending.setVisibility(View.GONE);
        }

        //// 由子类设置指定消息类型的views
        layoutVariableViews(conversation, position);
    }

    public void layoutVariableViews(ConversationInfo conversationInfo, int position) {

    }

    private static class EmojiData{
        private int start;
        private int end;
        private String emojiText;

        public int getEnd() {
            return end;
        }

        public void setEnd(int end) {
            this.end = end;
        }

        public int getStart() {
            return start;
        }

        public void setStart(int start) {
            this.start = start;
        }

        public String getEmojiText() {
            return emojiText;
        }

        public void setEmojiText(String emojiText) {
            this.emojiText = emojiText;
        }
    }
}
