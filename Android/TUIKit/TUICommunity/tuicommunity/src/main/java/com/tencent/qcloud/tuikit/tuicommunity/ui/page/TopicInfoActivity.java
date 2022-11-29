package com.tencent.qcloud.tuikit.tuicommunity.ui.page;


import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.component.popupcard.PopupInputCard;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.component.SelectListPopupView;
import com.tencent.qcloud.tuikit.tuicommunity.component.SettingsLinearView;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.BottomPopupCard;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.TopicPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ITopicInfoActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

import java.util.ArrayList;
import java.util.List;

public class TopicInfoActivity extends BaseLightActivity implements ITopicInfoActivity {

    private TopicPresenter presenter;

    private TextView deleteTopicButton;
    private SettingsLinearView nameSetting;
    private SettingsLinearView categorySetting;
    private TopicBean topicBean;
    private CommunityBean communityBean;
    private TUIKitDialog deleteTopicDialog;
    private SelectListPopupView selectListPopupView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_activity_topic_info);
        nameSetting = findViewById(R.id.topic_name_setting);
        deleteTopicButton = findViewById(R.id.delete_topic_button);
        categorySetting = findViewById(R.id.topic_category_setting);
        Intent intent = getIntent();
        String topicID = intent.getStringExtra(TUIConstants.TUICommunity.TOPIC_ID);
        if (TextUtils.isEmpty(topicID)) {
            return;
        }

        presenter = new TopicPresenter();
        presenter.setCommunityEventListener();
        presenter.setTopicInfoActivity(this);
        loadTopicBean(topicID);
    }

    private void loadTopicBean(String topicID) {
        presenter.getCommunityBean(topicID, new IUIKitCallback<CommunityBean>() {
            @Override
            public void onSuccess(CommunityBean data) {
                communityBean = data;
                presenter.setCommunityBean(data);
                if (data.isOwner()) {
                    setOwnerView();
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
            }
        });

        presenter.getTopicBean(topicID, new IUIKitCallback<TopicBean>() {
            @Override
            public void onSuccess(TopicBean data) {
                topicBean = data;
                nameSetting.setContent(topicBean.getTopicName());
                if (TextUtils.isEmpty(topicBean.getCategory())) {
                    categorySetting.setContent(getString(R.string.community_no_category));
                } else {
                    categorySetting.setContent(topicBean.getCategory());
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUICommunityLog.e("TopicInfoActivity", "getTopicBean failed, code=" + errCode + ", msg=" + errMsg);
            }
        });
    }

    private void setOwnerView() {
        deleteTopicButton.setVisibility(View.VISIBLE);
        deleteTopicButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                deleteTopic();
            }
        });
        nameSetting.setShowArrow(true);
        nameSetting.setOnContentClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (topicBean == null) {
                    return;
                }
                PopupInputCard popupInputCard = new PopupInputCard(TopicInfoActivity.this);
                popupInputCard.setTitle(getString(R.string.community_topic_name));
                popupInputCard.setContent(topicBean.getTopicName());
                popupInputCard.setOnPositive(new PopupInputCard.OnClickListener() {
                    @Override
                    public void onClick(String result) {
                        presenter.modifyTopicName(topicBean.getID(), result, new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                // do nothing, you can receive onTopicInfoChanged callback in TUICommunityService.java
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastShortMessage("modify name failed, code=" + errCode + " msg=" + errMsg);
                            }
                        });
                    }
                });
                popupInputCard.show(nameSetting, Gravity.BOTTOM);
            }
        });
        categorySetting.setShowArrow(true);
        categorySetting.setOnContentClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (topicBean == null || communityBean == null) {
                    return;
                }
                if (selectListPopupView != null && selectListPopupView.isShown()) {
                    return;
                }
                selectListPopupView = new SelectListPopupView(TopicInfoActivity.this);
                List<String> selectData = new ArrayList<>();
                String noCategory = getString(R.string.community_no_category);
                selectData.add(noCategory);
                if (communityBean.getTopicCategories() != null) {
                    selectData.addAll(communityBean.getTopicCategories());
                }

                selectListPopupView.setData(selectData);
                selectListPopupView.setTitle(getString(R.string.community_select_category));
                selectListPopupView.setMaxHeightPx(ScreenUtil.dip2px(360));
                selectListPopupView.setOnSelectListener(new SelectListPopupView.OnSelectListener() {
                    @Override
                    public void onSelected(String data) {
                        if (!TextUtils.equals(data, topicBean.getCategory())) {
                            if (TextUtils.equals(noCategory, data)) {
                                data = "";
                            }
                            presenter.modifyTopicCategory(topicBean, data, new IUIKitCallback<Void>() {
                                @Override
                                public void onSuccess(Void data) {
                                    // do nothing, you can receive onTopicInfoChanged callback in TUICommunityService.java
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    ToastUtil.toastShortMessage("modify category failed, code=" + errCode + " msg=" + errMsg);
                                }
                            });
                        }
                    }
                });
                BottomPopupCard bottomPopupCard = new BottomPopupCard(TopicInfoActivity.this, selectListPopupView);
                bottomPopupCard.show(categorySetting);

            }
        });
    }

    private void deleteTopic() {
        if (deleteTopicDialog == null || !deleteTopicDialog.isShowing()) {
            deleteTopicDialog = new TUIKitDialog(this)
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getString(R.string.community_delete_topic_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getString(com.tencent.qcloud.tuicore.R.string.sure), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            presenter.deleteTopic(topicBean.getID(), new IUIKitCallback<Void>() {
                                @Override
                                public void onSuccess(Void data) {
                                    finish();
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    ToastUtil.toastShortMessage("delete topic failed, code=" + errCode + " msg=" + errMsg);
                                }
                            });
                        }
                    });
            deleteTopicDialog.show();
        }
    }

    @Override
    public void onTopicChanged(TopicBean topicBean) {
        if (TextUtils.equals(this.topicBean.getID(), topicBean.getID())) {

            this.topicBean = topicBean;
            nameSetting.setContent(topicBean.getTopicName());
            if (TextUtils.isEmpty(topicBean.getCategory())) {
                categorySetting.setContent(getString(R.string.community_no_category));
            } else {
                categorySetting.setContent(topicBean.getCategory());
            }
        }
    }
}