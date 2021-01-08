package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.widget;

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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * 用于展示等待连麦的观众
 *
 * @author guanyifeng
 */
public class LinkMicListDialog extends BottomSheetDialog {
    private Context            mContext;
    private RecyclerView       mPusherListRv;
    private ListAdapter        mListAdapter;
    private List<MemberEntity> mMemberEntityList;
    private onSelectedCallback mOnSelectedCallback;
    private TextView           mPusherTagTv;
    private TextView           mTextCancel;
    private Set<String>        mUserIdSet;

    public LinkMicListDialog(@NonNull Context context) {
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
        mMemberEntityList = new ArrayList<>();
        mListAdapter = new ListAdapter(mContext, mMemberEntityList, new ListAdapter.OnItemClickListener() {
            @Override
            public void onItemAgree(int position) {
                if (mOnSelectedCallback != null) {
                    mOnSelectedCallback.onItemAgree(mMemberEntityList.get(position));
                }
            }

            @Override
            public void onItemReject(int position) {
                if (mOnSelectedCallback != null) {
                    mOnSelectedCallback.onItemReject(mMemberEntityList.get(position));
                }
            }
        });
        mPusherListRv.setAdapter(mListAdapter);
        mUserIdSet = new HashSet<>();
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

    public List<MemberEntity> getList() {
        return mMemberEntityList;
    }

    public void addMemberEntity(MemberEntity memberEntity) {
        if (mUserIdSet.contains(memberEntity.userId)) {
            return;
        }
        mUserIdSet.add(memberEntity.userId);
        mMemberEntityList.add(memberEntity);
        mListAdapter.notifyDataSetChanged();
    }

    public void removeMemberEntity(String userId) {
        mUserIdSet.remove(userId);
        Iterator<MemberEntity> entityIterator = mMemberEntityList.iterator();
        while (entityIterator.hasNext()) {
            MemberEntity entity = entityIterator.next();
            if (entity.userId != null && entity.userId.equals(userId)) {
                entityIterator.remove();
                break;
            }
        }
        notifyDataSetChanged();
    }

    public void setList(List<MemberEntity> userInfoList) {
        mMemberEntityList.clear();
        mUserIdSet.clear();
        for (MemberEntity memberEntity : userInfoList) {
            mUserIdSet.add(memberEntity.userId);
        }
        mMemberEntityList.addAll(userInfoList);
        notifyDataSetChanged();
    }

    public interface onSelectedCallback {
        void onItemAgree(MemberEntity memberEntity);

        void onItemReject(MemberEntity memberEntity);

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

            View view = inflater.inflate(R.layout.live_item_link_mic, parent, false);

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
            void onItemAgree(int position);

            void onItemReject(int position);
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            private TextView  mUserNameTv;
            private Button    mButtonAgree;
            private Button    mButtonReject;
            private ImageView mImageAvatar;

            ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
                mButtonAgree = (Button) itemView.findViewById(R.id.btn_agree);
                mButtonReject = (Button) itemView.findViewById(R.id.btn_reject);
                mImageAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            }

            public void bind(final MemberEntity model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
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

                mButtonAgree.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemAgree(getLayoutPosition());
                    }
                });
                mButtonReject.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemReject(getLayoutPosition());
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
