package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.presenter.NewFriendApplicationPresenter;

public class NewFriendApplicationDetailActivity extends BaseLightActivity {
    private static final String TAG = "NewFriendApplicationDetailActivity";

    private TitleBarLayout mTitleBar;
    private ImageView mHeadImageView;
    private TextView mNickNameView;
    private TextView mIDView;
    private TextView acceptFriendBtn;
    private TextView refuseFriendBtn;
    private TextView resultBtn;

    private TextView friendApplicationAddWording;
    private NewFriendApplicationPresenter presenter = new NewFriendApplicationPresenter();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_new_friend_application_detail_layout);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        mIDView = findViewById(R.id.friend_account);
        resultBtn = findViewById(R.id.result_button);
        acceptFriendBtn = findViewById(R.id.accept_friend_send_btn);
        refuseFriendBtn = findViewById(R.id.refuse_friend_send_btn);
        friendApplicationAddWording = findViewById(R.id.friend_application_add_wording);

        mTitleBar = findViewById(R.id.new_friend_application_detail_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.getRightGroup().setVisibility(View.GONE);

        Intent intent = getIntent();
        FriendApplicationBean applicationBean = (FriendApplicationBean) intent.getSerializableExtra(TUIConstants.TUIContact.CONTENT);
        setApplicationBean(applicationBean);
    }

    void setApplicationBean(FriendApplicationBean applicationBean) {
        int radius = ScreenUtil.dip2px(4.6f);
        GlideEngine.loadUserIcon(mHeadImageView, applicationBean.getFaceUrl(), radius);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mNickNameView.setText(applicationBean.getDisplayName());
        mIDView.setText(applicationBean.getUserId());
        friendApplicationAddWording.setText(applicationBean.getAddWording());

        acceptFriendBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presenter.acceptFriendApplication(applicationBean, new TUICallback() {
                    @Override
                    public void onSuccess() {
                        acceptFriendBtn.setVisibility(View.GONE);
                        refuseFriendBtn.setVisibility(View.GONE);
                        resultBtn.setVisibility(View.VISIBLE);
                        resultBtn.setText(R.string.accepted);
                        finish();
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        ToastUtil.toastShortMessage(errorMessage);
                    }
                });
            }
        });

        refuseFriendBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presenter.refuseFriendApplication(applicationBean, new TUICallback() {
                    @Override
                    public void onSuccess() {
                        acceptFriendBtn.setVisibility(View.GONE);
                        refuseFriendBtn.setVisibility(View.GONE);
                        resultBtn.setVisibility(View.VISIBLE);
                        resultBtn.setText(R.string.refused);
                        finish();
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        ToastUtil.toastShortMessage(errorMessage);
                    }
                });
            }
        });
    }
}
