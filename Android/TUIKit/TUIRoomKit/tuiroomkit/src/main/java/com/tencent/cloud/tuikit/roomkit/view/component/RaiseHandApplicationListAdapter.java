package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;


import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.base.UserBaseAdapter;

import java.util.HashMap;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class RaiseHandApplicationListAdapter extends UserBaseAdapter {

    public RaiseHandApplicationListAdapter(Context context) {
        super(context);
    }

    public class ViewHolder extends UserBaseViewHolder {
        private Button          mButtonAgree;
        private Button          mButtonDisagree;
        private TextView        mTextUserName;
        private CircleImageView mImageHead;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(final View itemView) {
            mImageHead = itemView.findViewById(R.id.img_head);
            mTextUserName = itemView.findViewById(R.id.tv_user_name);
            mButtonAgree = itemView.findViewById(R.id.btn_agree_apply);
            mButtonDisagree = itemView.findViewById(R.id.btn_disagree_apply);
        }

        @Override
        public void bind(Context context, final UserModel userModel) {
            ImageLoader.loadImage(context, mImageHead, userModel.userAvatar, R.drawable.tuiroomkit_head);
            mTextUserName.setText(userModel.userName);
            mButtonAgree.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Map<String, Object> params = new HashMap<>();
                    params.put(RoomEventConstant.KEY_USER_ID, userModel.userId);
                    RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT, params);
                }
            });
            mButtonDisagree.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Map<String, Object> params = new HashMap<>();
                    params.put(RoomEventConstant.KEY_USER_ID, userModel.userId);
                    RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT,
                            params);
                }
            });
        }
    }

    @Override
    protected UserBaseViewHolder createViewHolder(View view) {
        return new ViewHolder(view);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_item_raise_hand_apply;
    }
}