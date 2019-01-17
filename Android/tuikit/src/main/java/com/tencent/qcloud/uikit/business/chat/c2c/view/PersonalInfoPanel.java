package com.tencent.qcloud.uikit.business.chat.c2c.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.infos.IPersonalInfoPanel;
import com.tencent.qcloud.uikit.common.component.info.InfoItemAction;
import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoBean;
import com.tencent.qcloud.uikit.business.chat.c2c.presenter.PersonalPresenter;
import com.tencent.qcloud.uikit.api.infos.PersonalInfoPanelEvent;
import com.tencent.qcloud.uikit.common.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;
import com.tencent.qcloud.uikit.common.widget.UIKitSwitch;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class PersonalInfoPanel extends LinearLayout implements IPersonalInfoPanel {
    private ImageView mUserIcon;
    private TextView mNickName, mAccount, mSignature, mLocation, mBirthday;
    private UIKitSwitch mTopILiveSwitch;
    private Button mBtn, mDelFriendBtn, mAddBlackListBtn, mCancelBtn;
    private PageTitleBar mTitleBar;
    private PersonalPresenter mPresenter;
    private PersonalInfoPanelEvent mEvent;
    private AlertDialog mDialog;
    private PersonalInfoBean mInfo;

    public PersonalInfoPanel(Context context) {
        super(context);
        init();
    }

    public PersonalInfoPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public PersonalInfoPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.personal_info_panel, this);
        mUserIcon = findViewById(R.id.personal_icon);
        mNickName = findViewById(R.id.personal_nickName);
        mAccount = findViewById(R.id.personal_account);
        mSignature = findViewById(R.id.personal_signature);
        mLocation = findViewById(R.id.personal_location);
        mBirthday = findViewById(R.id.personal_birthday);
        mTopILiveSwitch = (UIKitSwitch) findViewById(R.id.chat_to_top_switch);
        mBtn = findViewById(R.id.personal_info_button);
        mTitleBar = findViewById(R.id.personal_info_title_bar);
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mDialog != null && mDialog.isShowing()) {
                    mDialog.dismiss();
                } else {
                    buildPopMenu();
                }
            }
        });

        mPresenter = new PersonalPresenter(this);
    }

    public void initPersonalInfo(PersonalInfoBean info) {
        this.mInfo = info;
        GlideEngine.loadImage(mUserIcon, info.getIconUrl(), null);
        mNickName.setText(info.getNickName());
        mAccount.setText(info.getAccount());
        mSignature.setText(info.getSignature());
        mLocation.setText(info.getLocation());
        mBirthday.setText(info.getBirthday());
        mTopILiveSwitch.setChecked(info.isTopChat());
        if (!info.isFriend())
            mBtn.setText(R.string.add_friend);

    }

    private void buildPopMenu() {
        if (mDialog == null) {
            mDialog = PopWindowUtil.buildFullScreenDialog((Activity) getContext());
            View moreActionView = inflate(getContext(), R.layout.personal_more_action_panel, null);
            moreActionView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mDelFriendBtn = moreActionView.findViewById(R.id.del_friend_button);
            mDelFriendBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mEvent.onDelFriendClick(mInfo);
                }
            });
            mAddBlackListBtn = moreActionView.findViewById(R.id.add_to_blacklist);
            mAddBlackListBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mEvent.onAddToBlackListClick(mInfo);
                }
            });
            mCancelBtn = moreActionView.findViewById(R.id.cancel);
            mCancelBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mDialog.setContentView(moreActionView);
        } else {
            mDialog.show();
        }

    }

    @Override
    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setPersonalInfoPanelEvent(final PersonalInfoPanelEvent event) {
        mEvent = event;
        mTitleBar.setLeftClick(new OnClickListener() {
            @Override
            public void onClick(View view) {
                event.onBackClick();
            }
        });

        mBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                event.onBottomButtonClick(mInfo.isFriend(), mInfo);
            }
        });
    }

    @Override
    public void initDefault() {
        setPersonalInfoPanelEvent(new PersonalInfoPanelEvent() {
            @Override
            public void onBackClick() {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }

            @Override
            public void onBottomButtonClick(boolean isFriend, PersonalInfoBean info) {

            }

            @Override
            public void onAddFriendClick(PersonalInfoBean info) {
                mPresenter.addFriend(info);
            }

            @Override
            public void onDelFriendClick(PersonalInfoBean info) {
                mPresenter.delFriend(info);
            }

            @Override
            public void onAddToBlackListClick(PersonalInfoBean info) {
                mPresenter.addToBlackList(info);
            }
        });
    }

    @Override
    public void addInfoItem(List<InfoItemAction> items, int group, int index) {

    }
}
