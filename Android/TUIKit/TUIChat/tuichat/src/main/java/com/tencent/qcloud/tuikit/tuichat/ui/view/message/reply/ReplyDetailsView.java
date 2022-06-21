package com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.gatherimage.UserIconView;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class ReplyDetailsView extends RecyclerView {
    private ReplyDetailsAdapter adapter;
    private LinearLayoutManager layoutManager;

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

    public static class ReplyDetailsAdapter extends Adapter<ReplyDetailsViewHolder>{
        Map<MessageRepliesBean.ReplyBean, TUIMessageBean> data;

        public void setData(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap) {
            this.data = messageBeanMap;
        }

        @NonNull
        @Override
        public ReplyDetailsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_reply_details_item_layout, parent, false);
            return new ReplyDetailsViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ReplyDetailsViewHolder holder, int position) {
            MessageRepliesBean.ReplyBean replyBean = new ArrayList<>(data.keySet()).get(position);
            TUIMessageBean messageBean = data.get(replyBean);
            String userName;
            String messageText;
            List<Object> iconList = new ArrayList<>();
            if (messageBean == null) {
                userName = replyBean.getMessageSender();
                messageText = replyBean.getMessageAbstract();
            } else {
                messageText = messageBean.getExtra();
                userName = messageBean.getUserDisplayName();
                iconList.add(messageBean.getFaceUrl());
                holder.timeText.setText(DateTimeUtil.getTimeFormatText(new Date(messageBean.getMessageTime() * 1000)));
            }
            holder.userFaceView.setIconUrls(iconList);
            holder.userNameTv.setText(userName);
            FaceManager.handlerEmojiText(holder.messageText, messageText, false);

        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }
    }

    static class ReplyDetailsViewHolder extends ViewHolder {
        public UserIconView userFaceView;
        protected TextView userNameTv;
        protected TextView messageText;
        protected TextView timeText;

        public ReplyDetailsViewHolder(View itemView) {
            super(itemView);
            userFaceView = itemView.findViewById(R.id.user_icon);
            userNameTv = itemView.findViewById(R.id.user_name_tv);
            messageText = itemView.findViewById(R.id.msg_abstract);
            timeText = itemView.findViewById(R.id.msg_time);
        }
    }
}
