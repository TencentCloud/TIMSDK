package com.tencent.qcloud.tuikit.tuichat.minimalistui;

import android.content.Context;

import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.LocationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MessageTypingBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextAtMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomEvaluationMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomLinkReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomOrderMessageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FaceReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.LocationReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.MergeReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ReplyReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.SoundReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.VideoReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.FaceReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.FileReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.ImageReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.LocationReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.MergeReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.SoundReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.TextReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.VideoReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CallingMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomEvaluationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomLinkMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.CustomOrderMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.FaceMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.FileMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.LocationMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MergeMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.QuoteMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ReplyMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.SoundMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.TextMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.TipsMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.VideoMessageHolder;

import java.util.HashMap;
import java.util.Map;

/**
 * Internal service for MinimalistUI
 */
public class MinimalistUIService extends ServiceInitializer {
    private static MinimalistUIService instance;

    public static MinimalistUIService getInstance() {
        return instance;
    }

    private final Map<Class<? extends TUIMessageBean>, Integer> messageViewTypeMap = new HashMap<>();
    private final Map<Integer, Class<? extends MessageBaseHolder>> messageViewHolderMap = new HashMap<>();
    private final Map<Class<? extends TUIReplyQuoteBean>, Class<? extends TUIReplyQuoteView>> replyMessageViewMap = new HashMap<>();
    private int viewType = 0;

    @Override
    public void init(Context context) {
        instance = this;
        initMessage();
        initReplyMessage();
    }

    public void initMessage() {
        addMessageType(FaceMessageBean.class, FaceMessageHolder.class);
        addMessageType(FileMessageBean.class, FileMessageHolder.class);
        addMessageType(ImageMessageBean.class, ImageMessageHolder.class);
        addMessageType(LocationMessageBean.class, LocationMessageHolder.class);
        addMessageType(MergeMessageBean.class, MergeMessageHolder.class);
        addMessageType(SoundMessageBean.class, SoundMessageHolder.class);
        addMessageType(TextAtMessageBean.class, TextMessageHolder.class);
        addMessageType(TextMessageBean.class, TextMessageHolder.class);
        addMessageType(TipsMessageBean.class, TipsMessageHolder.class);
        addMessageType(VideoMessageBean.class, VideoMessageHolder.class);
        addMessageType(ReplyMessageBean.class, ReplyMessageHolder.class);
        addMessageType(QuoteMessageBean.class, QuoteMessageHolder.class);
        addMessageType(CallingMessageBean.class, CallingMessageHolder.class);
        addMessageType(CustomLinkMessageBean.class, CustomLinkMessageHolder.class);
        addMessageType(CustomEvaluationMessageBean.class, CustomEvaluationMessageHolder.class);
        addMessageType(CustomOrderMessageBean.class, CustomOrderMessageHolder.class);
        addMessageType(MessageTypingBean.class, null);
    }

    private void addMessageType(Class<? extends TUIMessageBean> beanClazz, Class<? extends MessageBaseHolder> holderClazz) {
        viewType++;
        messageViewTypeMap.put(beanClazz, viewType);
        messageViewHolderMap.put(viewType, holderClazz);
    }

    private void initReplyMessage() {
        replyMessageViewMap.put(CustomEvaluationMessageReplyQuoteBean.class, TextReplyQuoteView.class);
        replyMessageViewMap.put(CustomLinkReplyQuoteBean.class, TextReplyQuoteView.class);
        replyMessageViewMap.put(CustomOrderMessageReplyQuoteBean.class, TextReplyQuoteView.class);
        replyMessageViewMap.put(FaceReplyQuoteBean.class, FaceReplyQuoteView.class);
        replyMessageViewMap.put(FileReplyQuoteBean.class, FileReplyQuoteView.class);
        replyMessageViewMap.put(ImageReplyQuoteBean.class, ImageReplyQuoteView.class);
        replyMessageViewMap.put(LocationReplyQuoteBean.class, LocationReplyQuoteView.class);
        replyMessageViewMap.put(MergeReplyQuoteBean.class, MergeReplyQuoteView.class);
        replyMessageViewMap.put(ReplyReplyQuoteBean.class, TextReplyQuoteView.class);
        replyMessageViewMap.put(SoundReplyQuoteBean.class, SoundReplyQuoteView.class);
        replyMessageViewMap.put(TextReplyQuoteBean.class, TextReplyQuoteView.class);
        replyMessageViewMap.put(VideoReplyQuoteBean.class, VideoReplyQuoteView.class);
    }

    public Class<? extends TUIReplyQuoteView> getReplyMessageViewClass(Class<? extends TUIReplyQuoteBean> replyQuoteBeanType) {
        return replyMessageViewMap.get(replyQuoteBeanType);
    }

    public Class<? extends MessageBaseHolder> getMessageViewHolderClass(int viewType) {
        return messageViewHolderMap.get(viewType);
    }

    public int getViewType(Class<? extends TUIMessageBean> messageBeanClass) {
        Integer viewType = messageViewTypeMap.get(messageBeanClass);
        if (viewType != null) {
            return viewType;
        } else {
            return 0;
        }
    }

    @Override
    public int getLightThemeResId() {
        return R.style.TUIChatLightTheme;
    }

    @Override
    public int getLivelyThemeResId() {
        return R.style.TUIChatLivelyTheme;
    }

    @Override
    public int getSeriousThemeResId() {
        return R.style.TUIChatSeriousTheme;
    }
}
