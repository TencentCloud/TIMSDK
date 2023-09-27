package com.tencent.qcloud.tuikit.tuisearch.classicui;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.tuisearch.R;
import java.util.List;
import java.util.Map;

public class ClassicUIExtensionObserver extends ServiceInitializer implements ITUIExtension {
    @Override
    public void init(Context context) {
        super.init(context);
        TUICore.registerExtension(TUIConstants.TUIConversation.Extension.ConversationListHeader.CLASSIC_EXTENSION_ID, this);
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIConversation.Extension.ConversationListHeader.CLASSIC_EXTENSION_ID)) {
            ViewGroup viewGroup = null;
            if (parentView instanceof ViewGroup) {
                viewGroup = (ViewGroup) parentView;
            }
            if (viewGroup == null) {
                return false;
            }
            View searchView = LayoutInflater.from(getAppContext()).inflate(R.layout.search_bar_layout, null);
            viewGroup.setVisibility(View.VISIBLE);
            viewGroup.removeAllViews();
            searchView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TUICore.startActivity("SearchMainActivity", null);
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

    private <T> T getOrDefault(Map map, Object key, T defaultValue) {
        if (map == null || map.isEmpty()) {
            return defaultValue;
        }
        Object object = map.get(key);
        try {
            if (object != null) {
                return (T) object;
            }
        } catch (ClassCastException e) {
            return defaultValue;
        }
        return defaultValue;
    }
}
