package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils.getWaitingSpan;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ImageSpan;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.CenterImageSpan;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ChatbotMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;

public class ChatbotMessageHolder extends MessageContentHolder {
    public ChatbotMessageHolder(View itemView) {
        super(itemView);
        timeInLineTextLayout = itemView.findViewById(R.id.text_message_layout);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_minimalist_message_adapter_content_text;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof ChatbotMessageBean)) {
            return;
        }
        ChatbotMessageBean chatbotMessageBean = (ChatbotMessageBean) msg;
        chatbotMessageBean.setSelectText(chatbotMessageBean.getText());

        applyCustomConfig();

        setOnTimeInLineTextClickListener(chatbotMessageBean);
        if (!chatbotMessageBean.isFinished()) {
            setOnItemClickListener(null);
        }
        if (chatbotMessageBean.getText() != null) {
            timeInLineTextLayout.getTextView().setText(chatbotMessageBean.getText());
            if (!chatbotMessageBean.isFinished()) {
                timeInLineTextLayout.getTextView().append(getWaitingSpan(timeInLineTextLayout.getContext()));
            }
        } else {
            FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), TUIChatService.getAppContext().getString(R.string.no_support_msg), false);
        }
        TextUtil.linkifyUrls(timeInLineTextLayout.getTextView());
    }

    protected void applyCustomConfig() {
        if (isLayoutOnStart) {
            int sendTextMessageColor = TUIChatConfigMinimalist.getSendTextMessageColor();
            if (sendTextMessageColor != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextColor(sendTextMessageColor);
            }
            int sendTextMessageFontSize = TUIChatConfigMinimalist.getSendTextMessageFontSize();
            if (sendTextMessageFontSize != TUIChatConfigMinimalist.UNDEFINED)  {
                timeInLineTextLayout.setTextSize(sendTextMessageFontSize);
            }
        } else {
            int receiveTextMessageColor = TUIChatConfigMinimalist.getReceiveTextMessageColor();
            if (receiveTextMessageColor != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextColor(receiveTextMessageColor);
            }
            int receiveTextMessageFontSize = TUIChatConfigMinimalist.getReceiveTextMessageFontSize();
            if (receiveTextMessageFontSize != TUIChatConfigMinimalist.UNDEFINED)  {
                timeInLineTextLayout.setTextSize(receiveTextMessageFontSize);
            }
        }
    }

}
