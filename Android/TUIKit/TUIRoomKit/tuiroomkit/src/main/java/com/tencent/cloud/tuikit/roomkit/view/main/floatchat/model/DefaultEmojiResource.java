package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;

import androidx.core.content.res.ResourcesCompat;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service.IEmojiResource;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class DefaultEmojiResource implements IEmojiResource {

    private final Map<Integer, String> resource = new LinkedHashMap<>();

    public DefaultEmojiResource() {
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_0, "[TUIEmoji_Smile]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_1, "[TUIEmoji_Expect]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_2, "[TUIEmoji_Blink]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_3, "[TUIEmoji_Guffaw]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_4, "[TUIEmoji_KindSmile]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_5, "[TUIEmoji_Haha]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_6, "[TUIEmoji_Cheerful]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_7, "[TUIEmoji_Speechless]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_8, "[TUIEmoji_Amazed]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_9, "[TUIEmoji_Sorrow]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_10, "[TUIEmoji_Complacent]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_11, "[TUIEmoji_Silly]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_12, "[TUIEmoji_Lustful]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_13, "[TUIEmoji_Giggle]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_14, "[TUIEmoji_Kiss]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_15, "[TUIEmoji_Wail]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_16, "[TUIEmoji_TearsLaugh]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_17, "[TUIEmoji_Trapped]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_18, "[TUIEmoji_Mask]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_19, "[TUIEmoji_Fear]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_20, "[TUIEmoji_BareTeeth]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_21, "[TUIEmoji_FlareUp]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_22, "[TUIEmoji_Yawn]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_23, "[TUIEmoji_Tact]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_24, "[TUIEmoji_Stareyes]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_25, "[TUIEmoji_ShutUp]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_26, "[TUIEmoji_Sigh]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_27, "[TUIEmoji_Hehe]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_28, "[TUIEmoji_Silent]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_29, "[TUIEmoji_Surprised]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_30, "[TUIEmoji_Askance]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_31, "[TUIEmoji_Ok]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_32, "[TUIEmoji_Shit]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_33, "[TUIEmoji_Monster]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_34, "[TUIEmoji_Daemon]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_35, "[TUIEmoji_Rage]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_36, "[TUIEmoji_Fool]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_37, "[TUIEmoji_Pig]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_38, "[TUIEmoji_Cow]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_39, "[TUIEmoji_Ai]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_40, "[TUIEmoji_Skull]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_41, "[TUIEmoji_Bombs]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_42, "[TUIEmoji_Coffee]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_43, "[TUIEmoji_Cake]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_44, "[TUIEmoji_Beer]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_45, "[TUIEmoji_Flower]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_46, "[TUIEmoji_Watermelon]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_47, "[TUIEmoji_Rich]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_48, "[TUIEmoji_Heart]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_49, "[TUIEmoji_Moon]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_50, "[TUIEmoji_Sun]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_51, "[TUIEmoji_Star]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_52, "[TUIEmoji_RedPacket]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_53, "[TUIEmoji_Celebrate]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_54, "[TUIEmoji_Bless]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_55, "[TUIEmoji_Fortune]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_56, "[TUIEmoji_Convinced]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_57, "[TUIEmoji_Prohibit]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_58, "[TUIEmoji_666]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_59, "[TUIEmoji_857]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_60, "[TUIEmoji_Knife]");
        resource.put(R.drawable.tuiroomkit_float_chat_emoji_61, "[TUIEmoji_Like]");
    }

    public int getResId(String key) {
        for (Map.Entry<Integer, String> entry : resource.entrySet()) {
            if (TextUtils.equals(key, entry.getValue())) {
                return entry.getKey().intValue();
            }
        }
        return 0;
    }

    public List<Integer> getResIds() {
        List<Integer> list = new ArrayList<>();
        list.addAll(resource.keySet());
        return list;
    }

    public String getEncodeValue(int resId) {
        return resource.get(resId);
    }

    @Override
    public String getEncodePattern() {
        return "\\[(.*?)\\]";
    }

    @Override
    public Drawable getDrawable(Context context, int resId, Rect bounds) {
        Drawable drawable = ResourcesCompat.getDrawable(context.getResources(), resId, null);
        if (drawable != null && bounds != null) {
            drawable.setBounds(bounds.left, bounds.top, bounds.right, bounds.bottom);
        }
        return drawable;
    }
}
