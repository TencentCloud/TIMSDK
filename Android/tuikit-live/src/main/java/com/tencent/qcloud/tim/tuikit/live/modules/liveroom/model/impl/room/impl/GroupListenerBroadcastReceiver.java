package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room.impl;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TRTCLogger;

import java.util.List;
import java.util.Map;

public class GroupListenerBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = GroupListenerBroadcastReceiver.class.getName();
    private V2TIMGroupListener mV2TIMGroupListener;
    private Gson               mGson;

    public GroupListenerBroadcastReceiver(V2TIMGroupListener v2TIMGroupListener) {
        mV2TIMGroupListener = v2TIMGroupListener;
        mGson = new Gson();
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null
                || intent.getAction() == null
                || !intent.getAction().equals(GroupListenerConstants.ACTION)) {
            return;
        }
        String method = intent.getStringExtra(GroupListenerConstants.KEY_METHOD);
        TRTCLogger.d(TAG, "method " + method);
        switch (method) {
            case GroupListenerConstants.METHOD_ON_MEMBER_ENTER:
                onMemberEnter(intent);
                break;
            case GroupListenerConstants.METHOD_ON_MEMBER_LEAVE:
                onMemberLeave(intent);
                break;
            case GroupListenerConstants.METHOD_ON_GROUP_DISMISSED:
                onGroupDismissed(intent);
                break;
            case GroupListenerConstants.METHOD_ON_GROUP_RECYCLED:
                onGroupRecycled(intent);
                break;
            case GroupListenerConstants.METHOD_ON_REV_CUSTOM_DATA:
                onReceiveRESTCustomData(intent);
                break;
            case GroupListenerConstants.METHOD_ON_GROUP_INFO_CHANGED:
                onGroupInfoChanged(intent);
                break;
            case GroupListenerConstants.METHOD_ON_GROUP_ATTRS_CHANGED:
                onGroupAttributeChanged(intent);
                break;
            default:
                //不支持的method
                break;
        }
    }

    private void onMemberEnter(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_MEMBER);
        try {
            List<V2TIMGroupMemberInfo> list = mGson.fromJson(json, new TypeToken<List<V2TIMGroupMemberInfo>>() {
            }.getType());
            mV2TIMGroupListener.onMemberEnter(groupId, list);
        } catch (Exception e) {

        }
    }

    private void onMemberLeave(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_MEMBER);
        try {
            V2TIMGroupMemberInfo info = mGson.fromJson(json, V2TIMGroupMemberInfo.class);
            mV2TIMGroupListener.onMemberLeave(groupId, info);
        } catch (Exception e) {

        }
    }

    private void onGroupDismissed(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_OP_USER);
        try {
            V2TIMGroupMemberInfo info = mGson.fromJson(json, V2TIMGroupMemberInfo.class);
            mV2TIMGroupListener.onGroupDismissed(groupId, info);
        } catch (Exception e) {

        }
    }

    private void onGroupRecycled(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_OP_USER);
        try {
            V2TIMGroupMemberInfo info = mGson.fromJson(json, V2TIMGroupMemberInfo.class);
            mV2TIMGroupListener.onGroupRecycled(groupId, info);
        } catch (Exception e) {

        }
    }

    private void onReceiveRESTCustomData(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        byte[] customData    = intent.getByteArrayExtra(GroupListenerConstants.KEY_CUSTOM_DATA);
        mV2TIMGroupListener.onReceiveRESTCustomData(groupId, customData);
    }

    private void onGroupInfoChanged(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_INFO);
        try {
            List<V2TIMGroupChangeInfo> list = mGson.fromJson(json, new TypeToken<List<V2TIMGroupChangeInfo>>() {
            }.getType());
            mV2TIMGroupListener.onGroupInfoChanged(groupId, list);
        } catch (Exception e) {
        }
    }

    private void onGroupAttributeChanged(Intent intent) {
        String groupId = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ID);
        String json    = intent.getStringExtra(GroupListenerConstants.KEY_GROUP_ATTR);
        try {
            Map<String, String> map = mGson.fromJson(json, Map.class);
            mV2TIMGroupListener.onGroupAttributeChanged(groupId, map);
        } catch (Exception e) {
        }
    }
}
