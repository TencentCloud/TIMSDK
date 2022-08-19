package com.tencent.qcloud.tuikit.tuicommunity.presenter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.tuicommunity.TUICommunityService;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.CommunityEventListener;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunitySelfView;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;

import java.util.HashMap;
import java.util.Map;

public class CommunityExperiencePresenter {
    private static final String TAG = "CommunityExperiencePresenter";

    private ICommunitySelfView iCommunitySelfView;
    private CommunityEventListener eventListener;
    private Map<String, Boolean> experienceMap;
    public CommunityExperiencePresenter() {
        setExperienceChangedListener();
        setExperience();
    }

    public void setCommunitySelfView(ICommunitySelfView iCommunitySelfView) {
        this.iCommunitySelfView = iCommunitySelfView;
    }

    private void setExperienceChangedListener() {
        eventListener = new CommunityEventListener() {
            @Override
            public void onCommunityExperienceChanged(String experienceName) {
                if (experienceMap == null) {
                    experienceMap = new HashMap<>();
                }
                if (Boolean.TRUE.equals(experienceMap.get(experienceName))) {
                    return;
                }
                experienceMap.put(experienceName, true);
                Gson gson = new Gson();
                String experienceString = gson.toJson(experienceMap);
                SPUtils.getInstance(CommunityConstants.COMMUNITY_SP_NAME).put(CommunityConstants.COMMUNITY_EXPERIENCE_SP_KEY, experienceString, true);
                if (iCommunitySelfView != null) {
                    iCommunitySelfView.setExperience();
                }
            }
        };
        TUICommunityService.getInstance().addCommunityEventListener(eventListener);
    }

    private void setExperience() {
        Gson gson = new Gson();
        String experience = SPUtils.getInstance(CommunityConstants.COMMUNITY_SP_NAME).getString(CommunityConstants.COMMUNITY_EXPERIENCE_SP_KEY);
        experienceMap = gson.fromJson(experience, TypeToken.getParameterized(Map.class, String.class, Boolean.class).getType());
    }
}
