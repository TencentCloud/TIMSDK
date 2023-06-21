package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.presenter.NewFriendPresenter;

public class NewFriendApplicationDetailMinimalistActivity extends BaseMinimalistLightActivity {
    private static final String TAG = NewFriendApplicationDetailMinimalistActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private NewFriendPresenter presenter;
    private FriendApplicationBean applicationBean;
    private ShadeImageView avatarView;
    private TextView userNameTv;
    private TextView userIDTv;
    private TextView addWordingTv;
    private TextView agreeButton;
    private TextView rejectButton;
    private TextView resultButton;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_minimalist_new_friend_application_detail_activity);
        applicationBean = (FriendApplicationBean) getIntent().getSerializableExtra(TUIContactConstants.ProfileType.CONTENT);
        init();
    }

    private void init() {
        mTitleBar = findViewById(R.id.new_friend_detail_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.contact_friend_application_detail_title), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);

        avatarView = findViewById(R.id.avatar);
        avatarView.setRadius(ScreenUtil.dip2px(25));
        GlideEngine.loadImage(avatarView, applicationBean.getFaceUrl());

        userNameTv = findViewById(R.id.user_name);
        if (TextUtils.isEmpty(applicationBean.getNickName())) {
            userNameTv.setText(applicationBean.getUserId());
        } else {
            userNameTv.setText(applicationBean.getNickName());
        }
        userIDTv = findViewById(R.id.user_id);
        userIDTv.setText(applicationBean.getUserId());

        addWordingTv = findViewById(R.id.validation_message);
        addWordingTv.setText(applicationBean.getAddWording());

        agreeButton = findViewById(R.id.agree);
        rejectButton = findViewById(R.id.reject);
        resultButton = findViewById(R.id.result_tv);

        presenter = new NewFriendPresenter();
        agreeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presenter.acceptFriendApplication(applicationBean, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        agreeButton.setVisibility(View.GONE);
                        rejectButton.setVisibility(View.GONE);
                        resultButton.setVisibility(View.VISIBLE);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        super.onError(module, errCode, errMsg);
                    }
                });
            }
        });

        rejectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presenter.refuseFriendApplication(applicationBean, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        agreeButton.setVisibility(View.GONE);
                        rejectButton.setVisibility(View.GONE);
                        resultButton.setVisibility(View.VISIBLE);
                        resultButton.setText(getResources().getString(R.string.refused));
                        resultButton.setTextColor(0xFFFF584C);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        super.onError(module, errCode, errMsg);
                    }
                });
            }
        });
    }
}
