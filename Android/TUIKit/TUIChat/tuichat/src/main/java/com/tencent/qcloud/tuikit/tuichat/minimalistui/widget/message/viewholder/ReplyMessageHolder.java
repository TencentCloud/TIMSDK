package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

public class ReplyMessageHolder extends MessageContentHolder {
    private View originMsgLayout;

    private TextView senderNameTv;
    private FrameLayout quoteFrameLayout;

    public ReplyMessageHolder(View itemView) {
        super(itemView);
        senderNameTv = itemView.findViewById(R.id.sender_tv);
        originMsgLayout = itemView.findViewById(R.id.origin_msg_abs_layout);
        quoteFrameLayout = itemView.findViewById(R.id.quote_frame_layout);
        timeInLineTextLayout = itemView.findViewById(R.id.time_in_line_text);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_message_adapter_content_reply;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msg.setSelectText(msg.getExtra());
        timeInLineTextLayout.setTextSize(14);
        timeInLineTextLayout.setTextColor(0xFF000000);
        ReplyMessageBean replyMessageBean = (ReplyMessageBean) msg;
        TUIMessageBean replyContentBean = replyMessageBean.getContentMessageBean();
        String replyContent = replyContentBean.getExtra();
        String senderName = replyMessageBean.getOriginMsgSender();
        senderNameTv.setText(senderName + ":");

        performMsgAbstract(replyMessageBean, position);
        if (!TextUtils.isEmpty(replyContent)) {
            FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), replyContent, false);
        }
    }

    @Override
    protected void setGravity(boolean isStart) {
        super.setGravity(isStart);
    }

    private void performMsgAbstract(ReplyMessageBean replyMessageBean, int position) {
        TUIMessageBean originMessage = replyMessageBean.getOriginMessageBean();

        TUIReplyQuoteBean replyQuoteBean = replyMessageBean.getReplyQuoteBean();
        if (originMessage != null) {
            performReply(replyQuoteBean, replyMessageBean);
        } else {
            performNotFound(replyQuoteBean, replyMessageBean);
        }

        originMsgLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onReplyMessageClick(v, position, replyMessageBean);
                }
            }
        });

        originMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageLongClick(msgArea, position, replyMessageBean);
                }
                return true;
            }
        });
    }

    private void performNotFound(TUIReplyQuoteBean replyQuoteBean, ReplyMessageBean replyMessageBean) {
        String typeStr = ChatMessageParser.getMsgTypeStr(replyQuoteBean.getMessageType());
        String abstractStr = replyQuoteBean.getDefaultAbstract();
        if (ChatMessageParser.isFileType(replyQuoteBean.getMessageType())) {
            abstractStr = "";
        }
        TextReplyQuoteBean textReplyQuoteBean = new TextReplyQuoteBean();
        textReplyQuoteBean.setText(typeStr + abstractStr);
        TextReplyQuoteView textReplyQuoteView = new TextReplyQuoteView(itemView.getContext());
        textReplyQuoteView.onDrawReplyQuote(textReplyQuoteBean);
        if (isForwardMode || isMessageDetailMode) {
            textReplyQuoteView.setSelf(false);
        } else {
            textReplyQuoteView.setSelf(replyMessageBean.isSelf());
        }
        quoteFrameLayout.removeAllViews();
        quoteFrameLayout.addView(textReplyQuoteView);
    }

    private void performReply(TUIReplyQuoteBean replyQuoteBean, ReplyMessageBean replyMessageBean) {
        Class<? extends TUIReplyQuoteView> quoteViewClass = MinimalistUIService.getInstance().getReplyMessageViewClass(replyQuoteBean.getClass());
        if (quoteViewClass != null) {
            TUIReplyQuoteView quoteView = null;
            try {
                Constructor quoteViewConstructor = quoteViewClass.getConstructor(Context.class);
                quoteView = (TUIReplyQuoteView) quoteViewConstructor.newInstance(itemView.getContext());
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
            if (quoteView != null) {
                quoteView.onDrawReplyQuote(replyQuoteBean);
                quoteFrameLayout.removeAllViews();
                quoteFrameLayout.addView(quoteView);
                if (isForwardMode || isMessageDetailMode) {
                    quoteView.setSelf(false);
                } else {
                    quoteView.setSelf(replyMessageBean.isSelf());
                }
            }
        }
    }
}
