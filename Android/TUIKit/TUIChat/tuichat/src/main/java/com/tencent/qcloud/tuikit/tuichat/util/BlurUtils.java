package com.tencent.qcloud.tuikit.tuichat.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicBlur;

import androidx.annotation.RequiresApi;

public class BlurUtils {

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    public static Bitmap fastBlur(Context context, Bitmap bitmap) {
        if (context == null || bitmap ==  null) {
            return null;
        }
        RenderScript renderScript = RenderScript.create(context);
        ScriptIntrinsicBlur scriptIntrinsicBlur = ScriptIntrinsicBlur.create(renderScript, Element.U8_4(renderScript));
        Bitmap outBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Allocation in = Allocation.createFromBitmap(renderScript, bitmap);
        Allocation out = Allocation.createFromBitmap(renderScript, outBitmap);
        scriptIntrinsicBlur.setRadius(25);
        scriptIntrinsicBlur.setInput(in);
        scriptIntrinsicBlur.forEach(out);
        out.copyTo(outBitmap);
        scriptIntrinsicBlur.destroy();
        bitmap.recycle();
        return outBitmap;
    }
}
