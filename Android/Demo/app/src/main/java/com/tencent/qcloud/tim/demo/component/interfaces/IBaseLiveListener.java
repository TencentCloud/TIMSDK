package com.tencent.qcloud.tim.demo.component.interfaces;

import android.content.Intent;

import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tim.demo.bean.OfflineMessageBean;

public interface IBaseLiveListener {
    void handleOfflinePushCall(Intent intent);
    void handleOfflinePushCall(OfflineMessageBean bean);
    void redirectCall(OfflineMessageBean bean);
    Fragment getSceneFragment();
    void refreshUserInfo();
}
