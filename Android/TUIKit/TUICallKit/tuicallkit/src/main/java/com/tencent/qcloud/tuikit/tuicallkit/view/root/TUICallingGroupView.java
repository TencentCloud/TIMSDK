package com.tencent.qcloud.tuikit.tuicallkit.view.root;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayout;
import com.tencent.qcloud.tuikit.tuicallkit.base.UserLayoutEntity;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DisplayUtils;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;
import com.tencent.qcloud.tuikit.tuicallkit.view.UserLayoutFactory;

import java.util.ArrayList;
import java.util.Iterator;

public class TUICallingGroupView extends BaseCallView {
    private TextView          mTextCallHint;
    private RelativeLayout    mLayoutFunction;
    private TextView          mTextTime;
    private UserLayoutFactory mUserLayoutFactory;
    private View              mRootView;
    private RelativeLayout    mLayoutFloatView;
    private RelativeLayout    mLayoutAddUserView;
    private RelativeLayout    mLayoutGroupManager;

    private int     mCount     = 0;
    private boolean mInitParam = false;

    private ArrayList<LayoutParams> mGrid1ParamList;
    private ArrayList<LayoutParams> mGrid2ParamList;
    private ArrayList<LayoutParams> mGrid3ParamList;
    private ArrayList<LayoutParams> mGrid4ParamList;
    private ArrayList<LayoutParams> mGrid9ParamList;

    public TUICallingGroupView(Context context, UserLayoutFactory factory) {
        super(context);
        mUserLayoutFactory = factory;
        initView();
        initData();
    }

    public void initView() {
        mRootView = LayoutInflater.from(mContext).inflate(R.layout.tuicalling_background_group_view, this);
        mLayoutGroupManager = findViewById(R.id.group_layout_manager);
        mLayoutFloatView = findViewById(R.id.rl_float_view);
        mLayoutAddUserView = findViewById(R.id.rl_add_user_view);
        mTextCallHint = findViewById(R.id.tv_group_call_hint);
        mTextTime = findViewById(R.id.tv_group_time);
        mLayoutFunction = findViewById(R.id.rl_group_function);
    }

    private void initData() {
        for (UserLayoutEntity entity : mUserLayoutFactory.mLayoutEntityList) {
            if (null == entity || TextUtils.isEmpty(entity.userId)) {
                continue;
            }
            UserLayout layout = allocUserLayout(entity.userModel);
            TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
            if (entity.userId.equals(TUILogin.getLoginUser())) {
                if (TUICallDefine.MediaType.Video.equals(mediaType)) {
                    layout.setVideoAvailable(true);
                    TUICommonDefine.Camera camera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
                    mCallingAction.openCamera(camera, layout.getVideoView(), null);
                } else {
                    ImageLoader.loadImage(mContext, entity.layout.getAvatarImage(), TUILogin.getFaceUrl(),
                            R.drawable.tuicalling_ic_avatar);
                    entity.layout.setUserName(TUILogin.getNickName());
                }
            } else {
                if (null != entity.userModel) {
                    if (TUICallDefine.MediaType.Video.equals(mediaType) && entity.userModel.isVideoAvailable) {
                        layout.setVideoAvailable(true);
                        mCallingAction.startRemoteView(entity.userId, layout.getVideoView(),
                                new TUICommonDefine.PlayCallback() {
                                    @Override
                                    public void onPlaying(String userId) {

                                    }

                                    @Override
                                    public void onLoading(String userId) {

                                    }

                                    @Override
                                    public void onError(String userId, int errCode, String errMsg) {

                                    }
                                });
                    }
                    ImageLoader.loadImage(mContext, entity.layout.getAvatarImage(), entity.userModel.userAvatar,
                            R.drawable.tuicalling_ic_avatar);
                    entity.layout.setUserName(entity.userModel.userName);
                    if (entity.userModel.isEnter) {
                        entity.layout.stopLoading();
                    } else {
                        entity.layout.startLoading();
                    }
                }
            }
        }
    }

    @Override
    public void userEnter(CallingUserModel userModel) {
        super.userEnter(userModel);
        UserLayout layout = mUserLayoutFactory.findUserLayout(userModel.userId);
        if (null == layout) {
            layout = allocUserLayout(userModel);
        }
        if (layout == null) {
            return;
        }
        layout.stopLoading();
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        if (TUICallDefine.MediaType.Video.equals(mediaType)) {
            layout.setVideoAvailable(true);
            mCallingAction.startRemoteView(userModel.userId, layout.getVideoView(),
                    new TUICommonDefine.PlayCallback() {
                        @Override
                        public void onPlaying(String userId) {
                        }

                        @Override
                        public void onLoading(String userId) {
                        }

                        @Override
                        public void onError(String userId, int errCode, String errMsg) {
                        }
                    });
        }
    }

    @Override
    public void userAdd(CallingUserModel userModel) {
        super.userAdd(userModel);
        UserLayout layout = mUserLayoutFactory.findUserLayout(userModel.userId);
        if (null == layout) {
            layout = allocUserLayout(userModel);
        }
        if (layout == null) {
            return;
        }
        layout.startLoading();
        TUICallDefine.MediaType mediaType = TUICallingStatusManager.sharedInstance(mContext).getMediaType();
        if (TUICallDefine.MediaType.Video.equals(mediaType)) {
            mCallingAction.startRemoteView(userModel.userId, layout.getVideoView(),
                    new TUICommonDefine.PlayCallback() {
                        @Override
                        public void onPlaying(String userId) {
                        }

                        @Override
                        public void onLoading(String userId) {
                        }

                        @Override
                        public void onError(String userId, int errCode, String errMsg) {
                        }
                    });
        }
    }

    @Override
    public void userLeave(CallingUserModel userModel) {
        super.userLeave(userModel);
        if (null != userModel) {
            recyclerUserLayout(userModel.userId);
            mCallingAction.stopRemoteView(userModel.userId);
        }
    }

    @Override
    public void updateUserInfo(CallingUserModel userModel) {
        super.updateUserInfo(userModel);
        UserLayout userLayout = mUserLayoutFactory.findUserLayout(userModel.userId);
        if (null != userLayout) {
            userLayout.setVideoAvailable(userModel.isVideoAvailable);
        }
    }

    @Override
    public void updateCallingHint(String hint) {
        super.updateCallingHint(hint);
        mTextCallHint.setText(hint);
        mTextCallHint.setVisibility(TextUtils.isEmpty(hint) ? GONE : VISIBLE);
    }

    @Override
    public void updateCallTimeView(String time) {
        mTextTime.setText(time);
        mTextTime.setVisibility(TextUtils.isEmpty(time) ? GONE : VISIBLE);
    }

    @Override
    public void updateFunctionView(View view) {
        mLayoutFunction.removeAllViews();
        if (null != view) {
            mLayoutFunction.addView(view);
        }
    }

    @Override
    public void updateBackgroundColor(int color) {
        mRootView.setBackgroundColor(color);
    }

    @Override
    public void updateTextColor(int color) {
        super.updateTextColor(color);
        mTextCallHint.setTextColor(color);
        mTextTime.setTextColor(color);
    }

    @Override
    public void enableFloatView(View view) {
        mLayoutFloatView.removeAllViews();
        if (null != view) {
            mLayoutFloatView.addView(view);
        }
    }

    @Override
    public void enableAddUserView(View view) {
        mLayoutAddUserView.removeAllViews();
        if (null != view) {
            mLayoutAddUserView.addView(view);
        }
    }

    @Override
    public void finish() {
        if (null != mLayoutGroupManager) {
            recyclerAllUserLayout();
        }
        super.finish();
    }

    private UserLayout allocUserLayout(CallingUserModel userModel) {
        if (null == userModel || TextUtils.isEmpty(userModel.userId)) {
            return null;
        }
        if (mCount > Constants.MAX_USER) {
            return null;
        }
        UserLayout userLayout = mUserLayoutFactory.allocUserLayout(userModel);
        if (null != userLayout.getParent()) {
            ((ViewGroup) userLayout.getParent()).removeView(userLayout);
        }
        mLayoutGroupManager.addView(userLayout);
        mCount++;
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
        return userLayout;
    }

    private void recyclerUserLayout(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        Iterator iterator = mUserLayoutFactory.mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            UserLayoutEntity item = (UserLayoutEntity) iterator.next();
            if (userId.equals(item.userId)) {
                mLayoutGroupManager.removeView(item.layout);
                iterator.remove();
                mCount--;
                break;
            }
        }
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
    }

    private void recyclerAllUserLayout() {
        if (null == mUserLayoutFactory) {
            return;
        }
        Iterator iterator = mUserLayoutFactory.mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            UserLayoutEntity item = (UserLayoutEntity) iterator.next();
            mLayoutGroupManager.removeView(item.layout);
            iterator.remove();
        }
        mCount = 0;
    }

    private void makeGirdLayout(boolean needUpdate) {
        if (!mInitParam) {
            int width = DeviceUtils.getScreenWidth(mContext);
            int height = DeviceUtils.getScreenHeight(mContext);
            int size = Math.min(width, height);
            mGrid1ParamList = DisplayUtils.initGrid1Param(getContext(), size, size);
            mGrid2ParamList = DisplayUtils.initGrid2Param(getContext(), size, size);
            mGrid3ParamList = DisplayUtils.initGrid3Param(getContext(), size, size);
            mGrid4ParamList = DisplayUtils.initGrid4Param(getContext(), size, size);
            mGrid9ParamList = DisplayUtils.initGrid9Param(getContext(), size, size);
            mInitParam = true;
        }
        if (null == mUserLayoutFactory || mUserLayoutFactory.mLayoutEntityList.isEmpty()) {
            return;
        }
        if (needUpdate) {
            ArrayList<LayoutParams> paramList;
            if (mCount <= 1) {
                paramList = mGrid1ParamList;
                UserLayoutEntity entity = mUserLayoutFactory.mLayoutEntityList.get(0);
                entity.layout.setLayoutParams(paramList.get(0));
                return;
            } else if (mCount == 2) {
                paramList = mGrid2ParamList;
            } else if (mCount == 3) {
                paramList = mGrid3ParamList;
            } else if (mCount == 4) {
                paramList = mGrid4ParamList;
            } else {
                paramList = mGrid9ParamList;
            }
            int layoutIndex = TextUtils.isEmpty(TUILogin.getLoginUser()) ? 0 : 1;
            for (int i = 0; i < mUserLayoutFactory.mLayoutEntityList.size(); i++) {
                UserLayoutEntity entity = mUserLayoutFactory.mLayoutEntityList.get(i);
                if (entity.userId.equals(TUILogin.getLoginUser())) {
                    entity.layout.setLayoutParams(paramList.get(0));
                } else if (layoutIndex < paramList.size()) {
                    entity.layout.setLayoutParams(paramList.get(layoutIndex++));
                }
            }
        }
    }
}
