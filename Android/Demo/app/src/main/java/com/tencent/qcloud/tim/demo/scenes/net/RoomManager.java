package com.tencent.qcloud.tim.demo.scenes.net;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.adapter.RoomListAdapter;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoom;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class RoomManager {

    private static final String TAG = "RoomManager";

    private static final String URL = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest";

    private static final String REQUEST_PARAM_METHOD = "method";
    private static final String REQUEST_PARAM_APP_ID = "appId";
    private static final String REQUEST_PARAM_ROOM_ID = "roomId";
    private static final String REQUEST_PARAM_TYPE = "type";

    private static final String REQUEST_VALUE_CREATE_ROOM = "createRoom";
    private static final String REQUEST_VALUE_UPDATE_ROOM = "updateRoom";
    private static final String REQUEST_VALUE_DESTROY_ROOM = "destroyRoom";
    private static final String REQUEST_VALUE_GET_ROOM_LIST = "getRoomList";

    public static final String TYPE_LIVE_ROOM = "liveRoom";
    public static final String TYPE_VOICE_ROOM = "voiceRoom";
    public static final String TYPE_GROUP_LIVE = "groupLive";

    public static final String ROOM_TITLE = "room_title";
    public static final String GROUP_ID = "group_id";
    public static final String USE_CDN_PLAY = "use_cdn_play";
    public static final String PUSHER_NAME = "pusher_name";
    public static final String COVER_PIC = "cover_pic";
    public static final String PUSHER_AVATAR = "pusher_avatar";
    public static final String ANCHOR_ID = "anchor_id";

    private static final RoomManager mOurInstance = new RoomManager();

    public static final int ERROR_CODE_UNKNOWN = -1;

    private Handler mHandler = new Handler(Looper.getMainLooper());

    public static RoomManager getInstance() {
        return mOurInstance;
    }

    public void createRoom(int roomId, String type, final ActionCallback callback) {
        OkHttpClient okHttpClient = new OkHttpClient();
        RequestBody formBody = new FormBody.Builder()
                .add(REQUEST_PARAM_METHOD, REQUEST_VALUE_CREATE_ROOM)
                .add(REQUEST_PARAM_APP_ID, String.valueOf(GenerateTestUserSig.SDKAPPID))
                .add(REQUEST_PARAM_ROOM_ID, String.valueOf(roomId))
                .add(REQUEST_PARAM_TYPE, type)
                .build();
        final Request request = new Request.Builder()
                .url(URL)
                .post(formBody)
                .build();
        okHttpClient.newCall(request)
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        Log.e(TAG, "onFailure: ", e);
                        if (callback != null) {
                            callback.onFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (!response.isSuccessful()) {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                            return;
                        }
                        String result = response.body().string();
                        Log.i(TAG, "createRoom, onResponse: result -> " + result);
                        if (!TextUtils.isEmpty(result)) {
                            Gson gson = new Gson();
                            ResponseEntity res = gson.fromJson(result, ResponseEntity.class);
                            if (res.errorCode == 0) {
                                doSuccess();
                            } else {
                                doFailed(res.errorCode, res.errorMessage);
                            }
                        } else {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    private void doFailed(final int code, final String msg) {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onFailed(code, msg);
                                }
                            }
                        });
                    }

                    private void doSuccess() {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onSuccess();
                                }
                            }
                        });
                    }
                });
    }

    public void updateRoom(int roomId, String type, final ActionCallback callback) {
        OkHttpClient okHttpClient = new OkHttpClient();
        RequestBody formBody = new FormBody.Builder()
                .add(REQUEST_PARAM_METHOD, REQUEST_VALUE_UPDATE_ROOM)
                .add(REQUEST_PARAM_APP_ID, String.valueOf(GenerateTestUserSig.SDKAPPID))
                .add(REQUEST_PARAM_ROOM_ID, String.valueOf(roomId))
                .add(REQUEST_PARAM_TYPE, type)
                .build();
        final Request request = new Request.Builder()
                .url(URL)
                .post(formBody)
                .build();
        okHttpClient.newCall(request)
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        Log.e(TAG, "onFailure: ", e);
                        if (callback != null) {
                            callback.onFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (!response.isSuccessful()) {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                            return;
                        }
                        String result = response.body().string();
                        Log.i(TAG, "updateRoom, onResponse: result -> " + result);
                        if (!TextUtils.isEmpty(result)) {
                            Gson gson = new Gson();
                            ResponseEntity res = gson.fromJson(result, ResponseEntity.class);
                            if (res.errorCode == 0) {
                                doSuccess();
                            } else {
                                doFailed(res.errorCode, res.errorMessage);
                            }
                        } else {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    private void doFailed(final int code, final String msg) {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onFailed(code, msg);
                                }
                            }
                        });
                    }

                    private void doSuccess() {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onSuccess();
                                }
                            }
                        });
                    }
                });
    }

    public void destroyRoom(int roomId, String type, final ActionCallback callback) {
        OkHttpClient okHttpClient = new OkHttpClient();
        RequestBody formBody = new FormBody.Builder()
                .add(REQUEST_PARAM_METHOD, REQUEST_VALUE_DESTROY_ROOM)
                .add(REQUEST_PARAM_APP_ID, String.valueOf(GenerateTestUserSig.SDKAPPID))
                .add(REQUEST_PARAM_ROOM_ID, String.valueOf(roomId))
                .add(REQUEST_PARAM_TYPE, type)
                .build();
        final Request request = new Request.Builder()
                .url(URL)
                .post(formBody)
                .build();
        okHttpClient.newCall(request)
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        Log.e(TAG, "onFailure: ", e);
                        if (callback != null) {
                            callback.onFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (!response.isSuccessful()) {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                            return;
                        }
                        String result = response.body().string();
                        Log.i(TAG, "destroyRoom, onResponse: result -> " + result);
                        if (!TextUtils.isEmpty(result)) {
                            Gson gson = new Gson();
                            ResponseEntity res = gson.fromJson(result, ResponseEntity.class);
                            if (res.errorCode == 0) {
                                doSuccess();
                            } else {
                                doFailed(res.errorCode, res.errorMessage);
                            }
                        } else {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    private void doFailed(final int code, final String msg) {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onFailed(code, msg);
                                }
                            }
                        });
                    }

                    private void doSuccess() {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onSuccess();
                                }
                            }
                        });
                    }
                });
    }

    public void getRoomList(String type, final GetRoomListCallback callback) {
        OkHttpClient okHttpClient = new OkHttpClient();
        RequestBody formBody = new FormBody.Builder()
                .add(REQUEST_PARAM_METHOD, REQUEST_VALUE_GET_ROOM_LIST)
                .add(REQUEST_PARAM_APP_ID, String.valueOf(GenerateTestUserSig.SDKAPPID))
                .add(REQUEST_PARAM_TYPE, type)
                .build();
        final Request request = new Request.Builder()
                .url(URL)
                .post(formBody)
                .build();
        okHttpClient.newCall(request)
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        Log.e(TAG, "onFailure: ", e);
                        if (callback != null) {
                            callback.onFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (!response.isSuccessful()) {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                            return;
                        }
                        String result = response.body().string();
                        Log.i(TAG, "getRoomList, onResponse: result -> " + result);
                        if (!TextUtils.isEmpty(result)) {
                            Gson gson = new Gson();
                            ResponseEntity res = gson.fromJson(result, ResponseEntity.class);
                            if (res.errorCode == 0 && res.data != null) {
                                List<RoomInfo> roomInfoList = res.data;
                                List<String> roomIdList = new ArrayList<>();
                                for (RoomInfo info : roomInfoList) {
                                    roomIdList.add(info.roomId);
                                }
                                doSuccess(roomIdList);
                            } else {
                                doFailed(res.errorCode, res.errorMessage);
                            }
                        } else {
                            doFailed(ERROR_CODE_UNKNOWN, DemoApplication.instance().getString(R.string.unknow_error));
                        }
                    }

                    private void doFailed(final int code, final String msg) {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onFailed(code, msg);
                                }
                            }
                        });
                    }

                    private void doSuccess(final List<String> roomIdList) {
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onSuccess(roomIdList);
                                }
                            }
                        });
                    }
                });
    }

    public void getScenesRoomInfos(final Context context, String type, final GetScenesRoomInfosCallback callback) {
        RoomManager.getInstance().getRoomList(type, new RoomManager.GetRoomListCallback() {
            @Override
            public void onSuccess(List<String> roomIdList) {
                if (roomIdList != null && !roomIdList.isEmpty()) {
                    // 从组件出获取房间信息
                    List<Integer> roomList = new ArrayList<>();
                    for (String id : roomIdList) {
                        try {
                            roomList.add(Integer.parseInt(id));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    TRTCLiveRoom.sharedInstance(context).getRoomInfos(roomList, new TRTCLiveRoomCallback.RoomInfoCallback() {
                        @Override
                        public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list) {
                            if (code == 0) {
                                List<RoomListAdapter.ScenesRoomInfo> scenesRoomInfos = new ArrayList<>();
                                for (int i = 0, listSize = list.size(); i < listSize; i++) {
                                    TRTCLiveRoomDef.TRTCLiveRoomInfo liveRoomInfo = list.get(i);
                                    RoomListAdapter.ScenesRoomInfo scenesRoomInfo = new RoomListAdapter.ScenesRoomInfo();
                                    scenesRoomInfo.anchorId = liveRoomInfo.ownerId;
                                    scenesRoomInfo.anchorName = liveRoomInfo.ownerName;
                                    scenesRoomInfo.roomId = String.valueOf(liveRoomInfo.roomId);
                                    scenesRoomInfo.coverUrl = liveRoomInfo.coverUrl;
                                    scenesRoomInfo.roomName = liveRoomInfo.roomName;
                                    scenesRoomInfo.memberCount = liveRoomInfo.memberCount;
                                    scenesRoomInfos.add(scenesRoomInfo);
                                }
                                doSuccess(scenesRoomInfos);
                            } else {
                                doSuccess(new ArrayList<RoomListAdapter.ScenesRoomInfo>());
                            }
                        }
                    });
                } else {
                    doSuccess(new ArrayList<RoomListAdapter.ScenesRoomInfo>());
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                doFailed(code, msg);
            }

            private void doFailed(final int code, final String msg) {
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onFailed(code, msg);
                        }
                    }
                });
            }

            private void doSuccess(final List<RoomListAdapter.ScenesRoomInfo> roomInfos) {
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onSuccess(roomInfos);
                        }
                    }
                });
            }
        });
    }

    public void checkRoomExist(String type, final int roomId, final ActionCallback callback) {
        getRoomList(type, new GetRoomListCallback() {
            @Override
            public void onSuccess(List<String> roomIdList) {
                if (roomIdList.contains(String.valueOf(roomId))) {
                    doSuccess();
                } else {
                    doFailed(-1, "roomId not exist.");
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                doFailed(code, msg);
            }

            private void doFailed(final int code, final String msg) {
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onFailed(code, msg);
                        }
                    }
                });
            }

            private void doSuccess() {
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }
                });
            }
        });
    }

    private class ResponseEntity {
        public int errorCode;
        public String errorMessage;
        public List<RoomInfo> data;
    }

    public static class RoomInfo {
        public String roomId;
    }

    // 操作回调
    public interface ActionCallback {
        void onSuccess();

        void onFailed(int code, String msg);
    }

    // 操作回调
    public interface GetRoomListCallback {
        void onSuccess(List<String> roomIdList);

        void onFailed(int code, String msg);
    }

    public interface GetScenesRoomInfosCallback {
        void onSuccess(List<RoomListAdapter.ScenesRoomInfo> scenesRoomInfos);

        void onFailed(int code, String msg);
    }
}
