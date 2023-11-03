package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class CustomerServiceProfileLayout extends LinearLayout implements View.OnClickListener, IFriendProfileLayout {
    private static final String TAG = CustomerServiceProfileLayout.class.getSimpleName();

    private static final int CHANGE_REMARK_CODE = 200;

    private TitleBarLayout mTitleBar;
    private ImageView mHeadImageView;
    private TextView mNickNameView;
    private TextView mIDView;
    private TextView mSignatureView;
    private TextView mSignatureTagView;
    private LineControllerView mMessageOptionView;
    private Button clearMessageBtn;
    private ContactItemBean mContactInfo;
    private String mId;
    private String mNickname;

    private FriendProfilePresenter presenter;

    public CustomerServiceProfileLayout(Context context) {
        super(context);
        init();
    }

    public CustomerServiceProfileLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CustomerServiceProfileLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(FriendProfilePresenter presenter) {
        this.presenter = presenter;
    }

    private void init() {
        inflate(getContext(), R.layout.customer_service_profile_layout, this);

        mHeadImageView = findViewById(R.id.customer_service_icon);
        mNickNameView = findViewById(R.id.customer_service_nick_name);
        mIDView = findViewById(R.id.customer_service_account);
        mSignatureTagView = findViewById(R.id.customer_service_signature_tag);
        mSignatureView = findViewById(R.id.customer_service_signature);
        mMessageOptionView = findViewById(R.id.customer_service_msg_rev_opt);
        mMessageOptionView.setOnClickListener(this);
        clearMessageBtn = findViewById(R.id.btn_customer_service_clear_chat_history);
        clearMessageBtn.setOnClickListener(this);

        mTitleBar = findViewById(R.id.customer_service_titlebar);
        mTitleBar.setTitle(getResources().getString(com.tencent.qcloud.tuikit.tuicontact.R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });
    }

    public void initData(Object data) {
        if (data instanceof String) {
            mId = (String) data;
            loadUserProfile(mId);
        } else if (data instanceof ContactItemBean) {
            setViewContentFromItemBean((ContactItemBean) data);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }
        mIDView.setText(mId);
    }

    private void setViewContentFromItemBean(ContactItemBean data) {
        mContactInfo = data;
        mId = mContactInfo.getId();
        mNickname = mContactInfo.getNickName();
        mSignatureView.setText(mContactInfo.getSignature());
        if (TextUtils.isEmpty(mContactInfo.getSignature())) {
            mSignatureTagView.setText(getResources().getString(com.tencent.qcloud.tuikit.tuicontact.R.string.contact_no_status));
        } else {
            mSignatureTagView.setText(getResources().getString(com.tencent.qcloud.tuikit.tuicontact.R.string.contact_signature_tag));
        }
        int radius = getResources().getDimensionPixelSize(com.tencent.qcloud.tuikit.tuicontact.R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(mHeadImageView, mContactInfo.getAvatarUrl(), radius);

        clearMessageBtn.setVisibility(VISIBLE);

        if (!TextUtils.equals(mContactInfo.getId(), TUILogin.getLoginUser())) {
            updateMessageOptionView();
        }
    }

    private void updateMessageOptionView() {
        mMessageOptionView.setVisibility(VISIBLE);
        // get
        final ArrayList<String> userIdList = new ArrayList<>();
        userIdList.add(mId);

        presenter.getC2CReceiveMessageOpt(userIdList, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                mMessageOptionView.setChecked(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mMessageOptionView.setChecked(false);
            }
        });

        // set
        mMessageOptionView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                presenter.setC2CReceiveMessageOpt(userIdList, isChecked);
            }
        });
    }

    @Override
    public void onDataSourceChanged(ContactItemBean bean) {
        setViewContentFromItemBean(bean);
        if (bean.isFriend()) {
            updateMessageOptionView();
            clearMessageBtn.setVisibility(VISIBLE);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        if (!TextUtils.isEmpty(bean.getAvatarUrl())) {
            int radius = getResources().getDimensionPixelSize(com.tencent.qcloud.tuikit.tuicontact.R.dimen.contact_profile_face_radius);
            GlideEngine.loadUserIcon(mHeadImageView, bean.getAvatarUrl(), radius);
        }
        mIDView.setText(mId);
    }

    private void loadUserProfile(String id) {
        final ContactItemBean bean = new ContactItemBean();
        presenter.getUsersInfo(id, bean);
    }

    @Override
    public void onClick(View v) {
        if (v == clearMessageBtn) {
            new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(com.tencent.qcloud.tuikit.tuicontact.R.string.clear_msg_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Map<String, Object> hashMap = new HashMap<>();
                            hashMap.put(TUIConstants.TUIContact.FRIEND_ID, mId);
                            TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, hashMap);
                        }
                    })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {}
                    })
                .show();
        }
    }
}
