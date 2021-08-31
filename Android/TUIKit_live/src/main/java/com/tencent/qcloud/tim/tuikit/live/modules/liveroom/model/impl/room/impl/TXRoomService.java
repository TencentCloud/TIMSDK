package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl;

import android.content.Context;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMFriendAddApplication;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSignalingListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TRTCLogger;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXRoomInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXRoomInfoListCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXUserInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXUserListCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.ITXRoomService;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.ITXRoomServiceDelegate;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.tencent.imsdk.v2.V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION;

public class TXRoomService implements ITXRoomService {
    private static final String TAG = "TXRoomService";

    private static final int CODE_ERROR                = -1;
    private static final int CODE_TIMEOUT              = -2;
    private static final int SEND_MSG_TIMEOUT          = 15000;     // 发送消息的超时时间
    private static final int WAIT_ANCHOR_ENTER_TIMEOUT = 3000;      // 等待主播进房的超时时间

    private static TXRoomService                  sInstance;
    private        Context                        mContext;
    private        ITXRoomServiceDelegate         mDelegate;
    private        boolean                        mIsInitIMSDK;
    private        boolean                        mIsLogin;
    private        boolean                        mIsEnterRoom;
    private        List<IMAnchorInfo>             mAnchorList;
    private        int                            mCurrentRoomStatus;        // 房间外部状态，见 TRTCLiveRoomDef
    private        String                         mRoomId;
    private        String                         mPKingRoomId;
    private        IMAnchorInfo                   mMySelfIMInfo;
    private        IMAnchorInfo                   mOwnerIMInfo;
    private        IMAnchorInfo                   mPKingIMAnchorInfo;
    private        TXRoomInfo                     mTXRoomInfo;
    private        Map<String, String>            mPKUserIdMap;    // 接收方记录一个map  一个userId对应一个requestID
    private        Map<String, String>            mJoinAnchorUserIdMap;    // 接收方记录一个map  一个userId对应一个requestID
    private        LiveRoomSimpleMsgListener      mSimpleListener;
    private        LiveRoomGroupListener          mGroupListener;
    private        LiveRoomSignalListener         mSignalListener;
    private        Pair<String, TXCallback>       mLinkMicReqPair;    // 主动发起方记录
    private        Pair<String, TXCallback>       mPKReqPair;    // 主动发起方记录
    private        Handler                        mTimeoutHandler;
    private        boolean                        mIsAttachTuikit = false;
    private        GroupListenerBroadcastReceiver mGroupListenerBroadcast;
    private        Map<String, TXUserInfo>        mAudienceInfoMap;

    public static synchronized TXRoomService getInstance() {
        if (sInstance == null) {
            sInstance = new TXRoomService();
        }
        return sInstance;
    }

    private TXRoomService() {
        mTXRoomInfo = new TXRoomInfo();
        mAnchorList = new ArrayList<>();
        mMySelfIMInfo = new IMAnchorInfo();
        mOwnerIMInfo = new IMAnchorInfo();
        mRoomId = "";
        mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;
        mTimeoutHandler = new Handler(Looper.getMainLooper());
        mSimpleListener = new LiveRoomSimpleMsgListener();
        mGroupListener = new LiveRoomGroupListener();
        mSignalListener = new LiveRoomSignalListener();
        mAudienceInfoMap = new HashMap<>();
        mJoinAnchorUserIdMap = new HashMap<>();
        mPKUserIdMap = new HashMap<>();
    }

    @Override
    public void init(Context context) {
        mContext = context;

    }

    public void destroy() {
        mTimeoutHandler.removeCallbacksAndMessages(null);
    }

    @Override
    public void setDelegate(ITXRoomServiceDelegate delegate) {
        mDelegate = delegate;
    }

    @Override
    public void login(int sdkAppId, final String userId, String userSign, boolean isAttachTuikit, final TXCallback callback) {
        // 未初始化 IM 先初始化 IM
        mIsAttachTuikit = isAttachTuikit;
        if (isAttachTuikit) {
            //依附于tuikit使用，不在单独初始化
            mIsLogin = true;
            mMySelfIMInfo.userId = V2TIMManager.getInstance().getLoginUser();
            V2TIMManager.getInstance().getUsersInfo(Arrays.asList(V2TIMManager.getInstance().getLoginUser()), new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
                @Override
                public void onError(int code, String desc) {

                }

                @Override
                public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                    mMySelfIMInfo.name = v2TIMUserFullInfos.get(0).getNickName();
                }
            });
            if (callback != null) {
                callback.onCallback(0, "login im success.");
            }
            return;
        }
        if (!mIsInitIMSDK) {
            V2TIMSDKConfig config = new V2TIMSDKConfig();
            config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_DEBUG);
            mIsInitIMSDK = V2TIMManager.getInstance().initSDK(mContext, sdkAppId, config, new V2TIMSDKListener() {
                @Override
                public void onConnecting() {
                }

                @Override
                public void onConnectSuccess() {
                }

                @Override
                public void onConnectFailed(int code, String error) {
                    TRTCLogger.e(TAG, "init im sdk error.");
                }
            });

            if (!mIsInitIMSDK) {
                if (callback != null) {
                    callback.onCallback(CODE_ERROR, "init im sdk error.");
                }
                return;
            }
        }

        // 登陆到 IM
        String loginedUserId = V2TIMManager.getInstance().getLoginUser();
        if (loginedUserId != null && loginedUserId.equals(userId)) {
            // 已经登录过了
            mIsLogin = true;
            mMySelfIMInfo.userId = userId;
            TRTCLogger.i(TAG, "login im success.");
            if (callback != null) {
                callback.onCallback(0, "login im success.");
            }
            return;
        }
        if (isLogin()) {
            TRTCLogger.e(TAG, "start login fail, you have been login, can't login twice.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start login fail, you have been login, can't login twice.");
            }
            return;
        }
        V2TIMManager.getInstance().login(userId, userSign, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "login im fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                mIsLogin = true;
                mMySelfIMInfo.userId = userId;
                TRTCLogger.i(TAG, "login im success.");
                if (callback != null) {
                    callback.onCallback(0, "login im success.");
                }
            }
        });
    }

    @Override
    public void logout(final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "start logout fail, not login yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start logout fail, not login yet.");
            }
            return;
        }
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "start logout fail, you are in room:" + mRoomId + ", please exit room before logout.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "start logout fail, you are in room:" + mRoomId + ", please exit room before logout.");
            }
            return;
        }

        if (mIsAttachTuikit) {
            mIsLogin = false;
            mMySelfIMInfo.clean();
            if (callback != null) {
                callback.onCallback(0, "login im success.");
            }
            return;
        }

        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "logout fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                mIsLogin = false;
                mMySelfIMInfo.clean();
                TRTCLogger.i(TAG, "logout im success.");
                if (callback != null) {
                    callback.onCallback(0, "login im success.");
                }
            }
        });
    }

    @Override
    public void setSelfProfile(final String userName, final String avatarURL, final TXCallback callback) {
        if (!isLogin()) {
            TRTCLogger.e(TAG, "set profile fail, not login yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "set profile fail, not login yet.");
            }
            return;
        }

        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        v2TIMUserFullInfo.setNickname(userName);
        v2TIMUserFullInfo.setFaceUrl(avatarURL);
        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "set profile code:" + code + " msg:" + desc);
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "set profile success.");
                mMySelfIMInfo.name = userName;
                if (isOwner()) {
                    mOwnerIMInfo.name = userName;
                }
                if (callback != null) {
                    callback.onCallback(0, "set profile success.");
                }
            }
        });
    }

    @Override
    public void createRoom(final String roomId, final String roomName, final String coverUrl, final TXCallback callback) {
        TRTCLogger.e(TAG, "createRoom mIsEnterRoom:" + mIsEnterRoom);
        // 如果已经在一个房间了，则不允许再次进入
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "you have been in room:" + mRoomId + " can't create another room:" + roomId);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "you have been in room:" + mRoomId + " can't create another room:" + roomId);
            }
            return;
        }
        if (!isLogin()) {
            TRTCLogger.e(TAG, "not log yet, create room fail.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "not log yet, create room fail.");
            }
            return;
        }

        final V2TIMManager imManager = V2TIMManager.getInstance();
        imManager.createGroup(V2TIMManager.GROUP_TYPE_AVCHATROOM, roomId, roomName, new V2TIMValueCallback<String>() {
            @Override
            public void onError(int code, String s) {
                String msg = s;
                if (code == 10036) {
                    msg = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673";
                }
                if (code == 10037) {
                    msg = "单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673";
                }
                if (code == 10038) {
                    msg = "群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673";
                }
                if (code == 10025) {
                    // 10025 表明群主是自己，那么认为创建房间成功
                    onSuccess("success");
                } else {
                    TRTCLogger.e(TAG, "create room fail, code:" + code + " msg:" + msg);
                    if (callback != null) {
                        callback.onCallback(code, msg);
                    }
                }
            }

            @Override
            public void onSuccess(String s) {
                cleanStatus();
                initGroupListener();
                TRTCLogger.d(TAG, "createGroup setGroupListener roomId: " + roomId + " mGroupListener: " + mGroupListener.hashCode());

                mIsEnterRoom = true;
                mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_SINGLE;

                mRoomId = roomId;

                mOwnerIMInfo.userId = mMySelfIMInfo.userId;
                mOwnerIMInfo.streamId = mMySelfIMInfo.streamId;
                mOwnerIMInfo.name = mMySelfIMInfo.name;
                // 组装 RoomInfo 抛给上层
                mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                mTXRoomInfo.roomId = roomId;
                mTXRoomInfo.roomName = roomName;
                mTXRoomInfo.ownerId = mMySelfIMInfo.userId;
                mTXRoomInfo.coverUrl = coverUrl;
                mTXRoomInfo.ownerName = mMySelfIMInfo.name;
                mTXRoomInfo.streamUrl = mMySelfIMInfo.streamId;
                mTXRoomInfo.memberCount = 1;

                // 主播自己更新到主播列表中
                mAnchorList.add(mMySelfIMInfo);
                updateRoomInfo(coverUrl);
                // 更新群资料以及发送广播
                updateHostAnchorInfo();
                TRTCLogger.i(TAG, "create room success.");
                if (callback != null) {
                    callback.onCallback(0, "create room success.");
                }
                if (mDelegate != null) {
                    mDelegate.onRoomInfoChange(mTXRoomInfo);
                }
            }
        });
    }

    private void updateRoomInfo(final String coverUrl) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setFaceUrl(coverUrl);
        v2TIMGroupInfo.setGroupID(mRoomId);
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "updateRoomInfo" + code + " msg:" + desc);
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "updateRoomInfo success:"  + coverUrl);
            }
        });
    }

    private void initGroupListener() {
        V2TIMManager.getSignalingManager().addSignalingListener(mSignalListener);
        V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
        if (mIsAttachTuikit) {
            if (mGroupListenerBroadcast == null) {
                mGroupListenerBroadcast = new GroupListenerBroadcastReceiver(mGroupListener);
            }
            LocalBroadcastManager.getInstance(mContext).registerReceiver(mGroupListenerBroadcast,
                    new IntentFilter(GroupListenerConstants.ACTION));
        } else {
            V2TIMManager.getInstance().setGroupListener(mGroupListener);
        }
    }

    private void unInitGroupListener() {
        V2TIMManager.getSignalingManager().removeSignalingListener(mSignalListener);
        V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
        if (mIsAttachTuikit) {
            LocalBroadcastManager.getInstance(mContext).unregisterReceiver(mGroupListenerBroadcast);
        } else {
            V2TIMManager.getInstance().setGroupListener(null);
        }
    }

    @Override
    public void destroyRoom(final TXCallback callback) {
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setIntroduction("");
        v2TIMGroupInfo.setGroupID(mRoomId);
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "destroyRoom room owner update anchor list into group introduction fail, code: " + code + " msg:" + desc);
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "room owner update anchor list into group introduction success");
                V2TIMManager.getInstance().dismissGroup(mRoomId, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        TRTCLogger.e(TAG, "destroy room fail, code:" + i + " msg:" + s);
                        if (callback != null) {
                            callback.onCallback(i, s);
                        }
                    }

                    @Override
                    public void onSuccess() {
                        TRTCLogger.d(TAG, "destroyRoom remove GroupListener roomId: " + mRoomId + " mGroupListener: " + mGroupListener.hashCode());
                        unInitGroupListener();

                        cleanStatus();

                        TRTCLogger.i(TAG, "destroy room success.");
                        if (callback != null) {
                            callback.onCallback(0, "destroy room success.");
                        }
                    }
                });
            }
        });
    }

    @Override
    public void enterRoom(final String roomId, final TXCallback callback) {
        // 如果已经在一个房间了，则不允许再次进入
        if (isEnterRoom()) {
            TRTCLogger.e(TAG, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "you have been in room:" + mRoomId + ", can't enter another room:" + roomId);
            }
            return;
        }

        List<String> groupList = new ArrayList<>(Arrays.asList(roomId));
        V2TIMManager.getGroupManager().getGroupsInfo(groupList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get group info error, enter room fail. code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(-1, "get group info error, enter room fail. code:" + i + " msg:" + s);
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                boolean isSuccess = false;
                if (v2TIMGroupInfoResults != null && v2TIMGroupInfoResults.size() == 1) {
                    final V2TIMGroupInfoResult v2TIMGroupInfoResult = v2TIMGroupInfoResults.get(0);
                    if (v2TIMGroupInfoResult != null) {
                        final String introduction = v2TIMGroupInfoResult.getGroupInfo().getIntroduction();
                        TRTCLogger.i(TAG, "get group info success, info:" + introduction);
                        if (introduction != null) {
                            isSuccess = true;
                            V2TIMManager.getInstance().joinGroup(roomId, "", new V2TIMCallback() {
                                @Override
                                public void onError(int i, String s) {
                                    // 已经是群成员了，可以继续操作
                                    if (i == 10013) {
                                        onSuccess();
                                    } else {
                                        TRTCLogger.e(TAG, "enter room fail, code:" + i + " msg:" + s);
                                        if (callback != null) {
                                            callback.onCallback(i, s);
                                        }
                                    }
                                }

                                @Override
                                public void onSuccess() {
                                    cleanStatus();
                                    initGroupListener();

                                    TRTCLogger.i(TAG, "enter room success. roomId: " + roomId);
                                    mRoomId = roomId;
                                    mIsEnterRoom = true;

                                    mTXRoomInfo.roomId = roomId;
                                    mTXRoomInfo.roomName = v2TIMGroupInfoResult.getGroupInfo().getGroupName();
                                    mTXRoomInfo.coverUrl = v2TIMGroupInfoResult.getGroupInfo().getFaceUrl();
                                    mTXRoomInfo.memberCount = v2TIMGroupInfoResult.getGroupInfo().getMemberCount();

                                    // 获取群资料，解析群简介，获取成员列表和当前房间类型
                                    Pair<Integer, List<IMAnchorInfo>> pair = IMProtocol.parseGroupInfo(introduction);
                                    if (pair != null) {
                                        TRTCLogger.i(TAG, "parse room info success, type:" + pair.first + " list:" + pair.second.toString());
                                        mCurrentRoomStatus = pair.first;
                                        mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                                        if (pair.second.size() > 0) {
                                            // 添加到主播列表
                                            mAnchorList.clear();
                                            mAnchorList.addAll(pair.second);

                                            // 主播列表的第一个认为是群组的owner
                                            IMAnchorInfo ownerInfo = pair.second.get(0);
                                            mOwnerIMInfo.userId = ownerInfo.userId;
                                            mOwnerIMInfo.streamId = ownerInfo.streamId;
                                            // mOwnerIMInfo.avatar = ownerInfo.avatar
                                            mOwnerIMInfo.name = ownerInfo.name;
                                            // 组装房间的info信息
                                            mTXRoomInfo.ownerName = ownerInfo.name;
                                            mTXRoomInfo.ownerId = ownerInfo.userId;
                                            mTXRoomInfo.streamUrl = ownerInfo.streamId;

                                            ITXRoomServiceDelegate delegate = mDelegate;
                                            if (delegate != null) {
                                                // 回调当前房间信息状态变更
                                                delegate.onRoomInfoChange(mTXRoomInfo);
                                                // 回调当前的主播列表、流列表
                                                for (IMAnchorInfo info : pair.second) {
                                                    delegate.onRoomAnchorEnter(info.userId);
                                                    // 如果 streamId 不为空，说明当前可以播放
                                                    if (!TextUtils.isEmpty(info.streamId)) {
                                                        delegate.onRoomStreamAvailable(info.userId);
                                                    }
                                                }
                                            }
                                        }
                                        if (callback != null) {
                                            callback.onCallback(0, "enter room success");
                                        }
                                    } else {
                                        TRTCLogger.e(TAG, "parse room info error, maybe something error.");
                                    }
                                }
                            });
                        } else {
                            isSuccess = false;
                        }

                    } else {
                        isSuccess = false;
                    }
                }
                if (!isSuccess) {
                    onError(-1, "get info fail.");
                }
            }
        });
    }

    @Override
    public void exitRoom(final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "not enter room yet, can't exit room.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "not enter room yet, can't exit room.");
            }
            return;
        }
        V2TIMManager.getInstance().quitGroup(mRoomId, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "exit room fail, code:" + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "exit room success.");
                unInitGroupListener();
                cleanStatus();

                if (callback != null) {
                    callback.onCallback(0, "exit room success.");
                }
            }
        });
    }

    @Override
    public void getRoomInfos(final List<String> roomIds, final TXRoomInfoListCallback callback) {
        V2TIMManager.getGroupManager().getGroupsInfo(roomIds, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s, null);
                }
            }

            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                List<TXRoomInfo>            txRoomInfos        = new ArrayList<>();
                Map<String, V2TIMGroupInfo> groupInfoResultMap = new HashMap<>();
                // 注意 IM 返回的顺序可能不对，所以需要重新排序
                for (V2TIMGroupInfoResult result : v2TIMGroupInfoResults) {
                    V2TIMGroupInfo groupInfo = result.getGroupInfo();
                    // 防止为空
                    if (groupInfo == null) {
                        continue;
                    }
                    groupInfoResultMap.put(groupInfo.getGroupID(), groupInfo);
                }
                for (String roomId : roomIds) {
                    V2TIMGroupInfo timGroupDetailInfo = groupInfoResultMap.get(roomId);
                    if (timGroupDetailInfo == null) {
                        continue;
                    }
                    TXRoomInfo txRoomInfo = new TXRoomInfo();
                    txRoomInfo.roomId = timGroupDetailInfo.getGroupID();
                    txRoomInfo.ownerId = timGroupDetailInfo.getOwner();
                    txRoomInfo.memberCount = timGroupDetailInfo.getMemberCount();
                    txRoomInfo.coverUrl = timGroupDetailInfo.getFaceUrl();
                    txRoomInfo.roomName = timGroupDetailInfo.getGroupName();

                    Pair<Integer, List<IMAnchorInfo>> pair = IMProtocol.parseGroupInfo(timGroupDetailInfo.getIntroduction());
                    if (pair != null) {
                        List<IMAnchorInfo> list = pair.second;
                        for (IMAnchorInfo anchor : list) {
                            if (anchor.userId.equals(txRoomInfo.ownerId)) {
                                txRoomInfo.streamUrl = anchor.streamId;
                                txRoomInfo.ownerName = anchor.name;
                                break;
                            }
                        }
                    }
                    txRoomInfos.add(txRoomInfo);
                }
                if (callback != null) {
                    callback.onCallback(0, "get room info success", txRoomInfos);
                }

            }
        });
    }

    @Override
    public void updateStreamId(String streamId, TXCallback callback) {
        mMySelfIMInfo.streamId = streamId;
        TRTCLogger.i(TAG, "updateStreamId " + mMySelfIMInfo.streamId);
        for (IMAnchorInfo info : mAnchorList) {
            if (info.userId.equals(mMySelfIMInfo.userId)) {
                info.streamId = streamId;
            }
        }
        if (isOwner()) {
            mOwnerIMInfo.streamId = streamId;
            mTXRoomInfo.streamUrl = streamId;
            updateHostAnchorInfo();
        }
        if (callback != null) {
            callback.onCallback(0, "update stream id success.");
        }
    }

    public void handleAnchorEnter(String userId) {
        // 有主播真的进来了
        TRTCLogger.i(TAG, "handleAnchorEnter " + " " + userId + " pk " + mPKingIMAnchorInfo);
        if (!isOwner()) {
            // 大主播进房
            return;
        }
        // 状态为PK
        if (mPKingIMAnchorInfo != null && userId.equals(mPKingIMAnchorInfo.userId)) {
            updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_PK);
        } else {
            updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC);
        }
    }

    public void handleAnchorExit(String userId) {
        // 有主播退出了
        TRTCLogger.i(TAG, "handleAnchorExit " + " " + userId + " pk " + mPKingIMAnchorInfo);
        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK
                && mPKingIMAnchorInfo != null && userId.equals(mPKingIMAnchorInfo.userId)) {
            // 处理主播退出
            clearPkStatus();
        }
    }

    @Override
    public void getAudienceList(final TXUserListCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "get audience info list fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, not enter room yet.", new ArrayList<TXUserInfo>());
            }
            return;
        }

        V2TIMManager.getGroupManager().getGroupMemberList(mRoomId, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON, 0,
                new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                    @Override
                    public void onError(int code, String desc) {
                    }

                    @Override
                    public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                        List<TXUserInfo> list = new ArrayList<>();
                        for (V2TIMGroupMemberFullInfo info : v2TIMGroupMemberInfoResult.getMemberInfoList()) {
                            TXUserInfo userInfo = new TXUserInfo();
                            userInfo.userName = info.getNickName();
                            userInfo.userId = info.getUserID();
                            userInfo.avatarURL = info.getFaceUrl();
                            list.add(userInfo);
                        }
                        if (callback != null) {
                            callback.onCallback(0, "success", list);
                        }
                    }
                });
    }

    @Override
    public void getUserInfo(final List<String> userList, final TXUserListCallback callback) {
        if (userList == null || userList.size() == 0) {
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "get user info list fail, user list is empty.", new ArrayList<TXUserInfo>());
            }
            return;
        }

        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "get user info list fail, code:" + i);
                if (callback != null) {
                    callback.onCallback(i, s, null);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                List<TXUserInfo> list = new ArrayList<>();
                if (v2TIMUserFullInfos != null && v2TIMUserFullInfos.size() != 0) {
                    for (int i = 0; i < v2TIMUserFullInfos.size(); i++) {
                        TXUserInfo userInfo = new TXUserInfo();
                        userInfo.userName = v2TIMUserFullInfos.get(i).getNickName();
                        userInfo.userId = v2TIMUserFullInfos.get(i).getUserID();
                        userInfo.avatarURL = v2TIMUserFullInfos.get(i).getFaceUrl();
                        list.add(userInfo);
                    }
                }
                if (callback != null) {
                    callback.onCallback(0, "success", list);
                }
            }
        });
    }

    @Override
    public void sendRoomTextMsg(String msg, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room text fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room text fail, not enter room yet.");
            }
            return;
        }

        V2TIMManager.getInstance().sendGroupTextMessage(msg, mRoomId, V2TIMMessage.V2TIM_PRIORITY_LOW, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                TRTCLogger.e(TAG, "message send fail, code: " + i + " msg:" + s);
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                if (callback != null) {
                    callback.onCallback(0, "send group message success.");
                }
            }
        });
    }

    @Override
    public void sendRoomCustomMsg(String cmd, String message, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "send room custom msg fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "send room custom msg fail, not enter room yet.");
            }
            return;
        }

        String data = IMProtocol.getCusMsgJsonStr(cmd, message);
        sendGroupCustomMessage(data, callback, V2TIMMessage.V2TIM_PRIORITY_LOW);
    }

    @Override
    public void requestJoinAnchor(String reason, int timeout, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "request join anchor fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, not enter room yet.");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            TRTCLogger.e(TAG, "response join anchor fail, mCurrentRoomStatus " + mCurrentRoomStatus);
            if (callback != null) {
                callback.onCallback(-1, "当前房间正在PK中");
            }
            return;
        }

        if (isOwner()) {
            TRTCLogger.e(TAG, "request join anchor fail, you are the owner of current room, id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, you are the owner of current room, id:" + mRoomId);
            }
            return;
        }
        if (!TextUtils.isEmpty(mOwnerIMInfo.userId)) {
            final String inviteId = V2TIMManager.getSignalingManager().invite(mOwnerIMInfo.userId,  IMProtocol.getJoinReqJsonStr(reason), true, null,  timeout, null);
            mLinkMicReqPair = new Pair<>(inviteId, callback);
        } else {
            TRTCLogger.e(TAG, "request join anchor fail, can't find host anchor user id.");
            if (callback != null) {
                callback.onCallback(-1, "request join anchor fail, can't find host anchor user id.");
            }
        }
    }

    @Override
    public void cancelRequestJoinAnchor(String reason, final TXCallback callback) {
        if (isOwner()) {
            TRTCLogger.e(TAG, "cancel join anchor fail, you are the owner of current room, id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "cancel join anchor fail, you are the owner of current room, id:" + mRoomId);
            }
            return;
        }
        if (mLinkMicReqPair == null || TextUtils.isEmpty(mLinkMicReqPair.first)) {
            TRTCLogger.e(TAG, "link mic request id is empty");
            if (callback != null) {
                callback.onCallback(-1, "link mic request id is empty");
            }
            return;
        }
        String     requestId       = mLinkMicReqPair.first;
        TXCallback requestCallback = mLinkMicReqPair.second;
        if (requestCallback != null) {
            requestCallback.onCallback(-2, "cancel request join anchor");
        }
        mLinkMicReqPair = null;
        V2TIMManager.getSignalingManager().cancel(requestId, IMProtocol.getCancelReqJsonStr(reason), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onCallback(0, "success");
                }
            }
        });
    }

    @Override
    public void responseJoinAnchor(String userId, boolean agree, String reason) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response join anchor fail, not enter room yet.");
            return;
        }
        String requestId = mJoinAnchorUserIdMap.remove(userId);
        if (TextUtils.isEmpty(requestId)) {
            TRTCLogger.e(TAG, "requestId is empty:" + userId);
            return;
        }
        if (isOwner()) {
            String data = IMProtocol.getJoinRspJsonStr(reason);
            if (agree) {
                V2TIMManager.getSignalingManager().accept(requestId, data, null);
            } else {
                V2TIMManager.getSignalingManager().reject(requestId, data, null);
            }
        } else {
            TRTCLogger.e(TAG, "send join anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
        }
    }

    @Override
    public void kickoutJoinAnchor(String userId, TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "kickout join anchor fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "kickout join anchor fail, not enter room yet.");
            }
            return;
        }
        if (isOwner()) {
            if (mMySelfIMInfo.userId.equals(userId)) {
                TRTCLogger.e(TAG, "kick out join anchor fail, you can't kick out yourself.");
                if (callback != null) {
                    callback.onCallback(-1, "kick out join anchor fail, you can't kick out yourself.");
                }
                return;
            }
            String inviteId = V2TIMManager.getSignalingManager().invite(userId, IMProtocol.getKickOutJoinJsonStr(), true, null, 0, null);
            if (callback != null) {
                callback.onCallback(0, "");
            }
        } else {
            TRTCLogger.e(TAG, "kick out anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
            if (callback != null) {
                callback.onCallback(-1, "kick out anchor fail, not the room owner, room id:" + mRoomId + " my id:" + mMySelfIMInfo.userId);
            }
        }
    }

    @Override
    public void requestRoomPK(String roomId, final String userId, int timeout, final TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "request room pk fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "request room pk fail, not enter room yet.");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC) {
            TRTCLogger.e(TAG, "request room pk fail, room status is " + mCurrentRoomStatus);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "正在连麦中");
            }
            return;
        }

        if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
            TRTCLogger.e(TAG, "request room pk fail, room status is " + mCurrentRoomStatus);
            if (callback != null) {
                callback.onCallback(CODE_ERROR, "已经处于PK状态");
            }
            return;
        }

        if (isOwner()) {
            mPKingRoomId = roomId;
            mPKingIMAnchorInfo = new IMAnchorInfo();
            mPKingIMAnchorInfo.userId = userId;
            String inviteId = V2TIMManager.getSignalingManager().invite(userId, IMProtocol.getPKReqJsonStr(mRoomId, mMySelfIMInfo.userId), true, null, timeout, null);
            mPKReqPair = new Pair<>(inviteId, callback);
        } else {
            TRTCLogger.e(TAG, "request room pk fail, not the owner of current room, room id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "request room pk fail, not the owner of current room, room id:" + mRoomId);
            }
        }
    }

    @Override
    public void cancelRequestRoomPK(String roomId, String userId, final TXCallback callback) {
        if (mPKReqPair == null || TextUtils.isEmpty(mPKReqPair.first)) {
            TRTCLogger.e(TAG, "room pk request id is empty");
            if (callback != null) {
                callback.onCallback(-1, "room pk request id is empty");
            }
            return;
        }
        String     requestId       = mPKReqPair.first;
        TXCallback requestCallback = mPKReqPair.second;
        mPKReqPair = null;
        if (requestCallback != null) {
            requestCallback.onCallback(-1, "you have canceled room pk!");
        }
        V2TIMManager.getSignalingManager().cancel(requestId, IMProtocol.getPKCancelJsonStr(roomId, userId), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onCallback(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onCallback(0, "success");
                }
            }
        });
    }

    @Override
    public void responseRoomPK(String userId, boolean agree, String reason) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        String requestId = mPKUserIdMap.remove(userId);
        if (TextUtils.isEmpty(requestId)) {
            TRTCLogger.e(TAG, "requestId is empty:" + userId);
            return;
        }
        if (isOwner()) {
            if (agree) {
                //增加超时监测，如果PK主播没过来，就清空状态
                mTimeoutHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (isOwner() && mCurrentRoomStatus != TRTCLiveRoomDef.ROOM_STATUS_PK) {
                            clearPkStatus();
                        }
                    }
                }, WAIT_ANCHOR_ENTER_TIMEOUT);
            } else {
                mPKingIMAnchorInfo = null;
                mPKingRoomId = null;
            }
            String data = IMProtocol.getPKRspJsonStr(reason, mMySelfIMInfo.streamId);
            if (agree) {
                V2TIMManager.getSignalingManager().accept(requestId, data, null);
            } else {
                V2TIMManager.getSignalingManager().reject(requestId, data, null);
            }
        } else {
            TRTCLogger.e(TAG, "response room pk fail, not the owner of this room, room id:" + mRoomId);
        }
    }

    private void clearPkStatus() {
        if (mPKingIMAnchorInfo == null || mPKingRoomId == null) {
            return;
        }
        mPKingIMAnchorInfo = null;
        mPKingRoomId = null;
        updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
        final ITXRoomServiceDelegate delegate = mDelegate;
        if (delegate != null) {
            delegate.onRoomQuitRoomPk();
        }
    }

    private void rejectRoomPk(String requestId, String msg) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        V2TIMManager.getSignalingManager().reject(requestId, IMProtocol.getPKRspJsonStr(msg, mMySelfIMInfo.streamId), null);
    }

    private void rejectLinkMic(String requestId, String msg) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "response room pk fail, not enter room yet.");
            return;
        }
        if (isOwner()) {
            V2TIMManager.getSignalingManager().reject(requestId, IMProtocol.getJoinRspJsonStr(msg), null);
        }
    }

    public void quitLinkMic() {
        // 观众退出连麦
    }

    @Override
    public void resetRoomStatus() {
        if (isOwner()) {
            updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
        }
    }

    @Override
    public void quitRoomPK(TXCallback callback) {
        if (!isEnterRoom()) {
            TRTCLogger.e(TAG, "quit room pk fail, not enter room yet.");
            if (callback != null) {
                callback.onCallback(-1, "quit room pk fail, not enter room yet.");
            }
            return;
        }
        if (isOwner()) {
            IMAnchorInfo pkingAnchorInfo = mPKingIMAnchorInfo;
            String       pkingRoomId     = mPKingRoomId;
            if (pkingAnchorInfo != null && !TextUtils.isEmpty(pkingAnchorInfo.userId) && !TextUtils.isEmpty(pkingRoomId)) {
                mPKingIMAnchorInfo = null;
                mPKingRoomId = null;
                updateRoomType(TRTCLiveRoomDef.ROOM_STATUS_SINGLE);
                V2TIMManager.getSignalingManager().invite(pkingAnchorInfo.userId, IMProtocol.getQuitPKJsonStr(), true, null,0, null);
            } else {
                TRTCLogger.e(TAG, "quit room pk fail, not in pking, pk room id:" + pkingRoomId + " pk user:" + pkingAnchorInfo);
                if (callback != null) {
                    callback.onCallback(-1, "quit room pk fail, not in pk.");
                }
            }
        } else {
            TRTCLogger.e(TAG, "quit room pk fail, not the owner of this room, room id:" + mRoomId);
            if (callback != null) {
                callback.onCallback(-1, "quit room pk fail, not the owner of this room, room id:" + mRoomId);
            }
        }
    }

    @Override
    public String exchangeStreamId(String userId) {
        for (IMAnchorInfo info : mAnchorList) {
            if (info != null && info.userId != null && info.userId.equals(userId)) {
                return info.streamId;
            }
        }
        return null;
    }

    @Override
    public boolean isLogin() {
        return mIsLogin;
    }

    @Override
    public boolean isEnterRoom() {
        return mIsLogin && mIsEnterRoom;
    }

    @Override
    public String getOwnerUserId() {
        return mOwnerIMInfo != null ? mOwnerIMInfo.userId : null;
    }

    @Override
    public boolean isOwner() {
        return mMySelfIMInfo.equals(mOwnerIMInfo);
    }

    @Override
    public boolean isPKing() {
        return !TextUtils.isEmpty(mPKingRoomId) && mPKingIMAnchorInfo != null && !TextUtils.isEmpty(mPKingIMAnchorInfo.userId);
    }

    @Override
    public String getPKRoomId() {
        return mPKingRoomId;
    }

    @Override
    public String getPKUserId() {
        return mPKingIMAnchorInfo != null ? mPKingIMAnchorInfo.userId : null;
    }

    private void cleanStatus() {
        mCurrentRoomStatus = TRTCLiveRoomDef.ROOM_STATUS_NONE;

        mTXRoomInfo = new TXRoomInfo();

        mIsEnterRoom = false;

        mRoomId = "";
        mAnchorList.clear();
        // 个人信息不需要清除，但是流需要
        mMySelfIMInfo.streamId = "";
        mOwnerIMInfo.clean();

        mPKingIMAnchorInfo = null;
        mPKingRoomId = null;

        mPKReqPair = new Pair<>(null, null);
        mLinkMicReqPair = new Pair<>(null, null);
        mAudienceInfoMap.clear();
        mJoinAnchorUserIdMap.clear();
        mPKUserIdMap.clear();
        mTimeoutHandler.removeCallbacksAndMessages(null);
    }

    private void updateRoomType(int type) {
        int oldType = mCurrentRoomStatus;
        mCurrentRoomStatus = type;
        updateHostAnchorInfo();
        ITXRoomServiceDelegate delegate = mDelegate;
        mTXRoomInfo.roomStatus = type;
        if (delegate != null && mCurrentRoomStatus != oldType) {
            delegate.onRoomInfoChange(mTXRoomInfo);
        }
    }

    private void updateHostAnchorInfo() {
        if (!isOwner()) {
            return;
        }
        TRTCLogger.i(TAG, "updateHostAnchorInfo " + mMySelfIMInfo.streamId);
        TRTCLogger.i(TAG, "start update anchor info, type:" + mCurrentRoomStatus + " list:" + mAnchorList.toString());
        // 更新群简介
        V2TIMGroupInfo v2TIMGroupInfo = new V2TIMGroupInfo();
        v2TIMGroupInfo.setIntroduction(IMProtocol.getGroupInfoJsonStr(mCurrentRoomStatus, new ArrayList<>(mAnchorList)));
        v2TIMGroupInfo.setGroupID(mRoomId);
        V2TIMManager.getGroupManager().setGroupInfo(v2TIMGroupInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TRTCLogger.e(TAG, "updateHostAnchorInfo room owner update anchor list into group introduction fail, code: " + code + " msg:" + desc);
            }

            @Override
            public void onSuccess() {
                TRTCLogger.i(TAG, "room owner update anchor list into group introduction success");
            }
        });
        // 发出全员公告
        String json = IMProtocol.getUpdateGroupInfoJsonStr(mCurrentRoomStatus, new ArrayList<>(mAnchorList));
        sendGroupCustomMessage(json, null, V2TIMMessage.V2TIM_PRIORITY_HIGH);

    }

    private void sendGroupCustomMessage(String data, final TXCallback callback, int priority) {
        if (!isEnterRoom()) {
            return;
        }

        V2TIMManager.getInstance().sendGroupCustomMessage(data.getBytes(), mRoomId, priority, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                if (callback != null) {
                    callback.onCallback(i, s);
                }
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                if (callback != null) {
                    callback.onCallback(0, "send group message success.");
                }
            }
        });
    }

    private void onGroupInfoChange(JSONObject jsonObject) {
        if (isOwner()) {
            // 主播不需要再进入
            return;
        }
        Pair<Integer, List<IMAnchorInfo>> roomPair = IMProtocol.parseGroupInfo(jsonObject.toString());
        if (roomPair != null) {
            int newRoomStatus = roomPair.first;
            if (mCurrentRoomStatus != newRoomStatus) {
                mCurrentRoomStatus = newRoomStatus;
                mTXRoomInfo.roomStatus = mCurrentRoomStatus;
                if (mDelegate != null) {
                    mDelegate.onRoomInfoChange(mTXRoomInfo);
                }
            }

            List<IMAnchorInfo> copyList = new ArrayList<>(mAnchorList);
            mAnchorList.clear();
            mAnchorList.addAll(roomPair.second);

            if (mDelegate != null) {
                // 回调主播列表变更通知
                List<IMAnchorInfo> anchorLeaveList = new ArrayList<>(copyList);
                List<IMAnchorInfo> anchorEnterList = new ArrayList<>(roomPair.second);

                Iterator<IMAnchorInfo> leaveIterator = anchorLeaveList.iterator();
                while (leaveIterator.hasNext()) {
                    IMAnchorInfo           info          = leaveIterator.next();
                    Iterator<IMAnchorInfo> enterIterator = anchorEnterList.iterator();
                    while (enterIterator.hasNext()) {
                        IMAnchorInfo info2 = enterIterator.next();
                        if (info.equals(info2)) {
                            // 两个都有，说明个主播，前后都存在，移除出列表。
                            leaveIterator.remove();
                            enterIterator.remove();
                            break;
                        }
                    }
                }

                for (IMAnchorInfo info : anchorLeaveList) {
                    mDelegate.onRoomAnchorExit(info.userId);
                }
                for (IMAnchorInfo info : anchorEnterList) {
                    mDelegate.onRoomAnchorEnter(info.streamId);
                }
                // 回调流变更通知
                List<IMAnchorInfo> oldAnchorList = new ArrayList<>(copyList);
                List<IMAnchorInfo> newAnchorList = new ArrayList<>(roomPair.second);
                for (IMAnchorInfo oldInfo : oldAnchorList) {
                    for (IMAnchorInfo newInfo : newAnchorList) {
                        if (oldInfo.equals(newInfo)) {
                            if (TextUtils.isEmpty(oldInfo.streamId) && !TextUtils.isEmpty(newInfo.streamId)) {
                                // 流新增
                                mDelegate.onRoomStreamAvailable(newInfo.userId);
                            } else if (!TextUtils.isEmpty(oldInfo.streamId) && TextUtils.isEmpty(newInfo.streamId)) {
                                // 流移除
                                mDelegate.onRoomStreamUnavailable(newInfo.userId);
                            }
                        }
                    }
                }
            }
        }
    }

    private void onRecvC2COrGroupCustomMessage(final TXUserInfo txUserInfo, byte[] customData) {
        final ITXRoomServiceDelegate delegate  = mDelegate;
        String                       customStr = new String(customData);
        TRTCLogger.i(TAG, "im msg dump, sender id:" + txUserInfo.userId + " customStr:" + customStr);
        if (!TextUtils.isEmpty(customStr)) {
            // 一定会有自定义消息的头
            try {
                JSONObject jsonObject = new JSONObject(customStr);
                String     version    = jsonObject.getString(IMProtocol.Define.KEY_VERSION);
                if (!version.equals(IMProtocol.Define.VALUE_PROTOCOL_VERSION)) {
                    TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
                }
                int action = jsonObject.getInt(IMProtocol.Define.KEY_ACTION);
                switch (action) {
                    case IMProtocol.Define.CODE_UNKNOWN:
                        // ignore
                        break;
                    case IMProtocol.Define.CODE_ROOM_CUSTOM_MSG:
                        Pair<String, String> cusPair = IMProtocol.parseCusMsg(jsonObject);
                        if (delegate != null && cusPair != null) {
                            delegate.onRoomRecvRoomCustomMsg(mRoomId, cusPair.first, cusPair.second, txUserInfo);
                        }
                        break;
                    case IMProtocol.Define.CODE_UPDATE_GROUP_INFO:
                        onGroupInfoChange(jsonObject);
                        break;
                    default:
                        break;
                }
            } catch (JSONException e) {
                // ignore 无需关注的消息
            }
        }
    }

    private void RoomPkCallback(final String inviter, final String roomId, final String streamId, final boolean isRequest) {
        V2TIMManager.getInstance().getUsersInfo(Arrays.asList(inviter), new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                if (mDelegate != null) {
                    // 回调到上层
                    TXUserInfo userInfo = new TXUserInfo();
                    userInfo.userId = inviter;
                    userInfo.avatarURL = "";
                    userInfo.userName = inviter;
                    if (isRequest) {
                        mDelegate.onRoomRequestRoomPK(userInfo);
                    } else {
                        mDelegate.onRoomResponseRoomPK(roomId, streamId, userInfo);
                    }
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (mDelegate != null) {
                    // 回调到上层
                    TXUserInfo userInfo = new TXUserInfo();
                    userInfo.userId = inviter;
                    userInfo.avatarURL = v2TIMUserFullInfos.get(0).getFaceUrl();
                    userInfo.userName = v2TIMUserFullInfos.get(0).getNickName();
                    if (isRequest) {
                        mDelegate.onRoomRequestRoomPK(userInfo);
                    } else {
                        mDelegate.onRoomResponseRoomPK(roomId, streamId, userInfo);
                    }
                }
            }
        });
    }

    private void onRecvSignalResponse(final String inviteId, final String invitee, String data, boolean accept) {
        final ITXRoomServiceDelegate delegate   = mDelegate;
        JSONObject                   jsonObject = null;
        int                          action;
        try {
            jsonObject = new JSONObject(data);
            String version = jsonObject.getString(IMProtocol.Define.KEY_VERSION);
            if (!version.equals(IMProtocol.Define.VALUE_PROTOCOL_VERSION)) {
                TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
            }
            action = jsonObject.getInt(IMProtocol.Define.KEY_ACTION);
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }

        switch (action) {
            case IMProtocol.Define.CODE_RESPONSE_JOIN_ANCHOR:
                // 收到连麦回包的消息：
                String joinRspReason = IMProtocol.parseJoinRspResult(jsonObject);
                Pair<String, TXCallback> linkMicPair = mLinkMicReqPair;
                if (linkMicPair != null) {
                    String     requestId = linkMicPair.first;
                    TXCallback callback  = linkMicPair.second;
                    if (!TextUtils.isEmpty(requestId) && callback != null) {
                        if (requestId.equals(inviteId)) {
                            mLinkMicReqPair = null;
                            callback.onCallback(accept ? 0 : -1, accept ? "anchor agree to link mic" : joinRspReason);
                        } else {
                            TRTCLogger.e(TAG, "recv join rsp, but link request id:" + requestId + " recv :" + inviteId);
                        }
                    } else {
                        TRTCLogger.e(TAG, "recv join rsp, but link mic pair params is invalid, requestId:" + requestId + " callback:" + callback);
                    }
                } else {
                    TRTCLogger.e(TAG, "recv join rsp, but link mic pair is null.");
                }
                break;
            case IMProtocol.Define.CODE_RESPONSE_PK:
                Pair<String, String> pkRspPair = IMProtocol.parsePKRsp(jsonObject);
                if (pkRspPair != null) {
                    String                   reason   = pkRspPair.first;
                    String                   streamId = pkRspPair.second;
                    Pair<String, TXCallback> pkPair   = mPKReqPair;
                    if (pkPair != null) {
                        String     requestId = pkPair.first;
                        TXCallback callback  = pkPair.second;
                        if (!TextUtils.isEmpty(requestId)) {
                            if (requestId.equals(inviteId)) {
                                mPKReqPair = null;
                                if (accept) {
                                    mPKingIMAnchorInfo.streamId = streamId;
                                    RoomPkCallback(invitee, mPKingRoomId, mPKingIMAnchorInfo.streamId, false);
                                } else {
                                    mPKingRoomId = null;
                                    mPKingIMAnchorInfo = null;
                                }
                                if (callback != null) {
                                    callback.onCallback(accept ? 0 : -1, accept ? "agree to pk" : reason);
                                }
                            } else {
                                TRTCLogger.e(TAG, "recv pk rsp, but pk id:" + requestId + " im id:" + inviteId);
                            }
                        } else {
                            TRTCLogger.e(TAG, "recv pk rsp, but pk pair params is invalid.");
                        }
                    } else {
                        TRTCLogger.e(TAG, "recv pk rsp, but pk pair is null.");
                    }
                } else {
                    TRTCLogger.e(TAG, "recv pk rsp, but parse pair is null, maybe something error.");
                }
                break;
        }
    }

    private void onRecvNewSignal(String inviteId, String inviter, String groupID, String data) {
        final ITXRoomServiceDelegate delegate   = mDelegate;
        JSONObject                   jsonObject = null;
        int                          action;
        try {
            jsonObject = new JSONObject(data);
            String version = jsonObject.getString(IMProtocol.Define.KEY_VERSION);
            if (!version.equals(IMProtocol.Define.VALUE_PROTOCOL_VERSION)) {
                TRTCLogger.e(TAG, "protocol version is not match, ignore msg.");
            }
            action = jsonObject.getInt(IMProtocol.Define.KEY_ACTION);
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }

        switch (action) {
            case IMProtocol.Define.CODE_REQUEST_JOIN_ANCHOR:
                // 收到请求连麦的消息：
                if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                    TRTCLogger.e(TAG, "recv join anchor mCurrentRoomStatus " + mCurrentRoomStatus);
                    rejectLinkMic(inviter, "主播正在PK中");
                    return;
                }
                String reqReason = IMProtocol.parseJoinReqReason(jsonObject);
                mJoinAnchorUserIdMap.put(inviter, inviteId);
                if (delegate != null) {
                    TXUserInfo userInfo = mAudienceInfoMap.get(inviter);
                    if (userInfo != null) {
                        delegate.onRoomRequestJoinAnchor(userInfo, reqReason);
                    }
                }
                break;
            case IMProtocol.Define.CODE_KICK_OUT_JOIN_ANCHOR:
                // 收到被踢出的消息：
                V2TIMManager.getSignalingManager().accept(inviteId, IMProtocol.getResponseKickOutJoinJsonStr(), null);
                if (delegate != null) {
                    delegate.onRoomKickoutJoinAnchor();
                }
                break;
            case IMProtocol.Define.CODE_REQUEST_ROOM_PK:
                // 收到请求跨房PK的消息：
                // 首先检查状态，如果状态不对，立即回复拒绝
                if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_LINK_MIC) {
                    TRTCLogger.e(TAG, "received pk msg, but mCurrentRoomStatus is" + mCurrentRoomStatus);
                    rejectRoomPk(inviteId, "主播正在连麦中");
                    return;
                }
                if (mCurrentRoomStatus == TRTCLiveRoomDef.ROOM_STATUS_PK) {
                    TRTCLogger.e(TAG, "received pk msg, but mCurrentRoomStatus is" + mCurrentRoomStatus);
                    rejectRoomPk(inviteId, "主播正在PK中");
                    return;
                }
                Pair<String, String> pkReqPair = IMProtocol.parsePKReq(jsonObject);
                if (pkReqPair != null) {
                    String fromRoomId   = pkReqPair.first;
                    String fromStreamId = pkReqPair.second;
                    if (!TextUtils.isEmpty(fromRoomId) && !TextUtils.isEmpty(fromStreamId)) {
                        mPKingRoomId = fromRoomId;
                        mPKingIMAnchorInfo = new IMAnchorInfo();
                        mPKingIMAnchorInfo.name = inviter;
                        mPKingIMAnchorInfo.streamId = fromStreamId;
                        mPKingIMAnchorInfo.userId = inviter;
                        mPKUserIdMap.put(inviter, inviteId);
                        RoomPkCallback(inviter, mPKingRoomId, null, true);
                    } else {
                        TRTCLogger.e(TAG, "recv pk req, room id:" + fromRoomId + " or stream id:" + fromStreamId + " is invalid.");
                    }
                } else {
                    TRTCLogger.e(TAG, "recv pk req, but parse pair is null, maybe something error.");
                }
                break;
            case IMProtocol.Define.CODE_QUIT_ROOM_PK:
                if (mPKingIMAnchorInfo != null) {
                    return;
                }
                clearPkStatus();
                break;
        }
    }

    private void onRecvSignalCancel(String inviteID, String inviter, String data) {
        if (inviteID.equals(mPKUserIdMap.get(inviter))) {
            // 这里说明对端PK主播取消了这个请求
            mPKUserIdMap.remove(inviter);
            if (mDelegate != null) {
                mDelegate.onAnchorCancelRequestRoomPK(inviter);
            }
            return;
        }
        if (inviteID.equals(mJoinAnchorUserIdMap.get(inviter))) {
            // 这里说明连麦用户取消了这个请求
            mJoinAnchorUserIdMap.remove(inviter);
            if (mDelegate != null) {
                mDelegate.onAudienceCancelRequestJoinAnchor(inviter);
            }
            return;
        }
    }

    private static String getKey(Map map, String requestId) {
        Set<Map.Entry<String, String>> sets = map.entrySet();
        for (Map.Entry<String, String> item : sets) {
            if (requestId.equals(item.getValue())) {
                return item.getKey();
            }
        }
        return "";
    }

    private class LiveRoomSimpleMsgListener extends V2TIMSimpleMsgListener {

        @Override
        public void onRecvC2CTextMessage(String msgID, V2TIMUserInfo sender, String text) {
        }

        @Override
        public void onRecvC2CCustomMessage(String msgID, V2TIMUserInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupCustomMessage(txUserInfo, customData);
        }

        @Override
        public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
            final TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();

            if (mDelegate != null) {
                mDelegate.onRoomRecvRoomTextMsg(groupID, text, txUserInfo);
            }
        }

        @Override
        public void onRecvGroupCustomMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupCustomMessage(txUserInfo, customData);
        }
    }

    private class LiveRoomSignalListener extends V2TIMSignalingListener {
        /**
         * 收到邀请
         */
        @Override
        public void onReceiveNewInvitation(String inviteID, String inviter, String groupID, List<String> inviteeList, String data) {
            if (!IMProtocol.isLiveRoomSignal(data)) {
                return;
            }
            onRecvNewSignal(inviteID, inviter, groupID, data);
        }

        /**
         * 被邀请者接受邀请
         */
        @Override
        public void onInviteeAccepted(String inviteID, String invitee, String data) {
            if (!IMProtocol.isLiveRoomSignal(data)) {
                return;
            }
            onRecvSignalResponse(inviteID, invitee, data, true);
        }

        /**
         * 被邀请者拒绝邀请
         */
        @Override
        public void onInviteeRejected(String inviteID, String invitee, String data) {
            if (!IMProtocol.isLiveRoomSignal(data)) {
                return;
            }
            onRecvSignalResponse(inviteID, invitee, data, false);
        }

        /**
         * 邀请被取消
         */
        @Override
        public void onInvitationCancelled(String inviteID, String inviter, String data) {
            if (!IMProtocol.isLiveRoomSignal(data)) {
                return;
            }
            onRecvSignalCancel(inviteID, inviter, data);
        }

        /**
         * 邀请超时
         */
        @Override
        public void onInvitationTimeout(String inviteID, List<String> inviteeList) {
            if (mLinkMicReqPair != null && inviteID.equals(mLinkMicReqPair.first)) {
                // 走到这里表示观众端申请连麦超时了
                TXCallback callback = mLinkMicReqPair.second;
                if (callback != null) {
                    callback.onCallback(-2, "request join anchor timeout!");
                }
                return;
            }
            if (mPKReqPair != null && inviteID.equals(mPKReqPair.first)) {
                // 走到这里表示主播端主动申请pk超时了
                TXCallback callback = mPKReqPair.second;
                if (callback != null) {
                    callback.onCallback(-2, "request join anchor timeout!");
                }
                return;
            }
            if (mJoinAnchorUserIdMap.containsValue(inviteID)) {
                // 走到这里说明某个观众连麦超时了
                String userId = getKey(mJoinAnchorUserIdMap, inviteID);
                mJoinAnchorUserIdMap.remove(userId);
                if (mDelegate != null) {
                    mDelegate.onAudienceRequestJoinAnchorTimeout(userId);
                }
                return;
            }
            if (mPKUserIdMap.containsValue(inviteID)) {
                // 走到这里说明某个主播申请PK超时了
                String userId = getKey(mPKUserIdMap, inviteID);
                mPKUserIdMap.remove(userId);
                if (mDelegate != null) {
                    mDelegate.onAnchorRequestRoomPKTimeout(userId);
                }
                return;
            }
        }
    }


    private class LiveRoomGroupListener extends V2TIMGroupListener {
        @Override
        public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
            Log.d(TAG, "onMemberEnter");
            if (!isEnterRoom()) {
                return;
            }

            for (V2TIMGroupMemberInfo timUserProfile : memberList) {
                TXUserInfo userInfo = new TXUserInfo();
                userInfo.userName = timUserProfile.getNickName();
                Log.d(TAG, "onMemberEnter userName: " + userInfo.userName);
                userInfo.userId = timUserProfile.getUserID();
                userInfo.avatarURL = timUserProfile.getFaceUrl();
                mAudienceInfoMap.put(userInfo.userId, userInfo);
                if (TextUtils.isEmpty(userInfo.userId) || userInfo.userId.equals(mMySelfIMInfo.userId)) {
                    return;
                }
                if (mDelegate != null) {
                    mDelegate.onRoomAudienceEnter(userInfo);
                }
            }
        }

        @Override
        public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
            if (!isEnterRoom()) {
                return;
            }

            TXUserInfo userInfo = new TXUserInfo();
            userInfo.userName = member.getNickName();
            Log.d(TAG, "onMemberLeave userName: " + userInfo.userName);
            userInfo.userId = member.getUserID();
            userInfo.avatarURL = member.getFaceUrl();
            mAudienceInfoMap.remove(userInfo.userId);
            if (TextUtils.isEmpty(userInfo.userId) || userInfo.userId.equals(mMySelfIMInfo.userId)) {
                return;
            }
            if (mDelegate != null) {
                mDelegate.onRoomAudienceExit(userInfo);
            }
        }

        @Override
        public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
            TRTCLogger.i(TAG, "recv room destroy msg");
            // 如果发现房间已经解散，那么内部退一次房间
            exitRoom(new TXCallback() {
                @Override
                public void onCallback(int code, String msg) {
                    TRTCLogger.i(TAG, "recv room destroy msg, exit room inner, code:" + code + " msg:" + msg);
                    // 无论结果是否成功，都清空状态，并且回调出去
                    cleanStatus();
                    ITXRoomServiceDelegate delegate = mDelegate;
                    if (delegate != null) {
                        String roomId = mRoomId;
                        delegate.onRoomDestroy(roomId);
                    }
                }
            });
        }

        @Override
        public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
            super.onGroupInfoChanged(groupID, changeInfos);
            if (groupID.equals(mRoomId)) {
                for (V2TIMGroupChangeInfo groupChangeInfo : changeInfos) {
                    if (groupChangeInfo.getType() == V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                        // 群公告修改
                        String data = groupChangeInfo.getValue();
                        try {
                            JSONObject jsonObject = new JSONObject(data);
                            onGroupInfoChange(jsonObject);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }

    public void followAnchor(String userId, final TRTCLiveRoomCallback.ActionCallback callback) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        V2TIMFriendAddApplication v2TIMFriendAddApplication = new V2TIMFriendAddApplication(userId);
        v2TIMFriendAddApplication.setAddSource("android");
        V2TIMManager.getFriendshipManager().addFriend(v2TIMFriendAddApplication, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "followAnchor err code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                int resultCode = v2TIMFriendOperationResult.getResultCode();
                if (resultCode == BaseConstants.ERR_SUCC) {
                    callback.onCallback(0, v2TIMFriendOperationResult.getResultInfo());
                } else {
                    Log.d(TAG, "followAnchor failed:" + resultCode);
                    callback.onCallback(1, v2TIMFriendOperationResult.getResultInfo());
                }
            }
        });
    }

    public void checkFollowState(String userId, final TRTCLiveRoomCallback.RoomFollowStateCallback callback) {
        List<String> userIDList = new ArrayList<>();
        userIDList.add(userId);
        V2TIMManager.getFriendshipManager().checkFriend(userIDList, V2TIMFriendInfo.V2TIM_FRIEND_TYPE_SINGLE, new V2TIMValueCallback<List<V2TIMFriendCheckResult>>() {
            @Override
            public void onError(int code, String desc) {
                Log.d(TAG, "check follow state onError: " + code);
                callback.onFailed(desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendCheckResult> v2FriendCheckResults) {
                if (v2FriendCheckResults != null && v2FriendCheckResults.size() != 0) {
                    V2TIMFriendCheckResult v2TIMFriendCheckResult = v2FriendCheckResults.get(0);
                    if (v2TIMFriendCheckResult != null) {
                        int resultType = v2TIMFriendCheckResult.getResultType();
                        Log.d(TAG, "check follow state Success result type is : " + resultType);
                        if (resultType == V2TIMFriendCheckResult.V2TIM_FRIEND_RELATION_TYPE_NONE) {
                            callback.isNotFollowed();
                        } else {
                            callback.isFollowed();
                        }
                    }
                } else {
                    Log.d(TAG, "checkFriend() v2FriendCheckResults is null");
                }
            }
        });
    }


}
