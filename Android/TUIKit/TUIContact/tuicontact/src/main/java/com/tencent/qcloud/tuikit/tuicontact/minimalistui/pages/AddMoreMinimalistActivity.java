package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IAddMoreActivity;
import com.tencent.qcloud.tuikit.tuicontact.presenter.AddMorePresenter;

public class AddMoreMinimalistActivity extends BaseLightActivity implements IAddMoreActivity {

    private static final String TAG = AddMoreMinimalistActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private EditText searchEdit;
    private TextView idLabel;
    private TextView notFoundTip;
    private TextView searchBtn;
    private View detailArea;

    private ImageView faceImgView;
    private TextView idTextView;
    private TextView groupTypeView;
    private TextView groupTypeTagView;
    private TextView nickNameView;

    private boolean mIsGroup;

    private AddMorePresenter presenter;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_add_activity);
        if (getIntent() != null) {
            mIsGroup = getIntent().getExtras().getBoolean(TUIContactConstants.GroupType.GROUP);
        }

        presenter = new AddMorePresenter();
        presenter.setAddMoreActivity(this);

        faceImgView = findViewById(R.id.friend_icon);
        idTextView = findViewById(R.id.friend_account);
        groupTypeView = findViewById(R.id.group_type);
        nickNameView = findViewById(R.id.friend_nick_name);
        groupTypeTagView = findViewById(R.id.group_type_tag);

        mTitleBar = findViewById(R.id.add_friend_titlebar);
        mTitleBar.setTitle(mIsGroup ? getResources().getString(R.string.add_group) : getResources().getString(R.string.add_friend), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mTitleBar.getRightGroup().setVisibility(View.GONE);

        searchEdit = findViewById(R.id.search_edit);
        if (mIsGroup) {
            searchEdit.setHint(R.string.hint_search_group_id);
        }

        idLabel = findViewById(R.id.id_label);
        notFoundTip = findViewById(R.id.not_found_tip);
        searchBtn = findViewById(R.id.search_button);
        detailArea = findViewById(R.id.friend_detail_area);
        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                notFoundTip.setVisibility(View.GONE);
                String id = searchEdit.getText().toString();

                if (mIsGroup) {
                    presenter.getGroupInfo(id, new IUIKitCallback<GroupInfo>() {
                        @Override
                        public void onSuccess(GroupInfo data) {
                            setGroupDetail(data);
                            detailArea.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    Intent intent = new Intent(TUIContactService.getAppContext(), FriendProfileMinimalistActivity.class);
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    intent.putExtra(TUIContactConstants.ProfileType.CONTENT, data);
                                    TUIContactService.getAppContext().startActivity(intent);
                                }
                            });
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            setNotFound(true);
                        }
                    });
                    return;
                }

                presenter.getUserInfo(id, new IUIKitCallback<ContactItemBean>() {
                    @Override
                    public void onSuccess(ContactItemBean data) {
                        setFriendDetail(data.getAvatarUrl(), data.getId(), data.getNickName());
                        detailArea.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Intent intent = new Intent(TUIContactService.getAppContext(), FriendProfileMinimalistActivity.class);
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                intent.putExtra(TUIContactConstants.ProfileType.CONTENT, data);
                                TUIContactService.getAppContext().startActivity(intent);
                            }
                        });
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        setNotFound(false);
                    }
                });
            }
        });

        if (!mIsGroup) {
            idLabel.setText(getString(R.string.contact_my_user_id, TUILogin.getLoginUser()));
        }

        searchEdit.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    idLabel.setVisibility(View.GONE);
                }
            }
        });

        searchEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(searchEdit.getText())) {
                    detailArea.setVisibility(View.GONE);
                    notFoundTip.setVisibility(View.GONE);
                }
            }
        });

    }

    private void setGroupDetail(GroupInfo groupInfo) {
        int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(faceImgView, groupInfo.getFaceUrl(),
                TUIUtil.getDefaultGroupIconResIDByGroupType(this, groupInfo.getGroupType()), radius);
        idTextView.setText(groupInfo.getId());
        nickNameView.setText(groupInfo.getGroupName());
        groupTypeTagView.setVisibility(View.VISIBLE);
        groupTypeView.setVisibility(View.VISIBLE);
        groupTypeView.setText(groupInfo.getGroupType());
        detailArea.setVisibility(View.VISIBLE);
    }

    private void setFriendDetail(String faceUrl, String id, String nickName) {
        int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(faceImgView, faceUrl, radius);
        idTextView.setText(id);
        if (TextUtils.isEmpty(nickName)) {
            nickNameView.setText(id);
        } else {
            nickNameView.setText(nickName);
        }
        groupTypeTagView.setVisibility(View.GONE);
        groupTypeView.setVisibility(View.GONE);
        detailArea.setVisibility(View.VISIBLE);
    }

    private void setNotFound(boolean isGroup) {
        detailArea.setVisibility(View.GONE);
        if (isGroup) {
            notFoundTip.setText(getString(R.string.contact_no_such_group));
        } else {
            notFoundTip.setText(getString(R.string.contact_no_such_user));
        }
        notFoundTip.setVisibility(View.VISIBLE);
    }

    @Override
    public void finish() {
        super.finish();
    }
}
