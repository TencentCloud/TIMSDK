package com.tencent.cloud.tuikit.roomkit.common.utils;

import static com.tencent.imsdk.BaseConstants.ERR_SUCC;

import android.util.Log;

import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class FetchRoomId {
    private static final String TAG = "FetchRoomId";

    private static final int ROOM_ID_LENGTH = 6;

    public interface GetRoomIdCallback {
        void onGetRoomId(String roomId);
    }

    public static void fetch(GetRoomIdCallback callback) {
        String roomId = generateRandomRoomId(ROOM_ID_LENGTH);
        isRoomIdExisted(roomId, new TUICallback() {
            @Override
            public void onSuccess() {
                fetch(callback);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                if (callback != null) {
                    callback.onGetRoomId(roomId);
                }
            }
        });
    }

    private static String generateRandomRoomId(int numberOfDigits) {
        Random random = new Random();
        int minNumber = (int) Math.pow(10, numberOfDigits - 1);
        int maxNumber = (int) Math.pow(10, numberOfDigits) - 1;
        int randomNumber = random.nextInt(maxNumber - minNumber) + minNumber;
        String roomId = randomNumber + "";
        Log.d(TAG, "generateRandomRoomId : " + roomId);
        return roomId;
    }

    private static void isRoomIdExisted(String roomId, TUICallback callback) {
        List<String> idList = new ArrayList<>(1);
        idList.add(roomId);
        Log.d(TAG, "getGroupsInfo roomId=" + roomId);
        V2TIMManager.getGroupManager().getGroupsInfo(idList, new V2TIMValueCallback<List<V2TIMGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMGroupInfoResult> v2TIMGroupInfoResults) {
                Log.d(TAG, "getGroupsInfo onSuccess");
                if (v2TIMGroupInfoResults == null || v2TIMGroupInfoResults.isEmpty()) {
                    callback.onError(0, "result is empty");
                    return;
                }
                if (v2TIMGroupInfoResults.get(0).getResultCode() == ERR_SUCC) {
                    callback.onSuccess();
                    return;
                }
                callback.onError(v2TIMGroupInfoResults.get(0).getResultCode(),
                        v2TIMGroupInfoResults.get(0).getResultMessage());
            }

            @Override
            public void onError(int code, String desc) {
                Log.d(TAG, "getGroupsInfo onError code=" + code + " desc=" + desc);
                callback.onError(code, desc);
            }
        });
    }
}
