package com.tencent.qcloud.tuikit.tuigroup.classicui;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.classicui.page.GroupInfoActivity;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ClassicUIExtensionObserver extends ServiceInitializer implements ITUIExtension {
    @Override
    public void init(Context context) {
        super.init(context);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID)) {
            Object groupID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID);
            if (groupID instanceof String) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setIcon(TUIThemeManager.getAttrResId(getContext(), R.attr.group_chat_extension_title_bar_more_menu));
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), GroupInfoActivity.class);
                        intent.putExtra(TUIGroupConstants.Group.GROUP_ID, (String) groupID);
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
}
