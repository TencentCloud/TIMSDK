package com.tencent.qcloud.tuikit.tuichat.util;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.webkit.MimeTypeMap;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtil {
    private static final String TAG = FileUtil.class.getSimpleName();

    public static boolean saveVideoToGallery(Context context, String videoPath) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return saveVideoToGalleryByMediaStore(context, videoPath);
        } else {
            return saveVideoToGalleryByFile(context, videoPath);
        }
    }

    public static boolean saveImageToGallery(Context context, String videoPath) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return saveImageToGalleryByMediaStore(context, videoPath);
        } else {
            return saveImageToGalleryByFile(context, videoPath);
        }
    }


    public static boolean saveVideoToGalleryByMediaStore(Context context, String videoPath) {
        if (TextUtils.isEmpty(videoPath) || context == null) {
            TUIChatLog.e(TAG, "param invalid");
            return false;
        }

        String videoFileName = getFileName(videoPath);
        String videoMimeType = getMimeType(videoPath);
        final long now = System.currentTimeMillis();
        ContentValues videoImageValues = new ContentValues();
        videoImageValues.put(MediaStore.Video.Media.DATE_ADDED, now / 1000);
        videoImageValues.put(MediaStore.Video.Media.DATE_MODIFIED, now / 1000);
        videoImageValues.put(MediaStore.Video.Media.DISPLAY_NAME,videoFileName);
        videoImageValues.put(MediaStore.Video.Media.MIME_TYPE, videoMimeType);
        // insert to gallery
        Uri videoExternalContentUri = MediaStore.Video.Media
                .getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
        videoImageValues.put(MediaStore.Video.Media.IS_PENDING, 1);
        videoImageValues.put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/" + getAppName(context) + "/");

        ContentResolver resolver = context.getContentResolver();
        Uri uri;
        try {
            uri = resolver.insert(videoExternalContentUri, videoImageValues);
        } catch (IllegalArgumentException e) {
            TUIChatLog.e(TAG, "saveVideoToGalleryByMediaStore failed, " + e.getMessage());
            return false;
        }
        if (uri == null) {
            return false;
        }
        // got permission, write file to public media dir
        boolean saveSuccess = saveFileToUri(resolver, uri, videoPath);
        if (!saveSuccess) {
            resolver.delete(uri, null, null);
            return false;
        }
        videoImageValues.clear();
        videoImageValues.put(MediaStore.Images.Media.IS_PENDING, 0);
        resolver.update(uri, videoImageValues, null, null);

        // update system gallery
        MediaScannerConnection.scanFile(context, new String[]{uri.toString()}, new String[]{videoMimeType}, null);
        return true;
    }

    public static boolean saveVideoToGalleryByFile(Context context, String videoPath) {
        String videoDirPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES) + "/" + getAppName(context) + "/";
        File dir = new File(videoDirPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String videoName = getFileName(videoPath);
        String outputPath = videoDirPath + videoName;
        File outputFile = new File(outputPath);
        if (outputFile.exists()) {
            outputFile.delete();
        }
        boolean isSuccess = saveFileFromPath(outputFile, videoPath);
        if (!isSuccess) {
            return false;
        }
        String videoMimeType = getMimeType(videoPath);
        MediaScannerConnection.scanFile(context, new String[]{outputPath}, new String[]{videoMimeType}, null);
        return true;
    }

    public static boolean saveImageToGalleryByMediaStore(Context context, String imagePath) {
        if (TextUtils.isEmpty(imagePath) || context == null) {
            TUIChatLog.e(TAG, "param invalid");
            return false;
        }

        String imageFileName = getFileName(imagePath);
        String imageMimeType = getMimeType(imagePath);
        final long now = System.currentTimeMillis();

        ContentValues newImageValues = new ContentValues();
        newImageValues.put(MediaStore.Images.Media.DATE_ADDED, now / 1000);
        newImageValues.put(MediaStore.Images.Media.DATE_MODIFIED, now / 1000);
        newImageValues.put(MediaStore.Images.Media.DISPLAY_NAME,imageFileName);
        newImageValues.put(MediaStore.Images.Media.MIME_TYPE, imageMimeType);
        // insert to gallery
        Uri imageExternalContentUri = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
        newImageValues.put(MediaStore.Images.Media.IS_PENDING, 1);
        newImageValues.put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/" + getAppName(context) + "/");

        ContentResolver resolver = context.getContentResolver();
        Uri uri;
        try {
            uri = resolver.insert(imageExternalContentUri, newImageValues);
        } catch (IllegalArgumentException e) {
            TUIChatLog.e(TAG, "saveImageToGalleryByMediaStore failed, " + e.getMessage());
            return false;
        }
        if (uri == null) {
            return false;
        }
        // got permission, write file to public media dir
        boolean saveSuccess = saveFileToUri(resolver, uri, imagePath);
        if (!saveSuccess) {
            resolver.delete(uri, null, null);
            return false;
        }
        newImageValues.clear();
        newImageValues.put(MediaStore.Images.Media.IS_PENDING, 0);
        resolver.update(uri, newImageValues, null, null);

        // update system gallery
        MediaScannerConnection.scanFile(context, new String[]{uri.toString()}, new String[]{imageMimeType}, null);
        return true;
    }

    public static boolean saveImageToGalleryByFile(Context context, String imagePath) {
        String imageDirPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) + "/" + getAppName(context) + "/";
        File dir = new File(imageDirPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String imageName = getFileName(imagePath);
        String outputPath = imageDirPath + imageName;
        if (!outputPath.endsWith(".jpg")) {
            outputPath += ".jpg";
        }
        File outputFile = new File(outputPath);
        if (outputFile.exists()) {
            outputFile.delete();
        }
        boolean isSuccess = saveFileFromPath(outputFile, imagePath);
        if (!isSuccess) {
            return false;
        }
        String imageMimeType = getMimeType(imagePath);
        MediaScannerConnection.scanFile(context, new String[]{outputPath}, new String[]{imageMimeType}, null);
        return true;
    }

    public static String getMimeType(String filePath) {
        String fileExtension = com.tencent.qcloud.tuicore.util.FileUtil.getFileExtensionFromUrl(filePath);
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
    }

    public static String getFileName(String path) {
        int filenamePos = path.lastIndexOf('/');
        return 0 <= filenamePos ? path.substring(filenamePos + 1) : path;
    }

    public static boolean saveFileToUri(ContentResolver contentResolver, Uri destinationUri, String srcPath) {
        InputStream is = null;
        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(contentResolver.openOutputStream(destinationUri));
            is = new FileInputStream(srcPath);
            byte[] buf = new byte[1024];

            int actualBytes;
            while ((actualBytes = is.read(buf)) != -1) {
                bos.write(buf, 0, actualBytes);
            }
        } catch (IOException e) {
            return false;
        } finally {
            try {
                if (is != null) is.close();
                if (bos != null) bos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return true;
    }

    public static boolean saveFileFromPath(File desFile, String srcFilePath) {
        InputStream is = null;
        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(new FileOutputStream(desFile));
            is = new FileInputStream(srcFilePath);
            byte[] buf = new byte[1024];

            int actualBytes;
            while ((actualBytes = is.read(buf)) != -1) {
                bos.write(buf, 0, actualBytes);
            }
        } catch (IOException e) {
            return false;
        } finally {
            try {
                if (is != null) is.close();
                if (bos != null) bos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return true;
    }

    private static String getAppName(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        return String.valueOf(context.getPackageManager().getApplicationLabel(applicationInfo));
    }

}

