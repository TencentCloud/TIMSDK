package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;

public class TextMessageHolder extends MessageContentHolder {
    protected TextView msgBodyText;

    public TextMessageHolder(View itemView) {
        super(itemView);
        msgBodyText = itemView.findViewById(R.id.msg_body_tv);
        msgBodyText.setTextIsSelectable(true);
        msgBodyText.setHighlightColor(itemView.getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.timcommon_text_highlight_color));
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_text;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof TextMessageBean)) {
            return;
        }
        if (hasRiskContent) {
            setRiskContent(itemView.getResources().getString(R.string.chat_risk_send_message_failed_alert));
        }
        TextMessageBean textMessageBean = (TextMessageBean) msg;

        if (isForwardMode || isReplyDetailMode || !textMessageBean.isSelf()) {
            int otherTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_other_msg_text_color);
            int otherTextColor = msgBodyText.getResources().getColor(otherTextColorResId);
            msgBodyText.setTextColor(otherTextColor);
        } else {
            int selfTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_self_msg_text_color);
            int selfTextColor = msgBodyText.getResources().getColor(selfTextColorResId);
            msgBodyText.setTextColor(selfTextColor);
        }

        msgBodyText.setVisibility(View.VISIBLE);

        if (properties.getChatContextFontSize() != 0) {
            msgBodyText.setTextSize(properties.getChatContextFontSize());
        }
        if (textMessageBean.isSelf()) {
            if (properties.getRightChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getRightChatContentFontColor());
            }
        } else {
            if (properties.getLeftChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getLeftChatContentFontColor());
            }
        }

        msgArea.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (selectableTextHelper != null) {
                    selectableTextHelper.selectAll();
                }
                return true;
            }
        });
        if (textMessageBean.getText() != null) {
            FaceManager.handlerEmojiText(msgBodyText, textMessageBean.getText(), false);
        } else if (!TextUtils.isEmpty(textMessageBean.getExtra())) {
            FaceManager.handlerEmojiText(msgBodyText, textMessageBean.getExtra(), false);
        } else {
            FaceManager.handlerEmojiText(msgBodyText, TUIChatService.getAppContext().getString(R.string.no_support_msg), false);
        }
        if (isForwardMode || isReplyDetailMode) {
            return;
        }
        setSelectableTextHelper(msg, msgBodyText, position);

        msgBodyText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(v, textMessageBean);
                }
            }
        });
    }
}
