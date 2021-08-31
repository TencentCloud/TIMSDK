package com.tencent.qcloud.tim.tuikit.live.component.report;

import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class ReportController {
    private static final String TAG = "ReportController";
    private static final String REPORT_URL = "http://demo.vod2.myqcloud.com/lite/report_user";
    private static final String PARAM_USER_ID = "userid";
    private static final String PARAM_HOST_USER_ID = "hostuserid";
    private static final String PARAM_REASON = "reason";

    private static final String[] REPORT_ITEMS = {
            "违法违规", "色情低俗", "标题党、封面党、骗点击", "未成年人不适当行为", "制售假冒伪劣商品", "滥用作品", "泄露我的隐私",
    };

    public String[] getReportItems() {
        return REPORT_ITEMS;
    }

    public void reportUser(String selfUserId, String reportUserId, String reportContent) {
        Log.d(TAG, "reportUser: selfUserId: " + selfUserId + " reportUserId:" + reportUserId + " reportContent:" + reportContent);
        if (TextUtils.isEmpty(selfUserId) || TextUtils.isEmpty(reportUserId) || TextUtils.isEmpty(reportContent)) {
            return;
        }
        ReportUserTask task = new ReportUserTask();
        task.execute(new Object[]{selfUserId, reportUserId, reportContent});
    }


    private class ReportUserTask extends AsyncTask {
        @Override
        protected Object doInBackground(Object[] objects) {
            String selfUserId = (String) objects[0];
            String reportUserId = (String) objects[1];
            String reportContent = (String) objects[2];
            OkHttpClient client = new OkHttpClient.Builder()
                    .connectTimeout(15, TimeUnit.SECONDS)
                    .readTimeout(20, TimeUnit.SECONDS)
                    .build();
            JSONObject jsonObject = new JSONObject();
            boolean success = false;
            try {
                jsonObject.put(PARAM_USER_ID, reportUserId);
                jsonObject.put(PARAM_HOST_USER_ID, selfUserId);
                jsonObject.put(PARAM_REASON, reportContent);
                RequestBody body = RequestBody.create(MediaType.parse("application/json"), jsonObject.toString());
                Request request = new Request.Builder().url(REPORT_URL).post(body).build();
                Response response = client.newCall(request).execute();
                success = response.isSuccessful();
                Log.i(TAG, "response body:" + response.body().string());
            } catch (JSONException | IOException e) {
                Log.d(TAG, "response error:" + e.getMessage());
                e.printStackTrace();
            }
            return success;
        }

        @Override
        protected void onPostExecute(Object result) {
            boolean success = (boolean) result;
            Log.d(TAG, "response success: " + success);
            Context context = TUIKitLive.getAppContext();
            Toast.makeText(context, context.getText(R.string.report_success), Toast.LENGTH_SHORT).show();
        }
    }
}
