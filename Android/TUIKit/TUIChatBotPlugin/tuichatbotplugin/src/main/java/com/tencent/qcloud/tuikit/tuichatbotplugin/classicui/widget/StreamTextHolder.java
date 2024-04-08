package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.os.Handler;
import android.text.TextUtils;
import android.view.View;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.StreamTextMessageBean;

public class StreamTextHolder extends TextMessageHolder {
    private Handler handler;
    private Runnable runnable;

    public StreamTextHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return super.getVariableLayout();
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        StreamTextMessageBean streamTextMessageBean = (StreamTextMessageBean)msg;

        if (streamTextMessageBean.getMessageSource() != TUIMessageBean.MSG_SOURCE_ONLINE_PUSH) {
            streamTextMessageBean.setExtra(streamTextMessageBean.getContent());
            streamTextMessageBean.setDisplayedContentLength(streamTextMessageBean.getContent().length());
            refreshUI(msg, position);
            return;
        }

        int repeatTime = 50;
        if (handler == null) {
            handler = new Handler();
        }

        if (runnable == null) {
            runnable = new Runnable() {
                @Override
                public void run() {
                    String content = streamTextMessageBean.getContent();
                    int displayedContentLength = streamTextMessageBean.getDisplayedContentLength();
                    if (displayedContentLength >= content.length()) {
                        return;
                    }

                    displayedContentLength++;
                    streamTextMessageBean.setDisplayedContentLength(displayedContentLength);
                    String displayedContent = content.substring(0, displayedContentLength);
                    streamTextMessageBean.setExtra(displayedContent);
                    refreshUI(msg, position);

                    
                    MessageRecyclerView messageRecyclerView = (MessageRecyclerView)getRecyclerView();
                    boolean canScrolledToBottom = messageRecyclerView.canScrollVertically(1);
                    
                    if (!canScrolledToBottom && position == (messageRecyclerView.getAdapter().getItemCount() - 1)) {
                        ((MessageRecyclerView)getRecyclerView()).scrollToEnd();
                    }

                    handler.postDelayed(this, repeatTime);
                }
            };
        }

        handler.removeCallbacks(runnable);
        handler.postDelayed(runnable, repeatTime);
    }

    private void refreshUI(TUIMessageBean msg, int position) {
        if (!(msg instanceof TextMessageBean)) {
            return;
        }
        if (hasRiskContent) {
            setRiskContent(itemView.getResources().getString(com.tencent.qcloud.tuikit.tuichat.R.string.chat_risk_send_message_failed_alert));
        }
        TextMessageBean textMessageBean = (TextMessageBean) msg;

        if (isForwardMode || isReplyDetailMode || !textMessageBean.isSelf()) {
            int otherTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(),
                    com.tencent.qcloud.tuikit.tuichat.R.attr.chat_other_msg_text_color);
            int otherTextColor = msgBodyText.getResources().getColor(otherTextColorResId);
            msgBodyText.setTextColor(otherTextColor);
        } else {
            int selfTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), com.tencent.qcloud.tuikit.tuichat.R.attr.chat_self_msg_text_color);
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
            FaceManager.handlerEmojiText(msgBodyText, TUIChatService.getAppContext().getString(com.tencent.qcloud.tuikit.tuichat.R.string.no_support_msg), false);
        }
        if (isForwardMode || isReplyDetailMode) {
            return;
        }
        setSelectableTextHelper(msg, msgBodyText, position);
    }
}
