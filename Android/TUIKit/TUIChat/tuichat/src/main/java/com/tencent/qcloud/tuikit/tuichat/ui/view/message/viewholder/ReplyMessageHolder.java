package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

public class ReplyMessageHolder extends MessageContentHolder {

    private View originMsgLayout;

    private TextView senderNameTv;
    private TextView replyContentTv;
    private FrameLayout quoteFrameLayout;

    public ReplyMessageHolder(View itemView) {
        super(itemView);
        senderNameTv = itemView.findViewById(R.id.sender_tv);
        replyContentTv = itemView.findViewById(R.id.reply_content_tv);
        originMsgLayout = itemView.findViewById(R.id.origin_msg_abs_layout);
        quoteFrameLayout = itemView.findViewById(R.id.quote_frame_layout);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_reply;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        ReplyMessageBean replyMessageBean = (ReplyMessageBean) msg;
        TUIMessageBean replyContentBean = replyMessageBean.getContentMessageBean();
        String replyContent = replyContentBean.getExtra();
        String senderName = replyMessageBean.getOriginMsgSender();
        senderNameTv.setText(senderName + ":");
        FaceManager.handlerEmojiText(replyContentTv, replyContent, false);

        performMsgAbstract(replyMessageBean, position);

        msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(view, position, msg);
                }
                return true;
            }
        });
        originMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(v, position, msg);
                }
                return true;
            }
        });
    }

    private void performMsgAbstract(ReplyMessageBean replyMessageBean, int position) {
        TUIMessageBean originMessage = replyMessageBean.getOriginMessageBean();

        TUIReplyQuoteBean replyQuoteBean = replyMessageBean.getReplyQuoteBean();
        if (originMessage != null) {
            performQuote(replyQuoteBean);
        } else {
            performNotFound(replyQuoteBean);
        }

        originMsgLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onReplyMessageClick(v, position, replyMessageBean.getOriginMsgId());
                }
            }
        });

    }

    private void performNotFound(TUIReplyQuoteBean replyQuoteBean) {
        String typeStr = ChatMessageParser.getMsgTypeStr(replyQuoteBean.getMessageType());
        String abstractStr = replyQuoteBean.getDefaultAbstract();
        if (ChatMessageParser.isFileType(replyQuoteBean.getMessageType())) {
            abstractStr = "";
        }
        TextReplyQuoteBean textReplyQuoteBean = new TextReplyQuoteBean();
        textReplyQuoteBean.setText(typeStr + abstractStr);
        TextReplyQuoteView textReplyQuoteView = new TextReplyQuoteView(itemView.getContext());
        textReplyQuoteView.onDrawReplyQuote(textReplyQuoteBean);
        quoteFrameLayout.removeAllViews();
        quoteFrameLayout.addView(textReplyQuoteView);
    }

    private void performQuote(TUIReplyQuoteBean replyQuoteBean) {
        Class<? extends TUIReplyQuoteView> quoteViewClass = replyQuoteBean.getReplyQuoteViewClass();
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
            }
        }
    }
}
