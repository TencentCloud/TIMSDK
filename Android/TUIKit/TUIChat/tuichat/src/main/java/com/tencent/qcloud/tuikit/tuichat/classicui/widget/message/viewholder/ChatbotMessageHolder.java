package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import static android.view.View.VISIBLE;
import static com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils.getWaitingSpan;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.face.CenterImageSpan;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ChatbotMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;

public class ChatbotMessageHolder extends MessageContentHolder {
    protected TextView msgBodyText;
    private View.OnClickListener onTextClickListener;
    private final GestureDetector gestureDetector;

    public ChatbotMessageHolder(View itemView) {
        super(itemView);
        msgBodyText = itemView.findViewById(R.id.msg_body_tv);
        gestureDetector = new GestureDetector(itemView.getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (onTextClickListener != null) {
                    onTextClickListener.onClick(msgBodyText);
                }
                return super.onSingleTapUp(e);
            }
        });
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_text;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof ChatbotMessageBean)) {
            return;
        }
        if (hasRiskContent) {
            setRiskContent(itemView.getResources().getString(R.string.chat_risk_send_message_failed_alert));
        }
        ChatbotMessageBean chatbotMessageBean = (ChatbotMessageBean) msg;

        if (isForwardMode || isReplyDetailMode || !chatbotMessageBean.isSelf()) {
            int otherTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_other_msg_text_color);
            int otherTextColor = msgBodyText.getResources().getColor(otherTextColorResId);
            msgBodyText.setTextColor(otherTextColor);
        } else {
            int selfTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_self_msg_text_color);
            int selfTextColor = msgBodyText.getResources().getColor(selfTextColorResId);
            msgBodyText.setTextColor(selfTextColor);
        }

        msgBodyText.setVisibility(VISIBLE);

        applyCustomConfig();

        if (chatbotMessageBean.getText() != null) {
            msgBodyText.setText(chatbotMessageBean.getText());
            if (!chatbotMessageBean.isFinished()) {
                msgBodyText.append(getWaitingSpan(msgBodyText.getContext()));
            }
        } else {
            FaceManager.handlerEmojiText(msgBodyText, TUIChatService.getAppContext().getString(R.string.no_support_msg), false);
        }
        TextUtil.linkifyUrls(msgBodyText);
        msgBodyText.setActivated(true);
        if (isForwardMode || isReplyDetailMode) {
            return;
        }

        if (!chatbotMessageBean.isFinished()) {
            setOnItemClickListener(null);
            msgArea.setOnLongClickListener(null);
            msgBodyText.setOnTouchListener(null);
            setTextClickListener(null);
        } else {
            setSelectionHelper(msg, msgBodyText, position);
            msgBodyText.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    return gestureDetector.onTouchEvent(event);
                }
            });

            msgArea.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (selectionHelper != null) {
                        selectionHelper.selectAll();
                    }
                    return true;
                }
            });

            setTextClickListener((v) -> {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(v, msg);
                }
            });
        }
    }

    protected void setTextClickListener(View.OnClickListener listener) {
        this.onTextClickListener = listener;
    }

    protected void applyCustomConfig() {
        if (isLayoutOnStart) {
            int receiveTextMessageColor = TUIChatConfigClassic.getReceiveTextMessageColor();
            if (receiveTextMessageColor != TUIChatConfigClassic.UNDEFINED) {
                msgBodyText.setTextColor(receiveTextMessageColor);
            }
            int receiveTextMessageFontSize = TUIChatConfigClassic.getReceiveTextMessageFontSize();
            if (receiveTextMessageFontSize != TUIChatConfigClassic.UNDEFINED) {
                msgBodyText.setTextSize(receiveTextMessageFontSize);
            }
        } else {
            int sendTextMessageColor = TUIChatConfigClassic.getSendTextMessageColor();
            if (sendTextMessageColor != TUIChatConfigClassic.UNDEFINED) {
                msgBodyText.setTextColor(sendTextMessageColor);
            }
            int sendTextMessageFontSize = TUIChatConfigClassic.getSendTextMessageFontSize();
            if (sendTextMessageFontSize != TUIChatConfigClassic.UNDEFINED) {
                msgBodyText.setTextSize(sendTextMessageFontSize);
            }
        }
    }
}
