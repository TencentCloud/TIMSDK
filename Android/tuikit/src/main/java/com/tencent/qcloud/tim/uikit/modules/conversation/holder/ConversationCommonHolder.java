package com.tencent.qcloud.tim.uikit.modules.conversation.holder;

import android.graphics.Color;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.component.face.FaceManager;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.TIMMentionEditText;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationIconView;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ConversationCommonHolder extends ConversationBaseHolder {

    public ConversationIconView conversationIconView;
    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected TextView unreadText;
    protected TextView atInfoText;

    public ConversationCommonHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        conversationIconView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
        atInfoText = rootView.findViewById(R.id.conversation_at_msg);
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        MessageInfo lastMsg = conversation.getLastMessage();
        if (lastMsg != null && lastMsg.getStatus() == MessageInfo.MSG_STATUS_REVOKE) {
            if (lastMsg.isSelf()) {
                lastMsg.setExtra(TUIKit.getAppContext().getString(R.string.revoke_tips_you));
            } else if (lastMsg.isGroup()) {
                String message = TUIKitConstants.covert2HTMLString(
                        TextUtils.isEmpty(lastMsg.getGroupNameCard())
                                ? lastMsg.getFromUser()
                                : lastMsg.getGroupNameCard());
                lastMsg.setExtra(message + TUIKit.getAppContext().getString(R.string.revoke_tips));
            } else {
                lastMsg.setExtra(TUIKit.getAppContext().getString(R.string.revoke_tips_other));
            }
        }

        if (conversation.isTop()) {
            leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.conversation_top_color));
        } else {
            leftItemLayout.setBackgroundColor(Color.WHITE);
        }

        titleText.setText(conversation.getTitle());
        messageText.setText("");
        timelineText.setText("");
        if (lastMsg != null) {
            if (lastMsg.getExtra() != null) {
                String result = emojiJudge(lastMsg.getExtra().toString());
                messageText.setText(Html.fromHtml(result));
                messageText.setTextColor(rootView.getResources().getColor(R.color.list_bottom_text_bg));
            }
            timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(lastMsg.getMsgTime() * 1000)));
        }

        if (conversation.getUnRead() > 0) {
            unreadText.setVisibility(View.VISIBLE);
            if (conversation.getUnRead() > 99) {
                unreadText.setText("99+");
            } else {
                unreadText.setText("" + conversation.getUnRead());
            }
        } else {
            unreadText.setVisibility(View.GONE);
        }

        if (conversation.getAtInfoText().isEmpty()){
            atInfoText.setVisibility(View.GONE);
        } else {
            atInfoText.setVisibility(View.VISIBLE);
            atInfoText.setText(conversation.getAtInfoText());
            atInfoText.setTextColor(Color.RED);
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

        if (conversation.getIconUrlList() != null) {
            conversationIconView.setConversation(conversation);
        }

        //// 由子类设置指定消息类型的views
        layoutVariableViews(conversation, position);
    }


    private static String emojiJudge(String text){
        if (TextUtils.isEmpty(text)){
            return "";
        }

        String[] emojiList = FaceManager.getEmojiFilters();
        if (emojiList ==null || emojiList.length == 0){
            return text;
        }

        SpannableStringBuilder sb = new SpannableStringBuilder(text);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        ArrayList<EmojiData> emojiDataArrayList = new ArrayList<>();
        //遍历找到匹配字符并存储
        int lastMentionIndex = -1;
        while (m.find()) {
            String emojiName = m.group();
            int start;
            if (lastMentionIndex != -1) {
                start = text.indexOf(emojiName, lastMentionIndex);
            } else {
                start = text.indexOf(emojiName);
            }
            int end = start + emojiName.length();
            lastMentionIndex = end;

            int index = findeEmoji(emojiName);
            String[] emojiListValues = FaceManager.getEmojiFiltersValues();
            if (index != -1 && emojiListValues != null && emojiListValues.length >= index){
                emojiName = emojiListValues[index];
            }


            EmojiData emojiData =new EmojiData();
            emojiData.setStart(start);
            emojiData.setEnd(end);
            emojiData.setEmojiText(emojiName);

            emojiDataArrayList.add(emojiData);
        }

        //倒叙替换
        if (emojiDataArrayList.isEmpty()){
            return text;
        }
        for (int i = emojiDataArrayList.size() - 1; i >= 0; i--){
            EmojiData emojiData = emojiDataArrayList.get(i);
            String emojiName = emojiData.getEmojiText();
            int start = emojiData.getStart();
            int end = emojiData.getEnd();

            if (!TextUtils.isEmpty(emojiName) && start != -1 && end != -1) {
                sb.replace(start, end, emojiName);
            }
        }
        return sb.toString();
    }

    private static int findeEmoji(String text){
        int result = -1;
        if (TextUtils.isEmpty(text)){
            return result;
        }

        String[] emojiList = FaceManager.getEmojiFilters();
        if (emojiList ==null || emojiList.length == 0){
            return result;
        }

        for (int i = 0; i < emojiList.length; i++){
            if (text.equals(emojiList[i])){
                result = i;
                break;
            }
        }

        return result;
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
