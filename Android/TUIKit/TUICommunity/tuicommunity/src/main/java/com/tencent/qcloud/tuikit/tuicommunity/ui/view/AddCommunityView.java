package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.component.banner.BannerView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.CreateCommunityActivity;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.JoinCommunityActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;

import java.util.ArrayList;
import java.util.List;

public class AddCommunityView extends FrameLayout {
    private static final int CREATE_CODE = 1;
    private View createBtn;
    private View joinBtn;
    private BannerView bannerView;

    public AddCommunityView(@NonNull Context context) {
        super(context);
        init();
    }

    public AddCommunityView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AddCommunityView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public AddCommunityView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.community_add_community_layout, this);
        createBtn = view.findViewById(R.id.create_community);
        joinBtn = view.findViewById(R.id.join_community);
        bannerView = view.findViewById(R.id.banner_view);
        initEvent();
    }

    private void initEvent() {
        createBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getContext(), CreateCommunityActivity.class);
                Activity activity = (Activity) getContext();
                activity.startActivityForResult(intent, CREATE_CODE);
            }
        });

        joinBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getContext(), JoinCommunityActivity.class);
                Activity activity = (Activity) getContext();
                activity.startActivity(intent);
            }
        });

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
    }

}
