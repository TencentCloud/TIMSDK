package com.tencent.qcloud.uipojo.login.model;


import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.message.TIMConversationExt;
import com.tencent.imsdk.ext.message.TIMMessageExt;
import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uipojo.PojoApplication;
import com.tencent.qcloud.uipojo.utils.Constants;
import com.tencent.qcloud.uipojo.utils.SimpleHelper;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * Created by valexhuang on 2018/6/21.
 */

public class PojoLoginManager {
    private static final String TAG = "PojoLoginManager";
    private static PojoLoginManager instance = new PojoLoginManager();
    private static final String REGISTER_URL = "https://xzb.qcloud.com";

    private OkHttpClient client;

    public static PojoLoginManager getInstance() {
        return instance;
    }

    private PojoLoginManager() {
        client = new OkHttpClient();
    }

    // 测试IM登录，使用用户名identifier和对应的userSig直接进行IM登录
    public void imloginForDev(final String name, String userSig, final boolean autoJoin, final LoginCallback callback){
        TIMManager.getInstance().login(name, userSig, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null)
                    callback.onFail(TAG, code, desc);
                QLog.i(TAG, "imLogin onError=" + code + ":" + desc);
            }

            @Override
            public void onSuccess() {
                afterLogin(name, "");
                if (autoJoin) {
                    autoJoin();
                }
                if (callback != null)
                    callback.onSuccess("");
            }
        });
    }

    //IM登录
    private void imLogin(final String name, final String password, final boolean autoJoin, final LoginCallback callback) {
        SimpleHelper.getUsersig(Constants.SDKAPPID, name, new TIMValueCallBack<String>() {
            @Override
            public void onError(int code, String desc) {
                QLog.i(TAG, "getUsersig onError=" + code + ":" + desc);
            }

            @Override
            public void onSuccess(String userSig) {
                TIMManager.getInstance().login(name, userSig, new TIMCallBack() {
                    @Override
                    public void onError(int code, String desc) {
                        if (callback != null)
                            callback.onFail(TAG, code, desc);
                        QLog.i(TAG, "imLogin onError=" + code + ":" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        afterLogin(name, password);
                        if (autoJoin) {
                            autoJoin();
                        }
                        if (callback != null)
                            callback.onSuccess("");
                    }
                });
            }
        });
    }

    /**
     * 向业务服务发起登录请求
     *
     * @param name     用户名
     * @param password 密码
     * @param callback 回调
     */
    public void login(final String name, final String password, final LoginCallback callback) {
        new Thread() {
            @Override
            public void run() {
                JSONObject resJson = null;
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("userid", name);
                    jsonObject.put("password", password);
                    RequestBody body = RequestBody.create(MediaType.parse("application/json"), jsonObject.toString());
                    Request request = new Request.Builder()
                            .url(REGISTER_URL + "/login")
                            .post(body)
                            .build();
                    Response response = client.newCall(request).execute();
                    resJson = new JSONObject(response.body().string());
                    if (response.isSuccessful()) {
                        int resCode = resJson.optInt("code");
                        String msg = resJson.optString("message");
                        //在业务服务器登录成功后内部自动发起IM登录
                        if (resCode == 200) {
                            imLogin(name, password, false, callback);
                        } else {
                            if (callback != null)
                                callback.onFail(TAG, resCode, handleRegisterError(resCode));
                        }
                    } else {
                        if (callback != null)
                            callback.onFail(TAG, response.code(), response.message());
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    callback.onFail(TAG, -1, e.getMessage());
                }

            }
        }.start();

    }


    /**
     * 向业务服务发起登录请求
     *
     * @param name     用户名
     * @param password 密码
     * @param callback 回调
     */
    public void myLogin(final String name, final String password, final LoginCallback callback) {
        new Thread() {
            @Override
            public void run() {
                JSONObject resJson = null;
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("userid", name);
                    jsonObject.put("password", password);
                    RequestBody body = RequestBody.create(MediaType.parse("application/json"), jsonObject.toString());
                    Request request = new Request.Builder()
                            .url(REGISTER_URL + "/login")
                            .post(body)
                            .build();
                    Response response = client.newCall(request).execute();
                    resJson = new JSONObject(response.body().string());
                    if (response.isSuccessful()) {
                        int resCode = resJson.optInt("code");
                        String msg = resJson.optString("message");
                        String usersig = resJson.optString("message");
                        //在业务服务器登录成功后内部自动发起IM登录
                        if (resCode == 200) {
                            callback.onSuccess(usersig);
                        } else {
                            if (callback != null)
                                callback.onFail(TAG, resCode, handleRegisterError(resCode));
                        }
                    } else {
                        if (callback != null)
                            callback.onFail(TAG, response.code(), response.message());
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    callback.onFail(TAG, -1, e.getMessage());
                }

            }
        }.start();

    }


    public void register(final String name, final String password, final LoginCallback callback) {
        new Thread() {
            @Override
            public void run() {
                JSONObject resJson = null;
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("userid", name);
                    jsonObject.put("password", password);
                    RequestBody body = RequestBody.create(MediaType.parse("application/json"), jsonObject.toString());
                    Request request = new Request.Builder()
                            .url(REGISTER_URL + "/register")
                            .post(body)
                            .build();
                    Response response = client.newCall(request).execute();
                    resJson = new JSONObject(response.body().string());
                    if (response.isSuccessful()) {
                        int resCode = resJson.optInt("code");
                        String msg = resJson.optString("message");
                        if (resCode == 200) {
                            imLogin(name, password, true, callback);
                        } else {
                            if (callback != null)
                                callback.onFail(TAG, resCode, handleRegisterError(resCode));
                        }
                    } else {
                        if (callback != null)
                            callback.onFail(TAG, response.code(), response.message());
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    callback.onFail(TAG, -1, e.getMessage());
                }

            }
        }.start();

    }


    private void autoJoin() {
        List<TIMMessage> msgs = new ArrayList<>();
        TIMConversationExt ext = new TIMConversationExt(TIMManager.getInstance().getConversation(TIMConversationType.C2C, "腾讯云通信团队"));
        TIMMessage TIMMsg = new TIMMessage();
        TIMMessageExt msgExt = new TIMMessageExt(TIMMsg);
        TIMTextElem ele = new TIMTextElem();
        ele.setText("欢迎使用腾讯云TUIKit，祝您体验愉快。");
        TIMMsg.addElement(ele);
        msgs.add(TIMMsg);
        msgExt.convertToImportedMsg();
        msgExt.setSender("TUIKit消息测试");
        msgExt.setTimestamp(System.currentTimeMillis() / 1000);
        ext.importMsg(msgs);

        TIMGroupManager.getInstance().applyJoinGroup("developers@Android", "", new TIMCallBack() {
            @Override
            public void onError(final int code, final String desc) {
                QLog.e(TAG, "autoJoin failed, code: " + code + "|desc: " + desc);

            }

            @Override
            public void onSuccess() {
                QLog.e(TAG, "autoJoin onSuccess");
            }
        });
    }

    private String handleRegisterError(int errorCode) {
        if (errorCode == 610) {
            return "用户名格式错误";
        }
        if (errorCode == 602) {
            return "用户名或密码不合法";
        } else if (errorCode == 612) {
            return "用户已存在";
        } else if (errorCode == 500) {
            return "服务器错误";
        } else if (errorCode == 610) {
            return "用户名格式错误";
        }
        return "";
    }

    // 登录成功
    private void afterLogin(String userName, String password) {
        UserInfo.getInstance().setAccount(userName);
        UserInfo.getInstance().setPassword(password);
        UserInfo.getInstance().writeToCache(PojoApplication.instance());
    }

    public interface LoginCallback {
        void onSuccess(String usersig);

        void onFail(String module, int errCode, String errMsg);
    }
}
