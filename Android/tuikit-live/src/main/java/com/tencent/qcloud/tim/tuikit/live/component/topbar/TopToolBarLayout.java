package com.tencent.qcloud.tim.tuikit.live.component.topbar;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.tuikit.live.component.common.CircleImageView;
import com.tencent.qcloud.tim.tuikit.live.component.topbar.adapter.SpacesDecoration;
import com.tencent.qcloud.tim.tuikit.live.component.topbar.adapter.TopAudienceListAdapter;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;

import java.util.ArrayList;
import java.util.List;

public class TopToolBarLayout extends LinearLayout {
    private static final String TAG = "TopAnchorInfoLayout";

    private Context         mContext;
    private LinearLayout    mLayoutRoot;
    private CircleImageView mImageAnchorIcon;
    private TextView        mTextAnchorName;
    private TextView        mButtonAnchorFollow;
    private TextView        mAudienceNumber;
    private RecyclerView    mRecycleAudiences;

    private TopAudienceListAdapter         mTopAudienceListAdapter;
    private TopToolBarDelegate             mTopToolBarDelegate;
    private TRTCLiveRoomDef.LiveAnchorInfo mLiveAnchorInfo;

    public TopToolBarLayout(Context context) {
        super(context);
        initView(context);
    }

    public TopToolBarLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    public TopToolBarLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        mContext = context;
        mLayoutRoot = (LinearLayout) inflate(context, R.layout.live_layout_top_tool_bar, this);
        initAnchorInfoView();

        initAudienceRecyclerView();
        initAudienceNumberView();
        updateAudienceNumber();
    }

    private void initAnchorInfoView() {
        mImageAnchorIcon = mLayoutRoot.findViewById(R.id.iv_anchor_head);
        mTextAnchorName = mLayoutRoot.findViewById(R.id.tv_anchor_name);
        mButtonAnchorFollow = mLayoutRoot.findViewById(R.id.btn_anchor_follow);

        // 处理主播头像点击事件
        mImageAnchorIcon.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mTopToolBarDelegate != null) {
                    mTopToolBarDelegate.onClickAnchorAvatar();
                }
            }
        });

        // 处理主播关注按钮点击事件
        mButtonAnchorFollow.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mTopToolBarDelegate != null) {
                    mTopToolBarDelegate.onClickFollow(mLiveAnchorInfo);
                }
            }
        });
    }

    private void initAudienceRecyclerView() {
        mRecycleAudiences = mLayoutRoot.findViewById(R.id.rv_audiences);

        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRecycleAudiences.setLayoutManager(layoutManager);
        mRecycleAudiences.addItemDecoration(new SpacesDecoration(mContext, 3, SpacesDecoration.HORIZONTAL));

        DefaultItemAnimator defaultItemAnimator = new DefaultItemAnimator();
        defaultItemAnimator.setAddDuration(500);
        defaultItemAnimator.setRemoveDuration(500);
        mRecycleAudiences.setItemAnimator(defaultItemAnimator);

        mTopAudienceListAdapter = new TopAudienceListAdapter(new ArrayList<TRTCLiveRoomDef.TRTCLiveUserInfo>(), new TopAudienceListAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(TRTCLiveRoomDef.TRTCLiveUserInfo audienceInfo) {
                if (mTopToolBarDelegate != null) {
                    mTopToolBarDelegate.onClickAudience(audienceInfo);
                }
            }
        });
        mRecycleAudiences.setAdapter(mTopAudienceListAdapter);
    }

    private void initAudienceNumberView() {
        mAudienceNumber = mLayoutRoot.findViewById(R.id.tv_audience_number);
        mAudienceNumber.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mTopToolBarDelegate != null) {
                    mTopToolBarDelegate.onClickOnlineNum();
                }
            }
        });
    }

    public void setHasFollowed(boolean followed) {
        if (followed) {
            mButtonAnchorFollow.setVisibility(GONE);
        } else {
            mButtonAnchorFollow.setVisibility(VISIBLE);
        }
    }

    public void setAnchorInfo(TRTCLiveRoomDef.LiveAnchorInfo anchorInfo) {
        mLiveAnchorInfo = anchorInfo;
        mTextAnchorName.setText(!TextUtils.isEmpty(anchorInfo.userName) ? anchorInfo.userName : anchorInfo.userId);
        if (!TextUtils.isEmpty(anchorInfo.avatarUrl)) {
            Glide.with(TUIKitLive.getAppContext()).load(anchorInfo.avatarUrl).into(mImageAnchorIcon);
        } else {
            Glide.with(TUIKitLive.getAppContext()).load(R.drawable.live_default_head_img).into(mImageAnchorIcon);
        }
    }

    public void addAudienceListUser(List<TRTCLiveRoomDef.TRTCLiveUserInfo> userInfoList) {
        mTopAudienceListAdapter.addAudienceUser(userInfoList);
        updateAudienceNumber();
    }

    public void addAudienceListUser(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mTopAudienceListAdapter.addAudienceUser(userInfo);
        updateAudienceNumber();
    }

    public void removeAudienceUser(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mTopAudienceListAdapter.removeAudienceUser(userInfo);
        updateAudienceNumber();
    }

    private void updateAudienceNumber() {
        int size = mTopAudienceListAdapter.getAudienceListSize();
        Log.d(TAG, "setOnlineNum number = " + size);
        String audienceNum = mContext.getString(R.string.live_on_line_number, size < 0 ? 0 : size);
        mAudienceNumber.setText(audienceNum);
    }

    public void setTopToolBarDelegate(TopToolBarDelegate delegate) {
        mTopToolBarDelegate = delegate;
    }

    public interface TopToolBarDelegate {
        void onClickAnchorAvatar();

        void onClickFollow(TRTCLiveRoomDef.LiveAnchorInfo liveAnchorInfo);

        void onClickAudience(TRTCLiveRoomDef.TRTCLiveUserInfo audienceInfo);

        void onClickOnlineNum();
    }
}
