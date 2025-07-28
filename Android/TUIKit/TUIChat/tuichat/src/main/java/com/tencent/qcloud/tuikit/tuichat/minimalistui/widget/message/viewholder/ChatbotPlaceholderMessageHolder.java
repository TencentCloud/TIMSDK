package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static android.view.View.VISIBLE;
import static com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils.getWaitingSpan;

import android.content.Context;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ChatbotPlaceholderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;

public class ChatbotPlaceholderMessageHolder extends MessageContentHolder {

    ImageView imageView;

    public ChatbotPlaceholderMessageHolder(View itemView) {
        super(itemView);
        timeInLineTextLayout = itemView.findViewById(R.id.text_message_layout);
        imageView = itemView.findViewById(R.id.content_image_iv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_minimalist_message_adapter_content_chatbot_placeholder;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof ChatbotPlaceholderMessageBean)) {
            return;
        }
        Drawable drawable = imageView.getDrawable();
        if (drawable instanceof Animatable) {
            ((Animatable) drawable).start();
        }
        setOnItemClickListener(null);
        timeInLineTextLayout.setVisibility(VISIBLE);
        timeInLineTextLayout.setText("");
        applyCustomConfig();
    }

    protected void applyCustomConfig() {
        if (isLayoutOnStart) {
            int sendTextMessageColor = TUIChatConfigMinimalist.getSendTextMessageColor();
            if (sendTextMessageColor != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextColor(sendTextMessageColor);
            }
            int sendTextMessageFontSize = TUIChatConfigMinimalist.getSendTextMessageFontSize();
            if (sendTextMessageFontSize != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextSize(sendTextMessageFontSize);
            }
        } else {
            int receiveTextMessageColor = TUIChatConfigMinimalist.getReceiveTextMessageColor();
            if (receiveTextMessageColor != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextColor(receiveTextMessageColor);
            }
            int receiveTextMessageFontSize = TUIChatConfigMinimalist.getReceiveTextMessageFontSize();
            if (receiveTextMessageFontSize != TUIChatConfigMinimalist.UNDEFINED) {
                timeInLineTextLayout.setTextSize(receiveTextMessageFontSize);
            }
        }
    }
}
