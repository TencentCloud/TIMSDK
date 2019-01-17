package com.tencent.qcloud.uikit.common.widget.gatherimage;

import android.graphics.Bitmap;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;


public class BitmapUtils {

    /**
     * @param outFile 图片的目录路径
     * @param bitmap
     * @return
     */
    public static File storeBitmap(File outFile, Bitmap bitmap) {
        // 检测是否达到存放文件的上限
        if (!outFile.exists() || outFile.isDirectory()) {
            outFile.getParentFile().mkdirs();
        }
        FileOutputStream fOut = null;
        try {
            outFile.deleteOnExit();
            outFile.createNewFile();
            fOut = new FileOutputStream(outFile);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
            fOut.flush();
        } catch (IOException e1) {
            outFile.deleteOnExit();
        } finally {
            if (null != fOut) {
                try {
                    fOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    outFile.deleteOnExit();
                }
            }
        }
        return outFile;
    }
}
