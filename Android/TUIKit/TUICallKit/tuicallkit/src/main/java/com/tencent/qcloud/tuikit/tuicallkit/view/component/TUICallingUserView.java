package com.tencent.qcloud.tuikit.tuicallkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

public class TUICallingUserView extends BaseUserView {
    private Context   mContext;
    private ImageView mImageAvatar;
    private TextView  mTextUserName;

    public TUICallingUserView(Context context) {
        super(context);
        mContext = context.getApplicationContext();
        initView();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_user_view, this);
        mImageAvatar = findViewById(R.id.img_avatar);
        mTextUserName = findViewById(R.id.tv_name);
    }

    @Override
    public void updateUserInfo(CallingUserModel model) {
        super.updateUserInfo(model);
        ImageLoader.loadImage(mContext, mImageAvatar, model.userAvatar, R.drawable.tuicalling_ic_avatar);
        mTextUserName.setText(TextUtils.isEmpty(model.userName) ? model.userId : model.userName);
    }

    @Override
    public void updateTextColor(int color) {
        super.updateTextColor(color);
        mTextUserName.setTextColor(color);
    }
}
