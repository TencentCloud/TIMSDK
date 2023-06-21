package com.tencent.cloud.tuikit.videoseat.ui;

import static android.content.res.Configuration.ORIENTATION_PORTRAIT;
import static com.tencent.cloud.tuikit.videoseat.Constants.VOLUME_NO_SOUND;
import static com.tencent.cloud.tuikit.videoseat.ui.layout.UserListAdapter.PAYLOAD_AUDIO;
import static com.tencent.cloud.tuikit.videoseat.ui.layout.UserListAdapter.PAYLOAD_VIDEO;

import android.content.Context;
import android.content.res.Configuration;
import android.util.Log;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.videoseat.R;
import com.tencent.cloud.tuikit.videoseat.ui.layout.LandscapePageLayoutManager;
import com.tencent.cloud.tuikit.videoseat.ui.layout.PageLayoutManager;
import com.tencent.cloud.tuikit.videoseat.ui.layout.PagerSnapHelper;
import com.tencent.cloud.tuikit.videoseat.ui.layout.PortraitPageLayoutManager;
import com.tencent.cloud.tuikit.videoseat.ui.layout.UserListAdapter;
import com.tencent.cloud.tuikit.videoseat.ui.view.CircleIndicator;
import com.tencent.cloud.tuikit.videoseat.ui.view.UserDisplayView;
import com.tencent.cloud.tuikit.videoseat.viewmodel.IVideoSeatViewModel;
import com.tencent.cloud.tuikit.videoseat.viewmodel.UserEntity;
import com.tencent.cloud.tuikit.videoseat.viewmodel.VideoSeatViewModel;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.ArrayList;
import java.util.List;

public class TUIVideoSeatView extends RelativeLayout {
    private static final String TAG = "TUIVideoSeatView";

    private Context mContext;

    private RecyclerView      mRecyclerView;
    private UserListAdapter   mMemberListAdapter;
    private CircleIndicator   mCircleIndicator;
    private PageLayoutManager mPageLayoutManager;
    private UserDisplayView   mUserDisplayView;

    private List<String>     mVisibleVideoStreams;
    private List<UserEntity> mMemberEntityList;

    private IVideoSeatViewModel mViewModel;
    private TUIRoomEngine       mRoomEngine;

    private boolean mIsSpeakerModeOn;
    private boolean mIsTwoPersonVideoOn;
    private boolean mIsTwoPersonSwitched;

    private int mScreenOrientation = ORIENTATION_PORTRAIT;
    private int mCurrentPageIndex = 0;

    public TUIVideoSeatView(Context context, String roomId, TUIRoomEngine roomEngine) {
        super(context);
        mContext = context;
        mRoomEngine = roomEngine;
    }

    public void setMemberEntityList(List<UserEntity> memberEntityList) {
        mMemberEntityList = memberEntityList;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        inflate(mContext, R.layout.tuivideoseat_anchor_list_view, this);
        mUserDisplayView = findViewById(R.id.tuivideoseat_user_talking_video_view);
        mCircleIndicator = findViewById(R.id.simple_view);
        int unSelectColor = getResources().getColor(R.color.tuivideoseat_color_indicator_un_select);
        int selectColor = getResources().getColor(R.color.tuivideoseat_color_white);
        mCircleIndicator.setSelectDotColor(selectColor);
        mCircleIndicator.setUnSelectDotColor(unSelectColor);
        mViewModel = new VideoSeatViewModel(mContext, mRoomEngine, this);
        initListView();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mViewModel.destroy();
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (newConfig.orientation != mScreenOrientation) {
            mScreenOrientation = newConfig.orientation;
            chooseLayoutManagerByOrientation();
        }
        if (mIsSpeakerModeOn) {
            enableSpeakerMode(true);
        }
        if (mIsTwoPersonVideoOn) {
            enableTwoPersonVideoMeeting(true);
        }
    }

    private void chooseLayoutManagerByOrientation() {
        if (mScreenOrientation == ORIENTATION_PORTRAIT) {
            mPageLayoutManager = new PortraitPageLayoutManager();
        } else {
            mPageLayoutManager = new LandscapePageLayoutManager();
        }
        mPageLayoutManager.setAllowContinuousScroll(false);
        mPageLayoutManager.setPageListener(new PageLayoutManager.PageListener() {
            @Override
            public void onPageSizeChanged(int pageSize) {

            }

            @Override
            public void onPageSelect(int pageIndex) {
                if (mIsSpeakerModeOn && mCurrentPageIndex == 0 && pageIndex == 1) {
                    post(new Runnable() {
                        @Override
                        public void run() {
                            mMemberListAdapter.notifyDataSetChanged();
                        }
                    });
                }
                mCurrentPageIndex = pageIndex;
                updateUserTalkingViewVisible(pageIndex);
            }

            @Override
            public void onItemVisible(int fromItem, int toItem) {
                Log.d(TAG, "onItemVisible: " + fromItem + " to " + toItem);
                    processVideoPlay(fromItem, toItem);
            }
        });
        mRecyclerView.setLayoutManager(mPageLayoutManager);
    }

    private void initListView() {
        mRecyclerView = findViewById(R.id.rv_list);
        mMemberListAdapter = new UserListAdapter(mContext, mMemberEntityList);
        mRecyclerView.setHasFixedSize(true);
        chooseLayoutManagerByOrientation();
        mRecyclerView.setAdapter(mMemberListAdapter);
        mCircleIndicator.setPageNum(mPageLayoutManager.getTotalPageCount());
        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                updateScrollIndicator();
            }
        });
        PagerSnapHelper pagerSnapHelper = new PagerSnapHelper();
        pagerSnapHelper.attachToRecyclerView(mRecyclerView);
    }

    private void updateUserTalkingViewVisible() {
        updateUserTalkingViewVisible(-1);
    }

    private void updateUserTalkingViewVisible(int pageIndex) {
        if (mIsSpeakerModeOn) {
            mUserDisplayView.setVisibility(
                    pageIndex == PageLayoutManager.SPEAKER_PAGE_INDEX ? VISIBLE : INVISIBLE);
        } else if (mIsTwoPersonVideoOn) {
            mUserDisplayView.setVisibility(VISIBLE);
        } else {
            mUserDisplayView.setVisibility(INVISIBLE);
        }
    }

    private void initUserTalkingViewLayout() {
        if (!mIsSpeakerModeOn && !mIsTwoPersonVideoOn) {
            return;
        }
        if (!(mUserDisplayView.getLayoutParams() instanceof RelativeLayout.LayoutParams)) {
            return;
        }
        UserEntity talkingEntity = mUserDisplayView.getUserEntity();
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) mUserDisplayView.getLayoutParams();
        setUserTalkingViewSize(talkingEntity, layoutParams);

        layoutParams.leftMargin =
                ScreenUtil.getScreenWidth(mContext) - layoutParams.width - UserDisplayView.MARGIN_PX;
        layoutParams.topMargin = UserDisplayView.MARGIN_PX;
        mUserDisplayView.setLayoutParams(layoutParams);
    }

    private void setUserTalkingViewSize(UserEntity talkingEntity, RelativeLayout.LayoutParams layoutParams) {
        int sizeSmall = (int) mContext.getResources().getDimension(R.dimen.tuivideoseat_video_view_size_small);
        int sizeMiddle = (int) mContext.getResources().getDimension(R.dimen.tuivideoseat_video_view_size_middle);
        if (talkingEntity == null || !talkingEntity.isVideoAvailable()) {
            layoutParams.width = sizeSmall;
            layoutParams.height = sizeSmall;
        } else if (mContext.getResources().getConfiguration().orientation == ORIENTATION_PORTRAIT) {
            layoutParams.width = sizeSmall;
            layoutParams.height = sizeMiddle;
        } else {
            layoutParams.width = sizeMiddle;
            layoutParams.height = sizeSmall;
        }
    }

    private void updateUserTalkingView(int position) {
        if (position < 0 || position >= mMemberEntityList.size()) {
            return;
        }
        UserEntity newEntity = mMemberEntityList.get(position);
        if (newEntity == null) {
            return;
        }

        mUserDisplayView.setUserEntity(newEntity);
        if (newEntity.isVideoAvailable()) {
            startVideoPlay(newEntity);
        } else {
            stopVideoPlay(newEntity);
        }

        ensureUserTalkingViewFullyDisplayed();
        mUserDisplayView.enableVolumeEffect(newEntity.isAudioAvailable());
        mUserDisplayView.updateVolumeEffect(newEntity.getAudioVolume());
        mUserDisplayView.setVolume(newEntity.isTalk());
        // sdk 最后不会回调音量0，所以 app 需要每次将音量清 0
        newEntity.setAudioVolume(VOLUME_NO_SOUND);
    }


    private void ensureUserTalkingViewFullyDisplayed() {
        if (!mIsSpeakerModeOn && !mIsTwoPersonVideoOn) {
            return;
        }
        if (!(mUserDisplayView.getLayoutParams() instanceof RelativeLayout.LayoutParams)) {
            return;
        }
        UserEntity talkingEntity = mUserDisplayView.getUserEntity();
        if (talkingEntity == null) {
            return;
        }
        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mUserDisplayView.getLayoutParams();
        setUserTalkingViewSize(talkingEntity, params);

        int rightMargin =
                ScreenUtil.getScreenWidth(mContext) - params.leftMargin - params.width - UserDisplayView.MARGIN_PX;
        params.leftMargin += rightMargin < 0 ? rightMargin : 0;
        int bottomMargin = getHeight() - params.topMargin - params.height - UserDisplayView.MARGIN_PX;
        params.topMargin += bottomMargin < 0 ? bottomMargin : 0;
        mUserDisplayView.setLayoutParams(params);
    }

    private void updateScrollIndicator() {
        mCircleIndicator.onPageScrolled(mPageLayoutManager.getCurrentPageIndex(), 0.0f);
    }

    /**
     * Process items to be displayed on the page. If you scroll to a new page, the playback of all items on the
     * previous page needs to be stopped. Whether a playback page is required for the new page is determined based on
     * whether video is enabled.
     *
     * @param fromItem
     * @param toItem
     */
    private void processVideoPlay(int fromItem, int toItem) {
        if (mViewModel == null) {
            return;
        }
        List<String> newUserIds = new ArrayList<>();
        if (mVisibleVideoStreams == null) {
            mVisibleVideoStreams = new ArrayList<>();
        }
        for (int i = fromItem; i <= toItem; i++) {
            UserEntity entity = mMemberEntityList.get(i);
            startVideoPlay(entity);
            if (!entity.isSelf()) {
                newUserIds.add(entity.getUserId());
            }
        }
        for (String userId : mVisibleVideoStreams) {
            if (!newUserIds.contains(userId) && !isUserTalkingViewPlaying(userId)) {
                mViewModel.stopPlayVideo(userId, false, false);
            }
        }
        mVisibleVideoStreams = newUserIds;
    }

    private boolean isUserTalkingViewPlaying(String userId) {
        UserEntity talkingEntity = mUserDisplayView.getUserEntity();
        if (talkingEntity == null) {
            return false;
        }
        if (!talkingEntity.isVideoAvailable()) {
            return false;
        }
        return talkingEntity.getUserId().equals(userId);
    }

    private void startVideoPlay(UserEntity entity) {
        if (entity == null) {
            return;
        }
        TUIVideoView roomVideoView = entity.getRoomVideoView();
        if (roomVideoView == null || mViewModel == null) {
            return;
        }
        if (entity.isSelf()) {
            mViewModel.setLocalVideoView(entity);
            return;
        }
        if (!entity.isVideoAvailable()) {
            mViewModel.stopPlayVideo(entity.getUserId(), entity.isScreenShareAvailable(), true);
            return;
        }
        mViewModel.startPlayVideo(entity.getUserId(), roomVideoView, entity.isScreenShareAvailable());
    }

    private void stopVideoPlay(UserEntity entity) {
        if (entity == null) {
            return;
        }
        if (mViewModel != null) {
            mViewModel.stopPlayVideo(entity.getUserId(), false, false);
        }
    }

    public void notifyItemVideoStageChanged(int position) {
        if (mMemberListAdapter == null) {
            return;
        }
        if (mIsTwoPersonVideoOn) {
            updateUserTalkingView(mIsTwoPersonSwitched ? 0 : 1);
        }
        if (needUpdateUserTalkingViewForSpeaker(position)) {
            updateUserTalkingView(position);
        }
        mMemberListAdapter.notifyItemChanged(position, PAYLOAD_VIDEO);
    }

    public void notifyItemAudioStateChanged(int position) {
        if (needUpdateUserTalkingViewForSpeaker(position)) {
            updateUserTalkingView(position);
        }
        if (mIsTwoPersonVideoOn) {
            updateUserTalkingView(mIsTwoPersonSwitched ? 0 : 1);
        }
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyItemChanged(position, PAYLOAD_AUDIO);
        }
    }

    private boolean needUpdateUserTalkingViewForSpeaker(int position) {
        if (!mIsSpeakerModeOn || position == 0 || mCurrentPageIndex != PageLayoutManager.SPEAKER_PAGE_INDEX) {
            return false;
        }
        return true;
    }

    public void notifyDataSetChanged() {
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyDataSetChanged();
        }
    }

    public void notifyItemChanged(int position) {
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyItemChanged(position);
        }
    }

    public void notifyItemInserted(int position) {
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyItemInserted(position);
            updateCircleIndicator();
        }
    }

    public void notifyItemRemoved(int position) {
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyItemRemoved(position);
            updateCircleIndicator();
        }
    }

    private void updateCircleIndicator() {
        mCircleIndicator.setPageNum(mPageLayoutManager.getTotalPageCount());
        updateScrollIndicator();
    }

    public void enableSpeakerMode(boolean enable) {
        Log.d(TAG, "enableSpeakerMode : " + enable);
        mIsSpeakerModeOn = enable;
        mPageLayoutManager.enableSpeakerMode(enable);
        mMemberListAdapter.notifyDataSetChanged();
        updateCircleIndicator();
        updateUserTalkingViewVisible(PageLayoutManager.SPEAKER_PAGE_INDEX);
        mUserDisplayView.clearUserEntity();
        if (enable) {
            initUserTalkingViewLayout();
        } else {
            stopVideoPlay(mUserDisplayView.getUserEntity());
        }
    }

    public void enableTwoPersonVideoMeeting(boolean enable) {
        Log.d(TAG, "enableTwoPersonVideoMeeting : " + enable);
        mIsTwoPersonVideoOn = enable;
        updateUserTalkingViewVisible();
        if (enable) {
            initUserTalkingViewLayout();
            updateUserTalkingView(mIsTwoPersonSwitched ? 0 : 1);
            setUserDisplayViewClickListener();
        } else {
            stopVideoPlay(mUserDisplayView.getUserEntity());
            mUserDisplayView.clearUserEntity();
        }
        mPageLayoutManager.enableTwoPersonMeeting(mIsTwoPersonVideoOn, mIsTwoPersonSwitched);

        if (mMemberListAdapter.getItemCount() == 1) {
            if (mIsTwoPersonSwitched) {
                mMemberListAdapter.notifyItemChanged(0);
            }
            return;
        }
        if (mMemberListAdapter.getItemCount() == 2 && enable) {
            if (mIsTwoPersonSwitched) {
                mMemberListAdapter.notifyItemChanged(mIsTwoPersonSwitched ? 1 : 0);
            }
            return;
        }
        mMemberListAdapter.notifyDataSetChanged();
    }

    public void notifyTalkingViewDataChanged() {
        updateUserTalkingView(mIsTwoPersonSwitched ? 0 : 1);
    }

    private void setUserDisplayViewClickListener() {
        mUserDisplayView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsTwoPersonVideoOn) {
                    switchTwoPersonVideoMeeting();
                }
            }
        });
    }

    private void switchTwoPersonVideoMeeting() {
        mIsTwoPersonSwitched = !mIsTwoPersonSwitched;
        Log.d(TAG, "switchTwoPersonVideoMeeting mIsTwoPersonSwitched=" + mIsTwoPersonSwitched);
        updateUserTalkingView(mIsTwoPersonSwitched ? 0 : 1);
        mPageLayoutManager.enableTwoPersonMeeting(mIsTwoPersonVideoOn, mIsTwoPersonSwitched);
        mMemberListAdapter.notifyItemChanged(mIsTwoPersonSwitched ? 1 : 0);
    }
}
