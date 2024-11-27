package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.text.TextUtils;
import android.view.View;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;

public class TextMessageHolder extends MessageContentHolder {
    public TextMessageHolder(View itemView) {
        super(itemView);
        timeInLineTextLayout = itemView.findViewById(R.id.text_message_layout);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_minimalist_message_adapter_content_text;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof TextMessageBean)) {
            return;
        }
        TextMessageBean textMessageBean = (TextMessageBean) msg;
        textMessageBean.setSelectText(textMessageBean.getText());

        applyCustomConfig();

        setOnTimeInLineTextClickListener(textMessageBean);
        if (textMessageBean.getText() != null) {
            FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), textMessageBean.getText(), false);
        } else if (!TextUtils.isEmpty(textMessageBean.getExtra())) {
            FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), textMessageBean.getExtra(), false);
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
