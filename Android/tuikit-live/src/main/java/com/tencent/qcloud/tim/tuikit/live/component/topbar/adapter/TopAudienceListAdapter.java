package com.tencent.qcloud.tim.tuikit.live.component.topbar.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.component.common.CircleImageView;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

import java.util.HashMap;
import java.util.List;

public class TopAudienceListAdapter extends RecyclerView.Adapter<TopAudienceListAdapter.ViewHolder> {
    private static final String TAG = "TopAudienceListAdapter";

    private List<TRTCLiveRoomDef.TRTCLiveUserInfo>            mAudienceList;
    private OnItemClickListener                               mOnItemClickListener;
    private HashMap<String, TRTCLiveRoomDef.TRTCLiveUserInfo> mAudienceMap;

    public TopAudienceListAdapter(List<TRTCLiveRoomDef.TRTCLiveUserInfo> audienceList, OnItemClickListener onItemClickListener) {
        mAudienceList = audienceList;
        mOnItemClickListener = onItemClickListener;
        mAudienceMap = new HashMap<>();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.live_item_top_audience_list, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        TRTCLiveRoomDef.TRTCLiveUserInfo item = mAudienceList.get(position);
        holder.bind(item, mOnItemClickListener);
    }

    @Override
    public int getItemCount() {
        return mAudienceList.size();
    }

    public void addAudienceUser(List<TRTCLiveRoomDef.TRTCLiveUserInfo> userInfoList){
        if (userInfoList == null) {
            return;
        }
        for (TRTCLiveRoomDef.TRTCLiveUserInfo userInfo : userInfoList) {

            addAudienceUser(userInfo);
        }
        notifyDataSetChanged();
    }

    public void addAudienceUser(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        if (userInfo == null) {
            return;
        }
        if (userInfo.userId == null) {
            return;
        }
        if (!mAudienceMap.containsKey(userInfo.userId)) {
            mAudienceList.add(userInfo);
            mAudienceMap.put(userInfo.userId, userInfo);
            notifyDataSetChanged();
        }
    }

    public void removeAudienceUser(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        if (userInfo == null) {
            return;
        }
        if (userInfo.userId == null) {
            return;
        }
        TRTCLiveRoomDef.TRTCLiveUserInfo localUserInfo = mAudienceMap.get(userInfo.userId);
        if (localUserInfo != null) {
            mAudienceList.remove(localUserInfo);
            mAudienceMap.remove(userInfo.userId);
            notifyDataSetChanged();
        }
    }

    public int getAudienceListSize() {
        return mAudienceList.size();
    }



    public static class ViewHolder extends RecyclerView.ViewHolder {
        private CircleImageView mImageAudienceIcon;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final TRTCLiveRoomDef.TRTCLiveUserInfo audienceInfo, final OnItemClickListener listener) {
            if (!TextUtils.isEmpty(audienceInfo.avatarUrl)) {
                GlideEngine.loadImage(mImageAudienceIcon, audienceInfo.avatarUrl);
            } else {
                GlideEngine.loadImage(mImageAudienceIcon, R.drawable.live_default_head_img);
            }

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    listener.onItemClick(audienceInfo);
                }
            });
        }

        private void initView(@NonNull final View itemView) {
            mImageAudienceIcon = itemView.findViewById(R.id.iv_audience_head);
        }
    }

    public interface OnItemClickListener {
        void onItemClick(TRTCLiveRoomDef.TRTCLiveUserInfo audienceInfo);
    }
}