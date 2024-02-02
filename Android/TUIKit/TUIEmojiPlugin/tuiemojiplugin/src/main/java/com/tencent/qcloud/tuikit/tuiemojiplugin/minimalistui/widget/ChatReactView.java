package com.tencent.qcloud.tuikit.tuiemojiplugin.minimalistui.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuiemojiplugin.R;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.common.widget.ChatReactDialogFragment;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.ReactPreviewView;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionPreviewPresenter;

import java.util.ArrayList;

public class ChatReactView extends FrameLayout implements ReactPreviewView {
    private static final int EMOJI_LIMIT = 5;
    private LinearLayoutManager layoutManager;
    private TextView reactNumText;
    private View moreIcon;
    private RecyclerView reactRecyclerView;
    private ChatReactAdapter adapter;
    private MessageReactionPreviewPresenter presenter;
    private TUIMessageBean messageBean;

    public ChatReactView(@NonNull Context context) {
        super(context);
        initView();
    }

    public ChatReactView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public ChatReactView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        presenter = new MessageReactionPreviewPresenter();
        presenter.setReactPreviewView(this);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.chat_minimalist_react_preview_layout, this);
        reactRecyclerView = view.findViewById(R.id.reacts_emoji_list);
        reactNumText = view.findViewById(R.id.reacts_num_text);
        moreIcon = view.findViewById(R.id.more_icon);
        layoutManager = new LinearLayoutManager(getContext());
        layoutManager.setOrientation(RecyclerView.HORIZONTAL);
        reactRecyclerView.setLayoutManager(layoutManager);
        adapter = new ChatReactAdapter();
        reactRecyclerView.setAdapter(adapter);
    }

    public void setData(MessageReactionBean messageReactionBean) {
        setVisibility(VISIBLE);
        int num = messageReactionBean.getReactionCount();
        int allReactionsUserNum = 0;
        for (ReactionBean reactionBean : messageReactionBean.getMessageReactionBeanMap().values()) {
            allReactionsUserNum += reactionBean.getTotalUserCount();
        }
        reactNumText.setText(allReactionsUserNum + "");
        if (num > EMOJI_LIMIT) {
            moreIcon.setVisibility(VISIBLE);
        } else {
            moreIcon.setVisibility(GONE);
        }
        if (num <= 0) {
            setVisibility(GONE);
            return;
        } else {
            setVisibility(VISIBLE);
        }
        if (adapter != null) {
            adapter.setData(messageReactionBean);
            adapter.notifyDataSetChanged();
        }
        OnClickListener onClickListener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                showReactionDetailDialog();
            }
        };
        setOnClickListener(onClickListener);
        adapter.clickListener = onClickListener;
    }

    private void showReactionDetailDialog() {
        ChatReactDialogFragment fragment = new ChatReactDialogFragment();
        fragment.setMessageBean(messageBean);
        Context context = getContext();
        FragmentManager fragmentManager = null;
        if (context instanceof AppCompatActivity) {
            fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
        }
        if (fragmentManager != null) {
            fragment.show(fragmentManager, "ReactionDetailDialog");
        }
    }

    @Override
    public TUIMessageBean getMessageBean() {
        return messageBean;
    }

    @Override
    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public void setPresenter(MessageReactionPreviewPresenter presenter) {
        this.presenter = presenter;
    }

    public MessageReactionPreviewPresenter getPresenter() {
        return presenter;
    }

    static class ChatReactAdapter extends RecyclerView.Adapter<ChatReactViewHolder> {
        private MessageReactionBean data;
        private OnClickListener clickListener;

        public void setData(MessageReactionBean data) {
            this.data = data;
        }

        @NonNull
        @Override
        public ChatReactViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_minimalist_react_item_layout, parent, false);
            return new ChatReactViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ChatReactViewHolder holder, int position) {
            ReactionBean reactionBean = new ArrayList<>(data.getMessageReactionBeanMap().values()).get(position);
            String emojiId = reactionBean.getReactionID();
            Bitmap bitmap = FaceManager.getEmoji(emojiId);
            holder.faceImageView.setImageBitmap(bitmap);
            holder.itemView.setOnClickListener(clickListener);
        }

        @Override
        public int getItemCount() {
            if (data != null) {
                return Math.min(data.getReactionCount(), EMOJI_LIMIT);
            }
            return 0;
        }
    }

    static class ChatReactViewHolder extends RecyclerView.ViewHolder {
        public ImageView faceImageView;

        public ChatReactViewHolder(@NonNull View itemView) {
            super(itemView);
            faceImageView = itemView.findViewById(R.id.face_iv);
        }
    }
}
