package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import java.util.List;

import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.tuichat.R;

public class FacePagerAdapter extends RecyclerView.Adapter<FaceViewHolder> {
    private List<FaceGroup> faceGroupList;
    private FaceView.OnItemClickListener onItemClickListener;

    public void setFaceGroupList(List<FaceGroup> faceGroupList) {
        this.faceGroupList = faceGroupList;
    }

    public void setOnEmojiClickListener(FaceView.OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    @NonNull
    @Override
    public FaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View facePageView  = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_face_page_item_layout, null);
        facePageView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        if (viewType == EmojiViewHolder.TYPE) {
            return new EmojiViewHolder(facePageView);
        } else {
            return new FaceViewHolder(facePageView);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull FaceViewHolder holder, int position) {
        holder.setOnEmojiClickListener(onItemClickListener);
        FaceGroup faceGroup = faceGroupList.get(position);
        holder.showFaceList(faceGroup);
    }

    @Override
    public int getItemCount() {
        return faceGroupList.size();
    }

    @Override
    public int getItemViewType(int position) {
        if (faceGroupList.get(position).isEmojiGroup()) {
            return EmojiViewHolder.TYPE;
        }
        return FaceViewHolder.TYPE;
    }
}