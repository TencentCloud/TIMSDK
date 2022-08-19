package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.reflect.TypeToken;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.component.banner.BannerView;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityExperiencePresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunitySelfView;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CommunitySelfView extends FrameLayout implements ICommunitySelfView {

    private BannerView bannerView;
    private CommunityExperienceView createCommunityExperience;
    private CommunityExperienceView addCommunityExperience;
    private CommunityExperienceView sendMessageInTopic;
    private CommunityExperienceView replyMessageInTopic;
    private CommunityExperienceView disbandCommunityExperience;
    private CommunityExperienceView createTopicExperience;
    private CommunityExperienceView deleteTopicExperience;
    private TextView experienceMoreButton;
    private CommunityExperiencePresenter presenter;

    public CommunitySelfView(@NonNull Context context) {
        super(context);
        init();
    }

    public CommunitySelfView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CommunitySelfView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public CommunitySelfView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        presenter = new CommunityExperiencePresenter();
        presenter.setCommunitySelfView(this);
        View view = LayoutInflater.from(getContext()).inflate(R.layout.community_self_frame, this);
        bannerView = view.findViewById(R.id.banner_view);
        List<BannerView.BannerItem> bannerItems = new ArrayList<>();
        BannerView.BannerItem communityIntroduction = new BannerView.BannerItem();
        communityIntroduction.setImageUri(R.drawable.community_introduction);
        communityIntroduction.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                CommunityUtil.openWebUrl(getContext(), CommunityConstants.COMMUNITY_INTRODUCTION);
            }
        });
        bannerItems.add(communityIntroduction);
        BannerView.BannerItem imNew = new BannerView.BannerItem();
        imNew.setImageUri(R.drawable.community_im_new);
        imNew.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                CommunityUtil.openWebUrl(getContext(), CommunityConstants.IM_NEW_BUYING);
            }
        });
        bannerItems.add(imNew);
        bannerView.setBannerData(bannerItems);

        createCommunityExperience = view.findViewById(R.id.create_community_experience);
        addCommunityExperience = view.findViewById(R.id.add_community_experience);
        sendMessageInTopic = view.findViewById(R.id.send_message_experience);
        replyMessageInTopic = view.findViewById(R.id.reply_message_experience);
        disbandCommunityExperience = view.findViewById(R.id.disband_community_experience);
        createTopicExperience = view.findViewById(R.id.create_topic_experience);
        deleteTopicExperience = view.findViewById(R.id.delete_topic_experience);
        experienceMoreButton = view.findViewById(R.id.experience_more_button);

        experienceMoreButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                CommunityUtil.openWebUrl(getContext(), CommunityConstants.EXPERIENCE_MORE_DEMOS);
            }
        });

        setExperience();
    }

    @Override
    public void setExperience() {
        Gson gson = new Gson();
        String experience = SPUtils.getInstance(CommunityConstants.COMMUNITY_SP_NAME).getString(CommunityConstants.COMMUNITY_EXPERIENCE_SP_KEY);
        Map<String, Boolean> experienceMap = null;
        try {
            experienceMap = gson.fromJson(experience, TypeToken.getParameterized(Map.class, String.class, Boolean.class).getType());
        } catch (JsonParseException e) {
            TUICommunityLog.e("CommunitySelfView", "setExperience " + e.getMessage());
        }
        if (experienceMap != null) {
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_CREATE_COMMUNITY_KEY))) {
                createCommunityExperience.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_ADD_COMMUNITY_KEY))) {
                addCommunityExperience.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_SEND_MESSAGE_IN_TOPIC_KEY))) {
                sendMessageInTopic.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_REPLY_MESSAGE_IN_TOPIC_KEY))) {
                replyMessageInTopic.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_DISBAND_COMMUNITY_KEY))) {
                disbandCommunityExperience.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_CREATE_TOPIC_KEY))) {
                createTopicExperience.setState(true);
            }
            if (Boolean.TRUE.equals(experienceMap.get(CommunityConstants.COMMUNITY_EXPERIENCE_DELETE_TOPIC_KEY))) {
                deleteTopicExperience.setState(true);
            }
        }
    }
}
