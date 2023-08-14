package com.tencent.qcloud.tuikit.tuicallkit.view.root;

import android.content.Context;
import android.text.TextUtils;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DisplayUtils;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;
import com.tencent.qcloud.tuikit.tuicallkit.view.UserLayoutFactory;
import com.tencent.qcloud.tuikit.tuicallkit.view.common.RoundCornerImageView;

import java.util.ArrayList;
import java.util.Iterator;

public class TUICallingSingleView extends BaseCallView {
    private Context           mContext;
    private UserLayoutFactory mUserLayoutFactory;
    private TextView          mTextTime;
    private RelativeLayout    mLayoutUserWaitView;
    private RelativeLayout    mLayoutSwitchAudio;
    private RelativeLayout    mLayoutFunction;
    private RelativeLayout    mLayoutFloatView;
    private RelativeLayout    mLayoutUserContainer;

    private ArrayList<LayoutParams> mFloatParamList;
    private int                     mCount = 0;

    public TUICallingSingleView(Context context, UserLayoutFactory factory) {
        super(context);
        mContext = context.getApplicationContext();
        mUserLayoutFactory = factory;
        initView();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        initData();
    }

    public void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_background_single_view, this);
        mLayoutUserContainer = findViewById(R.id.rl_video_container);
        mLayoutFloatView = findViewById(R.id.rl_float_view);
        mLayoutUserWaitView = findViewById(R.id.rl_single_video_user);
        mLayoutSwitchAudio = findViewById(R.id.rl_switch_audio);
        mTextTime = findViewById(R.id.tv_single_time);
        mLayoutFunction = findViewById(R.id.rl_single_function);
    }

    private void initData() {
        for (UserLayoutEntity entity : mUserLayoutFactory.mLayoutEntityList) {
            if (null != entity && !TextUtils.isEmpty(entity.userId) && entity.userId.equals(TUILogin.getLoginUser())) {
                UserLayout layout = allocUserLayout(entity.userModel);
                if (layout == null) {
                    continue;
                }

                boolean cameraOpen = TUICallingStatusManager.sharedInstance(mContext).isCameraOpen();
                layout.setVideoAvailable(cameraOpen);

                TUICallDefine.Status status = TUICallingStatusManager.sharedInstance(mContext).getCallStatus();
                if (!cameraOpen && !TUICallDefine.Status.Accept.equals(status)) {
                    TUICommonDefine.Camera camera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
                    mCallingAction.openCamera(camera, layout.getVideoView(), null);
                }
            }
        }
    }

    @Override
    public void userEnter(CallingUserModel userModel) {
        super.userEnter(userModel);
        UserLayout layout = findUserLayout(userModel.userId);
        if (null == layout) {
            layout = allocUserLayout(userModel);
        }

        layout.setVideoAvailable(userModel.isVideoAvailable);
        mCallingAction.startRemoteView(userModel.userId, layout.getVideoView(), null);
    }

    public void updateUserInfo(CallingUserModel userModel) {
        super.updateUserInfo(userModel);
        UserLayout layout = findUserLayout(userModel.userId);
        if (layout != null) {
            layout.setVideoAvailable(userModel.isVideoAvailable);
            ImageLoader.loadImage(mContext, layout.getAvatarImage(), userModel.userAvatar,
                    R.drawable.tuicalling_ic_avatar);
        }
    }

    @Override
    public void updateUserView(View view) {
        super.updateUserView(view);
        mLayoutUserWaitView.removeAllViews();
        if (null != view) {
            mLayoutUserWaitView.addView(view);
        }
    }

    @Override
    public void updateSwitchAudioView(View view) {
        mLayoutSwitchAudio.removeAllViews();
        if (null != view) {
            mLayoutSwitchAudio.addView(view);
        }
    }

    @Override
    public void updateCallTimeView(String time) {
        mTextTime.setText(time);
        mTextTime.setVisibility(TextUtils.isEmpty(time) ? GONE : VISIBLE);
    }

    @Override
    public void updateTextColor(int color) {
        super.updateTextColor(color);
        mTextTime.setTextColor(color);
    }

    @Override
    public void updateFunctionView(View view) {
        mLayoutFunction.removeAllViews();
        if (null != view) {
            mLayoutFunction.addView(view);
        }
    }

    @Override
    public void enableFloatView(View view) {
        mLayoutFloatView.removeAllViews();
        if (null != view) {
            mLayoutFloatView.addView(view);
        }
    }

    public void finish() {
        recyclerAllUserLayout();
        super.finish();
    }

    private UserLayout findUserLayout(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        return (null == mUserLayoutFactory) ? null : mUserLayoutFactory.findUserLayout(userId);
    }

    private UserLayout allocUserLayout(CallingUserModel userModel) {
        if (null == userModel || TextUtils.isEmpty(userModel.userId)) {
            return null;
        }
        UserLayout userLayout = mUserLayoutFactory.allocUserLayout(userModel);
        if (null != userLayout.getParent()) {
            ((ViewGroup) userLayout.getParent()).removeView(userLayout);
        }
        initGestureListener(userLayout);
        userLayout.setVisibility(VISIBLE);
        userLayout.disableAudioImage(true);
        RelativeLayout.LayoutParams lp = new LayoutParams(180, 180);
        lp.addRule(CENTER_IN_PARENT);
        ((RoundCornerImageView) userLayout.getAvatarImage()).setRadius(15);
        userLayout.getAvatarImage().setLayoutParams(lp);
        mLayoutUserContainer.addView(userLayout);
        mCount++;
        this.post(new Runnable() {
            @Override
            public void run() {
                makeFloatLayout();
            }
        });
        return userLayout;
    }

    private void recyclerAllUserLayout() {
        if (null == mUserLayoutFactory || null == mLayoutUserContainer) {
            return;
        }
        Iterator iterator = mUserLayoutFactory.mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            UserLayoutEntity item = (UserLayoutEntity) iterator.next();
            mLayoutUserContainer.removeView(item.layout);
            iterator.remove();
        }
        mCount = 0;
    }

    private void initGestureListener(UserLayout layout) {
        GestureDetector detector = new GestureDetector(getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                layout.performClick();
                return false;
            }

            @Override
            public boolean onDown(MotionEvent e) {
                return true;
            }

            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
                if (!layout.isMoveAble()) {
                    return false;
                }
                ViewGroup.LayoutParams params = layout.getLayoutParams();
                if (params instanceof LayoutParams) {
                    LayoutParams layoutParams = (LayoutParams) layout.getLayoutParams();
                    int newX = (int) (layoutParams.leftMargin + (e2.getX() - e1.getX()));
                    int newY = (int) (layoutParams.topMargin + (e2.getY() - e1.getY()));
                    if (newX >= 0 && newX <= (getWidth() - layout.getWidth())
                            && newY >= 0 && newY <= (getHeight() - layout.getHeight())) {
                        layoutParams.leftMargin = newX;
                        layoutParams.topMargin = newY;
                        layout.setLayoutParams(layoutParams);
                    }
                }
                return true;
            }
        });
        layout.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return detector.onTouchEvent(event);
            }
        });
    }

    private UserLayoutEntity findEntity(String userId) {
        for (UserLayoutEntity entity : mUserLayoutFactory.mLayoutEntityList) {
            if (entity.userId.equals(userId)) {
                return entity;
            }
        }
        return null;
    }

    private void makeFloatLayout() {
        if (null == mFloatParamList || mFloatParamList.size() == 0) {
            mFloatParamList = DisplayUtils.initFloatParamList(getContext(), getWidth(), getHeight());
        }

        int size = mUserLayoutFactory.mLayoutEntityList.size();
        for (int i = 0; i < size; i++) {
            UserLayoutEntity entity = mUserLayoutFactory.mLayoutEntityList.get(size - i - 1);
            LayoutParams layoutParams = mFloatParamList.get(i);

            entity.layout.setLayoutParams(layoutParams);
            entity.layout.setMoveAble(i != 0);
            addFloatViewClickListener(entity);
            entity.layout.bringToFront();
        }
    }

    private void addFloatViewClickListener(UserLayoutEntity entity) {
        final String userId = entity.userId;
        entity.layout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!TextUtils.isEmpty(userId)) {
                    makeFullVideoView(userId);
                }
            }
        });
    }

    private void makeFullVideoView(String userId) {
        UserLayoutEntity entity = findEntity(userId);
        mUserLayoutFactory.mLayoutEntityList.remove(entity);
        mUserLayoutFactory.mLayoutEntityList.addLast(entity);
        makeFloatLayout();
    }
}