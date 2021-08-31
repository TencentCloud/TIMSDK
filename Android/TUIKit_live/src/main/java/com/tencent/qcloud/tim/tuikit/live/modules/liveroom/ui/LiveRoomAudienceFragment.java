package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.liteav.demo.beauty.BeautyParams;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.tuikit.live.base.BaseFragment;
import com.tencent.qcloud.tim.tuikit.live.base.Constants;
import com.tencent.qcloud.tim.tuikit.live.component.common.ActionSheetDialog;
import com.tencent.qcloud.tim.tuikit.live.component.common.CircleImageView;
import com.tencent.qcloud.tim.tuikit.live.component.bottombar.BottomToolBarLayout;
import com.tencent.qcloud.tim.tuikit.live.component.danmaku.DanmakuManager;
import com.tencent.qcloud.tim.tuikit.live.component.floatwindow.FloatWindowLayout;
import com.tencent.qcloud.tim.tuikit.live.component.gift.GiftAdapter;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.GiftInfo;
import com.tencent.qcloud.tim.tuikit.live.component.gift.GiftPanelDelegate;
import com.tencent.qcloud.tim.tuikit.live.component.gift.IGiftPanelView;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.DefaultGiftAdapterImp;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.GiftAnimatorLayout;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.GiftInfoDataHandler;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.GiftPanelViewImp;
import com.tencent.qcloud.tim.tuikit.live.component.input.InputTextMsgDialog;
import com.tencent.qcloud.tim.tuikit.live.component.like.HeartLayout;
import com.tencent.qcloud.tim.tuikit.live.component.like.LikeFrequencyControl;
import com.tencent.qcloud.tim.tuikit.live.component.message.ChatEntity;
import com.tencent.qcloud.tim.tuikit.live.component.message.ChatLayout;
import com.tencent.qcloud.tim.tuikit.live.component.report.ReportController;
import com.tencent.qcloud.tim.tuikit.live.component.topbar.TopToolBarLayout;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.TUILiveRoomAudienceLayout;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDelegate;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.widget.LiveVideoManagerLayout;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.widget.LiveVideoView;
import com.tencent.qcloud.tim.tuikit.live.utils.PermissionUtils;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;

import java.util.Arrays;
import java.util.List;

import master.flame.danmaku.controller.IDanmakuView;

import static com.tencent.qcloud.tim.tuikit.live.base.Constants.REQUEST_LINK_MIC_TIME_OUT;

public class LiveRoomAudienceFragment extends BaseFragment implements TopToolBarLayout.TopToolBarDelegate {
    private static final String TAG = "LiveAudienceFragment";

    private static final long LINK_MIC_INTERVAL = 3 * 1000;    //连麦间隔控制

    private Context               mContext;
    private TopToolBarLayout      mLayoutTopToolBar;
    private BottomToolBarLayout   mLayoutBottomToolBar;
    private ChatLayout            mLayoutChatMessage;
    private IDanmakuView          mDanmakuView;             // 负责弹幕的显示
    private DanmakuManager        mDanmakuManager;          // 弹幕的管理类
    private AlertDialog           mDialogError;             // 错误提示的Dialog
    private TRTCLiveRoom          mLiveRoom;                // 组件类
    private LikeFrequencyControl  mLikeFrequencyControl;    //点赞频率的控制类
    private GiftAnimatorLayout    mGiftAnimatorLayout;
    private ConstraintLayout      mRootView;
    private LiveVideoManagerLayout mLayoutVideoManager;
    private HeartLayout           mHeartLayout;
    private CircleImageView       mButtonLink;
    private ImageView             mImagePkLayer;
    private TextView              mStatusTipsView;
    private Button                mButtonReportUser;         //举报按钮
    private FloatWindowLayout     mLayoutFloatWindow;        //悬浮窗组件

    private boolean isEnterRoom     = false;    // 表示当前是否已经进房成功
    private boolean isUseCDNPlay    = false;    // 表示当前是否是CDN模式
    private boolean mIsAnchorEnter  = false;    // 表示主播是否已经进房
    private boolean mIsBeingLinkMic = false;    // 表示当前是否在连麦状态
    private boolean isFloatRecovery = false;    // 表示是否是从悬浮窗恢复过来的
    private int     mCurrentStatus  = TRTCLiveRoomDef.ROOM_STATUS_NONE;
    private int     mRoomId;
    private long    mLastLinkMicTime;
    private String  mAnchorId;
    private String  mSelfUserId;
    private String  mCdnUrl;

    private GiftAdapter         mGiftAdapter;
    private GiftInfoDataHandler mGiftInfoDataHandler;

    private Runnable mGetAudienceRunnable;
    private Handler  mHandler         = new Handler(Looper.getMainLooper());
    private Runnable mShowAnchorLeave = new Runnable() {      //如果一定时间内主播没出现
        @Override
        public void run() {
            mLayoutVideoManager.setAnchorOfflineViewVisibility(mIsAnchorEnter ? View.GONE : View.VISIBLE);
            mLayoutBottomToolBar.setVisibility(mIsAnchorEnter ? View.VISIBLE : View.GONE);
            mButtonReportUser.setVisibility(mIsAnchorEnter ? View.VISIBLE : View.GONE);
        }
    };

    private TUILiveRoomAudienceLayout.TUILiveRoomAudienceDelegate mLiveRoomAudienceDelegate;
    private TRTCLiveRoomDef.LiveAnchorInfo                        mAnchorInfo           = new TRTCLiveRoomDef.LiveAnchorInfo();
    private TRTCLiveRoomDelegate                                  mTRTCLiveRoomDelegate = new TRTCLiveRoomDelegate() {
        @Override
        public void onError(int code, String message) {
            TUILiveLog.e(TAG, "onError: " + code + " " + message);
            if (mLiveRoomAudienceDelegate != null) {
                mLiveRoomAudienceDelegate.onError(code, message);
            }
        }

        @Override
        public void onWarning(int code, String message) {

        }

        @Override
        public void onDebugLog(String message) {

        }

        @Override
        public void onRoomInfoChange(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo) {
            mCurrentStatus = roomInfo.roomStatus;
            // 由于CDN模式下是只播放一路画面，所以不需要做画面的设置
            if (isUseCDNPlay) {
                if (mCurrentStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
                    mImagePkLayer.setVisibility(View.GONE);
                } else {
                    mImagePkLayer.setVisibility(View.VISIBLE);
                }
                return;
            }
            mLayoutVideoManager.updateRoomStatus(roomInfo.roomStatus);
            TUILiveLog.d(TAG, "onRoomInfoChange: " + mCurrentStatus);
        }

        @Override
        public void onRoomDestroy(String roomId) {
            if (FloatWindowLayout.getInstance().mWindowMode == Constants.WINDOW_MODE_FLOAT){
                FloatWindowLayout.getInstance().closeFloatWindow();
                return;
            }
            showErrorAndQuit(0, getString(R.string.live_warning_room_disband));
        }

        @Override
        public void onAnchorEnter(final String userId) {
            Log.d(TAG, "onAnchorEnter userId: " + userId + ", mOwnerId -> " + mAnchorId);
            if (userId.equals(mAnchorId)) {
                // 如果是大主播的画面
                mIsAnchorEnter = true;
                mButtonReportUser.setVisibility(View.VISIBLE);
                mHandler.removeCallbacks(mShowAnchorLeave);
                mLayoutVideoManager.startAnchorVideo(userId,true, new TRTCLiveRoomCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (code != 0) {
                            onAnchorExit(userId);
                        }
                    }
                });
                initBottomToolBar();
                updateFollowView(userId);
            } else {
                mLayoutVideoManager.startAnchorVideo(userId, false, null);
            }
        }

        @Override
        public void onAnchorExit(String userId) {
            if (userId.equals(mAnchorId)) {
                mLayoutVideoManager.stopAnchorVideo(userId, true, null);
                mLayoutBottomToolBar.setVisibility(View.GONE);
                mButtonReportUser.setVisibility(View.GONE);
            } else {
                mLayoutVideoManager.stopAnchorVideo(userId, false, null);
            }
        }

        @Override
        public void onAudienceEnter(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            //左下角显示用户加入消息
            ChatEntity entity = new ChatEntity();
            entity.setSenderName(mContext.getString(R.string.live_notification));
            if (TextUtils.isEmpty(userInfo.userName)) {
                entity.setContent(mContext.getString(R.string.live_user_join_live, userInfo.userId));
            } else {
                entity.setContent(mContext.getString(R.string.live_user_join_live, userInfo.userName));
            }
            entity.setType(Constants.MEMBER_ENTER);
            updateIMMessageList(entity);
            addAudienceListLayout(userInfo);
        }

        @Override
        public void onAudienceExit(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            ChatEntity entity = new ChatEntity();
            entity.setSenderName(mContext.getString(R.string.live_notification));
            if (TextUtils.isEmpty(userInfo.userName)) {
                entity.setContent(mContext.getString(R.string.live_user_quit_live, userInfo.userId));
            } else {
                entity.setContent(mContext.getString(R.string.live_user_quit_live, userInfo.userName));
            }
            entity.setType(Constants.MEMBER_EXIT);
            updateIMMessageList(entity);
            removeAudienceListLayout(userInfo);
        }

        @Override
        public void onRequestJoinAnchor(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String reason) {

        }

        @Override
        public void onAudienceRequestJoinAnchorTimeout(String userId) {

        }

        @Override
        public void onAudienceCancelRequestJoinAnchor(String userId) {

        }

        @Override
        public void onKickoutJoinAnchor() {
            stopLinkMic();
        }

        @Override
        public void onRequestRoomPK(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {

        }

        @Override
        public void onAnchorCancelRequestRoomPK(String userId) {

        }

        @Override
        public void onAnchorRequestRoomPKTimeout(String userId) {

        }

        @Override
        public void onQuitRoomPK() {

        }

        @Override
        public void onRecvRoomTextMsg(String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            handleTextMsg(userInfo, message);
        }

        @Override
        public void onRecvRoomCustomMsg(String cmd, String message, TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
            int type = Integer.valueOf(cmd);
            switch (type) {
                case Constants.IMCMD_PRAISE:
                    handlePraiseMsg(userInfo);
                    break;
                case Constants.IMCMD_DANMU:
                    handleDanmuMsg(userInfo, message);
                    break;
                case Constants.IMCMD_GIFT:
                    handleGiftMsg(userInfo, message);
                    break;
                default:
                    break;
            }
        }
    };

    public void setLiveRoomAudienceDelegate(TUILiveRoomAudienceLayout.TUILiveRoomAudienceDelegate liveRoomAudienceDelegate) {
        mLiveRoomAudienceDelegate = liveRoomAudienceDelegate;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initData(getContext());
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = (ConstraintLayout) inflater.inflate(R.layout.live_fragment_live_room_audience, container, false);
        initView(rootView);
        PermissionUtils.checkLivePermission(getActivity());
        return rootView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        if (isFloatRecovery) {
            mLiveRoom.exitRoom(new TRTCLiveRoomCallback.ActionCallback() {
                @Override
                public void onCallback(int code, String msg) {
                    enterRoom();
                }
            });
        } else {
            if (isEnterRoom) {
                enterRoom();
            }
            enterRoom();
        }
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacks(mShowAnchorLeave);
        mHandler.removeCallbacks(mGetAudienceRunnable);
    }

    private void initView(View rootView) {
        // 请求恢复全屏模式
        updateLiveWindowMode(Constants.WINDOW_MODE_FULL);

        mLayoutTopToolBar = rootView.findViewById(R.id.layout_top_toolbar);
        mLayoutBottomToolBar = rootView.findViewById(R.id.layout_bottom_toolbar);
        mLayoutChatMessage = rootView.findViewById(R.id.layout_chat);
        mGiftAnimatorLayout = rootView.findViewById(R.id.lottie_animator_layout);
        mDanmakuView = rootView.findViewById(R.id.view_danmaku);
        mDanmakuManager.setDanmakuView(mDanmakuView);
        mRootView = rootView.findViewById(R.id.root);
        mHeartLayout = rootView.findViewById(R.id.heart_layout);
        mImagePkLayer = rootView.findViewById(R.id.iv_pk_layer);
        mStatusTipsView = rootView.findViewById(R.id.state_tips);
        mLayoutTopToolBar.setTopToolBarDelegate(this);
        mButtonReportUser = rootView.findViewById(R.id.report_user);
        mLayoutVideoManager = rootView.findViewById(R.id.ll_video_view);
        mLayoutVideoManager.updateVideoLayoutByWindowStatus();
        mLayoutVideoManager.setVideoManagerLayoutDelegate(new LiveVideoManagerLayout.VideoManagerLayoutDelegate() {
            @Override
            public void onClose() {
                if (mLiveRoomAudienceDelegate != null) {
                    mLiveRoomAudienceDelegate.onClose();
                }
            }
        });
        mButtonReportUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                reportUser();
            }
        });
    }

    private void initData(Context context) {
        mContext = context;
        mSelfUserId = V2TIMManager.getInstance().getLoginUser();
        mLiveRoom = TRTCLiveRoom.sharedInstance(context);
        mLiveRoom.setDelegate(mTRTCLiveRoomDelegate);
        mDanmakuManager = new DanmakuManager(context);
        mGiftAdapter = new DefaultGiftAdapterImp();
        mGiftInfoDataHandler = new GiftInfoDataHandler();
        mGiftInfoDataHandler.setGiftAdapter(mGiftAdapter);

        Bundle bundle = getArguments();
        if (bundle != null) {
            mRoomId = bundle.getInt(Constants.ROOM_ID);
            isUseCDNPlay = bundle.getBoolean(Constants.USE_CDN);
            mCdnUrl = bundle.getString(Constants.CDN_URL);
            mAnchorId = bundle.getString(Constants.ANCHOR_ID);
        }
    }

    private void enterRoom() {
        if (isEnterRoom) {
            return;
        }
        mLiveRoom.enterRoom(mRoomId, isUseCDNPlay, mCdnUrl, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    isEnterRoom = true;
                    updateTopToolBar();
                } else {
                    exitRoom();
                }
            }
        });
        mHandler.postDelayed(mShowAnchorLeave, 3000);
    }

    private void exitRoom() {
        if (isEnterRoom && mLiveRoom != null) {
            mLiveRoom.exitRoom(null);
            isEnterRoom = false;
        }
    }

    private void initBottomToolBar() {
        mLayoutBottomToolBar.setVisibility(View.VISIBLE);
        mLayoutBottomToolBar.setOnTextSendListener(new InputTextMsgDialog.OnTextSendDelegate() {
            @Override
            public void onTextSend(String msg, boolean tanmuOpen) {
                ChatEntity entity = new ChatEntity();
                entity.setSenderName(mContext.getString(R.string.live_message_me));
                entity.setContent(msg);
                entity.setType(Constants.TEXT_TYPE);
                updateIMMessageList(entity);

                if (tanmuOpen) {
                    if (mDanmakuManager != null) {
                        mDanmakuManager.addDanmu(TUIKitLive.getLoginUserInfo().getFaceUrl(), TUIKitLive.getLoginUserInfo().getNickName(), msg);
                    }

                    mLiveRoom.sendRoomCustomMsg(String.valueOf(Constants.IMCMD_DANMU), msg, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {

                        }
                    });
                } else {
                    mLiveRoom.sendRoomTextMsg(msg, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            if (code != 0) {
                                Toast.makeText(TUIKitLive.getAppContext(), R.string.live_message_send_fail, Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                }
            }
        });

        updateBottomFunctionLayout();
    }


    private void updateBottomFunctionLayout() {
        // 初始化连麦按钮
        mButtonLink = new CircleImageView(mContext);
        mButtonLink.setImageResource(mIsBeingLinkMic ? R.drawable.live_linkmic_off : R.drawable.live_linkmic_on);
        mButtonLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (getActivity() == null){
                    TUILiveLog.d(TAG, "getActivity is null");
                    return;
                }
                if (!mIsBeingLinkMic) {
                    long curTime = System.currentTimeMillis();
                    if (curTime < mLastLinkMicTime + LINK_MIC_INTERVAL) {
                        Toast.makeText(getActivity(), R.string.live_tips_rest, Toast.LENGTH_SHORT).show();
                    } else {
                        mLastLinkMicTime = curTime;
                        requestPermissions(PermissionUtils.getLivePermissions(), new OnPermissionGrandCallback() {
                            @Override
                            public void onAllPermissionsGrand() {
                                startLinkMic();
                            }
                        });
                    }
                } else {
                    stopLinkMic();
                }
            }
        });
        // 初始化点赞按钮
        CircleImageView buttonLike = new CircleImageView(mContext);
        buttonLike.setImageResource(R.drawable.live_bottom_bar_like);
        buttonLike.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mHeartLayout != null) {
                    mHeartLayout.addFavor();
                }
                //点赞发送请求限制
                if (mLikeFrequencyControl == null) {
                    mLikeFrequencyControl = new LikeFrequencyControl();
                    mLikeFrequencyControl.init(2, 1);
                }
                if (mLikeFrequencyControl.canTrigger()) {
                    //向ChatRoom发送点赞消息
                    mLiveRoom.sendRoomCustomMsg(String.valueOf(Constants.IMCMD_PRAISE), "", null);
                }
            }
        });
        // 初始化礼物按钮
        CircleImageView buttonGift = new CircleImageView(mContext);
        buttonGift.setImageResource(R.drawable.live_gift_btn_icon);
        buttonGift.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showGiftPanel();
            }
        });
        // 初始化切换摄像头按钮
        CircleImageView buttonSwitchCam = new CircleImageView(TUIKitLive.getAppContext());
        buttonSwitchCam.setImageResource(R.drawable.live_ic_switch_camera_on);
        buttonSwitchCam.setVisibility(mIsBeingLinkMic ? View.VISIBLE : View.GONE);
        buttonSwitchCam.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mLiveRoom.switchCamera();
            }
        });
        // 初始化退出房间按钮
        CircleImageView buttonExitRoom = new CircleImageView(mContext);
        buttonExitRoom.setImageResource(R.drawable.live_exit_room);
        buttonExitRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                exitRoom();
                mLiveRoomAudienceDelegate.onClose();
            }
        });
        mLayoutBottomToolBar.setRightButtonsLayout(Arrays.asList(mButtonLink, buttonLike, buttonGift, buttonSwitchCam, buttonExitRoom));
    }

    private void startLinkMic() {
        mButtonLink.setEnabled(false);
        mButtonLink.setImageResource(R.drawable.live_linkmic_off);

        mStatusTipsView.setText(R.string.live_wait_anchor_accept);
        mStatusTipsView.setVisibility(View.VISIBLE);
        mLiveRoom.requestJoinAnchor(getString(R.string.live_request_link_mic_anchor, mSelfUserId), REQUEST_LINK_MIC_TIME_OUT, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (getActivity() == null){
                    TUILiveLog.d(TAG, "getActivity is null");
                    return;
                }

                mStatusTipsView.setText("");
                mStatusTipsView.setVisibility(View.GONE);
                if (code == 0) {
                    joinPusher();
                    return;
                }
                if (code == -1) {
                    // 拒绝请求
                    Toast.makeText(getActivity(), msg, Toast.LENGTH_SHORT).show();
                } else if (code == -2) {
                    // 主播超时未响应
                    Toast.makeText(getActivity(), getString(R.string.live_request_time_out), Toast.LENGTH_SHORT).show();
                } else {
                    //出现错误
                    Toast.makeText(getActivity(), getString(R.string.live_error_request_link_mic, msg), Toast.LENGTH_SHORT).show();
                }
                mButtonLink.setEnabled(true);
                //                hideNoticeToast();
                mIsBeingLinkMic = false;
                mButtonLink.setImageResource(R.drawable.live_linkmic_on);
            }
        });
    }

    private void joinPusher() {
        LiveVideoView videoView = mLayoutVideoManager.applyVideoView(mSelfUserId);
        if (videoView == null) {
            Toast.makeText(getActivity(), R.string.live_anchor_view_error, Toast.LENGTH_SHORT).show();
            return;
        }
        BeautyParams beautyParams = new BeautyParams();
        mLiveRoom.getBeautyManager().setBeautyStyle(beautyParams.mBeautyStyle);
        mLiveRoom.getBeautyManager().setBeautyLevel(beautyParams.mBeautyLevel);
        mLiveRoom.getBeautyManager().setWhitenessLevel(beautyParams.mWhiteLevel);
        mLiveRoom.getBeautyManager().setRuddyLevel(beautyParams.mRuddyLevel);
        mLiveRoom.startCameraPreview(true, videoView.getPlayerVideo(), new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code == 0) {
                    mLiveRoom.startPublish("", new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(int code, String msg) {
                            if (getActivity() == null){
                                TUILiveLog.d(TAG, "getActivity is null");
                                return;
                            }

                            if (code == 0) {
                                mButtonLink.setEnabled(true);
                                mIsBeingLinkMic = true;
                                updateBottomFunctionLayout();
                            } else {
                                stopLinkMic();
                                mButtonLink.setEnabled(true);
                                mButtonLink.setImageResource(R.drawable.live_linkmic_on);
                                Toast.makeText(getActivity(), getString(R.string.live_fail_link_mic, msg), Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                }
            }
        });
    }

    private void stopLinkMic() {
        mIsBeingLinkMic = false;

        mLiveRoom.stopCameraPreview();
        mLiveRoom.stopPublish(null);
        if (mLayoutVideoManager != null) {
            mLayoutVideoManager.recycleVideoView(mSelfUserId);
        }
        updateBottomFunctionLayout();
    }

    //展示礼物面板
    private void showGiftPanel() {
        IGiftPanelView giftPanelView = new GiftPanelViewImp(getContext());
        giftPanelView.init(mGiftInfoDataHandler);
        giftPanelView.setGiftPanelDelegate(new GiftPanelDelegate() {
            @Override
            public void onGiftItemClick(GiftInfo giftInfo) {
                sendGift(giftInfo);
            }

            @Override
            public void onChargeClick() {

            }
        });
        giftPanelView.show();
    }

    //发送礼物消息出去同时展示礼物动画和弹幕
    private void sendGift(GiftInfo giftInfo) {
        GiftInfo giftInfoCopy = giftInfo.copy();
        giftInfoCopy.sendUser = mContext.getString(R.string.live_message_me);
        giftInfoCopy.sendUserHeadIcon = TUIKitLive.getLoginUserInfo().getFaceUrl();
        mGiftAnimatorLayout.show(giftInfoCopy);
        mLiveRoom.sendRoomCustomMsg(String.valueOf(Constants.IMCMD_GIFT), giftInfoCopy.giftId, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                if (code != 0) {
                    Toast.makeText(TUIKitLive.getAppContext(), R.string.live_message_send_fail, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void updateTopToolBar() {
        if (!isEnterRoom) {
            return;
        }
        mGetAudienceRunnable = new Runnable() {
            @Override
            public void run() {
                updateTopAnchorInfo();
                updateTopAudienceInfo();
            }
        };
        //为了防止进房后立即获取列表不全，所以增加了一个延迟
        mHandler.postDelayed(mGetAudienceRunnable, 2000);
    }

    private void updateTopAnchorInfo() {
        mLiveRoom.getAnchorList(new TRTCLiveRoomCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveUserInfo> list) {
                if (code == 0) {
                    for (TRTCLiveRoomDef.TRTCLiveUserInfo info : list) {
                        if (info.userId.equals(mAnchorId)) {
                            mAnchorInfo.userId = info.userId;
                            mAnchorInfo.userName = info.userName;
                            mAnchorInfo.avatarUrl = info.avatarUrl;
                            mLayoutTopToolBar.setAnchorInfo(mAnchorInfo);
                            mLayoutVideoManager.updateAnchorOfflineViewBackground(mAnchorInfo.avatarUrl);
                        }
                    }
                } else {
                    Log.e(TAG, "code: " + code + " msg: " + msg + " list size: " + list.size());
                }
            }
        });
    }

    private void updateTopAudienceInfo() {
        mLiveRoom.getAudienceList(new TRTCLiveRoomCallback.UserListCallback() {
            @Override
            public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveUserInfo> list) {
                if (code == 0) {
                    addAudienceListLayout(list);
                }
            }
        });
    }

    private void addAudienceListLayout(List<TRTCLiveRoomDef.TRTCLiveUserInfo> list) {
        mLayoutTopToolBar.addAudienceListUser(list);
    }

    private void addAudienceListLayout(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mLayoutTopToolBar.addAudienceListUser(userInfo);
    }

    private void removeAudienceListLayout(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        mLayoutTopToolBar.removeAudienceUser(userInfo);
    }

    private void updateIMMessageList(ChatEntity entity) {
        mLayoutChatMessage.addMessageToList(entity);
    }

    /**
     * 处理点赞消息
     */
    public void handlePraiseMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        ChatEntity entity = new ChatEntity();

        entity.setSenderName(mContext.getString(R.string.live_notification));
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setContent(mContext.getString(R.string.live_user_click_like, userInfo.userId));
        } else {
            entity.setContent(mContext.getString(R.string.live_user_click_like, userInfo.userName));
        }
        if (mHeartLayout != null) {
            mHeartLayout.addFavor();
        }
        entity.setType(Constants.MEMBER_ENTER);
        updateIMMessageList(entity);
    }

    /**
     * 处理弹幕消息
     */
    public void handleDanmuMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String text) {
        handleTextMsg(userInfo, text);
        if (mDanmakuManager != null) {
            //这里暂时没有头像，所以用默认的一个头像链接代替
            mDanmakuManager.addDanmu(userInfo.avatarUrl, userInfo.userName, text);
        }
    }

    /**
     * 处理礼物弹幕消息
     */
    private void handleGiftMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String giftId) {
        if (mGiftInfoDataHandler != null) {
            GiftInfo giftInfo = mGiftInfoDataHandler.getGiftInfo(giftId);
            if (giftInfo != null) {
                if (userInfo != null) {
                    giftInfo.sendUserHeadIcon = userInfo.avatarUrl;
                    if (!TextUtils.isEmpty(userInfo.userName)) {
                        giftInfo.sendUser = userInfo.userName;
                    } else {
                        giftInfo.sendUser = userInfo.userId;
                    }
                }
                mGiftAnimatorLayout.show(giftInfo);
            }
        }
    }

    /**
     * 处理文本消息
     */
    public void handleTextMsg(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo, String text) {
        ChatEntity entity = new ChatEntity();
        if (TextUtils.isEmpty(userInfo.userName)) {
            entity.setSenderName(userInfo.userId);
        } else {
            entity.setSenderName(userInfo.userName);
        }
        entity.setContent(text);
        entity.setType(Constants.TEXT_TYPE);
        updateIMMessageList(entity);
    }

    @Override
    public void onBackPressed() {
        if (mDanmakuManager != null) {
            mDanmakuManager.destroy();
            mDanmakuManager = null;
        }
        updateLiveWindowMode(Constants.WINDOW_MODE_FLOAT);
    }

    protected void updateLiveWindowMode(int mode) {
        if (FloatWindowLayout.getInstance().mWindowMode == mode) return;

        if (mode == Constants.WINDOW_MODE_FLOAT) {
            FloatWindowLayout.IntentParams intentParams = new FloatWindowLayout.IntentParams(getActivity().getClass(), mRoomId, mAnchorId, isUseCDNPlay, mCdnUrl);
            boolean result =  FloatWindowLayout.getInstance().showFloatWindow(mLayoutVideoManager.mLayoutRoot, intentParams);
            if (!result) {
                exitRoom();
                return;
            }
            FloatWindowLayout.getInstance().mWindowMode = mode;
            mLayoutVideoManager.updateVideoLayoutByWindowStatus();
            FloatWindowLayout.getInstance().setFloatWindowLayoutDelegate(new FloatWindowLayout.FloatWindowLayoutDelegate() {
                @Override
                public void onClose() {
                    exitRoom();
                    if (mLiveRoomAudienceDelegate != null) {
                        mLiveRoomAudienceDelegate.onClose();
                    }

                }
            });
        } else if (mode == Constants.WINDOW_MODE_FULL) {
            FloatWindowLayout.getInstance().closeFloatWindow();
            FloatWindowLayout.getInstance().mWindowMode = mode;
            isFloatRecovery = true;
        }
    }


    /**
     * 显示错误并且退出直播
     *
     * @param errorCode
     * @param errorMsg
     */
    protected void showErrorAndQuit(int errorCode, String errorMsg) {
        if (mDialogError == null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(getContext(), R.style.TUILiveDialogTheme)
                    .setTitle(R.string.live_error)
                    .setMessage(errorMsg)
                    .setNegativeButton(R.string.live_get_it, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            mDialogError.dismiss();
                            exitRoom();
                            if (mLiveRoomAudienceDelegate != null) {
                                mLiveRoomAudienceDelegate.onClose();
                            }
                        }
                    });

            mDialogError = builder.create();
        }
        if (mDialogError.isShowing()) {
            mDialogError.dismiss();
        }
        mDialogError.show();
    }

    private void reportUser() {
        final ReportController reportController = new ReportController();
        String[] reportItems = reportController.getReportItems();
        ActionSheetDialog actionSheetDialog = new ActionSheetDialog(mContext);
        actionSheetDialog.builder();
        actionSheetDialog.setCancelable(false);
        int itemColor = mContext.getResources().getColor(R.color.live_action_sheet_blue);
        actionSheetDialog.addSheetItems(reportItems, itemColor, new ActionSheetDialog.OnSheetItemClickListener() {
            @Override
            public void onClick(int which, String text) {
                if (mAnchorInfo != null) {
                    String userId = mAnchorInfo.userId;
                    reportController.reportUser(mSelfUserId, userId, text);
                }
            }
        });
        actionSheetDialog.show();
    }

    @Override
    public void onClickAnchorAvatar() {

    }

    @Override
    public void onClickFollow(TRTCLiveRoomDef.LiveAnchorInfo liveAnchorInfo) {
        if (liveAnchorInfo != null) {
            followAnchor(liveAnchorInfo.userId);
        }
    }

    @Override
    public void onClickAudience(TRTCLiveRoomDef.TRTCLiveUserInfo audienceInfo) {

    }

    @Override
    public void onClickOnlineNum() {

    }

    private void followAnchor(String userId) {
        mLiveRoom.followAnchor(userId, new TRTCLiveRoomCallback.ActionCallback() {
            @Override
            public void onCallback(int code, String msg) {
                Log.d(TAG, "followAnchor code:" + code + " msg:" + msg);
                if (code == 0) {
                    mLayoutTopToolBar.setHasFollowed(true);
                    Toast.makeText(TUIKitLive.getAppContext(), R.string.live_follow_anchor_success, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void updateFollowView(String userId) {
        mLiveRoom.checkFollowAnchorState(userId, new TRTCLiveRoomCallback.RoomFollowStateCallback() {
            @Override
            public void isFollowed() {
                mLayoutTopToolBar.setHasFollowed(true);
            }

            @Override
            public void isNotFollowed() {
                mLayoutTopToolBar.setHasFollowed(false);
            }

            @Override
            public void onFailed(String errorMessage) {
                mLayoutTopToolBar.setHasFollowed(true);
            }
        });
    }
}
