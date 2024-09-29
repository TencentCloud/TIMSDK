package com.tencent.qcloud.tuikit.tuichat.config;

import android.graphics.drawable.Drawable;
import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;

import java.util.List;

public class ShortcutMenuConfig {

    private ShortcutMenuConfig() {}

    private static final class TUIChatShortcutMenuConfigHolder {
        private static final ShortcutMenuConfig INSTANCE = new ShortcutMenuConfig();
    }

    static ShortcutMenuConfig getInstance() {
        return TUIChatShortcutMenuConfigHolder.INSTANCE;
    }

    private ChatShortcutViewDataSource shortcutViewDataSource;

    public static void setShortcutViewDataSource(ChatShortcutViewDataSource shortcutViewDataSource) {
        getInstance().shortcutViewDataSource = shortcutViewDataSource;
    }

    public static ChatShortcutViewDataSource getShortcutViewDataSource() {
        return getInstance().shortcutViewDataSource;
    }

    public interface ChatShortcutViewDataSource {
        List<TUIChatShortcutMenuData> itemsInShortcutViewOfInfo(ChatInfo chatInfo);

        Drawable shortcutViewBackgroundOfInfo(ChatInfo chatInfo);
    }

    public static class  TUIChatShortcutMenuData {
        public static final int UNDEFINED = -1;
        public String text;
        public int textColor = UNDEFINED;
        public Drawable background;
        public int textFontSize = UNDEFINED;
        public View.OnClickListener onClickListener;
    }
}
