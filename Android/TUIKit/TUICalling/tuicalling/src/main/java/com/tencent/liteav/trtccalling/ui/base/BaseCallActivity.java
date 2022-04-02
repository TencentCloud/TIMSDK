package com.tencent.liteav.trtccalling.ui.base;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.TUICalling;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.model.util.PermissionUtil;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.audiocall.TUICallAudioView;
import com.tencent.liteav.trtccalling.ui.audiocall.TUIGroupCallAudioView;
import com.tencent.liteav.trtccalling.ui.common.Utils;
import com.tencent.liteav.trtccalling.ui.floatwindow.FloatCallView;
import com.tencent.liteav.trtccalling.ui.floatwindow.FloatWindowService;
import com.tencent.liteav.trtccalling.ui.floatwindow.HomeWatcher;
import com.tencent.liteav.trtccalling.ui.videocall.TUICallVideoView;
import com.tencent.liteav.trtccalling.ui.videocall.TUIGroupCallVideoView;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.rtmp.ui.TXCloudVideoView;

public class BaseCallActivity extends Activity {
    private static final String TAG = "BaseCallActivity";

    private Activity        mActivity;
    private BaseTUICallView mCallView;
    private FloatCallView   mFloatView;
    private TUICalling.Type mType;
    private TUICalling.Role mRole;
    private String[]        mUserIds;
    private String          mSponsorID;
    private String          mGroupID;
    private boolean         mIsFromGroup;
    private HomeWatcher     mHomeWatcher;
    private boolean         mEnableFloatWindow; //用户是否支持显示悬浮窗

    private VideoLayoutFactory mVideoFactory;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TRTCLogger.d(TAG, "onCreate");
        Utils.setScreenLockParams(getWindow());
        mActivity = this;
        Intent intent = getIntent();
        mType = (TUICalling.Type) intent.getExtras().get(TUICallingConstants.PARAM_NAME_TYPE);
        mRole = (TUICalling.Role) intent.getExtras().get(TUICallingConstants.PARAM_NAME_ROLE);
        mUserIds = intent.getExtras().getStringArray(TUICallingConstants.PARAM_NAME_USERIDS);
        mSponsorID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_SPONSORID);
        mGroupID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_GROUPID);
        mIsFromGroup = intent.getExtras().getBoolean(TUICallingConstants.PARAM_NAME_ISFROMGROUP);
        mEnableFloatWindow = intent.getExtras().getBoolean(TUICallingConstants.PARAM_NAME_FLOATWINDOW);
        if (isGroupCall(mGroupID, mUserIds, mRole, mIsFromGroup)) {
            if (TUICalling.Type.AUDIO == mType) {
                mCallView = createGroupAudioView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            } else if (TUICalling.Type.VIDEO == mType) {
                mCallView = createGroupVideoView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            }
        } else {
            if (TUICalling.Type.AUDIO == mType) {
                mCallView = createAudioView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            } else if (TUICalling.Type.VIDEO == mType) {
                mVideoFactory = new VideoLayoutFactory(this);
                mCallView = createVideoView(mRole, mType, mUserIds, mSponsorID, mGroupID, mIsFromGroup);
            }
        }
        setContentView(mCallView);
        initHomeWatcher();

        mCallView.enableFloatWindow(mEnableFloatWindow);
        //点击返回键,拉起悬浮窗,隐藏当前界面
        ImageView imageBack = mCallView.getImageBackView();
        if (null != imageBack) {
            imageBack.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!PermissionUtil.hasPermission(getApplicationContext())) {
                        ToastUtils.showLong(getString(R.string.trtccalling_float_permission));
                        return;
                    }

                    //注意:需给Activity添加该action,找不到会报错
                    Intent intent = new Intent("com.tencent.trtc.tuicalling");
                    startActivity(intent);
                    startFloatService();
                }
            });
        }
    }

    //创建C2C语音通话视图
    private BaseTUICallView createAudioView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                            String sponsorID, String groupID, boolean isFromGroup) {
        return new TUICallAudioView(this, role, type, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建C2C视频通话视图
    private BaseTUICallView createVideoView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                            String sponsorID, String groupID, boolean isFromGroup) {
        return new TUICallVideoView(this, role, type, userIds, sponsorID, groupID, isFromGroup, mVideoFactory) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建群聊语音通话视图
    private BaseTUICallView createGroupAudioView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                                 String sponsorID, String groupID, boolean isFromGroup) {
        return new TUIGroupCallAudioView(this, role, type, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建群聊视频通话视图
    private BaseTUICallView createGroupVideoView(TUICalling.Role role, TUICalling.Type type, String[] userIds,
                                                 String sponsorID, String groupID, boolean isFromGroup) {
        return new TUIGroupCallVideoView(this, role, type, userIds, sponsorID, groupID, isFromGroup) {
            @Override
            public void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    //创建悬浮窗视图
    private FloatCallView createFloatView() {
        //开启悬浮窗时有可能从视频切了语音,因此重新获取type
        TUICalling.Type type = mCallView.getCallType();
        return new FloatCallView(this, mRole, type, mUserIds, mSponsorID, mGroupID, mIsFromGroup, mVideoFactory) {
            @Override
            protected void finish() {
                super.finish();
                BaseCallActivity.this.finish();
            }
        };
    }

    @Override
    protected void onResume() {
        super.onResume();
        removeFloatWindow();
    }

    private void removeFloatWindow() {
        TRTCLogger.i(TAG, "removeFloatWindow: show = " + Status.mIsShowFloatWindow);
        if (!Status.mIsShowFloatWindow) {
            return;
        }
        FloatWindowService.stopService(this);
        if (TUICalling.Type.VIDEO == mType) {
            String userId = Status.mCurFloatUserId;
            if (TextUtils.isEmpty(userId) || null == mVideoFactory) {
                TRTCLogger.i(TAG, "userId or videoFactory is empty");
                return;
            }
            //悬浮窗状态变化,自己的图像可能被冲掉了,因此需要重置自己的图像
            if (Status.CALL_STATUS.ACCEPT == Status.mCallStatus) {
                resetView(mVideoFactory, userId);
                resetView(mVideoFactory, TUILogin.getLoginUser());
                return;
            }
            if (userId.equals(TUILogin.getUserId())) {
                resetView(mVideoFactory, TUILogin.getLoginUser());
            } else {
                resetView(mVideoFactory, userId);
            }
        }

    }

    //重置用户图像
    private void resetView(VideoLayoutFactory layoutFactory, String userId) {
        TRTCVideoLayout videoLayout = layoutFactory.findUserLayout(userId);
        if (null == videoLayout) {
            videoLayout = layoutFactory.allocUserLayout(userId, new TRTCVideoLayout(this));
        }
        TXCloudVideoView renderView = videoLayout.getVideoView();
        TextureView mTextureView = renderView.getVideoView();
        if (mTextureView != null) {
            if (null != mTextureView.getParent()) {
                ((ViewGroup) mTextureView.getParent()).removeView(mTextureView);
            }
            renderView.addVideoView(mTextureView);
        }
    }

    private boolean isGroupCall(String groupID, String[] userIDs, TUICalling.Role role, boolean isFromGroup) {
        if (!TextUtils.isEmpty(groupID)) {
            return true;
        }
        if (TUICalling.Role.CALL == role) {
            return userIDs.length >= 2;
        } else {
            return userIDs.length >= 1 || isFromGroup;
        }
    }

    @Override
    public void onBackPressed() {
        //不可删除,音视频通话中不支持返回
    }

    //开启悬浮窗
    private void startFloatService() {
        //不支持悬浮窗功能,则直接返回
        if (!mEnableFloatWindow) {
            return;
        }
        if (mActivity.isFinishing() || mActivity.isDestroyed()) {
            return;
        }
        if (Status.mIsShowFloatWindow) {
            return;
        }
        if (PermissionUtil.hasPermission(this)) {
            mFloatView = createFloatView();
            FloatWindowService.startFloatService(this, mFloatView);
        } else {
            TRTCLogger.i(TAG, "please open Display over other apps permission");
        }
    }

    //home键监听相关
    private void initHomeWatcher() {
        mHomeWatcher = new HomeWatcher(this);
        mHomeWatcher.setOnHomePressedListener(new HomeWatcher.OnHomePressedListener() {
            @Override
            public void onHomePressed() {
                //按了HOME键
                startFloatService();
            }

            @Override
            public void onRecentAppsPressed() {
                //最近app任务列表按键
                startFloatService();
            }
        });
        mHomeWatcher.startWatch();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        TRTCLogger.i(TAG, "onDestroy");
        if (null != mHomeWatcher) {
            mHomeWatcher.stopWatch();
        }
        Status.mBeginTime = 0;
    }
}
