package com.tencent.qcloud.tuikit.tuichat.util;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;

import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.ImageVideoScanPresenter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtil {
    private static final String TAG = ImageVideoScanPresenter.class.getSimpleName();
    //在picture目录下新建一个自己文件夹
    public static final String rootPath =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) + "/im";


    //保存文件到指定路径
    public static boolean saveImageToGallery(Context context, Bitmap bmp) {
        if (bmp == null) {
            TUIChatLog.e(TAG, "src is null");
            return false;
        }

        // 首先保存图片
        File appDir = new File(rootPath);
        if (!appDir.exists()) {
            appDir.mkdir();
        }
        String fileName = System.currentTimeMillis() + ".jpg";
        File file = new File(appDir, fileName);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            //通过io流的方式来压缩保存图片
            boolean isSuccess = bmp.compress(Bitmap.CompressFormat.JPEG, 60, fos);
            fos.flush();
            fos.close();

            //把文件插入到系统图库
            MediaStore.Images.Media.insertImage(context.getContentResolver(), file.getAbsolutePath(), fileName, null);

            //保存图片后发送广播通知更新数据库
            Uri uri = Uri.fromFile(file);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            if (isSuccess) {
                return true;
            } else {
                return false;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public static void saveFileToAlbum(Context context, String srcString) {
        if (TextUtils.isEmpty(srcString)) {
            TUIChatLog.e(TAG, "srcString is null");
            return;
        }
        File srcFile = new File(srcString);
        if (!srcFile.exists()) {
            TUIChatLog.e(TAG, "srcFile is null");
            return;
        }
        //如果root文件夹没有需要新建一个
        createDirIfNotExist();

        //拷贝文件到picture目录下
        File destFile = new File(rootPath + "/" + srcFile.getName());
        copyFile(srcFile, destFile);

        //将该文件扫描到相册
        MediaScannerConnection.scanFile(context, new String[] { destFile.getPath() }, null, null);
    }

    public static void createDirIfNotExist() {
        File file = new File(rootPath);
        if (!file.exists()) {
            try {
                file.mkdirs();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void copyFile(File src, File dest) {
        if (!src.getAbsolutePath().equals(dest.getAbsolutePath())) {
            try {
                InputStream in = new FileInputStream(src);
                FileOutputStream out = new FileOutputStream(dest);
                byte[] buf = new byte[1024];

                int len;
                while ((len = in.read(buf)) >= 0) {
                    out.write(buf, 0, len);
                }
                in.close();
                out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}

