package com.tencent.qcloud.uipojo.utils;

import android.annotation.SuppressLint;
import android.os.Build;
import android.util.Log;

import com.tencent.imsdk.TIMValueCallBack;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Created by forrestluo on 2017/10/17.
 */

public class SimpleHelper {

    /**
     * 到业务服务器获取usersig
     *
     * @param sdkappid   sdkappid
     * @param identifier 登录用户ID
     * @return 相应的usersig
     */
    public static void getUsersig(final long sdkappid, final String identifier, final TIMValueCallBack<String> cb) {

        if (sdkappid == 1104620500) {
            cb.onSuccess("123456");
            return;
        }

        new Thread(new Runnable() {
            @Override
            public void run() {
                String url = Constants.BUSIZ_SERVER_BASE_URL + "sdkappid=" + sdkappid;
                String usersig = "";
                HttpURLConnection http = null;
                try {
                    http = (HttpURLConnection) (new URL(url)).openConnection();

                    http.setRequestMethod("POST");
                    http.setDoOutput(true);
                    http.setRequestProperty("connection", "close");
                    http.setRequestProperty("content-type", "application/json");

                    JSONObject json = new JSONObject();
                    json.put("cmd", "open_account_svc");
                    json.put("sub_cmd", "fetch_sig");
                    json.put("id", identifier);

                    http.getOutputStream().write(json.toString().getBytes("utf-8"));

                    int httpStatus = http.getResponseCode();
                    if (httpStatus == 200) {
                        InputStream in = new BufferedInputStream(http.getInputStream());
                        int len = -1;
                        byte[] buff = new byte[1024];
                        ByteArrayOutputStream out = new ByteArrayOutputStream();
                        while ((len = in.read(buff)) > 0) {
                            out.write(buff, 0, len);
                        }
                        out.close();
                        in.close();

                        JSONObject jobj = new JSONObject(out.toString());
                        int errCode = jobj.optInt("error_code");
                        if (errCode != 0) {
                            String errMsg = jobj.optString("error_msg");
                            cb.onError(errCode, errMsg);
                            return;
                        }

                        usersig = jobj.optString("user_sig");
                        if (usersig.isEmpty()) {
                            cb.onError(-1, "getUsersig failed, nothing from server");
                        }

                        cb.onSuccess(usersig);
                    } else {
                        cb.onError(httpStatus, "getUsersig failed, code: " + httpStatus);
                    }

                } catch (Throwable e) {
                    cb.onError(-1, Log.getStackTraceString(e));
                } finally {
                    if (http != null) {
                        http.disconnect();
                    }
                }
            }
        }).start();

    }

    @SuppressLint("SimpleDateFormat")
    private static String getSimpleDate() {
        return new SimpleDateFormat("MM-dd hh:mm:ss").format(new Date());
    }

    public static boolean isHuawei() {
        String vendor = Build.MANUFACTURER;
        return vendor.toLowerCase(Locale.ENGLISH).contains("huawei");
    }

    public static boolean isXiaoMi() {
        String vendor = Build.MANUFACTURER;
        return vendor.toLowerCase(Locale.ENGLISH).contains("xiaomi");
    }
}
