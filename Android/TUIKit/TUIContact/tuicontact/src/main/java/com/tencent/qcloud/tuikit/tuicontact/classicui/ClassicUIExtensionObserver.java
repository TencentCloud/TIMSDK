package com.tencent.qcloud.tuikit.tuicontact.classicui;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.classicui.pages.FriendProfileActivity;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerID("TUIContactClassicUIExtensionObserver")
@TUIInitializerDependency("TUIContact")
public class ClassicUIExtensionObserver implements TUIInitializer, ITUIExtension {
    @Override
    public void init(Context context) {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID)) {
            Object userID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID);
            if (userID instanceof String) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setIcon(TUIThemeManager.getAttrResId(getAppContext(), R.attr.contact_chat_extension_title_bar_more_menu));
                extensionInfo.setWeight(100);
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), FriendProfileActivity.class);
                        intent.putExtra(TUIConstants.TUIChat.CHAT_ID, (String) userID);
                        intent.putExtra(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, (String) param.get(TUIConstants.TUIChat.CHAT_BACKGROUND_URI));
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        getAppContext().startActivity(intent);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        }
        return null;
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
