package com.tencent.qcloud.tim.tuikit.live.component.common;

import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

import java.util.List;

/**
 * 用于选取邀请人
 *
 * @author guanyifeng
 */
public class SelectMemberView extends BottomSheetDialog {
    private Context            mContext;
    private RecyclerView       mPusherListRv;
    private ListAdapter        mListAdapter;
    private List<MemberEntity> mMemberEntityList;
    private onSelectedCallback mOnSelectedCallback;
    private TextView           mPusherTagTv;
    private TextView           mTextCancel;
    private int                mSeatIndex;

    public SelectMemberView(@NonNull Context context) {
        super(context, R.style.live_action_sheet_theme);
        setContentView(R.layout.live_view_select_member);
        initView(context);
    }


    private void initView(Context context) {
        mContext = context;
        mPusherListRv = (RecyclerView) findViewById(R.id.rv_pusher_list);
        mPusherTagTv = (TextView) findViewById(R.id.tv_pusher_tag);
        mTextCancel = (TextView) findViewById(R.id.tv_cancel);
        if (mPusherListRv != null) {
            mPusherListRv.setLayoutManager(new LinearLayoutManager(mContext));
            mPusherListRv.addItemDecoration(new SpaceDecoration(dp2px(mContext, 15),
                    1));
        }
        mTextCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                if (mOnSelectedCallback != null) {
                    mOnSelectedCallback.onCancel();
                }
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public void setOnSelectedCallback(onSelectedCallback onSelectedCallback) {
        mOnSelectedCallback = onSelectedCallback;
    }

    public void refreshView() {
        mPusherTagTv.setText("正在加载中...");
    }

    public void setTitle(String title) {
        mPusherTagTv.setText(title);
    }

    public void notifyDataSetChanged() {
        if (mListAdapter != null) {
            mListAdapter.notifyDataSetChanged();
        }
    }

    public void setSeatIndex(int seatIndex) {
        mSeatIndex = seatIndex;
    }

    public void setList(List<MemberEntity> userInfoList) {
        if (mListAdapter == null) {
            mMemberEntityList = userInfoList;
            mListAdapter = new ListAdapter(mContext, mMemberEntityList, new ListAdapter.OnItemClickListener() {
                @Override
                public void onItemClick(int position) {
                    if (mOnSelectedCallback == null) {
                        return;
                    }
                    mOnSelectedCallback.onSelected(mSeatIndex, mMemberEntityList.get(position));
                }
            });
            mPusherListRv.setAdapter(mListAdapter);
        } else {
            mMemberEntityList.clear();
            mMemberEntityList.addAll(userInfoList);
            mListAdapter.notifyDataSetChanged();
        }
    }

    public interface onSelectedCallback {
        void onSelected(int seatIndex, MemberEntity memberEntity);

        void onCancel();
    }

    public static class ListAdapter extends
            RecyclerView.Adapter<ListAdapter.ViewHolder> {
        private Context             context;
        private List<MemberEntity>  list;
        private OnItemClickListener onItemClickListener;

        public ListAdapter(Context context, List<MemberEntity> list,
                           OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);

            View view = inflater.inflate(R.layout.live_item_select_member, parent, false);

            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            MemberEntity item = list.get(position);
            holder.bind(item, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }


        public interface OnItemClickListener {
            void onItemClick(int position);
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            private TextView  mUserNameTv;
            private Button    mButtonInvite;
            private ImageView mImageAvatar;

            ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
                mButtonInvite = (Button) itemView.findViewById(R.id.btn_invite_anchor);
                mImageAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            }

            public void bind(final MemberEntity model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }
                if (model.type == MemberEntity.TYPE_IDEL) {
                    mButtonInvite.setVisibility(View.VISIBLE);
                    mButtonInvite.setText("邀请");
                } else if (model.type == MemberEntity.TYPE_WAIT_AGREE) {
                    mButtonInvite.setVisibility(View.VISIBLE);
                    mButtonInvite.setText("同意");
                } else {
                    mButtonInvite.setVisibility(View.INVISIBLE);
                }
                if (TextUtils.isEmpty(model.userName)) {
                    mUserNameTv.setText(model.userId);
                } else {
                    mUserNameTv.setText(model.userName);
                }

                if (!TextUtils.isEmpty(model.userAvatar)) {
                    GlideEngine.loadImage(mImageAvatar, model.userAvatar);
                } else {
                    mImageAvatar.setImageResource(R.drawable.live_bg_cover);
                }

                mButtonInvite.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }
        }
    }

    public static class SpaceDecoration extends RecyclerView.ItemDecoration {
        private int space;
        private int colNum;

        public SpaceDecoration(int space, int colNum) {
            this.space = space;
            this.colNum = colNum;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            if (parent.getChildLayoutPosition(view) % colNum == 0) {
                outRect.right = space;
                outRect.bottom = space;
            } else {
                outRect.left = space;
                outRect.bottom = space;
            }
        }
    }

    public static class MemberEntity {
        public static final int TYPE_IDEL       = 0;
        public static final int TYPE_IN_SEAT    = 1;
        public static final int TYPE_WAIT_AGREE = 2;

        public int    type;
        /// 【字段含义】用户唯一标识
        public String userId;
        /// 【字段含义】用户昵称
        public String userName;
        /// 【字段含义】用户头像
        public String userAvatar;
        public int    roomId;
    }

    public static int dp2px(Context context, float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, context.getResources().getDisplayMetrics());
    }
}
