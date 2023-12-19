package com.tencent.cloud.tuikit.roomkit.videoseat.ui;

import static android.content.res.Configuration.ORIENTATION_PORTRAIT;
import static com.tencent.cloud.tuikit.roomkit.videoseat.Constants.VOLUME_NO_SOUND;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.LandscapePageLayoutManager;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.PageLayoutManager;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.PagerSnapHelper;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.PortraitPageLayoutManager;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.UserListAdapter;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.layout.VisibleRange;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.view.CircleIndicator;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.view.UserDisplayView;
import com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel.IVideoSeatViewModel;
import com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel.UserEntity;
import com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel.VideoSeatViewModel;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.ArrayList;
import java.util.List;

public class TUIVideoSeatView extends RelativeLayout {
    private static final String TAG = "TUIVideoSeatView";

    private static final int CLICK_ACTION_MAX_MOVE_DISTANCE = 10;
    private static final int SMALL_VIDEO_UPDATE_INTERVAL = 5 * 1000;

    private Context mContext;

    private RecyclerView      mRecyclerView;
    private UserListAdapter   mMemberListAdapter;
    private CircleIndicator   mCircleIndicator;
    private PageLayoutManager mPageLayoutManager;
    private UserDisplayView   mUserDisplayView;

    private List<String>     mVisibleVideoStreams;
    private List<UserEntity> mMemberEntityList;

    private IVideoSeatViewModel mViewModel;

    private boolean mIsSpeakerModeOn;
    private boolean mIsTwoPersonVideoOn;
    private boolean mIsTwoPersonSwitched;

    private int mCurrentPageIndex = 0;

    private long mSmallUserLastUpdateTime = 0L;

    private OnClickListener mClickListener;
    private boolean         mIsClickAction;
    private float           mTouchDownPointX;
    private float           mTouchDownPointY;

    private VisibleRange mVisibleRange = new VisibleRange();

    public TUIVideoSeatView(Context context) {
        super(context);
        Log.d(TAG, "new : " + this);
        mContext = context;
        inflate(mContext, R.layout.tuivideoseat_anchor_list_view, this);
        mUserDisplayView = findViewById(R.id.tuivideoseat_user_talking_video_view);
        mCircleIndicator = findViewById(R.id.simple_view);
        int unSelectColor = getResources().getColor(R.color.tuivideoseat_color_indicator_un_select);
        int selectColor = getResources().getColor(R.color.tuivideoseat_color_white);
        mCircleIndicator.setSelectDotColor(selectColor);
        mCircleIndicator.setUnSelectDotColor(unSelectColor);
        mViewModel = new VideoSeatViewModel(mContext, this);
        initListView();
    }

    public void setViewClickListener(OnClickListener clickListener) {
        mClickListener = clickListener;
        mMemberListAdapter.setItemClickListener(mClickListener);
    }

    public void setMemberEntityList(List<UserEntity> memberEntityList) {
        mMemberEntityList = memberEntityList;
    }

    public void destroy() {
        Log.d(TAG, "destroy : " + this);
        mViewModel.destroy();
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        chooseLayoutManagerByOrientation();
        if (mIsSpeakerModeOn) {
            enableSpeakerMode(true);
        }
        if (mIsTwoPersonVideoOn) {
            enableTwoPersonVideoMeeting(true);
        }
    }

    private void chooseLayoutManagerByOrientation() {
        if (mContext.getResources().getConfiguration().orientation == ORIENTATION_PORTRAIT) {
            mPageLayoutManager = new PortraitPageLayoutManager();
        } else {
            mPageLayoutManager = new LandscapePageLayoutManager();
        }
        mPageLayoutManager.setAllowContinuousScroll(false);
        mPageLayoutManager.setPageListener(new PageLayoutManager.PageListener() {
            @Override
            public void onPageSizeChanged(int pageSize) {
                updateScrollIndicator();
            }

            @Override
            public void onPageSelect(int pageIndex) {
                Log.d(TAG, "onPageSelect pageIndex=" + pageIndex);
                refreshSmallScreenForPageBack(mCurrentPageIndex, pageIndex);
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
                updateCircleIndicator();
                processVideoPlay(mVisibleRange.getMinVisibleRange(), mVisibleRange.getMaxVisibleRange());
            }

            @Override
            public void onItemVisible(int fromItem, int toItem) {
                mVisibleRange.updateRange(fromItem, toItem);
            }
        });
        mRecyclerView.setLayoutManager(mPageLayoutManager);
    }

    private void refreshSmallScreenForPageBack(int oldPageIndex, int newPageIndex) {
        if (!mIsSpeakerModeOn || !(oldPageIndex == 1) || !(newPageIndex == 0)) {
            return;
        }
        UserEntity smallUser = mUserDisplayView.getUserEntity();
        if (smallUser == null) {
            return;
        }
        mUserDisplayView.setUserEntity(smallUser);
        if (smallUser.isVideoAvailable()) {
            startVideoPlay(smallUser);
        } else {
            stopVideoPlay(smallUser);
        }
        ensureUserTalkingViewFullyDisplayed();
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
        mRecyclerView.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                mRecyclerView.onTouchEvent(event);
                return recognizeClickEventFromTouch(event);
            }
        });
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
        if (!(mUserDisplayView.getLayoutParams() instanceof LayoutParams)) {
            return;
        }
        UserEntity talkingEntity = mUserDisplayView.getUserEntity();
        LayoutParams layoutParams = (LayoutParams) mUserDisplayView.getLayoutParams();
        setUserTalkingViewSize(talkingEntity, layoutParams);

        int videoSeatViewWidth = ScreenUtil.getScreenWidth(mContext) - (int) mContext.getResources()
                .getDimension(R.dimen.tuiroomkit_video_seat_margin_start) - (int) mContext.getResources()
                .getDimension(R.dimen.tuiroomkit_video_seat_margin_end);
        layoutParams.leftMargin = videoSeatViewWidth - layoutParams.width - UserDisplayView.MARGIN_PX;

        layoutParams.topMargin = UserDisplayView.MARGIN_PX;
        mUserDisplayView.setLayoutParams(layoutParams);
    }

    private void setUserTalkingViewSize(UserEntity talkingEntity, LayoutParams layoutParams) {
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

    private void updateAudioForSmallScreen(int position) {
        updateUserInSpeakerMode(position);
        UserEntity newUser = mMemberEntityList.get(position);
        UserEntity curUser = mUserDisplayView.getUserEntity();
        if (curUser != null && TextUtils.equals(newUser.getUserId(), curUser.getUserId())) {
            mUserDisplayView.enableVolumeEffect(newUser.isAudioAvailable());
            mUserDisplayView.updateVolumeEffect(newUser.getAudioVolume());
            mUserDisplayView.setVolume(newUser.isTalk());
            // sdk 最后不会回调音量0，所以 app 需要每次将音量清 0
            newUser.setAudioVolume(VOLUME_NO_SOUND);
        }
    }

    private void updateUserInSpeakerMode(int position) {
        if (!mIsSpeakerModeOn) {
            return;
        }
        if (System.currentTimeMillis() - mSmallUserLastUpdateTime < SMALL_VIDEO_UPDATE_INTERVAL) {
            return;
        }
        UserEntity newUser = mMemberEntityList.get(position);
        if (!newUser.isAudioAvailable()) {
            return;
        }
        UserEntity curUser = mUserDisplayView.getUserEntity();
        if (curUser != null && TextUtils.equals(newUser.getUserId(), curUser.getUserId())) {
            return;
        }
        mUserDisplayView.setUserEntity(newUser);
        mSmallUserLastUpdateTime = System.currentTimeMillis();
        updateVideoForSmallScreen(position);
    }

    private void updateUserInTwoPersonMode(int position) {
        if (!mIsTwoPersonVideoOn) {
            return;
        }
        UserEntity newUser = mMemberEntityList.get(position);
        mUserDisplayView.setUserEntity(newUser);
        updateVideoForSmallScreen(position);
    }

    private void updateVideoForSmallScreen(int position) {
        UserEntity newUser = mMemberEntityList.get(position);
        UserEntity curUser = mUserDisplayView.getUserEntity();
        if (curUser == null || !TextUtils.equals(newUser.getUserId(), curUser.getUserId())) {
            return;
        }
        if (newUser.isVideoAvailable()) {
            startVideoPlay(newUser);
        } else {
            stopVideoPlay(newUser);
        }
        ensureUserTalkingViewFullyDisplayed();
        mUserDisplayView.updateVideoEnableEffect();
    }

    private void ensureUserTalkingViewFullyDisplayed() {
        if (!mIsSpeakerModeOn && !mIsTwoPersonVideoOn) {
            return;
        }
        if (!(mUserDisplayView.getLayoutParams() instanceof LayoutParams)) {
            return;
        }
        UserEntity talkingEntity = mUserDisplayView.getUserEntity();
        if (talkingEntity == null) {
            return;
        }
        LayoutParams params = (LayoutParams) mUserDisplayView.getLayoutParams();
        setUserTalkingViewSize(talkingEntity, params);

        int videoSeatViewWidth = ScreenUtil.getScreenWidth(mContext) - (int) mContext.getResources()
                .getDimension(R.dimen.tuiroomkit_video_seat_margin_start) - (int) mContext.getResources()
                .getDimension(R.dimen.tuiroomkit_video_seat_margin_end);
        int rightMargin = videoSeatViewWidth - params.leftMargin - params.width - UserDisplayView.MARGIN_PX;
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
            notifyItemVideoVisibilityStageChanged(mMemberEntityList.indexOf(entity));
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
        if (entity.isSelf()) {
            return;
        }
        if (mViewModel != null) {
            mViewModel.stopPlayVideo(entity.getUserId(), false, false);
        }
    }

    public void notifyItemVideoVisibilityStageChanged(int position) {
        if (mMemberListAdapter == null) {
            return;
        }
        post(new Runnable() {
            @Override
            public void run() {
                mMemberListAdapter.notifyItemChanged(position, UserListAdapter.PAYLOAD_VIDEO);
            }
        });
    }

    public void notifyItemVideoSwitchStageChanged(int position) {
        if (mMemberListAdapter == null) {
            return;
        }
        if (mIsTwoPersonVideoOn || needUpdateUserTalkingViewForSpeaker(position)) {
            updateVideoForSmallScreen(position);
        }
        if (position < mVisibleRange.getMinVisibleRange()
                || position > mVisibleRange.getMaxVisibleRange()) {
            return;
        }
        UserEntity entity = mMemberEntityList.get(position);
        if (entity.isSelf()) {
            notifyItemVideoVisibilityStageChanged(position);
        } else if (entity.isCameraAvailable()) {
            startVideoPlay(entity);
        } else {
            stopVideoPlay(entity);
        }
    }

    public void notifyItemAudioStateChanged(int position) {
        if (mIsTwoPersonVideoOn || needUpdateUserTalkingViewForSpeaker(position)) {
            updateAudioForSmallScreen(position);
        }
        if (mMemberListAdapter != null) {
            mMemberListAdapter.notifyItemChanged(position, UserListAdapter.PAYLOAD_AUDIO);
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
            updateUserInTwoPersonMode(mIsTwoPersonSwitched ? 0 : 1);
            setUserDisplayViewClickListener();
        } else {
            UserEntity displayUserEntity = mUserDisplayView.getUserEntity();
            mUserDisplayView.clearUserEntity();
            stopVideoPlay(displayUserEntity);
            startVideoPlay(findUserEntityFromLMember(displayUserEntity));
        }
        mPageLayoutManager.enableTwoPersonMeeting(mIsTwoPersonVideoOn, mIsTwoPersonSwitched);

        if (mMemberListAdapter.getItemCount() == 1) {
            mMemberListAdapter.notifyItemChanged(0);
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
        updateUserInTwoPersonMode(mIsTwoPersonSwitched ? 0 : 1);
    }

    private UserEntity findUserEntityFromLMember(UserEntity userEntity) {
        if (userEntity == null) {
            return null;
        }
        for (UserEntity item : mMemberEntityList) {
            if (TextUtils.equals(item.getUserId(), userEntity.getUserId())) {
                return item;
            }
        }
        return null;
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
        updateUserInTwoPersonMode(mIsTwoPersonSwitched ? 0 : 1);
        mPageLayoutManager.enableTwoPersonMeeting(mIsTwoPersonVideoOn, mIsTwoPersonSwitched);
        mMemberListAdapter.notifyItemChanged(mIsTwoPersonSwitched ? 1 : 0);
    }

    private boolean recognizeClickEventFromTouch(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mTouchDownPointX = event.getX();
                mTouchDownPointY = event.getY();
                mIsClickAction = true;
                break;

            case MotionEvent.ACTION_MOVE:
                float xDistance = Math.abs(event.getX() - mTouchDownPointX);
                float yDistance = Math.abs(event.getY() - mTouchDownPointY);
                if (xDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE || yDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE) {
                    mIsClickAction = false;
                }
                break;

            case MotionEvent.ACTION_UP:
                if (mIsClickAction && mClickListener != null) {
                    mClickListener.onClick(this);
                }
                break;

            default:
                break;
        }

        return true;
    }
}
