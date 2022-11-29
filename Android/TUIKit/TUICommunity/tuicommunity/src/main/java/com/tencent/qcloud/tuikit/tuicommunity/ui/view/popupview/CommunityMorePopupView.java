package com.tencent.qcloud.tuikit.tuicommunity.ui.view.popupview;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.IPopupCard;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.IPopupView;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.CommunityMemberActivity;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.CommunitySettingsActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;

public class CommunityMorePopupView extends FrameLayout implements IPopupView {
    private View contentView;
    private CommunityBean communityBean;

    private ImageView groupFace;
    private TextView communityName;
    private TextView communityID;
    private TextView communityIntroduction;
    private View userList;
    private View shareCommunity;
    private View settings;
    private TextView exitButton;
    private TUIKitDialog exitDialog;

    private IPopupCard popupCard;
    private CommunityPresenter communityPresenter;

    public CommunityMorePopupView(Context context) {
        super(context);
        init(context, null);
    }

    public CommunityMorePopupView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public CommunityMorePopupView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public CommunityMorePopupView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attributeSet) {
        communityPresenter = new CommunityPresenter();
        contentView = LayoutInflater.from(context).inflate(R.layout.community_more_popup_layout, this);
        groupFace = contentView.findViewById(R.id.community_group_face);
        communityName = contentView.findViewById(R.id.community_name_tv);
        communityID = contentView.findViewById(R.id.community_group_id_tv);
        communityIntroduction = contentView.findViewById(R.id.community_introduction);
        userList = contentView.findViewById(R.id.user_list);
        shareCommunity = contentView.findViewById(R.id.share_community);
        settings = contentView.findViewById(R.id.settings);
        exitButton = contentView.findViewById(R.id.exit_community_button);
    }

    public void setCommunityBean(CommunityBean communityBean) {
        this.communityBean = communityBean;
        GlideEngine.loadImageSetDefault(groupFace, communityBean.getGroupFaceUrl(),
                TUIThemeManager.getAttrResId(getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_group_icon_community));
        communityName.setText(communityBean.getCommunityName());
        communityID.setText(communityBean.getGroupId());

        if (TextUtils.isEmpty(communityBean.getIntroduction())) {
            communityIntroduction.setText(R.string.community_settings_not_set);
            communityIntroduction.setTextColor(getResources().getColor(R.color.community_setting_linear_content_disable_color));
        } else {
            communityIntroduction.setText(communityBean.getIntroduction());
            communityIntroduction.setTextColor(getResources().getColor(R.color.community_more_introduction_disable_color));
        }

        userList.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getContext(), CommunityMemberActivity.class);
                intent.putExtra(CommunityConstants.COMMUNITY_BEAN, communityBean);
                intent.putExtra(CommunityConstants.TITLE, getResources().getString(R.string.community_user_list));
                getContext().startActivity(intent);
                dismissPopup();
            }
        });

        shareCommunity.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastShortMessage(getResources().getString(R.string.community_coming_soon));
            }
        });

        settings.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getContext(), CommunitySettingsActivity.class);
                intent.putExtra(CommunityConstants.COMMUNITY_ID, communityBean.getGroupId());
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getContext().startActivity(intent);
                dismissPopup();
            }
        });

        if (communityBean.isOwner()) {
            exitButton.setVisibility(GONE);
        }
        exitButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (exitDialog == null) {
                    exitDialog = new TUIKitDialog(getContext()).builder()
                            .setTitle(getResources().getString(R.string.community_exit_community))
                            .setCancelOutside(true)
                            .setPositiveButton(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    exitCommunity();
                                }
                            })
                            .setNegativeButton(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {

                                }
                            });
                }
                exitDialog.show();
            }
        });
    }

    private void exitCommunity() {
        communityPresenter.quitCommunity(communityBean.getGroupId(), new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                dismissPopup();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("quit group error, code=" + errCode + " errMsg=" + errMsg);
            }
        });
    }

    private void dismissPopup() {
        if (popupCard != null) {
            popupCard.dismiss();
        }
    }

    @Override
    public void setPopupCard(IPopupCard popupCard) {
        this.popupCard = popupCard;
    }
}
