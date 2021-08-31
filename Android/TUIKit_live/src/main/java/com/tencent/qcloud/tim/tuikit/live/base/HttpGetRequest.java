package com.tencent.qcloud.tim.tuikit.live.base;

import androidx.annotation.NonNull;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpGetRequest implements Runnable {
    public static final int TIMEOUT = 30000;
    public static final int RESPONSE_SUCCESS = 200;
    private HttpListener mHttpListener;
    private String mUrl;

    public HttpGetRequest(String url, @NonNull HttpListener httpListener) {
        mHttpListener = httpListener;
        mUrl = url;
    }

    @Override
    public void run() {
        request();
    }

    private void request() {
        InputStream inputStream = null;
        BufferedReader br = null;
        try {
            URL url = new URL(mUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(TIMEOUT);
            conn.setReadTimeout(TIMEOUT);
            if (conn.getResponseCode() == RESPONSE_SUCCESS) {
                StringBuilder sb = new StringBuilder();
                inputStream = conn.getInputStream();
                br = new BufferedReader(new InputStreamReader(inputStream, "utf-8"));
                String readLine;
                while ((readLine = br.readLine()) != null) {
                    sb.append(readLine);
                }
                if (sb.length() > 0) {
                    mHttpListener.success(sb.toString());
                }
            } else {
                mHttpListener.onFailed(conn.getResponseMessage());
            }
        } catch (Exception e) {
            e.printStackTrace();
            mHttpListener.onFailed(e.getMessage());
        } finally {
            try {
                if (inputStream != null) inputStream.close();
                if (br != null) br.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public interface HttpListener {
        void success(String response);
        void onFailed(String message);
    }
}
