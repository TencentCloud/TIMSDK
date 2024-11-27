package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.graphics.Bitmap;
import com.tencent.ugc.TXVideoEditConstants.TXRect;

public class TUIMultimediaPasterInfo {

    public Bitmap image;
    public TXRect frame;
    public PasterType pasterType;

    public enum PasterType {
        SUBTITLE_PASTER,
        STATIC_PICTURE_PASTER
    }
}
