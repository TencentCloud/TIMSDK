package com.tencent.qcloud.tuikit.tuicallkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

public class TUICallingSingleVideoUserView extends BaseUserView {
    private Context   mContext;
    private ImageView mImageAvatar;
    private TextView  mTextUserName;
    private TextView  mTextVideoHint;
    private String    mHintMessage;

    public TUICallingSingleVideoUserView(Context context, String message) {
        super(context);
        mContext = context.getApplicationContext();
        mHintMessage = message;
        initView();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_single_video_user_view, this);
        mImageAvatar = findViewById(R.id.iv_user_avatar);
        mTextUserName = findViewById(R.id.tv_user_name);
        mTextVideoHint = findViewById(R.id.tv_video_tag);
        mTextVideoHint.setText(mHintMessage);
    }

    @Override
    public void updateUserInfo(CallingUserModel model) {
        super.updateUserInfo(model);
        if (null != model && !TextUtils.isEmpty(model.userId)) {
            ImageLoader.loadImage(mContext, mImageAvatar, model.userAvatar, R.drawable.tuicalling_ic_avatar);
            mTextUserName.setText(TextUtils.isEmpty(model.userName) ? model.userId : model.userName);
        }
    }
}
