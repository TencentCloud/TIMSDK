package com.tencent.qcloud.tuikit.tuisearch;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUISearchService extends ITUIExtension {
    /**
     * 提供搜索框 View
     * 唤起方法 ：TUICore.getExtensionInfo(TUIConstants.TUIConversation.EXTENSION_SEARCH, param);
     * @param key TUIConstants.TUIConversation.EXTENSION_SEARCH
     * @param param {TUIConstants.TUIConversation.CONTEXT : Context}
     * @return {TUIConstants.TUIConversation.SEARCH_VIEW : View}
     * 
     * 
     * Provide a search box
     * Call method: TUICore.getExtensionInfo(TUIConstants.TUIConversation.EXTENSION_SEARCH, param);
     * @param key TUIConstants.TUIConversation.EXTENSION_SEARCH
     * @param param {TUIConstants.TUIConversation.CONTEXT : Context}
     * @return {TUIConstants.TUIConversation.SEARCH_VIEW : View}
     */
    @Override
    Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param);
}
