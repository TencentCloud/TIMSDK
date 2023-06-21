package com.tencent.cloud.tuikit.videoseat.ui.view;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.videoseat.R;
import com.tencent.cloud.tuikit.videoseat.ui.utils.ImageLoader;
import com.tencent.cloud.tuikit.videoseat.viewmodel.UserEntity;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserDisplayView extends FrameLayout {
    public static final int MARGIN_PX = ScreenUtil.dip2px(5);

    private static final int CLICK_ACTION_MAX_MOVE_DISTANCE = 10;

    private Context              mContext;
    private View                 mTalkView;
    private View                 mViewBackground;
    private TextView             mUserNameTv;
    private ImageView            mIvMaster;
    private UserVolumePromptView mUserMic;
    private CircleImageView      mUserHeadImg;
    private UserEntity           mMemberEntity;
    private FrameLayout          mVideoContainer;
    private RoundRelativeLayout  mTopLayout;

    private int mRoundRadius;
    private int mWidth;
    private int mHeight;

    private float mTouchDownPointX;
    private float mTouchDownPointY;
    private int   mLeftWhenTouchDown;
    private int   mTopWhenTouchDown;
    private boolean mIsActionDrag;

    private OnClickListener mOnClickListener;

    public UserDisplayView(Context context) {
        this(context, null);
    }

    public UserDisplayView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public UserDisplayView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        mRoundRadius = (int) mContext.getResources().getDimension(R.dimen.tuivideoseat_video_view_conor);

        initView(context);
    }

    public UserEntity getUserEntity() {
        return mMemberEntity;
    }

    public void setUserEntity(final UserEntity model) {
        if (model == null) {
            return;
        }
        addRoomVideoView(model);
        mViewBackground.setVisibility(model.isVideoAvailable() ? GONE : VISIBLE);
        mUserHeadImg.setVisibility(model.isVideoAvailable() ? GONE : VISIBLE);
        updateUserAvatarIfNeeded(mMemberEntity, model);

        mUserNameTv.setText(model.getUserName());
        enableVolumeEffect(model.isAudioAvailable());
        updateVolumeEffect(model.getAudioVolume());
        mIvMaster.setVisibility(model.getRole() == TUIRoomDefine.Role.ROOM_OWNER ? VISIBLE : GONE);

        mTopLayout.setRadius(mRoundRadius);
        int backGroundId = R.drawable.tuivideoseat_talk_bg_round;
        mTalkView.setBackground(mContext.getResources().getDrawable(backGroundId));
        mTopLayout.setVisibility(VISIBLE);

        mMemberEntity = model;
    }

    private void updateUserAvatarIfNeeded(UserEntity oldUser, UserEntity newUser) {
        if (newUser == null) {
            return;
        }
        if (oldUser == null) {
            ImageLoader.loadImage(mContext, mUserHeadImg, newUser.getUserAvatar(), R.drawable.tuivideoseat_head);
            return;
        }
        if (oldUser.getUserId().equals(newUser.getUserId()) && oldUser.getUserAvatar()
                .equals(newUser.getUserAvatar())) {
            return;
        }
        ImageLoader.loadImage(mContext, mUserHeadImg, newUser.getUserAvatar(), R.drawable.tuivideoseat_head);
    }

    private void addRoomVideoView(UserEntity userEntity) {
        TUIVideoView videoView = userEntity.getRoomVideoView();
        if (videoView == null) {
            return;
        }
        ViewParent viewParent = videoView.getParent();
        if (viewParent != null && (viewParent instanceof ViewGroup)) {
            if (viewParent == mVideoContainer) {
                return;
            }
            ((ViewGroup) viewParent).removeView(videoView);
        }
        mVideoContainer.removeAllViews();
        mVideoContainer.addView(videoView);
    }

    public void clearUserEntity() {
        mMemberEntity = null;
        mVideoContainer.removeAllViews();
        mTopLayout.setVisibility(INVISIBLE);
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        mOnClickListener = l;
    }

    public void enableVolumeEffect(boolean enable) {
        mUserMic.enableVolumeEffect(enable);
    }

    public void updateVolumeEffect(int volume) {
        mUserMic.updateVolumeEffect(volume);
    }

    private void initView(Context context) {
        View parent = inflate(context, R.layout.tuivideoseat_item_member, this);
        mTopLayout = parent.findViewById(R.id.rl_content);
        mUserNameTv = parent.findViewById(R.id.tv_user_name);
        mVideoContainer = parent.findViewById(R.id.fl_container);
        mUserHeadImg = parent.findViewById(R.id.img_user_head);
        mUserMic = parent.findViewById(R.id.tuivideoseat_user_mic);
        mIvMaster = parent.findViewById(R.id.img_master);
        mTalkView = parent.findViewById(R.id.talk_view);
        mViewBackground = parent.findViewById(R.id.view_background);
    }

    private final Runnable mRunnable = new Runnable() {
        @Override
        public void run() {
            mTalkView.setVisibility(GONE);
            if (mMemberEntity != null) {
                mMemberEntity.setTalk(false);
            }
        }
    };

    public void setVolume(boolean isTalk) {
        mTalkView.setVisibility(isTalk ? VISIBLE : GONE);
        if (isTalk) {
            mTalkView.removeCallbacks(mRunnable);
            mTalkView.postDelayed(mRunnable, 2000);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        mWidth = right - left;
        mHeight = bottom - top;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        handleTouchEvent(event);
        return true;
    }

    private void handleTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mTouchDownPointX = event.getX();
                mTouchDownPointY = event.getY();
                mLeftWhenTouchDown = getLeft();
                mTopWhenTouchDown = getTop();
                mIsActionDrag = false;
                break;

            case MotionEvent.ACTION_MOVE:
                Rect position = calculateLayoutPosition(event.getX(), event.getY());
                relayoutInRelativeLayout(position.left, position.top);
                updateFlagOfDragAction(event.getX(), event.getY());
                break;

            case MotionEvent.ACTION_UP:
                if (mIsActionDrag) {
                    autoMoveToScreenEdge();
                } else {
                    relayoutInRelativeLayout(mLeftWhenTouchDown, mTopWhenTouchDown);
                    handleClickAction();
                }
                break;

            default:
                break;
        }
    }

    private void updateFlagOfDragAction(float xMovePoint, float yMovePoint) {
        float xDistance = Math.abs(xMovePoint - mTouchDownPointX);
        float yDistance = Math.abs(yMovePoint - mTouchDownPointY);
        if (xDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE || yDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE) {
            mIsActionDrag = true;
        }
    }

    private Rect calculateLayoutPosition(float xMovePoint, float yMovePoint) {
        float xDistance = xMovePoint - mTouchDownPointX;
        float yDistance = yMovePoint - mTouchDownPointY;

        int left = (int) (getLeft() + xDistance);
        int top = (int) (getTop() + yDistance);
        int right = left + mWidth;
        int bottom = top + mHeight;

        if (left < MARGIN_PX) {
            left = MARGIN_PX;
            right = mWidth + MARGIN_PX;
        }
        if (top < MARGIN_PX) {
            top = MARGIN_PX;
            bottom = mHeight + MARGIN_PX;
        }
        View parent = (View) getParent();
        if (parent != null && right > parent.getWidth() - MARGIN_PX) {
            right = parent.getWidth() - MARGIN_PX;
            left = right - mWidth;

        }
        if (parent != null && bottom > parent.getHeight()) {
            bottom = parent.getHeight() - MARGIN_PX;
            top = bottom - mHeight;

        }

        return new Rect(left, top, right, bottom);
    }

    private void relayoutInRelativeLayout(int leftMargin, int topMargin) {
        if (!(getParent() instanceof RelativeLayout)) {
            return;
        }
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) getLayoutParams();
        layoutParams.width = mWidth;
        layoutParams.height = mHeight;
        layoutParams.leftMargin = leftMargin;
        layoutParams.topMargin = topMargin;
        setLayoutParams(layoutParams);
    }

    private void handleClickAction() {
        if (mOnClickListener == null) {
            return;
        }
        mOnClickListener.onClick(this);
    }

    private void autoMoveToScreenEdge() {
        int left = getLeft();
        View parent = (View) getParent();
        if (parent == null) {
            return;
        }
        int parentWidth = parent.getWidth();
        if (left + (mWidth >> 1) > (parentWidth >> 1)) {
            left = parentWidth - mWidth - MARGIN_PX;
        } else {
            left = MARGIN_PX;
        }
        relayoutInRelativeLayout(left, getTop());
    }
}
