package com.tencent.qcloud.tim.demo.scenes.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.ClickUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

import java.util.List;

/**
 * 用于展示房间列表的item
 */
public class RoomListAdapter extends RecyclerView.Adapter<RoomListAdapter.ViewHolder> {

    private Context mContext;
    private List<ScenesRoomInfo> mList;
    private OnItemClickListener onItemClickListener;

    public RoomListAdapter(Context context, List<ScenesRoomInfo> list,
                           OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mList = list;
        this.onItemClickListener = onItemClickListener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.live_room_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        holder.bind(mContext, mList.get(position), onItemClickListener);
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        private ImageView mImagePic;
        private TextView mTextRoomName;
        private TextView mTextAnchorName;
        private TextView mTextMemberCount;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(@NonNull final View itemView) {
            mTextRoomName = itemView.findViewById(R.id.live_tv_live_room_name);
            mTextAnchorName = itemView.findViewById(R.id.live_tv_live_anchor_name);
            mTextMemberCount = itemView.findViewById(R.id.live_tv_live_member_count);
            mImagePic = itemView.findViewById(R.id.live_iv_live_room_pic);
        }

        public void bind(Context context, final ScenesRoomInfo roomInfo, final OnItemClickListener listener) {
            if (TextUtils.isEmpty(roomInfo.roomName)) {
                mTextRoomName.setVisibility(View.GONE);
            } else {
                mTextRoomName.setVisibility(View.VISIBLE);
                mTextRoomName.setText(roomInfo.roomName);
            }
            if (TextUtils.isEmpty(roomInfo.anchorName)) {
                mTextAnchorName.setVisibility(View.GONE);
            } else {
                mTextAnchorName.setVisibility(View.VISIBLE);
                mTextAnchorName.setText(roomInfo.anchorName);
            }
            mTextMemberCount.setText(roomInfo.memberCount + DemoApplication.instance().getString(R.string.online));
            if (!TextUtils.isEmpty(roomInfo.coverUrl)) {
                GlideEngine.loadImage(mImagePic, roomInfo.coverUrl, 0, 10);
            } else {
                GlideEngine.loadImage(mImagePic, R.drawable.live_room_default_cover);
            }

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!ClickUtils.isFastClick(v.getId())) {
                        listener.onItemClick(getLayoutPosition(), roomInfo);
                    }
                }
            });
        }
    }

    public interface OnItemClickListener {
        void onItemClick(int position, ScenesRoomInfo roomInfo);
    }

    public static class ScenesRoomInfo {
        public int memberCount;
        public String roomName;
        public String roomId;
        public String anchorName;
        public String coverUrl;
        public String anchorId;
    }
}
