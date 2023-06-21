package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.content.Context;
import android.content.res.Resources;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.ClassicUIService;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

public class ReplyMessageHolder extends MessageContentHolder {
    private View originMsgLayout;

    private TextView senderNameTv;
    private TextView replyContentTv;
    private FrameLayout quoteFrameLayout;
    private LinearLayout replyContainer;
    private View line;

    public ReplyMessageHolder(View itemView) {
        super(itemView);
        senderNameTv = itemView.findViewById(R.id.sender_tv);
        replyContainer = itemView.findViewById(R.id.reply_container);
        replyContentTv = itemView.findViewById(R.id.reply_content_tv);
        originMsgLayout = itemView.findViewById(R.id.origin_msg_abs_layout);
        quoteFrameLayout = itemView.findViewById(R.id.quote_frame_layout);
        line = itemView.findViewById(R.id.reply_line);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_reply;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msg.setSelectText(msg.getExtra());

        ReplyMessageBean replyMessageBean = (ReplyMessageBean) msg;
        TUIMessageBean replyContentBean = replyMessageBean.getContentMessageBean();
        String replyContent = replyContentBean.getExtra();
        String senderName = replyMessageBean.getOriginMsgSender();
        senderNameTv.setText(senderName + ":");
        FaceManager.handlerEmojiText(replyContentTv, replyContent, false);

        performMsgAbstract(replyMessageBean, position);

        msgArea.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                selectableTextHelper.selectAll();
                return true;
            }
        });

        msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                selectableTextHelper.selectAll();
                return true;
            }
        });

        originMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                selectableTextHelper.selectAll();
                return true;
            }
        });

        setThemeColor(msg);
        if (isForwardMode || isReplyDetailMode) {
            return;
        }
        boolean isEmoji = false;
        if (!TextUtils.isEmpty(replyContent)) {
            isEmoji = FaceManager.handlerEmojiText(replyContentTv, replyContent, false);
        }
        setSelectableTextHelper(msg, replyContentTv, position, isEmoji);
    }

    @Override
    protected void setGravity(boolean isStart) {
        super.setGravity(isStart);
    }

    private void setThemeColor(TUIMessageBean messageBean) {
        Context context = itemView.getContext();
        Resources resources = itemView.getResources();
        if (isReplyDetailMode || isForwardMode || !messageBean.isSelf()) {
            originMsgLayout.setBackgroundColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_other_reply_quote_bg_color)));
            senderNameTv.setTextColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_other_reply_quote_text_color)));
            replyContentTv.setTextColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_other_reply_text_color)));
            line.setBackgroundColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_other_reply_line_bg_color)));
        } else {
            originMsgLayout.setBackgroundColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_self_reply_quote_bg_color)));
            senderNameTv.setTextColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_self_reply_quote_text_color)));
            replyContentTv.setTextColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_self_reply_text_color)));
            line.setBackgroundColor(resources.getColor(TUIThemeManager.getAttrResId(context, R.attr.chat_self_reply_line_bg_color)));
        }
    }

    private void performMsgAbstract(ReplyMessageBean replyMessageBean, int position) {
        TUIMessageBean originMessage = replyMessageBean.getOriginMessageBean();

        TUIReplyQuoteBean replyQuoteBean = replyMessageBean.getReplyQuoteBean();
        if (originMessage != null) {
            performQuote(replyQuoteBean, replyMessageBean);
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
        if (isForwardMode || isReplyDetailMode) {
            textReplyQuoteView.setSelf(false);
        } else {
            textReplyQuoteView.setSelf(replyMessageBean.isSelf());
        }
        quoteFrameLayout.removeAllViews();
        quoteFrameLayout.addView(textReplyQuoteView);
    }

    private void performQuote(TUIReplyQuoteBean replyQuoteBean, ReplyMessageBean replyMessageBean) {
        Class<? extends TUIReplyQuoteView> quoteViewClass = ClassicUIService.getInstance().getReplyMessageViewClass(replyQuoteBean.getClass());
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
                if (isForwardMode || isReplyDetailMode) {
                    quoteView.setSelf(false);
                } else {
                    quoteView.setSelf(replyMessageBean.isSelf());
                }
            }
        }
    }
}
