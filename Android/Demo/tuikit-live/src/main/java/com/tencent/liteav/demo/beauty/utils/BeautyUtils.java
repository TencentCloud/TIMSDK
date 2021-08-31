package com.tencent.liteav.demo.beauty.utils;

import android.annotation.SuppressLint;
import android.app.Application;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.tencent.liteav.demo.beauty.model.BeautyInfo;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.util.Collection;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class BeautyUtils {

    private static final String TAG = "BeautyUtils";
    private static final String DEFAULT_BEAUTY_DATA = "default_beauty_data.json";

    @SuppressLint("StaticFieldLeak")
    private static Application sApplication;

    public static BeautyInfo getDefaultBeautyInfo() {
        return createBeautyInfo(readAssetsFile(DEFAULT_BEAUTY_DATA));
    }

    public static BeautyInfo createBeautyInfo(String json) {
        Gson gson = new Gson();
        return gson.fromJson(json, BeautyInfo.class);
    }

    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public static void setTextViewText(TextView textView, String resName) {
        textView.setText(ResourceUtils.getString(resName));
    }

    public static void setTextViewColor(TextView textView, String resName) {
        textView.setTextColor(ResourceUtils.getColor(resName));
    }

    public static void setTextViewSize(TextView textView, int size) {
        textView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, size);
    }

    public static void setImageResource(ImageView imageView, String res) {
        imageView.setImageResource(ResourceUtils.getDrawableId(res));
    }

    public static String readAssetsFile(String fileName) {
        StringBuilder sb = new StringBuilder();
        InputStream is = null;
        BufferedReader br = null;
        try {
            is = getApplication().getAssets().open(fileName);
            br = new BufferedReader(new InputStreamReader(is, "utf-8"));
            String readLine;
            while ((readLine = br.readLine()) != null) {
                sb.append(readLine);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) is.close();
                if (br != null) br.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return sb.toString();
    }

    public static Application getApplication() {
        if (sApplication != null) return sApplication;
        Application app = getApplicationByReflect();
        init(app);
        return app;
    }

    public static String getPackageName() {
        return getApplication().getPackageName();
    }

    private static void init(final Application app) {
        if (sApplication == null) {
            if (app == null) {
                sApplication = getApplicationByReflect();
            } else {
                sApplication = app;
            }
        } else {
            if (app != null && app.getClass() != sApplication.getClass()) {
                sApplication = app;
            }
        }
    }

    private static Application getApplicationByReflect() {
        try {
            @SuppressLint("PrivateApi")
            Class<?> activityThread = Class.forName("android.app.ActivityThread");
            Object thread = activityThread.getMethod("currentActivityThread").invoke(null);
            Object app = activityThread.getMethod("getApplication").invoke(thread);
            if (app == null) {
                throw new NullPointerException("You should init first.");
            }
            return (Application) app;
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        throw new NullPointerException("You should init first.");
    }

    public static synchronized String unZip(@NonNull String zipFile, @NonNull String targetDir) {
        if (TextUtils.isEmpty(zipFile)) {
            return null;
        } else {
            File file = new File(zipFile);
            if (!file.exists()) {
                return null;
            } else {
                File targetFolder = new File(targetDir);
                if (!targetFolder.exists()) {
                    targetFolder.mkdirs();
                }
                String dataDir = null;
                short BUFFER = 4096;
                FileInputStream fis = null;
                ZipInputStream zis = null;
                FileOutputStream fos = null;
                BufferedOutputStream dest = null;
                try {
                    fis = new FileInputStream(file);
                    zis = new ZipInputStream(new BufferedInputStream(fis));
                    while (true) {
                        String strEntry;
                        ZipEntry entry;
                        do {
                            if ((entry = zis.getNextEntry()) == null) {
                                return dataDir;
                            }
                            strEntry = entry.getName();
                        } while (strEntry.contains("../"));
                        if (entry.isDirectory()) {
                            String count1 = targetDir + File.separator + strEntry;
                            File data1 = new File(count1);
                            if (!data1.exists()) {
                                data1.mkdirs();
                            }
                            if (TextUtils.isEmpty(dataDir)) {
                                dataDir = data1.getPath();
                            }
                        } else {
                            byte[] data = new byte[BUFFER];
                            String targetFileDir = targetDir + File.separator + strEntry;
                            File targetFile = new File(targetFileDir);
                            try {
                                fos = new FileOutputStream(targetFile);
                                dest = new BufferedOutputStream(fos, BUFFER);
                                int count;
                                while ((count = zis.read(data)) != -1) {
                                    dest.write(data, 0, count);
                                }
                                dest.flush();
                            } catch (IOException var41) {
                                var41.printStackTrace();
                            } finally {
                                try {
                                    if (dest != null) {
                                        dest.close();
                                    }
                                    if (fos != null) {
                                        fos.close();
                                    }
                                } catch (IOException var40) {
                                    var40.printStackTrace();
                                }
                            }
                        }
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (zis != null) {
                            zis.close();
                        }
                        if (fis != null) {
                            fis.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                return dataDir;
            }
        }
    }

    public static boolean isEmpty(@Nullable Collection object) {
        return null == object || object.isEmpty();
    }

    public static boolean isNetworkAvailable(@NonNull Context context) {
        ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity == null) {
            return false;
        } else {
            NetworkInfo networkInfo = connectivity.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isConnectedOrConnecting();
        }
    }

    @Nullable
    public static File getExternalFilesDir(@NonNull Context context, String folder) {
        if (context == null) {
            Log.e(TAG, "getExternalFilesDir context is null");
            return null;
        }
        File sdcardDir = context.getApplicationContext().getExternalFilesDir(null);
        if (sdcardDir == null) {
            Log.e(TAG, "sdcardDir is null");
            return null;
        }
        String path = sdcardDir.getPath();
        File file = new File(path + File.separator + folder);
        try {
            if (file.exists() && file.isFile()) {
                file.delete();
            }
            if (!file.exists()) {
                file.mkdirs();
            }
        } catch (Exception var5) {
            var5.printStackTrace();
        }
        return file;
    }

}
