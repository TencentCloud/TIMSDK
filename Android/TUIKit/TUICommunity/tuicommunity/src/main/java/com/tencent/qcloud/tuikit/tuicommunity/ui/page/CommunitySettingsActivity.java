package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.RoundCornerImageView;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.component.popupcard.PopupInputCard;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.component.SettingsLinearView;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunitySettingsActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;

import java.util.ArrayList;
import java.util.List;

public class CommunitySettingsActivity extends BaseLightActivity implements ICommunitySettingsActivity {
    private static final int REQUEST_FOR_CHANGE_OWNER = 1;
    private static final int REQUEST_FOR_CHANGE_AVATAR = 2;
    private static final int REQUEST_FOR_CHANGE_COVER = 3;

    private SettingsLinearView communityNameLv;
    private SettingsLinearView communityAvatarLv;
    private SettingsLinearView communityCoverLv;
    private SettingsLinearView communityIntroductionLv;
    private SettingsLinearView communityIDLv;
    private View communitySettingsLabel;
    private SettingsLinearView createTopicCategoryLv;
    private SettingsLinearView createTopicLv;
    private SettingsLinearView groupNickNameLv;
    private View disbandButton;
    private View transferButton;
    private TUIKitDialog disbandDialog;
    private CommunityBean communityBean;
    private String communityID;
    private CommunityPresenter presenter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_settings_activity_layout);
        Intent intent = getIntent();
        communityID = intent.getStringExtra(CommunityConstants.COMMUNITY_ID);
        presenter = new CommunityPresenter();
        presenter.setCommunityEventListener();
        presenter.setSettingsActivity(this);

        communityNameLv = findViewById(R.id.community_name_lv);
        communityAvatarLv = findViewById(R.id.community_face_lv);
        communityCoverLv = findViewById(R.id.community_cover_lv);
        communityIntroductionLv = findViewById(R.id.community_introduction_lv);
        communityIDLv = findViewById(R.id.community_id_lv);
        createTopicCategoryLv = findViewById(R.id.create_topic_category_lv);
        communitySettingsLabel = findViewById(R.id.community_settings_label);
        createTopicLv = findViewById(R.id.create_topic_lv);
        groupNickNameLv = findViewById(R.id.self_nick_name);
        transferButton = findViewById(R.id.transfer_group_button);
        disbandButton = findViewById(R.id.disband_group_button);

        initData();
    }

    private void initData() {
        presenter.loadCommunityBean(communityID, new IUIKitCallback<CommunityBean>() {
            @Override
            public void onSuccess(CommunityBean data) {
                communityBean = data;
                presenter.setCurrentCommunityBean(data);
                setupView();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                super.onError(module, errCode, errMsg);
            }
        });
    }

    private void setupView() {
        if (communityBean == null) {
            return;
        }
        setNameView();
        setAvatarView();
        setCoverView();
        setIntroductionView();
        setIDView();
        setGroupNickNameView();
        setDisbandButton();
        setTransferButton();
        if (communityBean.isOwner()) {
            communitySettingsLabel.setVisibility(View.VISIBLE);
            createTopicLv.setVisibility(View.VISIBLE);
            createTopicCategoryLv.setVisibility(View.VISIBLE);
            setCreateCategoryView();
            setCreateTopicView();
        } else {
            communitySettingsLabel.setVisibility(View.GONE);
            createTopicLv.setVisibility(View.GONE);
            createTopicCategoryLv.setVisibility(View.GONE);
        }
    }

    private void setNameView() {
        if (communityBean.isOwner()) {
            communityNameLv.setShowArrow(true);
            communityNameLv.setOnContentClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    PopupInputCard popupInputCard = new PopupInputCard(CommunitySettingsActivity.this);
                    popupInputCard.setTitle(getString(R.string.community_community_name));
                    popupInputCard.setContent(communityBean.getCommunityName());
                    popupInputCard.setOnPositive(new PopupInputCard.OnClickListener() {
                        @Override
                        public void onClick(String result) {
                            presenter.modifyCommunityName(communityBean.getGroupId(), result, new IUIKitCallback<Void>() {
                                @Override
                                public void onSuccess(Void data) {
                                    // do nothing
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    ToastUtil.toastShortMessage("modify community name failed, code=" + errCode + " msg=" + errMsg);
                                }
                            });
                        }
                    });
                    popupInputCard.show(communityNameLv, Gravity.BOTTOM);
                }
            });
        }
        communityNameLv.setContent(communityBean.getCommunityName());
    }
    private void setAvatarView() {
        RoundCornerImageView cornerImageView = communityAvatarLv.getContentImage();
        GlideEngine.loadImageSetDefault(cornerImageView, communityBean.getGroupFaceUrl(),
                TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_default_group_icon_community));
        if (communityBean.isOwner()) {
            communityAvatarLv.setShowArrow(true);
            communityAvatarLv.setOnContentClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ArrayList<ImageSelectActivity.ImageBean> faceList = new ArrayList<>();
                    for (int i = 0; i < CommunityConstants.GROUP_FACE_COUNT; i++) {
                        ImageSelectActivity.ImageBean imageBean= new ImageSelectActivity.ImageBean();
                        imageBean.setThumbnailUri(String.format(CommunityConstants.GROUP_FACE_URL, (i + 1) + ""));
                        imageBean.setImageUri(String.format(CommunityConstants.GROUP_FACE_URL, (i + 1) + ""));
                        faceList.add(imageBean);
                    }

                    Intent intent = new Intent(CommunitySettingsActivity.this, ImageSelectActivity.class);
                    intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.community_choose_avatar));
                    intent.putExtra(ImageSelectActivity.SPAN_COUNT, 4);
                    intent.putExtra(ImageSelectActivity.PLACEHOLDER, com.tencent.qcloud.tuicore.R.drawable.core_default_user_icon_light);
                    intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(77));
                    intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(77));
                    intent.putExtra(ImageSelectActivity.DATA, faceList);
                    intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(communityBean.getGroupFaceUrl(), communityBean.getGroupFaceUrl(), false));
                    startActivityForResult(intent, REQUEST_FOR_CHANGE_AVATAR);
                }
            });
        }
    }
    private void setCoverView() {
        RoundCornerImageView cornerImageView = communityCoverLv.getContentImage();
        GlideEngine.loadImageSetDefault(cornerImageView, communityBean.getCoverUrl(), R.drawable.community_cover_default);
        if (communityBean.isOwner()) {
            communityCoverLv.setShowArrow(true);
            communityCoverLv.setOnContentClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ArrayList<ImageSelectActivity.ImageBean> coverList = new ArrayList<>();
                    for (int i = 0; i < CommunityConstants.COVER_COUNT; i++) {
                        ImageSelectActivity.ImageBean imageBean= new ImageSelectActivity.ImageBean();
                        imageBean.setThumbnailUri(String.format(CommunityConstants.COVER_URL, (i + 1) + ""));
                        imageBean.setImageUri(String.format(CommunityConstants.COVER_URL, (i + 1) + ""));
                        coverList.add(imageBean);
                    }

                    Intent intent = new Intent(CommunitySettingsActivity.this, ImageSelectActivity.class);
                    intent.putExtra(ImageSelectActivity.TITLE, getString(R.string.community_select_cover));
                    intent.putExtra(ImageSelectActivity.SPAN_COUNT, 2);
                    intent.putExtra(ImageSelectActivity.PLACEHOLDER, R.drawable.community_cover_default);
                    intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(165));
                    intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(79));
                    intent.putExtra(ImageSelectActivity.DATA, coverList);
                    intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(communityBean.getCoverUrl(), communityBean.getCoverUrl(), false));
                    startActivityForResult(intent, REQUEST_FOR_CHANGE_COVER);
                }
            });
        }
    }

    private void setIntroductionView() {
        if (communityBean.isOwner()) {
            communityIntroductionLv.setShowArrow(true);
            communityIntroductionLv.setOnContentClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    PopupInputCard popupInputCard = new PopupInputCard(CommunitySettingsActivity.this);
                    popupInputCard.setTitle(getString(R.string.community_community_introduction));
                    popupInputCard.setContent(communityBean.getIntroduction());
                    popupInputCard.setOnPositive(new PopupInputCard.OnClickListener() {
                        @Override
                        public void onClick(String result) {
                            presenter.modifyCommunityIntroduction(communityBean.getGroupId(), result, new IUIKitCallback<Void>() {
                                @Override
                                public void onSuccess(Void data) {
                                    // do nothing
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    ToastUtil.toastShortMessage("modify community introduction failed, code=" + errCode + " msg=" + errMsg);
                                }
                            });
                        }
                    });
                    popupInputCard.show(communityIntroductionLv, Gravity.BOTTOM);
                }
            });
        }
        if (TextUtils.isEmpty(communityBean.getIntroduction())) {
            communityIntroductionLv.setContent(getString(R.string.community_settings_not_set));
            communityIntroductionLv.getContentText().setTextColor(getResources().getColor(R.color.community_setting_linear_content_disable_color));
        } else {
            communityIntroductionLv.setContent(communityBean.getIntroduction());
            communityIntroductionLv.getContentText().setTextColor(getResources().getColor(R.color.community_setting_linear_content_default_color));
        }
    }

    private void setIDView() {
        communityIDLv.setContent(communityBean.getGroupId());
    }

    private void setCreateCategoryView() {
        createTopicCategoryLv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PopupInputCard inputCard = new PopupInputCard(CommunitySettingsActivity.this);
                inputCard.setTitle(getString(R.string.community_create_topic_category));
                inputCard.setOnPositive(new PopupInputCard.OnClickListener() {
                    @Override
                    public void onClick(String result) {
                        presenter.createCategory(communityBean.getGroupId(), result);
                    }
                });
                inputCard.show(createTopicCategoryLv, Gravity.BOTTOM);
            }
        });
    }
    private void setCreateTopicView() {
        createTopicLv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(CommunitySettingsActivity.this, CreateTopicActivity.class);
                intent.putExtra(CommunityConstants.COMMUNITY_BEAN, communityBean);
                startActivity(intent);
            }
        });
    }

    private void setGroupNickNameView() {
        presenter.getGroupNameCard(communityBean.getGroupId(), new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                groupNickNameLv.setContent(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
        groupNickNameLv.setOnContentClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PopupInputCard popupInputCard = new PopupInputCard(CommunitySettingsActivity.this);
                popupInputCard.setTitle(getString(R.string.community_self_nick_name));
                popupInputCard.setContent(groupNickNameLv.getContent());
                popupInputCard.setOnPositive(new PopupInputCard.OnClickListener() {
                    @Override
                    public void onClick(String result) {
                        presenter.modifyCommunitySelfNameCard(communityBean.getGroupId(), result, new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                setGroupNickNameView();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastShortMessage("modify name card failed, code=" + errCode + " msg=" + errMsg);
                            }
                        });
                    }
                });
                popupInputCard.show(groupNickNameLv, Gravity.BOTTOM);
            }
        });
    }

    private void setDisbandButton() {
        if (communityBean.isOwner()) {
            disbandButton.setVisibility(View.VISIBLE);
        } else {
            disbandButton.setVisibility(View.GONE);
        }
        disbandButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (disbandDialog == null) {
                    disbandDialog = new TUIKitDialog(CommunitySettingsActivity.this).builder()
                            .setTitle(getString(R.string.community_disband_group))
                            .setCancelOutside(true)
                            .setPositiveButton(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    disbandCommunity();
                                }
                            })
                            .setNegativeButton(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {

                                }
                            });
                }
                disbandDialog.show();
            }
        });
    }


    private void disbandCommunity() {
        presenter.disbandCommunity(communityBean.getGroupId(), new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("dismiss community failed, code=" + errCode + " errMsg=" + errMsg);
            }
        });
    }

    private void setTransferButton() {
        if (communityBean.isOwner()) {
            transferButton.setVisibility(View.VISIBLE);
        } else {
            transferButton.setVisibility(View.GONE);
        }
        transferButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle bundle = new Bundle();
                bundle.putSerializable(CommunityConstants.COMMUNITY_BEAN, communityBean);
                bundle.putSerializable(CommunityConstants.IS_SELECT_MODE, true);
                bundle.putSerializable(CommunityConstants.LIMIT, 1);
                TUICore.startActivity(CommunitySettingsActivity.this, "CommunityMemberActivity", bundle, REQUEST_FOR_CHANGE_OWNER);
            }
        });
    }

    @Override
    public void onCommunityChanged(CommunityBean communityBean) {
        if (TextUtils.equals(communityBean.getGroupId(), this.communityBean.getGroupId())) {
            this.communityBean = communityBean;
            setupView();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null) {
            if (requestCode == REQUEST_FOR_CHANGE_AVATAR) {
                ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
                if (imageBean == null) {
                    return;
                }

                String avatarUrl = imageBean.getImageUri();
                presenter.modifyCommunityAvatar(communityBean.getGroupId(), avatarUrl, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        // do nothing
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage("modify group avatar failed, code=" + errCode + " msg=" + errMsg);
                    }
                });
            } else if (requestCode == REQUEST_FOR_CHANGE_COVER) {
                ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
                if (imageBean == null) {
                    return;
                }

                String coverUrl = imageBean.getImageUri();
                presenter.modifyCommunityCover(communityBean.getGroupId(), coverUrl, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        // do nothing
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage("modify group avatar failed, code=" + errCode + " msg=" + errMsg);
                    }
                });
            } else if (requestCode == REQUEST_FOR_CHANGE_OWNER) {
                List<String> userIDs = data.getStringArrayListExtra(CommunityConstants.LIST);
                if (!userIDs.isEmpty()) {
                    String newOwnerID = userIDs.get(0);
                    presenter.transferCommunityOwner(communityBean.getGroupId(), newOwnerID, new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            initData();
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage("transfer group owner failed, code=" + errCode + " msg=" + errMsg);
                        }
                    });
                }

            }
        }
    }
}