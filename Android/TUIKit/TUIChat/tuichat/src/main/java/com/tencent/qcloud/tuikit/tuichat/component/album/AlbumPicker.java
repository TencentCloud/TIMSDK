package com.tencent.qcloud.tuikit.tuichat.component.album;

import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuikit.tuichat.interfaces.AlbumPickerListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IAlbumPicker;

public class AlbumPicker {
    private static final String TAG = AlbumPicker.class.getSimpleName();
    private static final AlbumPicker INSTANCE = new AlbumPicker();
    private final IAlbumPicker defaultAlbumPicker = new SystemAlbumPickerImpl();
    private IAlbumPicker advancedAlbumPicker;

    private AlbumPicker() {}

    public static void registerAdvancedAlbumPicker(IAlbumPicker albumPicker) {
        INSTANCE.advancedAlbumPicker = albumPicker;
    }

    public static void pickMedia(ActivityResultCaller activityResultCaller, AlbumPickerListener listener) {
        IAlbumPicker albumPicker = INSTANCE.defaultAlbumPicker;
        if (INSTANCE.advancedAlbumPicker != null) {
            albumPicker = INSTANCE.advancedAlbumPicker;
            //albumPicker.setConfig("{\"theme_color\": \"#FFFF0000\"}");
        }
        albumPicker.pickMedia(activityResultCaller, listener);
    }
}
