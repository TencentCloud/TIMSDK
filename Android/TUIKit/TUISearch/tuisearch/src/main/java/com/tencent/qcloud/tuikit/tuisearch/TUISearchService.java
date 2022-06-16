package com.tencent.qcloud.tuikit.tuisearch;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;

import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.HashMap;
import java.util.Map;

public class TUISearchService extends ServiceInitializer implements ITUISearchService {
    public static final String TAG = TUISearchService.class.getSimpleName();

    @Override
    public void init(Context context) {
        initExtension();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIConversation.EXTENSION_SEARCH, this);
    }

    @Override
    public Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param) {
        Map<String, Object> result = new HashMap<>();
        if (param != null) {
            Context context = (Context) param.get(TUIConstants.TUIConversation.CONTEXT);
            if (context != null) {
                View searchView = LayoutInflater.from(context).inflate(R.layout.search_bar_layout, null);
                searchView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUICore.startActivity("SearchMainActivity", new Bundle());
                    }
                });
                result.put(TUIConstants.TUIConversation.SEARCH_VIEW, searchView);
            }
        }
        return result;
    }
}
