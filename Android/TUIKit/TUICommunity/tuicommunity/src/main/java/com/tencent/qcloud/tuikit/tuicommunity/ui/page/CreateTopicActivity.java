package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.TUICommunityService;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.component.SelectListPopupView;
import com.tencent.qcloud.tuikit.tuicommunity.component.SettingsLinearView;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.BottomPopupCard;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.TopicPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICreateTopicActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import java.util.ArrayList;
import java.util.List;

public class CreateTopicActivity extends BaseLightActivity implements ICreateTopicActivity {
    private TitleBarLayout titleBarLayout;
    private EditText topicNameEdit;

    private View videoTypeArea;
    private View liveTypeArea;
    private SettingsLinearView topicCategoryView;
    private SelectListPopupView selectListPopupView;

    private CommunityBean communityBean;
    private TopicPresenter presenter;
    private CommunityPresenter communityPresenter;
    private String category;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_activity_create_topic);
        Intent intent = getIntent();
        communityBean = (CommunityBean) intent.getSerializableExtra(CommunityConstants.COMMUNITY_BEAN);

        presenter = new TopicPresenter();
        communityPresenter = new CommunityPresenter();
        communityPresenter.setCreateTopicActivity(this);
        communityPresenter.setCommunityEventListener();
        communityPresenter.setCurrentCommunityBean(communityBean);

        titleBarLayout = findViewById(R.id.create_topic_title);
        topicNameEdit = findViewById(R.id.topic_name_edit);
        videoTypeArea = findViewById(R.id.video_type_area);
        liveTypeArea = findViewById(R.id.live_type_area);
        topicCategoryView = findViewById(R.id.topic_category_linear);
        titleBarLayout.setTitle(getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideSoftInput();
                createTopic();
            }
        });

        videoTypeArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastShortMessage(getString(R.string.community_coming_soon));
            }
        });

        liveTypeArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastShortMessage(getString(R.string.community_coming_soon));
            }
        });

        topicCategoryView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideSoftInput();
                ThreadUtils.postOnUiThreadDelayed(new Runnable() {
                    @Override
                    public void run() {
                        showTopicCategoryView();
                    }
                }, 120);
            }
        });
    }

    @Override
    public void onCommunityChanged(CommunityBean communityBean) {
        if (TextUtils.equals(this.communityBean.getGroupId(), communityBean.getGroupId())) {
            this.communityBean = communityBean;
        }
    }

    private void setCategory() {
        topicCategoryView.setName(category);
    }

    private void showTopicCategoryView() {
        if (selectListPopupView != null && selectListPopupView.isShown()) {
            return;
        }
        selectListPopupView = new SelectListPopupView(this);
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
                if (!TextUtils.equals(noCategory, data)) {
                    category = data;
                    setCategory();
                } else {
                    category = null;
                    topicCategoryView.setName(noCategory);
                }
            }
        });
        BottomPopupCard bottomPopupCard = new BottomPopupCard(this, selectListPopupView);
        bottomPopupCard.show(titleBarLayout);
    }

    private void createTopic() {
        String topicName = topicNameEdit.getText().toString();
        if (!TextUtils.isEmpty(topicName)) {
            presenter.createTopic(communityBean.getGroupId(), topicName, category, TopicBean.TOPIC_TYPE_TEXT, new IUIKitCallback<String>() {
                @Override
                public void onSuccess(String data) {
                    TUICore.notifyEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_TOPIC, null);
                    ToastUtil.toastShortMessage(TUICommunityService.getAppContext().getString(R.string.community_create_topic_success));
                    finish();
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastShortMessage(
                        TUICommunityService.getAppContext().getString(R.string.community_create_topic_failed) + ", code=" + errCode + " message=" + errMsg);
                }
            });
        }
    }
}