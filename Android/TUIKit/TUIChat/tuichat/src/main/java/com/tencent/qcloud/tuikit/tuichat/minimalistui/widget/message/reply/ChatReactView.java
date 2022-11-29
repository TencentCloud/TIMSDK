package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

public class ChatReactView extends FrameLayout {

    private static final int EMOJI_LIMIT = 5;
    private LinearLayoutManager layoutManager;
    private TextView reactNumText;
    private View moreIcon;
    private RecyclerView reactRecyclerView;
    private ChatReactAdapter adapter;
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

    public void setData(MessageReactBean reactBean) {
        Map<String, Set<String>> reactsMap = reactBean.getReacts();
        int num = 0;
        for (Set<String> strings : reactsMap.values()) {
            num += strings.size();
        }
        reactNumText.setText(num + "");
        if (num > EMOJI_LIMIT) {
            moreIcon.setVisibility(VISIBLE);
        } else {
            moreIcon.setVisibility(GONE);
        }
        if (adapter != null) {
            adapter.setData(reactBean);
            adapter.notifyDataSetChanged();
        }
    }

    static class ChatReactAdapter extends RecyclerView.Adapter<ChatReactViewHolder> {
        private MessageReactBean data;

        public void setData(MessageReactBean data) {
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
            Map.Entry<String, Set<String>> entry = new ArrayList<>(data.getReacts().entrySet()).get(position);
            String emojiId = entry.getKey();
            Bitmap bitmap = FaceManager.getEmoji(emojiId);
            holder.faceImageView.setImageBitmap(bitmap);
        }

        @Override
        public int getItemCount() {
            if (data != null) {
                return Math.min(data.getReactSize(), EMOJI_LIMIT);
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
