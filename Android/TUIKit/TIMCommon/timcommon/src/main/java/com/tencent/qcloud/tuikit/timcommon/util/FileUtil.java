package com.tencent.qcloud.tuikit.timcommon.util;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.R;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;
import java.util.Random;

public class FileUtil {
    public static final String DOCUMENTS_DIR = "documents";

    public static final String FILE_PROVIDER_AUTH = ".timcommon.fileprovider";

    public static final int SIZETYPE_B = 1;
    public static final int SIZETYPE_KB = 2;
    public static final int SIZETYPE_MB = 3;
    public static final int SIZETYPE_GB = 4;

    public static boolean deleteFile(String path) {
        if (TextUtils.isEmpty(path)) {
            return false;
        }
        boolean result = false;
        File file = new File(path);
        if (file.exists()) {
            result = file.delete();
        }
        return result;
    }

    public static String getPathFromUri(Uri uri) {
        String path = "";
        try {
            int sdkVersion = Build.VERSION.SDK_INT;
            if (sdkVersion >= 19) {
                path = getPathByCopyFile(TUILogin.getAppContext(), uri);
            } else {
                path = getRealFilePath(uri);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (path == null) {
            path = "";
        }
        return path;
    }

    public static String getRealFilePath(Uri uri) {
        if (null == uri) {
            return null;
        }
        final String scheme = uri.getScheme();
        String data = null;
        if (scheme == null) {
            data = uri.getPath();
        } else if (ContentResolver.SCHEME_FILE.equals(scheme)) {
            data = uri.getPath();
        } else if (ContentResolver.SCHEME_CONTENT.equals(scheme)) {
            Cursor cursor = TUILogin.getAppContext().getContentResolver().query(uri, new String[] {MediaStore.Images.ImageColumns.DATA}, null, null, null);
            if (null != cursor) {
                if (cursor.moveToFirst()) {
                    int index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
                    if (index > -1) {
                        data = cursor.getString(index);
                    }
                }
                cursor.close();
            }
        }
        return data;
    }

    public static Uri getUriFromPath(String path) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                return FileProvider.getUriForFile(
                    TUIConfig.getAppContext(), TUIConfig.getAppContext().getApplicationInfo().packageName + FILE_PROVIDER_AUTH, new File(path));
            } else {
                return Uri.fromFile(new File(path));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     *
     * Get file path from Uri specially designed for Android4.4 and above
     */
    public static String getPath(final Context context, final Uri uri) {
        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                } else {
                    return getPathByCopyFile(context, uri);
                }
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {
                final String id = DocumentsContract.getDocumentId(uri);
                if (id.startsWith("raw:")) {
                    final String path = id.replaceFirst("raw:", "");
                    return path;
                }
                String[] contentUriPrefixesToTry =
                    new String[] {"content://downloads/public_downloads", "content://downloads/my_downloads", "content://downloads/all_downloads"};

                for (String contentUriPrefix : contentUriPrefixesToTry) {
                    Uri contentUri = ContentUris.withAppendedId(Uri.parse(contentUriPrefix), Long.parseLong(id));
                    try {
                        String path = getDataColumn(context, contentUri, null, null);
                        if (path != null && Build.VERSION.SDK_INT < 29) {
                            return path;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                
                // On some android8+ mobile phones, the path cannot be obtained, so the new file name is obtained by copying, and then the file is sent out
                return getPathByCopyFile(context, uri);
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[] {split[1]};

                String path = getDataColumn(context, contentUri, selection, selectionArgs);
                if (TextUtils.isEmpty(path) || Build.VERSION.SDK_INT >= 29) {
                    path = getPathByCopyFile(context, uri);
                }
                return path;
            }
        }
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {
            String path = getDataColumn(context, uri, null, null);
            if (TextUtils.isEmpty(path) || Build.VERSION.SDK_INT >= 29) {
                
                path = getPathByCopyFile(context, uri);
            }
            return path;
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }

        return null;
    }

    private static String getPathByCopyFile(Context context, Uri uri) {
        String fileName = getFileName(context, uri);
        File cacheDir = getDocumentCacheDir(context);
        File file = generateFileName(fileName, cacheDir);
        String destinationPath = null;
        if (file != null) {
            destinationPath = file.getAbsolutePath();
            boolean saveSuccess = saveFileFromUri(context, uri, destinationPath);
            if (!saveSuccess) {
                file.delete();
                return null;
            }
        }

        return destinationPath;
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

    public static String getFileName(@NonNull Context context, Uri uri) {
        String mimeType = context.getContentResolver().getType(uri);
        String filename = null;

        if (mimeType == null) {
            filename = getName(uri.toString());
        } else {
            Cursor returnCursor = context.getContentResolver().query(uri, null, null, null, null);
            if (returnCursor != null) {
                int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                returnCursor.moveToFirst();
                filename = returnCursor.getString(nameIndex);
                returnCursor.close();
            }
        }

        return filename;
    }

    public static String getName(String filePath) {
        if (filePath == null) {
            return null;
        }
        int index = filePath.lastIndexOf('/');
        return filePath.substring(index + 1);
    }

    public static File getDocumentCacheDir(@NonNull Context context) {
        File dir = new File(context.getCacheDir(), DOCUMENTS_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        return dir;
    }

    private static boolean saveFileFromUri(Context context, Uri uri, String destinationPath) {
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

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri, String selection, String[] selectionArgs) {
        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {column};

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return null;
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    /**
     *
     * Convert file size to string
     *
     * @param fileS
     * @return
     */
    public static String formatFileSize(long fileS) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.US);
        DecimalFormat df = new DecimalFormat("#.00", symbols);
        String fileSizeString = "";
        String wrongSize = "0B";
        if (fileS == 0) {
            return wrongSize;
        }
        if (fileS < 1024) {
            fileSizeString = df.format((double) fileS) + "B";
        } else if (fileS < 1048576) {
            fileSizeString = df.format((double) fileS / 1024) + "KB";
        } else if (fileS < 1073741824) {
            fileSizeString = df.format((double) fileS / 1048576) + "MB";
        } else {
            fileSizeString = df.format((double) fileS / 1073741824) + "GB";
        }
        return fileSizeString;
    }

    
    // fix the problem that getFileExtensionFromUrl does not support Chinese
    public static String getFileExtensionFromUrl(String url) {
        if (!TextUtils.isEmpty(url)) {
            int fragment = url.lastIndexOf('#');
            if (fragment > 0) {
                url = url.substring(0, fragment);
            }

            int query = url.lastIndexOf('?');
            if (query > 0) {
                url = url.substring(0, query);
            }

            int filenamePos = url.lastIndexOf('/');
            String filename = 0 <= filenamePos ? url.substring(filenamePos + 1) : url;

            // if the filename contains special characters, we don't
            // consider it valid for our matching purposes:
            
            //          if (!filename.isEmpty() && Pattern.matches("[a-zA-Z_0-9\\.\\-\\(\\)\\%]+", filename))
            if (!filename.isEmpty()) {
                int dotPos = filename.lastIndexOf('.');
                if (0 <= dotPos) {
                    return filename.substring(dotPos + 1).toLowerCase();
                }
            }
        }

        return "";
    }

    public static void openFile(String path, String fileName) {
        Uri uri = FileProvider.getUriForFile(
            TUIConfig.getAppContext(), TUIConfig.getAppContext().getApplicationInfo().packageName + FILE_PROVIDER_AUTH, new File(path));
        if (uri == null) {
            Log.e("FileUtil", "openFile failed , uri is null");
            return;
        }
        String fileExtension;
        if (TextUtils.isEmpty(fileName)) {
            fileExtension = FileUtil.getFileExtensionFromUrl(path);
        } else {
            fileExtension = FileUtil.getFileExtensionFromUrl(fileName);
        }
        String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.setDataAndType(uri, mimeType);
        try {
            Intent chooserIntent = Intent.createChooser(intent, TUIConfig.getAppContext().getString(R.string.open_file_tips));
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            TUIConfig.getAppContext().startActivity(chooserIntent);
        } catch (Exception e) {
            Log.e("FileUtil", "openFile failed , " + e.getMessage());
        }
    }

    public static long getFileSize(String path) {
        File file = new File(path);
        if (file.exists()) {
            return file.length();
        }
        return 0;
    }

    public static String generateImageFilePath() {
        String name = System.nanoTime() + "_" + Math.abs(new Random().nextInt());
        return TUIConfig.getImageBaseDir() + name + ".jpg";
    }

    public static String generateExternalStorageImageFilePath() {
        File dir = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + File.separatorChar + TUIConfig.getAppContext().getPackageName()
            + TUIConfig.IMAGE_BASE_DIR_SUFFIX);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir.getAbsolutePath() + File.separatorChar + System.nanoTime() + "_" + Math.abs(new Random().nextInt()) + ".jpg";
    }

    public static String generateVideoFilePath() {
        String name = System.nanoTime() + "_" + Math.abs(new Random().nextInt());
        return TUIConfig.getVideoBaseDir() + name + ".mp4";
    }

    public static String generateExternalStorageVideoFilePath() {
        File dir = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + File.separatorChar + TUIConfig.getAppContext().getPackageName()
            + TUIConfig.VIDEO_BASE_DIR_SUFFIX);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir.getAbsolutePath() + File.separatorChar + System.nanoTime() + "_" + Math.abs(new Random().nextInt()) + ".mp4";
    }

    public static boolean saveBitmap(String path, Bitmap b) {
        try {
            FileOutputStream fout = new FileOutputStream(path);
            BufferedOutputStream bos = new BufferedOutputStream(fout);
            b.compress(Bitmap.CompressFormat.JPEG, 100, bos);
            bos.flush();
            bos.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean isFileExists(String path) {
        try {
            File file = new File(path);
            return file.exists() && file.isFile();
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isDirExists(String path) {
        try {
            File file = new File(path);
            return file.exists() && file.isDirectory();
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isFileSizeExceedsLimit(Uri data, int maxSize) {
        try {
            Cursor returnCursor = ServiceInitializer.getAppContext().getContentResolver().query(data, null, null, null, null);
            if (returnCursor != null) {
                int sizeIndex = returnCursor.getColumnIndex(OpenableColumns.SIZE);
                returnCursor.moveToFirst();
                int size = returnCursor.getInt(sizeIndex);
                if (size > maxSize) {
                    return true;
                }
                returnCursor.close();
                return false;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
}
