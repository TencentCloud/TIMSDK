package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TimeInLineTextLayout;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReplyDetailsView extends RecyclerView {
    private ReplyDetailsAdapter adapter;
    private LinearLayoutManager layoutManager;
    private FrameLayout translationContentFrameLayout;
    private Fragment fragment;

    public ReplyDetailsView(@NonNull Context context) {
        super(context);
        initView();
    }

    public ReplyDetailsView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public ReplyDetailsView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        layoutManager = new LinearLayoutManager(getContext());
        setLayoutManager(layoutManager);
        adapter = new ReplyDetailsAdapter();
        setAdapter(adapter);
    }

    public void setData(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap) {
        adapter.setData(messageBeanMap);
        adapter.notifyDataSetChanged();
    }

    public void setFragment(Fragment fragment) {
        this.fragment = fragment;
    }

    public class ReplyDetailsAdapter extends Adapter<ReplyDetailsViewHolder> {
        Map<MessageRepliesBean.ReplyBean, TUIMessageBean> data;

        public void setData(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap) {
            this.data = messageBeanMap;
        }

        @NonNull
        @Override
        public ReplyDetailsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_minimalist_reply_details_item_layout, parent, false);
            translationContentFrameLayout = view.findViewById(R.id.translate_content_fl);
            return new ReplyDetailsViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ReplyDetailsViewHolder holder, int position) {
            List<MessageRepliesBean.ReplyBean> replyBeanList = new ArrayList<>(data.keySet());
            MessageRepliesBean.ReplyBean replyBean = replyBeanList.get(position);
            TUIMessageBean messageBean = data.get(replyBean);
            String messageText;
            String faceUrl;
            if (messageBean == null) {
                messageText = replyBean.getMessageAbstract();
                faceUrl = replyBean.getSenderFaceUrl();
            } else {
                messageText = messageBean.getExtra();
                faceUrl = messageBean.getFaceUrl();
                holder.timeInLineTextLayout.setTimeText(DateTimeUtil.getTimeFormatText(new Date(messageBean.getMessageTime() * 1000)));
            }
            Glide.with(holder.itemView.getContext())
                .load(faceUrl)
                .apply(new RequestOptions().error(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_default_user_icon_light))
                .into(holder.userFaceView);
            FaceManager.handlerEmojiText(holder.timeInLineTextLayout.getTextView(), messageText, false);

            setTranslationContent(messageBean);

            optimizeBackgroundAndAvatar(holder, replyBeanList, position);
        }

        void optimizeBackgroundAndAvatar(ReplyDetailsViewHolder holder, List<MessageRepliesBean.ReplyBean> replyBeanList, int position) {
            boolean isShowAvatar = true;
            MessageRepliesBean.ReplyBean nextReplyBean = null;
            MessageRepliesBean.ReplyBean replyBean = replyBeanList.get(position);
            if (replyBeanList.size() > position + 1) {
                nextReplyBean = replyBeanList.get(position + 1);
            }
            String sender = replyBean.getMessageSender();
            if (nextReplyBean != null) {
                String nextSender = nextReplyBean.getMessageSender();
                if (TextUtils.equals(sender, nextSender)) {
                    isShowAvatar = false;
                }
            }
            int horizontalPadding = ScreenUtil.dip2px(36);
            int verticalPadding = ScreenUtil.dip2px(20f);
            if (isShowAvatar) {
                holder.userFaceView.setVisibility(View.VISIBLE);
                holder.msgContent.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.chat_message_popup_stroke_border_left);
            } else {
                horizontalPadding = ScreenUtil.dip2px(36);
                verticalPadding = ScreenUtil.dip2px(2);
                holder.userFaceView.setVisibility(View.INVISIBLE);
                holder.msgContent.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.chat_message_popup_stroke_border);
            }
            holder.itemView.setPadding(0, 0, horizontalPadding, verticalPadding);
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }
    }

    private void setTranslationContent(TUIMessageBean msg) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.MESSAGE_BEAN, msg);
        param.put(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW, ReplyDetailsView.this);

        TUICore.raiseExtension(TUIConstants.TUITranslationPlugin.Extension.TranslationView.CLASSIC_EXTENSION_ID, translationContentFrameLayout, param);
    }

    static class ReplyDetailsViewHolder extends RecyclerView.ViewHolder {
        public ImageView userFaceView;
        public View msgContent;
        public TimeInLineTextLayout timeInLineTextLayout;

        public ReplyDetailsViewHolder(View itemView) {
            super(itemView);
            userFaceView = itemView.findViewById(R.id.user_icon);
            timeInLineTextLayout = itemView.findViewById(R.id.time_in_line_text);
            msgContent = itemView.findViewById(R.id.msg_content);
        }
    }
}
