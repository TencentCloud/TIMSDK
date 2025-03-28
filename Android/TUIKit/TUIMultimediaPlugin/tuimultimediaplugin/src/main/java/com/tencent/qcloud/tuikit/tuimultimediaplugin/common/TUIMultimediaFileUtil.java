package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.util.TypedValue;
import androidx.annotation.Nullable;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Random;

public class TUIMultimediaFileUtil {

    public static final String TAG = TUIMultimediaFileUtil.class.getSimpleName();
    public static final String ASSET_FILE_PREFIX = "file:///asset/";
    public static final String LOCAL_FILE_PREFIX = "/";
    public static final String CONTENT_FILE_PREFIX = "content:";

    public static boolean isFileExists(String path) {
        try {
            File file = new File(path);
            return file.exists() && file.isFile();
        } catch (Exception e) {
            return false;
        }
    }

    @Nullable
    public static File generateFileName(@Nullable String name, File directory) {
        if (name == null) {
            return null;
        }

        File file = new File(directory, name);

        if (file.exists()) {
            String fileName = name;
            String extension = "";
            int dotIndex = name.lastIndexOf('.');
            if (dotIndex > 0) {
                fileName = name.substring(0, dotIndex);
                extension = name.substring(dotIndex);
            }

            int index = 0;

            while (file.exists()) {
                index++;
                name = fileName + '(' + index + ')' + extension;
                file = new File(directory, name);
            }
        }

        try {
            if (!file.createNewFile()) {
                return null;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }

        return file;
    }

    public static boolean saveFileFromUri(Context context, Uri uri, String destinationPath) {
        InputStream is = null;
        BufferedOutputStream bos = null;
        try {
            is = context.getContentResolver().openInputStream(uri);
            bos = new BufferedOutputStream(new FileOutputStream(destinationPath, false));
            byte[] buf = new byte[1024];

            int actualBytes;
            while ((actualBytes = is.read(buf)) != -1) {
                bos.write(buf, 0, actualBytes);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
                if (bos != null) {
                    bos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return true;
    }

    public static boolean saveBitmap(String path, Bitmap b) {
        try {
            FileOutputStream outputStream = new FileOutputStream(path);
            BufferedOutputStream bufferOutputStream = new BufferedOutputStream(outputStream);
            b.compress(Bitmap.CompressFormat.JPEG, 100, bufferOutputStream);
            bufferOutputStream.flush();
            bufferOutputStream.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static String readTextFromFile(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }

        boolean isAssetFile = fileName.startsWith(ASSET_FILE_PREFIX);

        StringBuilder sb = new StringBuilder();
        InputStream is = null;
        BufferedReader br = null;
        try {
            if (isAssetFile) {
                is = TUIMultimediaPlugin.getAppContext().getAssets()
                        .open(fileName.substring(TUIMultimediaFileUtil.ASSET_FILE_PREFIX.length()));
            } else {
                is = new FileInputStream(fileName);
            }
            br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            String readLine;
            while ((readLine = br.readLine()) != null) {
                sb.append(readLine);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
                if (br != null) {
                    br.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return sb.toString();
    }

    public static Bitmap readBitmapFromUrl(Uri uri) {
        try {
            ContentResolver contentResolver = TUIMultimediaPlugin.getAppContext().getContentResolver();
            ParcelFileDescriptor parcelFileDescriptor = contentResolver.openFileDescriptor(uri, "r");
            FileInputStream fileInputStream = new FileInputStream(parcelFileDescriptor.getFileDescriptor());
            Bitmap bitmap = BitmapFactory.decodeStream(fileInputStream);
            fileInputStream.close();
            parcelFileDescriptor.close();
            return bitmap;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String generateFilePath(MultimediaPluginFileType fileType) {
        String fileName = "";
        String suffix = "";
        switch (fileType) {
            case RECODE_FILE:
                fileName = "multimedia_plugin_record_";
                suffix = ".mp4";
                break;
            case EDIT_FILE:
                fileName = "multimedia_plugin_edit_";
                suffix = ".mp4";
                break;
            case PICTURE_FILE:
                fileName = "multimedia_plugin_pic_";
                suffix = ".jpg";
                break;
        }

        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            File dir = new File(
                    Environment.getExternalStorageDirectory().getAbsolutePath() + File.separatorChar + TUIConfig
                            .getAppContext().getPackageName()
                            + TUIConfig.RECORD_DIR_SUFFIX);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            return dir.getAbsolutePath() + File.separatorChar + fileName + System.nanoTime() + "_" + Math
                    .abs(new Random().nextInt()) + suffix;
        } else {
            String name = System.nanoTime() + "_" + Math.abs(new Random().nextInt());
            return TUIConfig.getRecordDir() + fileName + name + suffix;
        }
    }

    public static boolean copyAssetsFile(String assetsFileName, String outputFilePath) {
        try {
            InputStream inputStream = TUIMultimediaPlugin.getAppContext().getAssets().open(assetsFileName);
            OutputStream outputStream = new FileOutputStream(outputFilePath);
            byte[] buffer = new byte[1024];
            int read;
            while ((read = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, read);
            }
            inputStream.close();
            outputStream.flush();
            outputStream.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static Bitmap decodeBitmap(String path) {
        LiteavLog.i(TAG, "decodeBitmap. path = " + path);
        if (path != null && path.startsWith(TUIMultimediaFileUtil.LOCAL_FILE_PREFIX)) {
            return decodeLocalFile(path);
        } else if (path != null && path.startsWith(TUIMultimediaResourceUtils.DRAWABLE_RESOURCE_PREFIX)) {
            return decodeDrawableRes(path);
        } else if (path != null && path.startsWith(TUIMultimediaFileUtil.ASSET_FILE_PREFIX)) {
            return decodeAssetFile(path);
        } else if (path != null && path.startsWith(TUIMultimediaFileUtil.CONTENT_FILE_PREFIX)) {
          return readBitmapFromUrl(Uri.parse(path));
        } else {
            LiteavLog.i(TAG, "decodeBitmap " + path + " is not supported path");
            return null;
        }
    }

    private static Bitmap decodeLocalFile(String localFilePath) {
        return BitmapFactory.decodeFile(localFilePath);
    }

    private static Bitmap decodeDrawableRes(String resName) {
        LiteavLog.i(TAG, "decode drawable res. resName = " + resName);
        TypedValue value = new TypedValue();
        int resId = TUIMultimediaResourceUtils.getDrawableId(resName);
        TUIMultimediaResourceUtils.getResources().openRawResource(resId, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(TUIMultimediaResourceUtils.getResources(), resId, opts);
    }

    private static Bitmap decodeAssetFile(String assetFileName) {
        LiteavLog.i("PicturePasterItemInfo", "decodeAssetFile assetFileName = " + assetFileName);
        try {
            assetFileName = assetFileName.substring(TUIMultimediaFileUtil.ASSET_FILE_PREFIX.length());
            InputStream is = TUIMultimediaPlugin.getAppContext().getAssets().open(assetFileName);
            return BitmapFactory.decodeStream(is);
        } catch (Exception e) {
            LiteavLog.e("PicturePasterItemInfo", "decode asset file error " + e.toString());
            return null;
        }
    }


    public static boolean saveBmpToFile(Bitmap bmp, File file, CompressFormat format) {
        if (null != bmp && null != file) {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            bmp.compress(format, 100, baos);
            return writeToFile(baos.toByteArray(), file);
        } else {
            LiteavLog.e("DebugUtils", "bmp or file is null");
            return false;
        }
    }

    public static boolean writeToFile(byte[] data, File file) {
        FileOutputStream fos = null;
        boolean ret = false;

        try {
            fos = new FileOutputStream(file);
            fos.write(data);
            fos.flush();
            ret = true;
        } catch (IOException var8) {
        } finally {
            closeQuietly(fos);
        }

        return ret;
    }

    private static void closeQuietly(final Closeable closeable) {
        try {
            if (closeable != null) {
                closeable.close();
            }
        } catch (IOException var2) {
        }
    }

    public enum MultimediaPluginFileType {
        RECODE_FILE,
        EDIT_FILE,
        PICTURE_FILE
    }

}
