package com.tencent.qcloud.tuikit.tuiconversation.component.face;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;


public class FaceManager {

    private static String[] emojiFilters = null;
    private static String[] emojiFilters_values = null;

    public static String[] getEmojiFiltersValues(){
        if (emojiFilters_values == null) {
            Context context = TUIConversationService.getAppContext();
            emojiFilters_values = context.getResources().getStringArray(R.array.emoji_filter_value);
        }
        return emojiFilters_values;
    }

    public static String[] getEmojiFilters(){
        if (emojiFilters == null) {
            Context context = TUIConversationService.getAppContext();
            emojiFilters = context.getResources().getStringArray(R.array.emoji_filter_key);
        }
        return emojiFilters;
    }
}
