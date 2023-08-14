package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.view.activity.PrepareActivity;
import com.tencent.cloud.tuikit.roomkit.view.component.PrepareView;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;

import java.util.Locale;

public class PrepareViewModel {
    private Context       mContext;
    private RoomStore     mRoomStore;
    private RoomInfo      mRoomInfo;

    public PrepareViewModel(Context context, PrepareView prepareView) {
        mContext = context;
        initRoomStore();
    }

    public UserModel getUserModel() {
        return mRoomStore.userModel;
    }

    public void changeLanguage() {
        boolean isEnglish = Locale.ENGLISH.equals(TUIThemeManager.getInstance().getLocale(mContext));
        String language = isEnglish ? Locale.CHINESE.getLanguage() : Locale.ENGLISH.getLanguage();
        TUIThemeManager.getInstance().changeLanguage(mContext, language);
        Intent intent = new Intent(mContext, PrepareActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        IntentUtils.safeStartActivity(mContext, intent);
    }


    public void initRoomStore() {
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(mContext);
        mRoomStore = engineManager.getRoomStore();
        mRoomInfo = mRoomStore.roomInfo;
    }



}
