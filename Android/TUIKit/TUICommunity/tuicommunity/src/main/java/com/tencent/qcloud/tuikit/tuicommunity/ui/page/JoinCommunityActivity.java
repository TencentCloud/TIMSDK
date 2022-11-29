package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.component.SelectTextButton;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

public class JoinCommunityActivity extends BaseLightActivity {

    private ImageView searchIcon;
    private TextView cancelButton;
    private View communityItemArea;
    private View notFoundArea;
    private SelectTextButton joinButton;
    private ImageView avatar;
    private TextView name;
    private TextView owner;
    private EditText idEditText;

    private CommunityPresenter presenter;
    private CommunityBean communityBean;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_activity_join_community);
        searchIcon = findViewById(R.id.search_icon);
        cancelButton = findViewById(R.id.cancel_button);
        communityItemArea = findViewById(R.id.community_item_rl);
        notFoundArea = findViewById(R.id.not_found_ll);
        joinButton = findViewById(R.id.join_community_button);
        avatar = findViewById(R.id.community_avatar);
        name = findViewById(R.id.community_name);
        owner = findViewById(R.id.community_owner);
        idEditText = findViewById(R.id.community_id_input);

        initView();
    }

    private void initView() {
        presenter = new CommunityPresenter();
        idEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(s)) {
                    cancelButton.setVisibility(View.GONE);
                    searchIcon.setVisibility(View.VISIBLE);
                } else {
                    cancelButton.setVisibility(View.VISIBLE);
                    searchIcon.setVisibility(View.GONE);
                }
                searchCommunity(s.toString());
            }
        });

        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                idEditText.setText("");
            }
        });
    }

    private void setCommunityArea(CommunityBean data) {
        communityBean = data;
        GlideEngine.loadImageSetDefault(avatar, data.getGroupFaceUrl(),
                TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_default_group_icon_community));
        name.setText(data.getCommunityName());
        owner.setText(getString(R.string.community_owner) + ": " + data.getOwner());
        setJoinButton(data.getRole() != CommunityBean.ROLE_UNDEFINED);
    }

    private void setJoinButton(boolean isJoined) {
        if (isJoined) {
            joinButton.setText(getString(R.string.community_joined));
            joinButton.setTextColor(0xFF999999);
            joinButton.setColor(0xFF999999);
        } else {
            joinButton.setText(getString(R.string.community_join));
            joinButton.setTextColor(0xFF006EFF);
            joinButton.setColor(0xFF006EFF);
        }
    }

    private void searchCommunity(String groupID) {
        if (TextUtils.isEmpty(groupID)) {
            notFoundArea.setVisibility(View.GONE);
            communityItemArea.setVisibility(View.GONE);
            return;
        }

        presenter.searchCommunity(groupID, new IUIKitCallback<CommunityBean>() {
            @Override
            public void onSuccess(CommunityBean data) {
                setCommunityArea(data);
                notFoundArea.setVisibility(View.GONE);
                communityItemArea.setVisibility(View.VISIBLE);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                communityBean = null;
                TUICommunityLog.e("JoinCommunityActivity", "not found the community, code=" + errCode + " errMsg=" + errMsg);
                notFoundArea.setVisibility(View.VISIBLE);
                communityItemArea.setVisibility(View.GONE);
            }
        });

        joinButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (communityBean != null && communityBean.getRole() == CommunityBean.ROLE_UNDEFINED) {
                    presenter.joinCommunity(communityBean.getGroupId(), new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            setJoinButton(true);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage("join community failed, code=" + errCode + " desc=" + errMsg);
                        }
                    });
                }
            }
        });
    }
}