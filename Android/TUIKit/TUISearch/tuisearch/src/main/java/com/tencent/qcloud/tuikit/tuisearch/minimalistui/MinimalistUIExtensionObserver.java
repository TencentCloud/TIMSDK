package com.tencent.qcloud.tuikit.tuisearch.minimalistui;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.tuisearch.R;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency({"TIMCommon"})
@TUIInitializerID("TUISearchMinimalistUIExtensionObserver")
public class MinimalistUIExtensionObserver implements TUIInitializer, ITUIExtension {
    @Override
    public void init(Context context) {
        TUICore.registerExtension(TUIConstants.TUIConversation.Extension.ConversationListHeader.MINIMALIST_EXTENSION_ID, this);
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIConversation.Extension.ConversationListHeader.MINIMALIST_EXTENSION_ID)) {
            ViewGroup viewGroup = null;
            if (parentView instanceof ViewGroup) {
                viewGroup = (ViewGroup) parentView;
            }
            if (viewGroup == null) {
                return false;
            }
            View searchView = LayoutInflater.from(getAppContext()).inflate(R.layout.minimalist_search_view_layout, null);
            viewGroup.removeAllViews();
            searchView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TUICore.startActivity("SearchMainMinimalistActivity", null);
                }
            });
            viewGroup.addView(searchView);
            return true;
        }

        return false;
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        return null;
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
