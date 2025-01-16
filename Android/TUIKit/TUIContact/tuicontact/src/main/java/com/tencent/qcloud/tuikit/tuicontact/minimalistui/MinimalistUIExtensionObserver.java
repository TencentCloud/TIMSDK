package com.tencent.qcloud.tuikit.tuicontact.minimalistui;

import static com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants.GROUP_PROFILE_BEAN;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import androidx.activity.result.ActivityResultCaller;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentActivity;

import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.AddMoreDetailMinimalistDialogFragment;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.ManageGroupMinimalistActivity;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerID("TUIContactMinimalistUIExtensionObserver")
@TUIInitializerDependency("TUIContact")
public class MinimalistUIExtensionObserver implements TUIInitializer, ITUIExtension, ITUIService {
    @Override
    public void init(Context context) {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.EXTENSION_ID, this);
        TUICore.registerService(TUIConstants.TUIContact.MINIMALIST_SERVICE_NAME, this);
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        if (TextUtils.equals(method, TUIConstants.TUIContact.Method.AddFriend.METHOD_NAME)) {
            String userID = (String) param.get(TUIConstants.TUIContact.Method.AddFriend.USER_ID);
            FragmentActivity activity = (FragmentActivity) param.get(TUIConstants.TUIContact.Method.AddFriend.ACTIVITY);
            AddMoreDetailMinimalistDialogFragment dialogFragment = new AddMoreDetailMinimalistDialogFragment();
            dialogFragment.setUserID(userID);
            dialogFragment.show(activity.getSupportFragmentManager(), "AddMoreDetailMinimalistDialogFragment");
        }
        return null;
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.EXTENSION_ID)) {
            GroupProfileBean groupProfileBean =
                (GroupProfileBean) param.get(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.GROUP_PROFILE_BEAN);
            int viewType = (int) param.get(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.VIEW_TYPE);
            if (viewType != TUIConstants.TUIChat.VIEW_TYPE_CLASSIC && groupProfileBean.canManage()) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setText(getAppContext().getString(R.string.group_manager));
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), ManageGroupMinimalistActivity.class);
                        intent.putExtra(GROUP_PROFILE_BEAN, groupProfileBean);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        getAppContext().startActivity(intent);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.EXTENSION_ID)) {
            GroupProfileBean groupProfileBean = (GroupProfileBean) param.get(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.GROUP_PROFILE_BEAN);
            int viewType = (int) param.get(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.VIEW_TYPE);
            ActivityResultCaller caller = (ActivityResultCaller) param.get(TUIConstants.TUIChat.Extension.GroupProfileBottomItemExtension.CALLER);
            if (viewType != TUIConstants.TUIChat.VIEW_TYPE_CLASSIC && groupProfileBean.isOwner()) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setText(getAppContext().getString(R.string.group_transfer_group_owner));
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        GroupMemberListProxy proxy = new GroupMemberListProxy();
                        proxy.transferGroupOwner(caller, groupProfileBean);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        }
        return null;
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.EXTENSION_ID)) {
            int viewType = (int) param.get(TUIConstants.TUIChat.Extension.GroupProfileSettingsItemExtension.VIEW_TYPE);
            if (viewType == TUIConstants.TUIChat.VIEW_TYPE_CLASSIC) {
                return false;
            }
            GroupProfileBean groupProfileBean = (GroupProfileBean) param.get(TUIConstants.TUIChat.Extension.GroupProfileMemberListExtension.GROUP_PROFILE_BEAN);
            GroupMemberListProxy proxy = new GroupMemberListProxy();
            proxy.raiseExtension(parentView, groupProfileBean);
        }
        return true;
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
