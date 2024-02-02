package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;

import java.util.List;

public class FaceListAdapter extends RecyclerView.Adapter<FaceListAdapter.FaceViewHolder> {
    private List<ChatFace> faceList;
    protected FaceView.OnItemClickListener onItemClickListener;

    public void setFaceList(List<ChatFace> faceList) {
        this.faceList = faceList;
    }

    public void setOnEmojiClickListener(FaceView.OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    @NonNull
    @Override
    public FaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_face_item_layout, null);
        return new FaceViewHolder(faceView);
    }

    @Override
    public void onBindViewHolder(@NonNull FaceViewHolder holder, int position) {
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) holder.imageView.getLayoutParams();
        ChatFace chatFace = faceList.get(position);
        if (chatFace != null && chatFace.getHeight() != 0 && chatFace.getWidth() != 0) {
            params.width = chatFace.getWidth();
            params.height = chatFace.getHeight();
        }
        holder.imageView.setLayoutParams(params);
        if (chatFace instanceof Emoji) {
            int emojiPadding = ScreenUtil.dip2px(1f);
            holder.itemView.setPaddingRelative(emojiPadding, emojiPadding, emojiPadding, emojiPadding);
        } else {
            holder.imageView.setPaddingRelative(0, 0, 0, 0);
        }
        FaceManager.loadFace(chatFace, holder.imageView);
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onFaceClicked(chatFace);
                }
            }
        });
        holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onFaceLongClick(chatFace);
                }
                return true;
            }
        });
    }

    @Override
    public int getItemCount() {
        return faceList.size();
    }

    static class FaceViewHolder extends RecyclerView.ViewHolder {
        private ImageView imageView;

        public FaceViewHolder(@NonNull View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.face_image);
        }
    }
}