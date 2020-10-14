package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.trtc.impl.TRTCCloudImpl;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDelegate;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.av.liveplayer.TXLivePlayerRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.av.trtc.ITXTRTCLiveRoomDelegate;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.av.trtc.TXTRTCLiveRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.av.trtc.TXTRTCMixUser;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TRTCLogger;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXRoomInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXRoomInfoListCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXUserInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXUserListCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.ITXRoomServiceDelegate;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl.TXRoomService;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloudDef;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef.ROOM_STATUS_NONE;
import static com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef.ROOM_STATUS_PK;


public class TRTCLiveRoomImpl extends TRTCLiveRoom implements ITXTRTCLiveRoomDelegate, ITXRoomServiceDelegate {
    private static final int CODE_SUCCESS   = 0;
    private static final int CODE_ERROR     = -1;
    public static final  int PK_ANCHOR_NUMS = 2;

    private static final class Role {
        static final int UNKNOWN       = 0;
        static final int TRTC_ANCHOR   = 1;
        static final int TRTC_AUDIENCE = 2;
        static final int CDN_AUDIENCE  = 3;
    }

    private static final class TXCallbackHolder implements TXCallback {
        private WeakReference<TRTCLiveRoomImpl> wefImpl;

        private TRTCLiveRoomCallback.ActionCallback realCallback;

        TXCallbackHolder(TRTCLiveRoomImpl impl) {
            wefImpl = new WeakReference<>(impl);
        }

        public void setRealCallback(TRTCLiveRoomCallback.ActionCallback callback) {
            realCallback = callback;
        }

        @Override
        public void onCallback(final int code, final String msg) {
            TRTCLiveRoomImpl impl = wefImpl.get();
            if (impl != null) {
                impl.runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (realCallback != null) {
                            realCallback.onCallback(code, msg);
                        }
                    }
                });
            }
        }
    }

    private static final String               TAG = "TRTCLiveRoom";
    private static       TRTCLiveRoomImpl     sInstance;
    private              TRTCLiveRoomDelegate mDelegate;
    // 所有调用都切到主线程使用，保证内部多线程安全问题
    private              Handler              mMainHandler;
    // 外部可指定的回调线程
    private              Handler              mDelegateHandler;

    // SDK AppId
    private int                                mSDKAppId;
    // 房间ID RoomService 与 TRTC 都是相同的 ID
    private String                             mRoomId;
    // 用户ID
    private String                             mUserId;
    // 用户签名
    private String                             mUserSign;
    // 配置
    private TRTCLiveRoomDef.TRTCLiveRoomConfig mRoomConfig;
    // 观众端进房默认播放cdn
    private boolean                            mUseCDNFirst;
    // CDN播放的域名
    private String                             mCDNDomain;
    // 房间现在的状态
    private int                                mRoomLiveStatus = ROOM_STATUS_NONE;
    // 房间现在的信息
    private TRTCLiveRoomDef.TRTCLiveRoomInfo   mLiveRoomInfo;
    // 是否依赖于Tuikit使用
    private boolean                            mIsAttachTuikit;

    // 主播列表
    private Set<String> mAnchorList;
    // 已抛出的观众列表
    private Set<String> mAudienceList;

    // 缓存播放的 user id 与对应的 View 用于 CDN 播放与 TRTC 播放切换
    private Map<String, TXCloudVideoView> mPlayViewMap;

    // 下面三个角色用于状态机判断
    // 当前角色
    private int mCurrentRole;
    // 目标角色
    private int mTargetRole;
    // 上一个角色 - 用于下麦后，切换到 CDN 观众还是 TRTC 观众
    private int mOriginalRole;

    // 防止内存泄露
    private TXCallbackHolder mJoinAnchorCallbackHolder;
    // 防止内存泄露
    private TXCallbackHolder mRequestPKHolder;

    public static synchronized TRTCLiveRoom sharedInstance(Context context) {
        if (sInstance == null) {
            sInstance = new TRTCLiveRoomImpl(context.getApplicationContext());
        }
        return sInstance;
    }

    public static synchronized void destroySharedInstance() {
        if (sInstance != null) {
            sInstance.destroy();
            sInstance = null;
        }
    }

    private TRTCLiveRoomImpl(Context context) {
        mCurrentRole = Role.CDN_AUDIENCE;
        mOriginalRole = Role.CDN_AUDIENCE;
        mTargetRole = Role.CDN_AUDIENCE;
        mMainHandler = new Handler(Looper.getMainLooper());
        mDelegateHandler = new Handler(Looper.getMainLooper());
        mLiveRoomInfo = new TRTCLiveRoomDef.TRTCLiveRoomInfo();
        mSDKAppId = 0;
        mRoomId = "";
        mUserId = "";
        mUserSign = "";
        TXLivePlayerRoom.getInstance().init(context);
        TXTRTCLiveRoom.getInstance().init(context);
        TXTRTCLiveRoom.getInstance().setDelegate(this);
        TXRoomService.getInstance().init(context);
        TXRoomService.getInstance().setDelegate(this);
        mPlayViewMap = new HashMap<>();
        mAnchorList = new HashSet<>();
        mAudienceList = new HashSet<>();
        //        mThrowVideoAvailableAnchorList = new HashSet<>();
        mJoinAnchorCallbackHolder = new TXCallbackHolder(this);
        mRequestPKHolder = new TXCallbackHolder(this);
    }

    private void destroy() {
        TXRoomService.getInstance().destroy();
        TRTCCloudImpl.destroySharedInstance();
    }

    private void runOnMainThread(Runnable runnable) {
        Handler handler = mMainHandler;
        if (handler != null) {
            if (handler.getLooper() == Looper.myLooper()) {
                runnable.run();
            } else {
                handler.post(runnable);
            }
        } else {
            runnable.run();
        }
    }

    private void runOnDelegateThread(Runnable runnable) {
        Handler handler = mDelegateHandler;
        if (handler != null) {
            if (handler.getLooper() == Looper.myLooper()) {
                runnable.run();
            } else {
                handler.post(runnable);
            }
        } else {
            runnable.run();
        }
    }

    @Override
    public void setDelegate(final TRTCLiveRoomDelegate delegate) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.setDelegate(delegate);
                mDelegate = delegate;
            }
        });
    }

    @Override
    public void setDelegateHandler(final Handler handler) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (handler != null) {
                    mDelegateHandler = handler;
                }
            }
        });
    }

    /**
     * 开始登陆：
     * 参数校验：check(params)
     * |- false: 回调失败
     * |- true: 登陆到房间服务: TXRoomService.login
     * |- callback 回调成功或失败
     *
     * @param sdkAppId
     * @param userId
     * @param userSig
     * @param config
     * @param callback
     */
    @Override
    public void login(final int sdkAppId, final String userId, final String userSig, final TRTCLiveRoomDef.TRTCLiveRoomConfig config, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start login, sdkAppId:" + sdkAppId + " userId:" + userId + " config:" + config + " sign is empty:" + TextUtils.isEmpty(userSig));
                if (sdkAppId == 0 || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userSig) || config == null) {
                    TRTCLogger.e(TAG, "start login fail. params invalid.");
                    if (callback != null) {
                        callback.onCallback(-1, "登录失败，参数有误");
                    }
                    return;
                }
                mSDKAppId = sdkAppId;
                mUserId = userId;
                mUserSign = userSig;
                mRoomConfig = config;
                mIsAttachTuikit = config.isAttachTuikit;
                TRTCLogger.i(TAG, "start login room service");
                TXRoomService.getInstance().login(sdkAppId, userId, userSig, mIsAttachTuikit, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "login room service finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 开始登出：
     * 从房间服务登出：TXRoomService.logout
     * |- 回调成功或失败
     *
     * @param callback
     */
    @Override
    public void logout(final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start logout");
                mSDKAppId = 0;
                mUserId = "";
                mUserSign = "";
                TRTCLogger.i(TAG, "start logout room service");
                TXRoomService.getInstance().logout(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "logout room service finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 设置个人信息：昵称、头像
     * 将个人信息设定到房间服务：TXRoomService.setSelfProfile
     * |- 回调成功或失败
     *
     * @param userName
     * @param avatarURL
     * @param callback
     */
    @Override
    public void setSelfProfile(final String userName, final String avatarURL, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "set profile, user name:" + userName + " avatar url:" + avatarURL);
                TXRoomService.getInstance().setSelfProfile(userName, avatarURL, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "set profile finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 主播创建房间：
     * 1. 进入 TRTC 房间：this.enterTRTCRoomInner
     * |- check(params)
     * |- false: 回调登陆失败
     * |- true:
     * |- TXTRTCRoom.enterRoom
     * |- false: 回调登陆失败
     * |- true:
     * |- 记录当前角色为 Role.TRTC_ANCHOR 角色，用于状态机判断
     * |- 回调登陆成功
     * 2. 登陆到房间服务，启用 IM 能力： TXRoomService.createRoom
     * |- 忽略返回值
     * <p>
     * 说明：
     * 1. 为了保证准确性，这里会先创建IM房间，再进入TRTC的房间
     * 2. 创建房间成功后，组装 RoomInfo，并通知房间状态变更，回调上层RoomInfoChange
     *
     * @param roomId
     * @param roomParam
     * @param callback
     */
    @Override
    public void createRoom(final int roomId, final TRTCLiveRoomDef.TRTCCreateRoomParam roomParam, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "create room, room id:" + roomId + " info:" + roomParam);
                if (roomId == 0) {
                    TRTCLogger.e(TAG, "create room fail. params invalid");
                    return;
                }

                mRoomId = String.valueOf(roomId);

                // 恢复设定
                mCurrentRole = Role.UNKNOWN;
                mTargetRole = Role.UNKNOWN;
                mOriginalRole = Role.TRTC_ANCHOR;
                mRoomLiveStatus = ROOM_STATUS_NONE;

                mAnchorList.clear();
                mAudienceList.clear();

                mTargetRole = Role.TRTC_ANCHOR;
                final String roomName  = (roomParam == null ? "" : roomParam.roomName);
                final String roomCover = (roomParam == null ? "" : roomParam.coverUrl);
                // 创建房间
                TXRoomService.getInstance().createRoom(mRoomId, roomName, roomCover, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "create room in service, code:" + code + " msg:" + msg);
                        if (code == 0) {
                            enterTRTCRoomInner(mRoomId, mUserId, mUserSign, TRTCCloudDef.TRTCRoleAnchor, new TRTCLiveRoomCallback.ActionCallback() {
                                @Override
                                public void onCallback(final int code, final String msg) {
                                    if (code == 0) {
                                        runOnMainThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                mAnchorList.add(mUserId);
                                                mCurrentRole = Role.TRTC_ANCHOR;
                                            }
                                        });
                                    }
                                    runOnDelegateThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (callback != null) {
                                                callback.onCallback(code, msg);
                                            }
                                        }
                                    });
                                }
                            });
                            return;
                        } else {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    TRTCLiveRoomDelegate delegate = mDelegate;
                                    if (delegate != null) {
                                        delegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 主播销毁房间：
     * 1. 退出 TRTC 房间：TXTRTCLiveRoom.destroyRoom
     * |- 失败则回调 onError，TRTC 的退房信令比较可靠，不过就算退房失败也是无所谓的。
     * <p>
     * 2. 从房间服务销毁：TXRoomService.destroyRoom
     * |- 回调成功与失败
     * <p>
     * 说明：
     * 1. destroyRoom 要以房间服务销毁的回调为准，只有房间服务销毁，才算销毁成功
     *
     * @param callback
     */
    @Override
    public void destroyRoom(final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start destroy room.");
                quitRoomPK(null);

                // TRTC 房间退房关心不关心结果都是无所谓的
                TRTCLogger.i(TAG, "start exit trtc room.");
                TXTRTCLiveRoom.getInstance().exitRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "exit trtc room finish, code:" + code + " msg:" + msg);
                        if (code != 0) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    TRTCLiveRoomDelegate delegate = mDelegate;
                                    if (delegate != null) {
                                        delegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });

                TRTCLogger.i(TAG, "start destroy room service.");
                TXRoomService.getInstance().destroyRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "destroy room finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
                mPlayViewMap.clear();

                // 恢复设定
                mCurrentRole = Role.UNKNOWN;
                mTargetRole = Role.UNKNOWN;
                mOriginalRole = Role.UNKNOWN;
                mRoomLiveStatus = ROOM_STATUS_NONE;

                mAnchorList.clear();
                mRoomId = "";

                mJoinAnchorCallbackHolder.setRealCallback(null);
                mRequestPKHolder.setRealCallback(null);
            }
        });
    }

    /**
     * 观众进房：
     * 1. 检查当前走 TRTC 还是 CDN：check(useCDNFirst)
     * |- true: 无需登录 TRTC
     * |- false: 登录到 TRTC
     * |- 回调结果
     * 2. 登录到房间服务：TXRoomService.enterRoom
     * |- 结果
     * |- check(useCDNFirst)
     * |- true: 回调结果
     * |- false: 无
     * <p>
     * 说明：
     * 1. 如果观众走 TRTC，会同步进入TRTC 房间和 IM 房间，回调结果以 TRTC 的为准。
     * 2. CDN观众不进入 TRTC 房间，回调结果以 IM 为准；
     * 3. 进入 IM 房间后会在群资料中获取 roomInfo 和 主播的信息，此时回调 房间状态变更 和 主播流信息（CDN下需要使用）
     *
     * @param roomId
     * @param callback
     */
    @Override
    public void enterRoom(final int roomId, final boolean useCDNFirst, final String cdnURL, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // 恢复设定
                mCurrentRole = Role.UNKNOWN;
                mTargetRole = Role.UNKNOWN;
                mOriginalRole = Role.UNKNOWN;
                mRoomLiveStatus = ROOM_STATUS_NONE;

                mAnchorList.clear();
                mRoomId = String.valueOf(roomId);
                mUseCDNFirst = useCDNFirst;
                mCDNDomain = cdnURL;
                TRTCLiveRoomDef.TRTCLiveRoomConfig config      = mRoomConfig;

                if (useCDNFirst) {
                    mOriginalRole = Role.CDN_AUDIENCE;
                } else {
                    mOriginalRole = Role.TRTC_AUDIENCE;
                }

                // 如果使用 CDN 那么使用 room service 作为 callbak，否则用 TRTC
                TRTCLogger.i(TAG, "start enter room, room id:" + roomId + " use cdn:" + useCDNFirst);
                final boolean finalUseCDNFirst = useCDNFirst;

                if (!finalUseCDNFirst) {
                    TRTCLogger.i(TAG, "start enter trtc room.");
                    mTargetRole = Role.TRTC_AUDIENCE;
                    enterTRTCRoomInner(mRoomId, mUserId, mUserSign, TRTCCloudDef.TRTCRoleAudience, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "trtc enter room finish, room id:" + roomId + " code:" + code + " msg:" + msg);
                            runOnMainThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (code == 0) {
                                        mCurrentRole = Role.TRTC_AUDIENCE;
                                    }
                                }
                            });
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    });
                }
                TXRoomService.getInstance().enterRoom(mRoomId, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "enter room service finish, room id:" + roomId + " code:" + code + " msg:" + msg);
                        runOnMainThread(new Runnable() {
                            @Override
                            public void run() {
                                if (finalUseCDNFirst && callback != null) {
                                    // 如果使用CDN，那么回调以 RoomService 的为准
                                    runOnDelegateThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            callback.onCallback(code, msg);
                                        }
                                    });
                                }
                                if (code != 0) {
                                    runOnDelegateThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            TRTCLiveRoomDelegate delegate = mDelegate;
                                            if (delegate != null) {
                                                delegate.onError(code, msg);
                                            }
                                        }
                                    });
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 观众退房
     * <p>
     * 1. 如果现在的角色是小主播（已经上麦），需要先停止推流告诉房主更新状态
     * 2. 无需判断是否已经在 TRTC 房间，都退一次房：TXTRTCLiveRoom.destroyRoom
     * |- 回调结果无需关注
     * <p>
     * 3. 无论判断是否用 CDN 播放，都将直播播放停止： TXLivePlayerRoom.stopAllPlay
     * <p>
     * 4. 退出房间服务： TXRoomService.destroyRoom
     * |- 回调结果
     *
     * @param callback
     */
    @Override
    public void exitRoom(final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start exit room.");
                // 退房的时候需要判断是否是连麦者，如果是连麦者，需要停止推流操作告诉房主更新房间状态
                if (mCurrentRole == Role.TRTC_ANCHOR) {
                    stopPublish(null);
                }

                TXTRTCLiveRoom.getInstance().exitRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        if (code != 0) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    TRTCLiveRoomDelegate delegate = mDelegate;
                                    if (delegate != null) {
                                        delegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });
                TRTCLogger.i(TAG, "start stop all live player.");
                TXLivePlayerRoom.getInstance().stopAllPlay();
                TRTCLogger.i(TAG, "start exit room service.");
                TXRoomService.getInstance().exitRoom(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "exit room finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
                mPlayViewMap.clear();
                mAnchorList.clear();
                mRoomId = "";
                mTargetRole = Role.UNKNOWN;
                mOriginalRole = Role.UNKNOWN;
                mCurrentRole = Role.UNKNOWN;
                mJoinAnchorCallbackHolder.setRealCallback(null);
                mRequestPKHolder.setRealCallback(null);
            }
        });
    }

    /**
     * 获取房间信息
     * 会从IM中获取房间信息，并且过滤掉没有房主id的房间
     */
    @Override
    public void getRoomInfos(final List<Integer> roomIdList, final TRTCLiveRoomCallback.RoomInfoCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                final List<TRTCLiveRoomDef.TRTCLiveRoomInfo> trtcLiveRoomInfoList = new ArrayList<>();
                TRTCLogger.i(TAG, "start getRoomInfos: " + roomIdList);
                List<String> strings = new ArrayList<>();
                for (Integer id : roomIdList) {
                    strings.add(String.valueOf(id));
                }
                TXRoomService.getInstance().getRoomInfos(strings, new TXRoomInfoListCallback() {
                    @Override
                    public void onCallback(int code, String msg, List<TXRoomInfo> list) {
                        if (code == 0) {
                            for (TXRoomInfo info : list) {
                                TRTCLogger.i(TAG, info.toString());
                                // 这里是否需要过滤那些没有ownerId的房间
                                if (TextUtils.isEmpty(info.ownerId)) {
                                    continue;
                                }
                                TRTCLiveRoomDef.TRTCLiveRoomInfo liveRoomInfo = new TRTCLiveRoomDef.TRTCLiveRoomInfo();
                                int                              translateRoomId;
                                try {
                                    translateRoomId = Integer.valueOf(info.roomId);
                                } catch (NumberFormatException e) {
                                    continue;
                                }
                                liveRoomInfo.roomId = translateRoomId;
                                liveRoomInfo.memberCount = info.memberCount;
                                liveRoomInfo.roomName = info.roomName;
                                liveRoomInfo.ownerId = info.ownerId;
                                liveRoomInfo.coverUrl = info.coverUrl;
                                liveRoomInfo.streamUrl = info.streamUrl;
                                liveRoomInfo.ownerName = info.ownerName;
                                trtcLiveRoomInfoList.add(liveRoomInfo);
                            }
                        }
                        if (callback != null) {
                            callback.onCallback(code, msg, trtcLiveRoomInfoList);
                        }
                    }
                });
            }
        });
    }

    /**
     * 获取主播信息
     * 1. TRTC进房后，有主播进/退房会通知流水线，流水线维护一个AnchorList
     * 2. 需要获取主播的详细信息，会拿这个AnchorList去IM查询信息
     * 3. 回调结果
     *
     * @param callback 用户详细信息回调
     */
    @Override
    public void getAnchorList(final TRTCLiveRoomCallback.UserListCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                List<String> anchorList = new ArrayList<>(mAnchorList);
                if (anchorList.size() > 0) {
                    TRTCLogger.i(TAG, "start getAnchorList");
                    TXRoomService.getInstance().getUserInfo(anchorList, new TXUserListCallback() {
                        @Override
                        public void onCallback(int code, String msg, List<TXUserInfo> list) {
                            if (code == 0) {
                                List<TRTCLiveRoomDef.TRTCLiveUserInfo> trtcLiveUserInfoList = new ArrayList<>();
                                for (TXUserInfo info : list) {
                                    TRTCLogger.i(TAG, info.toString());
                                    TRTCLiveRoomDef.TRTCLiveUserInfo userInfo = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                                    userInfo.userId = info.userId;
                                    userInfo.userName = info.userName;
                                    userInfo.avatarUrl = info.avatarURL;
                                    trtcLiveUserInfoList.add(userInfo);
                                }
                                callback.onCallback(code, msg, trtcLiveUserInfoList);
                            } else {
                                callback.onCallback(code, msg, new ArrayList<TRTCLiveRoomDef.TRTCLiveUserInfo>());
                            }
                            TRTCLogger.i(TAG, "onCallback: " + code + " " + msg);
                        }
                    });
                } else {
                    if (callback != null) {
                        callback.onCallback(0, "用户列表为空", new ArrayList<TRTCLiveRoomDef.TRTCLiveUserInfo>());
                    }
                }
            }
        });
    }

    /**
     * 获取观众信息
     * 1. TRTC进房后，有主播进/退房会通知流水线，流水线维护主播列表AnchorList
     * 2. 向IM查询群内所有的成员列表，然后过滤掉主播
     * 3. 回调结果
     *
     * @param callback 用户详细信息回调
     */
    @Override
    public void getAudienceList(final TRTCLiveRoomCallback.UserListCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().getAudienceList(new TXUserListCallback() {
                    @Override
                    public void onCallback(final int code, final String msg, final List<TXUserInfo> list) {
                        TRTCLogger.i(TAG, "get audience list finish, code:" + code + " msg:" + msg + " list:" + (list != null ? list.size() : 0));
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    List<TRTCLiveRoomDef.TRTCLiveUserInfo> userList = new ArrayList<>();
                                    if (list != null) {
                                        for (TXUserInfo info : list) {
                                            // 过滤掉主播
                                            if (mAnchorList.contains(info.userId)) {
                                                continue;
                                            }
                                            TRTCLiveRoomDef.TRTCLiveUserInfo trtcUserInfo = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                                            trtcUserInfo.userId = info.userId;
                                            trtcUserInfo.avatarUrl = info.avatarURL;
                                            trtcUserInfo.userName = info.userName;
                                            userList.add(trtcUserInfo);
                                            TRTCLogger.i(TAG, "info:" + info);
                                        }
                                    }
                                    callback.onCallback(code, msg, userList);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    /**
     * 透传给 TRTC 打开摄像头
     *
     * @param isFront  YES：前置摄像头；NO：后置摄像头。
     * @param view     承载视频画面的控件
     * @param callback 操作回调
     */
    @Override
    public void startCameraPreview(final boolean isFront, final TXCloudVideoView view, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start camera preview。");
                TXTRTCLiveRoom.getInstance().startCameraPreview(isFront, view, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "start camera preview finish, code:" + code + " msg:" + msg);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(code, msg);
                                }
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void stopCameraPreview() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "stop camera preview.");
                TXTRTCLiveRoom.getInstance().stopCameraPreview();
            }
        });
    }

    /**
     * 开始推流：
     * <p>
     * 1. 判断当前是否已经在 TRTC 房间：this.isTRTCMode
     * |- true: 直接开始推流
     * |            |- 回调结果
     * |- false:
     * |- 进入 TRTC 房间
     * |- false：回调结果
     * |- true：开始推流
     * |- 回调结果
     * <p>
     * 2. 更新 stream id 到房间服务：TXRoomService.updateStreamId
     * |- 回调结果忽略
     *
     * @param streamId
     * @param callback
     */
    @Override
    public void startPublish(final String streamId, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                String tempStreamId = streamId;
                if (TextUtils.isEmpty(tempStreamId)) {
                    tempStreamId = mSDKAppId + "_" + mRoomId + "_" + mUserId + "_main";
                }
                final String finalStreamId = tempStreamId;

                if (!isTRTCMode()) {
                    if (TextUtils.isEmpty(mRoomId)) {
                        TRTCLogger.e(TAG, "start publish error, room id is empty.");
                        if (callback != null) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    callback.onCallback(-1, "推流失败, room id 为空");
                                }
                            });
                        }
                        return;
                    }
                    mTargetRole = Role.TRTC_ANCHOR;
                    // 还没进入，先进入 TRTC 房
                    TRTCLogger.i(TAG, "enter trtc room before start publish.");
                    enterTRTCRoomInner(mRoomId, mUserId, mUserSign, TRTCCloudDef.TRTCRoleAudience, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "enter trtc room finish, code:" + code + " msg:" + msg);
                            mCurrentRole = Role.TRTC_ANCHOR;
                            if (code == 0) {
                                // 进入 TRTC 房完成，开始推流
                                startPublishInner(finalStreamId, callback);
                                if (mOriginalRole == Role.CDN_AUDIENCE) {
                                    changeToTRTCPlay();
                                }
                            } else {
                                runOnDelegateThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        callback.onCallback(code, msg);
                                    }
                                });
                            }
                        }
                    });
                } else {
                    startPublishInner(finalStreamId, new TRTCLiveRoomCallback.ActionCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    callback.onCallback(code, msg);
                                }
                            });
                        }
                    });
                }
                TRTCLogger.i(TAG, "update room service stream id:" + finalStreamId);
                TXRoomService.getInstance().updateStreamId(finalStreamId, new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "room service start publish, code:" + code + " msg:" + msg);
                        if (code != 0) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    TRTCLiveRoomDelegate delegate = mDelegate;
                                    if (delegate != null) {
                                        delegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });
            }
        });
    }

    /**
     * 停止推流
     * 1. 停止 TRTC 推流：TXTRTCLiveRoom.stopPublish，如果是原始角色是trtc主播需要退房，trtc观众则需要切换角色(即退出连麦)
     * |- check(mOriginalRole == Role.CDN_AUDIENCE)
     * |- true:
     * |    |- 1. 退出 TRTC 房间
     * |    |- 2. 切换到 CDN 播放
     * |- false:
     * 2. 更新 stream id 到房间服务：TXRoomService.updateStreamId
     * |- 回调结果忽略
     * 3. check(mOriginalRole == 观众) 退出连麦
     *
     * @param callback
     */
    @Override
    public void stopPublish(final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "stop publish");
                TXTRTCLiveRoom.getInstance().stopPublish(new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "stop publish finish, code:" + code + " msg:" + msg);
                        if (mOriginalRole == Role.CDN_AUDIENCE) {
                            mTargetRole = Role.CDN_AUDIENCE;

                            TRTCLogger.i(TAG, "start exit trtc room.");
                            TXTRTCLiveRoom.getInstance().exitRoom(new TXCallback() {
                                @Override
                                public void onCallback(int code, String msg) {
                                    TRTCLogger.i(TAG, "exit trtc room finish, code:" + code + " msg:" + msg);
                                    runOnMainThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            mCurrentRole = Role.CDN_AUDIENCE;
                                            changeToCDNPlay();
                                        }
                                    });
                                }
                            });
                        } else {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });

                TRTCLogger.i(TAG, "start update stream id");
                TXRoomService.getInstance().updateStreamId("", new TXCallback() {
                    @Override
                    public void onCallback(final int code, final String msg) {
                        TRTCLogger.i(TAG, "room service update stream id finish, code:" + code + " msg:" + msg);
                        if (code != 0) {
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    TRTCLiveRoomDelegate delegate = mDelegate;
                                    if (delegate != null) {
                                        delegate.onError(code, msg);
                                    }
                                }
                            });
                        }
                    }
                });
                if (mOriginalRole == Role.TRTC_AUDIENCE || mOriginalRole == Role.CDN_AUDIENCE) {
                    TXRoomService.getInstance().quitLinkMic();
                }
            }
        });
    }

    private void changeToCDNPlay() {
        TRTCLogger.i(TAG, "switch trtc to cdn play");
        // 需要等退房完成，否则可能导致View占用。
        // TRTC 播放切 CDN 播放

        // 1. 停止所有 TRTC 播放
        TXTRTCLiveRoom.getInstance().stopAllPlay();
        // 2. 获取房主的 userId
        final String ownerId = TXRoomService.getInstance().getOwnerUserId();
        if (!TextUtils.isEmpty(ownerId)) {
            // 3. 抛出其他流不可播放，且其他主播退房
            Set<String> leaveAnchorSet = new HashSet<>();

            Iterator<String> anchorIterator = mAnchorList.iterator();
            while (anchorIterator.hasNext()) {
                String userId = anchorIterator.next();
                if (!TextUtils.isEmpty(userId) && !userId.equals(ownerId)) {
                    // 只要不是房主的全部离开
                    leaveAnchorSet.add(userId);
                    anchorIterator.remove();
                    // 移除掉 View
                    mPlayViewMap.remove(userId);
                }
            }

            TRTCLiveRoomDelegate delegate = mDelegate;
            if (delegate != null) {
                for (String userId : leaveAnchorSet) {
                    delegate.onAnchorExit(userId);
                }
            }

            final String ownerPlayURL = getPlayURL(ownerId);
            if (!TextUtils.isEmpty(ownerPlayURL)) {
                TXCloudVideoView view = mPlayViewMap.get(ownerId);
                // 4. 开始 CDN 播放
                TXLivePlayerRoom.getInstance().startPlay(ownerPlayURL, view, null);
            } else {
                TRTCLogger.e(TAG, "change to play cdn fail, can't get owner play url, owner id:" + ownerId);
            }
        } else {
            TRTCLogger.e(TAG, "change to play cdn fail, can't get owner user id.");
        }
    }


    private void changeToTRTCPlay() {
        TRTCLogger.i(TAG, "switch cdn to trtc play");
        // 如果之前是 CDN 观众，那么则需要将播放的流切换到 TRTC
        TXLivePlayerRoom.getInstance().stopAllPlay();
        for (String userId : mAnchorList) {
            TXTRTCLiveRoom.getInstance().startPlay(userId, mPlayViewMap.get(userId), null);
        }
    }

    /**
     * 开始播放
     * <p>
     * 1. 保存 View 到集合中，用于 CDN 与 TRTC 播放切换的时候使用，TRTC 在首帧到来的时候，会回调成功
     * <p>
     * 2. 当前是否使用 TRTC 模式播放：check(isTRTCMode)
     * |- true: 直接使用 TRTC 播放：TXTRTCLiveRoom.startPlay
     * |- false：
     * |- 根据 user id 去房间服务查询 stream id: TXRoomService.exchangeStreamId
     * |- 根据 stream id 以及 config.domain 拼接播放 url
     * |- 使用直播播放器播放：TXLivePlayerRoom.startPlay
     *
     * @param userId
     * @param view
     * @param callback
     */
    @Override
    public void startPlay(final String userId, final TXCloudVideoView view, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mPlayViewMap.put(userId, view);
                if (isTRTCMode()) {
                    TXTRTCLiveRoom.getInstance().startPlay(userId, view, new TXCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "start trtc play finish, code:" + code + " msg:" + msg);
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    });
                } else {
                    String playURL = getPlayURL(userId);
                    if (!TextUtils.isEmpty(playURL)) {
                        TRTCLogger.i(TAG, "start cdn play, url:" + playURL);
                        TXLivePlayerRoom.getInstance().startPlay(playURL, view, new TXCallback() {
                            @Override
                            public void onCallback(final int code, final String msg) {
                                TRTCLogger.i(TAG, "start cdn play finish, code:" + code + " msg:" + msg);
                                runOnDelegateThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        if (callback != null) {
                                            callback.onCallback(code, msg);
                                        }
                                    }
                                });
                            }
                        });
                    } else {
                        TRTCLogger.e(TAG, "start cdn play error, can't find stream id by user id:" + userId);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(-1, "启动CDN播放失败，找不到对应的流ID");
                                }
                            }
                        });
                    }
                }
            }
        });
    }

    /**
     * 停止播放：
     * 1. 从集合移除缓存的 View
     * 2. 当前是否使用 TRTC 模式播放：check(isTRTCMode)
     * |- true: 直接停止播放
     * |- false:
     * |- 根据 user id 去房间服务查询 stream id: TXRoomService.exchangeStreamId
     * |- 根据 stream id 以及 config.domain 拼接播放 url
     * |- 使用直播播放器停止播放：TXLivePlayerRoom.stopPlay
     *
     * @param userId
     * @param callback
     */
    @Override
    public void stopPlay(final String userId, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mPlayViewMap.remove(userId);
                if (isTRTCMode()) {
                    TXTRTCLiveRoom.getInstance().stopPlay(userId, new TXCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "stop trtc play finish, code:" + code + " msg:" + msg);
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    });
                } else {
                    String playURL = getPlayURL(userId);
                    if (!TextUtils.isEmpty(playURL)) {
                        TRTCLogger.i(TAG, "stop play, url:" + playURL);
                        TXLivePlayerRoom.getInstance().stopPlay(playURL, new TXCallback() {
                            @Override
                            public void onCallback(final int code, final String msg) {
                                TRTCLogger.i(TAG, "stop cdn play finish, code:" + code + " msg:" + msg);
                                runOnDelegateThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        if (callback != null) {
                                            callback.onCallback(code, msg);
                                        }
                                    }
                                });
                            }
                        });
                    } else {
                        TRTCLogger.e(TAG, "stop cdn play error, can't find stream id by user id:" + userId);
                        runOnDelegateThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onCallback(-1, "停止播放失败，找不到对应的流ID");
                                }
                            }
                        });
                    }
                }
            }
        });
    }

    /**
     * 请求连麦：
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 发起连麦请求：TXRoomService.requestJoinAnchor
     * |                                           |- 回调结果
     * |- false: 回调失败
     * 观众主动发起连麦，等待15s的超时，如果超时回调-2
     *
     * @param reason
     * @param timeout
     * @param callback
     */
    @Override
    public void requestJoinAnchor(final String reason, final int timeout, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (mRoomLiveStatus == ROOM_STATUS_PK) {
                    //正在PK中
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(CODE_ERROR, "正在PK中");
                            }
                        }
                    });
                    return;
                }
                if (TXRoomService.getInstance().isLogin()) {
                    TRTCLogger.i(TAG, "start join anchor.");
                    mJoinAnchorCallbackHolder.setRealCallback(callback);
                    TXRoomService.getInstance().requestJoinAnchor(reason, timeout, mJoinAnchorCallbackHolder);
                } else {
                    TRTCLogger.e(TAG, "request join anchor fail, not login yet.");
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(CODE_ERROR, "请求上麦失败，IM未登录");
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    public void cancelRequestJoinAnchor(final String reason, TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start cancel request anchor.");
                TXRoomService.getInstance().cancelRequestJoinAnchor(reason, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {

                    }
                });
            }
        });
    }

    /**
     * 响应连麦请求
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 使用房间服务响应请求：TXRoomService.responseJoinAnchor
     * |- false: 忽略
     * 主播接受到连麦请求，等待10s超时，如果不调用 responseJoinAnchor，会自动结束流程
     * 回复同意连麦后 会等待3s 超时，如果超时会自动结束流程
     *
     * @param userId
     * @param agree
     * @param reason
     */
    @Override
    public void responseJoinAnchor(final String userId, final boolean agree, final String reason) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (TXRoomService.getInstance().isLogin()) {
                    TRTCLogger.i(TAG, "response join anchor.");
                    TXRoomService.getInstance().responseJoinAnchor(userId, agree, reason);
                } else {
                    TRTCLogger.e(TAG, "response join anchor fail. not login yet.");
                }
            }
        });
    }

    /**
     * 主播踢出连麦者
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 使用房间服务发送踢出信令：TXRoomService.kickJoinAnchor
     * |                                                   |- 回调结果
     * |- false: 回调失败
     * 观众端会自动调用stopPublish退出连麦
     *
     * @param userId
     * @param callback
     */
    @Override
    public void kickoutJoinAnchor(final String userId, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (TXRoomService.getInstance().isLogin()) {
                    TRTCLogger.i(TAG, "kick out join anchor.");
                    TXRoomService.getInstance().kickoutJoinAnchor(userId, new TXCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "kick out finish, code:" + code + " msg:" + msg);
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    });
                } else {
                    TRTCLogger.e(TAG, "kick out fail. not login yet.");
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(CODE_ERROR, "踢人失败，IM未登录");
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 发起 PK 请求
     * <p>
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 使用房间服务发送请求 PK 信令：TXRoomService.requestRoomPK
     * |                                                       |- 回调结果
     * |- false: 回调结果失败
     * 主动发起PK，等待15s的超时，如果超时回调-2
     *
     * @param roomId
     * @param userId
     * @param callback
     */
    @Override
    public void requestRoomPK(int roomId, String userId, int timeout, final TRTCLiveRoomCallback.ActionCallback callback) {
        if (TXRoomService.getInstance().isLogin()) {
            TRTCLogger.i(TAG, "request room pk.");
            mRequestPKHolder.setRealCallback(callback);
            TXRoomService.getInstance().requestRoomPK(String.valueOf(roomId), userId, timeout, mRequestPKHolder);
        } else {
            TRTCLogger.e(TAG, "request room pk fail. not login yet.");
            runOnDelegateThread(new Runnable() {
                @Override
                public void run() {
                    if (callback != null) {
                        callback.onCallback(CODE_ERROR, "请求PK失败，IM未登录");
                    }
                }
            });
        }
    }

    @Override
    public void cancelRequestRoomPK(final int roomId, final String userId, TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start cancel request pk.");
                TXRoomService.getInstance().cancelRequestRoomPK(String.valueOf(roomId), userId, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {

                    }
                });
            }
        });
    }

    /**
     * 响应 PK 请求
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 使用房间服务响应 PK 请求：TXRoomService.responseRoomPK
     * |- false: 忽略
     * 主播接受到PK请求，等待10s超时，如果不调用 responseRoomPK，会自动结束流程
     * 回复同意PK后 会等待3s 超时，如果超时会自动结束流程
     *
     * @param userId
     * @param agree
     * @param reason
     */
    @Override
    public void responseRoomPK(final String userId, final boolean agree, final String reason) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (TXRoomService.getInstance().isLogin()) {
                    TRTCLogger.i(TAG, "response pk.");
                    TXRoomService.getInstance().responseRoomPK(userId, agree, reason);
                } else {
                    TRTCLogger.e(TAG, "response pk fail. not login yet.");
                }
            }
        });
    }

    /**
     * 退出 PK
     * 1. 判断是否登陆到房间服务：check(isLogin)
     * |- true: 使用房间服务发送退出 PK 信令：TXRoomService.quitRoom
     * |- false: 回调失败
     *
     * @param callback
     */
    @Override
    public void quitRoomPK(final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // 先发送信令消息
                if (TXRoomService.getInstance().isLogin()) {
                    TRTCLogger.i(TAG, "quit pk.");
                    TXRoomService.getInstance().quitRoomPK(new TXCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "quit pk finish, code:" + code + " msg:" + msg);
                            runOnDelegateThread(new Runnable() {
                                @Override
                                public void run() {
                                    if (callback != null) {
                                        callback.onCallback(code, msg);
                                    }
                                }
                            });
                        }
                    });
                } else {
                    TRTCLogger.i(TAG, "quit pk fail.not login yet.");
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            if (callback != null) {
                                callback.onCallback(CODE_ERROR, "退出PK失败，IM未登录");
                            }
                        }
                    });
                }
                //再退房
                TXTRTCLiveRoom.getInstance().stopPK();
            }
        });
    }

    /**
     * 切换摄像头
     * <p>
     * 直接调用 TRTC 切换：TXTRTCLiveRoom.switchCamera
     */
    @Override
    public void switchCamera() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "switch camera.");
                TXTRTCLiveRoom.getInstance().switchCamera();
            }
        });
    }

    /**
     * 设置镜像
     * <p>
     * 直接调用 TRTC 设置：TXTRTCLiveRoom.setMirror
     */
    @Override
    public void setMirror(final boolean isMirror) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "set mirror.");
                TXTRTCLiveRoom.getInstance().setMirror(isMirror);
            }
        });
    }

    /**
     * 静音本地
     * <p>
     * 直接调用 TRTC 设置：TXTRTCLiveRoom.muteLocalAudio
     *
     * @param mute
     */
    @Override
    public void muteLocalAudio(final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "mute local audio, mute:" + mute);
                TXTRTCLiveRoom.getInstance().muteLocalAudio(mute);
            }
        });
    }

    /**
     * 静音音频
     * 1. 当前是否使用 TRTC 模式播放：check(isTRTCMode)
     * |- true: 直接静音：TXTRTCLiveRoom.muteRemoteAudio
     * |- false:
     * |- 根据 user id 去房间服务查询 stream id: TXRoomService.exchangeStreamId
     * |- 根据 stream id 以及 config.domain 拼接播放 url
     * |- 使用直播播放器静音播放：TXLivePlayerRoom.muteRemoteAudio
     *
     * @param userId
     * @param mute
     */
    @Override
    public void muteRemoteAudio(final String userId, final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (isTRTCMode()) {
                    TRTCLogger.i(TAG, "mute trtc audio, user id:" + userId);
                    TXTRTCLiveRoom.getInstance().muteRemoteAudio(userId, mute);
                } else {
                    TRTCLogger.i(TAG, "mute cnd audio, user id:" + userId);
                    String playURL = getPlayURL(userId);
                    if (!TextUtils.isEmpty(playURL)) {
                        // 走 CDN
                        TRTCLogger.i(TAG, "mute cdn audio success, url:" + playURL);
                        TXLivePlayerRoom.getInstance().muteRemoteAudio(playURL, mute);
                    } else {
                        TRTCLogger.e(TAG, "mute cdn remote audio fail, exchange stream id fail. user id:" + userId);
                    }
                }
            }
        });
    }

    /**
     * 静音所有音频
     * 1. 当前是否使用 TRTC 模式播放：check(isTRTCMode)
     * |- true：直接静音：TXTRTCLiveRoom.muteAllRemoteAudio
     * |- false：直接静音：TXLivePlayerRoom.muteAllRemoteAudio
     *
     * @param mute
     */
    @Override
    public void muteAllRemoteAudio(final boolean mute) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (isTRTCMode()) {
                    TRTCLogger.i(TAG, "mute all trtc remote audio success, mute:" + mute);
                    TXTRTCLiveRoom.getInstance().muteAllRemoteAudio(mute);
                } else {
                    TRTCLogger.i(TAG, "mute all cdn audio success, mute:" + mute);
                    TXLivePlayerRoom.getInstance().muteAllRemoteAudio(mute);
                }
            }
        });
    }

    /**
     * 发送文本信息
     * 1. 使用房间服务发送文本信息：TXRoomService.sendRoomTextMsg
     *
     * @param msg
     * @param callback
     */
    @Override
    public void sendRoomTextMsg(final String msg, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().sendRoomTextMsg(msg, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    /**
     * 发送自定义信息
     * 1. 使用房间服务发送自定义信息：TXRoomService.sendRoomCustomMsg
     *
     * @param cmd
     * @param message
     * @param callback
     */
    @Override
    public void sendRoomCustomMsg(final String cmd, final String message, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().sendRoomCustomMsg(cmd, message, new TXCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void showVideoDebugLog(final boolean isShow) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXLivePlayerRoom.getInstance().showVideoDebugLog(isShow);
                TXTRTCLiveRoom.getInstance().showVideoDebugLog(isShow);
            }
        });
    }

    @Override
    public TXAudioEffectManager getAudioEffectManager() {
        return TXTRTCLiveRoom.getInstance().getAudioEffectManager();
    }

    @Override
    public void setAudioQuality(final int quality) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXTRTCLiveRoom.getInstance().setAudioQuality(quality);
            }
        });
    }

    @Override
    public TXBeautyManager getBeautyManager() {
        return TXTRTCLiveRoom.getInstance().getTXBeautyManager();
    }

    private void enterTRTCRoomInner(final String roomId, final String userId, final String userSign, final int role, final TRTCLiveRoomCallback.ActionCallback callback) {
        // 进入 TRTC 房间
        TRTCLogger.i(TAG, "enter trtc room.");
        mTargetRole = Role.TRTC_ANCHOR;
        TXTRTCLiveRoom.getInstance().enterRoom(mSDKAppId, roomId, userId, userSign, role, new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                TRTCLogger.i(TAG, "enter trtc room finish, code:" + code + " msg:" + msg);
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    private void startPublishInner(String streamId, final TRTCLiveRoomCallback.ActionCallback callback) {
        TRTCLogger.i(TAG, "start publish stream id:" + streamId);
        // 已经在房间，直接开始推流
        TXTRTCLiveRoom.getInstance().startPublish(streamId, new TXCallback() {
            @Override
            public void onCallback(final int code, final String msg) {
                TRTCLogger.i(TAG, "start publish stream finish, code:" + code + " msg:" + msg);
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onCallback(code, msg);
                        }
                    }
                });
            }
        });
    }

    private boolean isTRTCMode() {
        return mCurrentRole == Role.TRTC_ANCHOR || mCurrentRole == Role.TRTC_AUDIENCE || mTargetRole == Role.TRTC_ANCHOR || mTargetRole == Role.TRTC_AUDIENCE;
    }

    private void updateMixConfig() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TRTCLogger.i(TAG, "start mix stream:" + mAnchorList.size() + " status:" + mRoomLiveStatus);
                if (TXRoomService.getInstance().isOwner()) {
                    if (mAnchorList.size() > 0) {
                        // 等待被混的主播列表（不包括自己本身）
                        List<TXTRTCMixUser> needToMixUserList = new ArrayList<>();
                        boolean             isPKing           = TXRoomService.getInstance().isPKing();
                        if (isPKing) {
                            // 如果是 PK 模式，那么肯定只应该有一个人，如果不止一个人，那么当前的状态应该是有问题的。
                            if (mAnchorList.size() == PK_ANCHOR_NUMS) {
                                String userId = TXRoomService.getInstance().getPKUserId();
                                String roomId = TXRoomService.getInstance().getPKRoomId();
                                if (!TextUtils.isEmpty(userId) && !TextUtils.isEmpty(userId)) {
                                    TXTRTCMixUser user = new TXTRTCMixUser();
                                    user.userId = userId;
                                    user.roomId = roomId;
                                    needToMixUserList.add(user);
                                } else {
                                    TRTCLogger.e(TAG, "set pk mix config fail, pk user id:" + userId + " pk room id:" + roomId);
                                }
                            } else {
                                TRTCLogger.e(TAG, "set pk mix config fail, available uer size:s" + mAnchorList.size());
                            }
                        } else {
                            // 不是 PK 模式，所有的人都加入进去混
                            for (String userId : mAnchorList) {
                                //把自己去除掉
                                if (userId.equals(mUserId)) {
                                    continue;
                                }
                                TXTRTCMixUser user = new TXTRTCMixUser();
                                user.roomId = null;
                                user.userId = userId;
                                needToMixUserList.add(user);
                            }
                        }
                        if (needToMixUserList.size() > 0) {
                            // 混流人数大于 0，需要混流
                            TXTRTCLiveRoom.getInstance().setMixConfig(needToMixUserList, isPKing);
                        } else {
                            // 没有需要混流的，取消混流
                            TXTRTCLiveRoom.getInstance().setMixConfig(null, false);
                        }
                    } else {
                        // 没有需要混流的取消混流
                        TXTRTCLiveRoom.getInstance().setMixConfig(null, false);
                    }
                }
            }
        });
    }

    private String getPlayURL(String userId) {
        String streamId = TXRoomService.getInstance().exchangeStreamId(userId);
        return generateCdnPlayURL(mCDNDomain, streamId);
    }

    private String generateCdnPlayURL(String cdnDomain, String streamId) {
        if (TextUtils.isEmpty(cdnDomain)) {
            return "";
        } else if (cdnDomain.startsWith("http") && cdnDomain.endsWith("flv")) {
            return cdnDomain;
        } else if (TextUtils.isEmpty(streamId)) {
            return "";
        }
        String prefix = "http://";
        if (cdnDomain.startsWith("https://")) {
            prefix = "https://";
            cdnDomain = cdnDomain.replace("https://", "");
        } else {
            cdnDomain = cdnDomain.replace("http://", "");
        }
        if (cdnDomain.startsWith("/") && cdnDomain.length() > 1) {
            cdnDomain = cdnDomain.substring(1);
        }
        String[] domainElements = cdnDomain.split("/");
        StringBuilder path = new StringBuilder("/");
        if (domainElements.length > 2) {
            for (int i = 1; i < domainElements.length; i++) {
                path.append(domainElements[i]).append("/");
            }
        } else {
            path.append("live/");
        }
        cdnDomain = domainElements[0];
        return String.format("%s%s%s%s.flv", prefix, cdnDomain, path.toString(), streamId);
    }

    @Override
    public void onRoomInfoChange(final TXRoomInfo roomInfo) {
        TRTCLogger.i(TAG, "onRoomInfoChange:" + roomInfo);
        //这里记录一下目前的房间状态
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mLiveRoomInfo.ownerId = roomInfo.ownerId;
                mLiveRoomInfo.coverUrl = roomInfo.coverUrl;
                mLiveRoomInfo.roomId = Integer.valueOf(roomInfo.roomId);
                mLiveRoomInfo.roomName = roomInfo.roomName;
                mLiveRoomInfo.ownerName = roomInfo.ownerName;
                mLiveRoomInfo.streamUrl = roomInfo.streamUrl;
                mLiveRoomInfo.roomStatus = roomInfo.roomStatus;
                mLiveRoomInfo.memberCount = roomInfo.memberCount;

                mRoomLiveStatus = roomInfo.roomStatus;
                updateMixConfig();
                runOnDelegateThread(new Runnable() {
                    @Override
                    public void run() {
                        TRTCLiveRoomDelegate delegate = mDelegate;
                        if (delegate != null) {
                            delegate.onRoomInfoChange(mLiveRoomInfo);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void onRoomDestroy(final String roomId) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onRoomDestroy(roomId);
                }
            }
        });
    }

    @Override
    public void onTRTCAnchorEnter(final String userId) {
        TRTCLogger.i(TAG, "onTRTCAnchorEnter:" + userId);
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().handleAnchorEnter(userId);
                if (mAnchorList.add(userId)) {
                    handleAnchorEnter(userId);
                } else {
                    //主播已经存在了
                    TRTCLogger.e(TAG, "trtc anchor enter, but already exit:" + userId);
                }
            }
        });
    }

    private void handleAnchorEnter(final String userId) {
        updateMixConfig();
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onAnchorEnter(userId);
                }
            }
        });
    }

    @Override
    public void onTRTCAnchorExit(final String userId) {
        TRTCLogger.i(TAG, "onTRTCAnchorExit:" + userId);
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                //有用户退出了，这个用户是不是PK/连麦用户呢? 还需要更新一下状态呢~
                TXRoomService.getInstance().handleAnchorExit(userId);
                if (mAnchorList.contains(userId)) {
                    mAnchorList.remove(userId);
                    updateMixConfig();
                    if (TXRoomService.getInstance().isOwner()
                            && mAnchorList.size() == 1) {
                        //状态为连麦状态，需要告诉TXRoom
                        TXRoomService.getInstance().resetRoomStatus();
                    }
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            TRTCLiveRoomDelegate delegate = mDelegate;
                            if (delegate != null) {
                                delegate.onAnchorExit(userId);
                            }
                        }
                    });
                } else {
                    TRTCLogger.e(TAG, "trtc anchor exit, but never throw yet, maybe something error.");
                }
            }
        });
    }

    @Override
    public void onTRTCStreamAvailable(final String userId) {
    }

    @Override
    public void onTRTCStreamUnavailable(final String userId) {
    }

    @Override
    public void onRoomAnchorEnter(final String userId) {
    }

    @Override
    public void onRoomAnchorExit(final String userId) {
    }

    @Override
    public void onRoomStreamAvailable(final String userId) {
        TRTCLogger.i(TAG, "onRoomStreamAvailable:" + userId);
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (isTRTCMode()) {
                    return;
                }
                if (!mAnchorList.contains(userId)) {
                    mAnchorList.add(userId);
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            TRTCLiveRoomDelegate delegate = mDelegate;
                            if (delegate != null) {
                                delegate.onAnchorEnter(userId);
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    public void onRoomStreamUnavailable(final String userId) {
        TRTCLogger.i(TAG, "onRoomStreamUnavailable:" + userId);
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (isTRTCMode()) {
                    return;
                }
                if (mAnchorList.contains(userId)) {
                    mAnchorList.remove(userId);
                    runOnDelegateThread(new Runnable() {
                        @Override
                        public void run() {
                            TRTCLiveRoomDelegate delegate = mDelegate;
                            if (delegate != null) {
                                delegate.onAnchorExit(userId);
                            }
                        }
                    });
                } else {
                    TRTCLogger.e(TAG, "room anchor exit, but never throw yet, maybe something error.");
                }
            }
        });
    }

    @Override
    public void onRoomAudienceEnter(final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                if (mAudienceList.contains(userInfo.userId)) {
                    return;
                }
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    mAudienceList.add(userInfo.userId);
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.avatarUrl = userInfo.avatarURL;
                    info.userName = userInfo.userName;
                    delegate.onAudienceEnter(info);
                }
            }
        });
    }

    @Override
    public void onRoomAudienceExit(final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    mAudienceList.remove(userInfo.userId);
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.avatarUrl = userInfo.avatarURL;
                    info.userName = userInfo.userName;
                    delegate.onAudienceExit(info);
                }
            }
        });
    }

    @Override
    public void onRoomRequestJoinAnchor(final TXUserInfo userInfo, final String reason) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.userName = userInfo.userName;
                    info.avatarUrl = userInfo.avatarURL;
                    delegate.onRequestJoinAnchor(info, reason);
                }
            }
        });
    }

    @Override
    public void onRoomKickoutJoinAnchor() {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                stopPublish(null);
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onKickoutJoinAnchor();
                }
            }
        });
    }

    @Override
    public void onRoomRequestRoomPK(final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.userName = userInfo.userName;
                    info.avatarUrl = userInfo.avatarURL;
                    delegate.onRequestRoomPK(info);
                }
            }
        });
    }

    @Override
    public void onRoomResponseRoomPK(final String roomId, final String streamId, final TXUserInfo userInfo) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mRequestPKHolder.setRealCallback(null);
                TRTCLogger.i(TAG, "recv pk repsonse, room id:" + roomId + " stream id:" + streamId + " info:" + userInfo.toString());
                // do pk
                // 如果收到 PK 的回包，那么则发起 PK
                if (mCurrentRole == Role.TRTC_ANCHOR || mTargetRole == Role.TRTC_ANCHOR) {
                    TXTRTCLiveRoom.getInstance().startPK(roomId, userInfo.userId, new TXCallback() {
                        @Override
                        public void onCallback(final int code, final String msg) {
                            TRTCLogger.i(TAG, "start pk, code:" + code + " msg:" + msg);
                            if (code != 0) {
                                runOnDelegateThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        TRTCLiveRoomDelegate delegate = mDelegate;
                                        if (delegate != null) {
                                            delegate.onError(code, msg);
                                        }
                                    }
                                });
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    public void onAnchorCancelRequestRoomPK(final String userId) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onAnchorCancelRequestRoomPK(userId);
                }
            }
        });
    }

    @Override
    public void onAudienceRequestJoinAnchorTimeout(final String userId) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onAudienceRequestJoinAnchorTimeout(userId);
                }
            }
        });
    }

    @Override
    public void onAnchorRequestRoomPKTimeout(final String userId) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onAnchorRequestRoomPKTimeout(userId);
                }
            }
        });
    }

    @Override
    public void onAudienceCancelRequestJoinAnchor(final String userId) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onAudienceCancelRequestJoinAnchor(userId);
                }
            }
        });
    }

    @Override
    public void onRoomQuitRoomPk() {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    delegate.onQuitRoomPK();
                }
            }
        });
    }

    @Override
    public void onRoomRecvRoomTextMsg(final String roomId, final String message, final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.userName = userInfo.userName;
                    info.avatarUrl = userInfo.avatarURL;
                    delegate.onRecvRoomTextMsg(message, info);
                }
            }
        });
    }

    @Override
    public void onRoomRecvRoomCustomMsg(final String roomId, final String cmd, final String message, final TXUserInfo userInfo) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TRTCLiveRoomDelegate delegate = mDelegate;
                if (delegate != null) {
                    TRTCLiveRoomDef.TRTCLiveUserInfo info = new TRTCLiveRoomDef.TRTCLiveUserInfo();
                    info.userId = userInfo.userId;
                    info.userName = userInfo.userName;
                    info.avatarUrl = userInfo.avatarURL;
                    delegate.onRecvRoomCustomMsg(cmd, message, info);
                }
            }
        });
    }

    @Override
    public void followAnchor(final String userId, final TRTCLiveRoomCallback.ActionCallback callback) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().followAnchor(userId, callback);
            }
        });
    }

    @Override
    public void checkFollowAnchorState(final String userId, final TRTCLiveRoomCallback.RoomFollowStateCallback callback) {
        runOnDelegateThread(new Runnable() {
            @Override
            public void run() {
                TXRoomService.getInstance().checkFollowState(userId, callback);
            }
        });
    }
}
