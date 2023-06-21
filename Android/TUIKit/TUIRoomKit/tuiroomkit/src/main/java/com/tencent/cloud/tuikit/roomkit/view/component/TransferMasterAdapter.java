package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.base.UserBaseAdapter;

import de.hdodenhof.circleimageview.CircleImageView;

public class TransferMasterAdapter extends UserBaseAdapter {
    private String mSelectedUserId;

    public TransferMasterAdapter(Context context) {
        super(context);
    }

    public String getSelectedUserId() {
        return mSelectedUserId;
    }

    @Override
    protected UserBaseViewHolder createViewHolder(View view) {
        return new ViewHolder(view);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_item_specify_master;
    }

    private class ViewHolder extends UserBaseViewHolder {
        private View            mRootView;
        private TextView        mTextUserName;
        private ImageView       mImageSelected;
        private CircleImageView mImageHead;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(final View itemView) {
            mRootView = itemView.findViewById(R.id.cl_item_root);
            mImageHead = itemView.findViewById(R.id.img_head);
            mTextUserName = itemView.findViewById(R.id.tv_user_name);
            mImageSelected = itemView.findViewById(R.id.img_selected);
        }

        @Override
        public void bind(Context context, final UserModel model) {
            int visibility = model.userId.equals(mSelectedUserId) ? View.VISIBLE : View.GONE;
            mImageSelected.setVisibility(visibility);
            ImageLoader.loadImage(context, mImageHead, model.userAvatar, R.drawable.tuiroomkit_head);
            String userName = TextUtils.isEmpty(model.userName) ? model.userId : model.userName;
            mTextUserName.setText(userName);
            mRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mSelectedUserId = model.userId;
                    notifyDataSetChanged();
                }
            });
        }
    }
}
