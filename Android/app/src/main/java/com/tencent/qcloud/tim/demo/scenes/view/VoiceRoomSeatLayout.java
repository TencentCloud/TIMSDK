package com.tencent.qcloud.tim.demo.scenes.view;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.tuikit.live.component.common.CircleImageView;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;

import java.util.ArrayList;
import java.util.List;

public class VoiceRoomSeatLayout extends RecyclerView {

    private Context mContext;

    private List<VoiceRoomSeatEntity> mVoiceRoomSeatEntities;
    private OnItemClickListener mOnItemClickListener;
    private VoiceRoomSeatAdapter mVoiceRoomSeatAdapter;

    public VoiceRoomSeatLayout(Context context) {
        super(context);
        initialize(context);
    }

    public VoiceRoomSeatLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize(context);
    }

    public VoiceRoomSeatLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mOnItemClickListener = listener;
    }

    public void setData(List<VoiceRoomSeatEntity> list) {
        mVoiceRoomSeatEntities.clear();
        mVoiceRoomSeatEntities.addAll(list);
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    public void addData(List<VoiceRoomSeatEntity> list) {
        mVoiceRoomSeatEntities.addAll(list);
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    public void setEmptyText(String emptyText) {
        mVoiceRoomSeatAdapter.setEmptyText(emptyText);
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    public void refresh() {
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    private void initialize(Context context) {
        mContext = context;
        mVoiceRoomSeatEntities = new ArrayList<>();
        mVoiceRoomSeatAdapter = new VoiceRoomSeatAdapter();
        setLayoutManager(new GridLayoutManager(mContext, 4));
        setAdapter(mVoiceRoomSeatAdapter);
    }

    public class VoiceRoomSeatAdapter extends RecyclerView.Adapter<VoiceRoomSeatAdapter.ViewHolder> {
        private String mEmptyText;

        public VoiceRoomSeatAdapter() {
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(mContext).inflate(R.layout.live_voice_room_item_seat_layout, parent, false);
            return new ViewHolder(view);
        }

        public void setEmptyText(String emptyText) {
            mEmptyText = emptyText;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            VoiceRoomSeatEntity item = mVoiceRoomSeatEntities.get(position);
            holder.bind(mContext, item);
        }

        @Override
        public int getItemCount() {
            return mVoiceRoomSeatEntities.size();
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            public CircleImageView mCircleImageView;
            public TextView mTextView;
            public FrameLayout mFrameLayoutHeadImg;

            public ViewHolder(View itemView) {
                super(itemView);
                initView();
            }

            public void bind(final Context context, final VoiceRoomSeatEntity entity) {
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mOnItemClickListener != null) {
                            mOnItemClickListener.onItemClick(entity, getLayoutPosition());
                        }
                    }
                });
                if (entity.isClose) {
                    //close的界面
                    mCircleImageView.setImageResource(R.drawable.live_voice_room_ic_lock);
                    mCircleImageView.setCircleBackgroundColor(context.getResources().getColor(R.color.live_voice_room_circle));
                    mTextView.setText(DemoApplication.instance().getString(R.string.seat_lock));
                    mFrameLayoutHeadImg.setForeground(null);
                    return;
                }
                if (!entity.isUsed) {
                    // 占位图片
                    mCircleImageView.setImageResource(R.drawable.live_voice_room_ic_head);
                    mTextView.setText(mEmptyText);
                    mTextView.setTextColor(context.getResources().getColor(R.color.live_voice_room_text_color_disable));
                } else {
                    if (!TextUtils.isEmpty(entity.userAvatar)) {
                        GlideEngine.loadImage(mCircleImageView, entity.userAvatar);
                    } else {
                        mCircleImageView.setImageResource(R.drawable.live_voice_room_ic_head);
                    }
                    if (!TextUtils.isEmpty(entity.userName)) {
                        mTextView.setText(entity.userName);
                    } else {
                        mTextView.setText(DemoApplication.instance().getString(R.string.find_anchor));
                    }
                }
                if (entity.isMute) {
                    mFrameLayoutHeadImg.setForeground(context.getResources().getDrawable(R.drawable.live_voice_room_ic_head_mute));
                } else {
                    mFrameLayoutHeadImg.setForeground(null);
                }
            }

            private void initView() {
                mCircleImageView = itemView.findViewById(R.id.live_civ_voice_room_item_head);
                mTextView = itemView.findViewById(R.id.live_tv_voice_room_item_name);
                mFrameLayoutHeadImg = itemView.findViewById(R.id.live_fl_voice_room_item_img_head);
            }
        }
    }

    public interface OnItemClickListener {
        void onItemClick(VoiceRoomSeatEntity entity, int position);
    }

    public static class VoiceRoomSeatEntity {

        public VoiceRoomSeatEntity() {
        }

        public VoiceRoomSeatEntity(String userId, String userName, String userAvatar, boolean isUsed, boolean isClose, boolean isMute) {
            this.userId = userId;
            this.userName = userName;
            this.userAvatar = userAvatar;
            this.isUsed = isUsed;
            this.isClose = isClose;
            this.isMute = isMute;
        }

        public String userId;
        public String userName;
        public String userAvatar;
        public boolean isUsed;
        public boolean isClose;
        public boolean isMute;
    }
}
