package com.huawei.android.hms.agent.common;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.hms.activity.BridgeActivity;
import com.huawei.hms.api.ConnectionResult;
import com.huawei.hms.api.HuaweiApiAvailability;
import com.huawei.hms.api.HuaweiApiClient;
import com.huawei.hms.support.api.push.HuaweiPush;

import java.util.ArrayList;
import java.util.List;


/**
 * Huawei Api Client 管理类 | Huawei API Client Management class
 * 负责HuaweiApiClient的连接，异常处理等 | Responsible for huaweiapiclient connection, exception handling, etc.
 */
public final class ApiClientMgr implements HuaweiApiClient.ConnectionCallbacks, HuaweiApiClient.OnConnectionFailedListener, IActivityResumeCallback, IActivityPauseCallback, IActivityDestroyedCallback {

    /**
     * 单实例 | Single Instance
     */
    public static final ApiClientMgr INST = new ApiClientMgr();

    /**
     * 应用市场包名 | HiApp's package name
     */
    private static final String PACKAGE_NAME_HIAPP = "com.huawei.appmarket";

    /**
     * 回调锁，避免连接回调紊乱 | Callback lock to avoid connection callback disorder
     */
    private static final Object CALLBACK_LOCK = new Object();

    /**
     * 静态注册回调锁，避免注册和回调紊乱 | Static registration callback lock to avoid registration and callback disturbances
     */
    private static final Object STATIC_CALLBACK_LOCK = new Object();

    /**
     * client操作锁，避免连接使用紊乱 | Client operation lock, avoid connection use disorder
     */
    private static final Object APICLIENT_LOCK = new Object();

    /**
     * api client 连接超时 | API Client Connection Timeout
     */
    private static final int APICLIENT_CONNECT_TIMEOUT = 30000;

    /**
     * 解决升级错误时activity onResume 稳定在3秒时间判断BridgeActivity上面有没有其他activity
     * To resolve an upgrade error, activity Onresume stable at 3 seconds to determine if there are any other activity on bridgeactivity.
     */
    private static final int UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT = 3000;

    /**
     * api client 解决错误拉起界面超时 | API client Resolution error Pull interface timeout
     */
    private static final int APICLIENT_STARTACTIVITY_TIMEOUT = 3000;

    /**
     * client 连接超时消息 | Client Connection Timeout Message
     */
    private static final int APICLIENT_TIMEOUT_HANDLE_MSG = 3;

    /**
     * client 拉起activity超时消息 | Client starts Activity Timeout message
     */
    private static final int APICLIENT_STARTACTIVITY_TIMEOUT_HANDLE_MSG = 4;

    /**
     * 解决升级错误时activity onResume 稳定在3秒时间判断BridgeActivity上面有没有其他activity
     * To resolve an upgrade error, activity Onresume stable at 3 seconds to determine if there are any other activity on bridgeactivity.
     */
    private static final int UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT_HANDLE_MSG = 5;

    /**
     * 最大尝试连接次数 | Maximum number of attempts to connect
     */
    private static final int MAX_RESOLVE_TIMES = 3;

    /**
     * 上下文，用来处理连接失败 | Context to handle connection failures
     */
    private Context context;

    /**
     * 当前应用包名 | Current Application Package Name
     */
    private String curAppPackageName;

    /**
     * HuaweiApiClient 实例 | Huaweiapiclient instance
     */
    private HuaweiApiClient apiClient;

    /**
     * 是否允许解决connect错误（解决connect错误需要拉起activity）
     * Whether to allow the connect error to be resolved (resolve connect error need to pull activity)
     */
    private boolean allowResolveConnectError = false;

    /**
     * 是否正在解决连接错误 | Whether a connection error is being resolved
     */
    private boolean isResolving;

    /**
     * HMSSDK 解决错误的activity | HMSSDK to solve the wrong activity
     */
    private BridgeActivity resolveActivity;

    /**
     * 是否存在其他activity覆盖在升级activity之上
     * Is there any other activity covering the escalation activity
     */
    private boolean hasOverActivity = false;

    /**
     * 当前剩余尝试次数 | Current number of remaining attempts
     */
    private int curLeftResolveTimes = MAX_RESOLVE_TIMES;

    /**
     * 连接回调 | Connection callback
     */
    private List<IClientConnectCallback> connCallbacks = new ArrayList<IClientConnectCallback>();

    /**
     * 注册的静态回调 | Registered Static callback
     */
    private List<IClientConnectCallback> staticCallbacks = new ArrayList<IClientConnectCallback>();

    /**
     * 超时handler用来处理client connect 超时
     * Timeout handler to handle client connect timeout
     */
    private Handler timeoutHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message msg) {

            boolean hasConnCallbacks;
            synchronized (CALLBACK_LOCK) {
                hasConnCallbacks = !connCallbacks.isEmpty();
            }

            if (msg != null && msg.what == APICLIENT_TIMEOUT_HANDLE_MSG && hasConnCallbacks) {
                HMSAgentLog.d("connect time out");
                resetApiClient();
                onConnectEnd(HMSAgent.AgentResultCode.APICLIENT_TIMEOUT);
                return true;
            } else if (msg != null && msg.what == APICLIENT_STARTACTIVITY_TIMEOUT_HANDLE_MSG && hasConnCallbacks) {
                HMSAgentLog.d("start activity time out");
                onConnectEnd(HMSAgent.AgentResultCode.APICLIENT_TIMEOUT);
                return true;
            } else if (msg != null && msg.what == UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT_HANDLE_MSG && hasConnCallbacks) {
                HMSAgentLog.d("Discarded update dispose:hasOverActivity=" +hasOverActivity + " resolveActivity=" + StrUtils.objDesc(resolveActivity));
                if (hasOverActivity && resolveActivity != null && !resolveActivity.isFinishing()) {
                    onResolveErrorRst(ConnectionResult.CANCELED);
                }
                return true;
            }
            return false;
        }
    });

    /**
     * 私有构造方法 | Private construction methods
     */
    private ApiClientMgr () {
    }

    /**
     * 初始化
     * @param app 应用程序
     */
    public void init(Application app) {

        HMSAgentLog.d("init");

        // 保存应用程序context
        context = app.getApplicationContext();

        // 取得应用程序包名
        curAppPackageName = app.getPackageName();

        // 注册activity onResume回调
        ActivityMgr.INST.unRegisterActivitResumeEvent(this);
        ActivityMgr.INST.registerActivitResumeEvent(this);

        // 注册activity onPause回调
        ActivityMgr.INST.unRegisterActivitPauseEvent(this);
        ActivityMgr.INST.registerActivitPauseEvent(this);

        // 注册activity onDestroyed 回调
        ActivityMgr.INST.unRegisterActivitDestroyedEvent(this);
        ActivityMgr.INST.registerActivitDestroyedEvent(this);
    }

    /**
     * 断开apiclient，一般不需要调用
     */
    public void release() {
        HMSAgentLog.d("release");

        isResolving = false;
        resolveActivity = null;
        hasOverActivity = false;

        HuaweiApiClient client =  getApiClient();
        if (client != null) {
            client.disconnect();
        }

        synchronized (APICLIENT_LOCK) {
            apiClient = null;
        }

        synchronized (STATIC_CALLBACK_LOCK) {
            staticCallbacks.clear();
        }

        synchronized (CALLBACK_LOCK) {
            connCallbacks.clear();
        }
    }

    /**
     * 获取当前的 HuaweiApiClient
     * @return HuaweiApiClient 实例
     */
    public HuaweiApiClient getApiClient() {
        synchronized (APICLIENT_LOCK) {
            return apiClient != null ? apiClient : resetApiClient();
        }
    }

    /**
     * 判断client是否已经连接
     * @param client 要检测的client
     * @return 是否已经连接
     */
    public boolean isConnect(HuaweiApiClient client) {
        return client != null && client.isConnected();
    }

    /**
     * 注册apiclient连接事件
     * @param staticCallback 连接回调
     */
    public void registerClientConnect(IClientConnectCallback staticCallback){
        synchronized (STATIC_CALLBACK_LOCK) {
            staticCallbacks.add(staticCallback);
        }
    }

    /**
     * 反注册apiclient连接事件
     * @param staticCallback 连接回调
     */
    public void removeClientConnectCallback(IClientConnectCallback staticCallback) {
        synchronized (STATIC_CALLBACK_LOCK) {
            staticCallbacks.remove(staticCallback);
        }
    }

    /**
     * 重新创建apiclient
     * 2种情况需要重新创建：1、首次 2、client的状态已经紊乱
     * @return 新创建的client
     */
    private HuaweiApiClient resetApiClient(){
        if (context == null) {
            HMSAgentLog.e("HMSAgent not init");
            return null;
        }

        synchronized (APICLIENT_LOCK) {
            if (apiClient != null) {
                // 对于老的apiClient，1分钟后才丢弃，防止外面正在使用过程中这边disConnect了
                disConnectClientDelay(apiClient, 60000);
            }

            HMSAgentLog.d("reset client");

            // 这种重置client，极端情况可能会出现2个client都回调结果的情况。此时可能出现rstCode=0，但是client无效。
            // 因为业务调用封装中都进行了一次重试。所以不会有问题
            apiClient = new HuaweiApiClient.Builder(context)
                    .addApi(HuaweiPush.PUSH_API)
                    .addConnectionCallbacks(INST)
                    .addOnConnectionFailedListener(INST)
                    .build();
            return apiClient;
        }
    }

    /**
     * 连接 HuaweiApiClient,
     * @param callback 连接结果回调，一定不能为null,在子线程进行回调
     * @param allowResolve 是否允许解决错误，解决错误时可能会拉起界面
     */
    public void connect(IClientConnectCallback callback, boolean allowResolve) {

        if (context == null) {
            aSysnCallback(HMSAgent.AgentResultCode.HMSAGENT_NO_INIT, callback);
            return;
        }

        HuaweiApiClient client =  getApiClient();
        // client 有效，则直接回调
        if (client != null && client.isConnected()) {
            HMSAgentLog.d("client is valid");
            aSysnCallback(HMSAgent.AgentResultCode.HMSAGENT_SUCCESS, callback);
            return;
        } else {
            // client无效，将callback加入队列，并启动连接
            synchronized (CALLBACK_LOCK) {
                HMSAgentLog.d("client is invalid：size=" + connCallbacks.size());
                allowResolveConnectError = allowResolveConnectError || allowResolve;
                if (connCallbacks.isEmpty()) {
                    connCallbacks.add(callback);

                    // 连接尝试最大次数
                    curLeftResolveTimes = MAX_RESOLVE_TIMES;

                    startConnect();
                } else {
                    connCallbacks.add(callback);
                }
            }
        }
    }

    /**
     * 线程中进行Huawei Api Client 的连接
     */
    private void startConnect() {

        // 触发一次连接将重试次数减1
        curLeftResolveTimes--;

        HMSAgentLog.d("start thread to connect");
        ThreadUtil.INST.excute(new Runnable() {
            @Override
            public void run() {
                HuaweiApiClient client =  getApiClient();

                if (client != null) {
                    HMSAgentLog.d("connect");
                    Activity curActivity = ActivityMgr.INST.getLastActivity();

                    // 考虑到有cp后台需要调用接口，HMSSDK去掉了activity不能为空的判断。这里只是取当前activity，可能为空
                    timeoutHandler.sendEmptyMessageDelayed(APICLIENT_TIMEOUT_HANDLE_MSG, APICLIENT_CONNECT_TIMEOUT);
                    client.connect(curActivity);
                } else {
                    HMSAgentLog.d("client is generate error");
                    onConnectEnd(HMSAgent.AgentResultCode.RESULT_IS_NULL);
                }
            }
        });
    }

    /**
     * Huawei Api Client 连接结束方法
     * @param rstCode client 连接结果码
     */
    private void onConnectEnd(final int rstCode) {
        HMSAgentLog.d("connect end:" + rstCode);

        synchronized (CALLBACK_LOCK) {
            // 回调各个回调接口连接结束
            for (IClientConnectCallback callback : connCallbacks) {
                aSysnCallback(rstCode, callback);
            }
            connCallbacks.clear();

            // 恢复默认不显示
            allowResolveConnectError = false;
        }

        synchronized (STATIC_CALLBACK_LOCK) {
            // 回调各个回调接口连接结束
            for (IClientConnectCallback callback : staticCallbacks) {
                aSysnCallback(rstCode, callback);
            }
            staticCallbacks.clear();
        }
    }

    /**
     * 起线程回调各个接口，避免其中一个回调者耗时长影响其他调用者
     * @param rstCode 结果码
     * @param callback 回调
     */
    private void aSysnCallback(final int rstCode, final IClientConnectCallback callback) {
        ThreadUtil.INST.excute(new Runnable() {
            @Override
            public void run() {
                HuaweiApiClient client =  getApiClient();
                HMSAgentLog.d("callback connect: rst=" + rstCode + " apiClient=" + client);
                callback.onConnect(rstCode, client);
            }
        });
    }

    /**
     * Activity onResume回调
     *
     * @param activity 发生 onResume 事件的activity
     */
    @Override
    public void onActivityResume(Activity activity) {
        // 通知hmssdk activity onResume了
        HuaweiApiClient client = getApiClient();
        if (client != null) {
            HMSAgentLog.d("tell hmssdk: onResume");
            client.onResume(activity);
        }

        // 如果正在解决错误，则处理被覆盖的场景
        HMSAgentLog.d("is resolving:" + isResolving);
        if (isResolving && !PACKAGE_NAME_HIAPP.equals(curAppPackageName)) {
            if (activity instanceof BridgeActivity) {
                resolveActivity = (BridgeActivity)activity;
                hasOverActivity = false;
                HMSAgentLog.d("received bridgeActivity:" + StrUtils.objDesc(resolveActivity));
            } else if (resolveActivity != null && !resolveActivity.isFinishing()){
                hasOverActivity = true;
                HMSAgentLog.d("received other Activity:" + StrUtils.objDesc(resolveActivity));
            }
            timeoutHandler.removeMessages(UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT_HANDLE_MSG);
            timeoutHandler.sendEmptyMessageDelayed(UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT_HANDLE_MSG, UPDATE_OVER_ACTIVITY_CHECK_TIMEOUT);
        }
    }

    /**
     * Activity onPause回调
     *
     * @param activity 发生 onPause 事件的activity
     */
    @Override
    public void onActivityPause(Activity activity) {
        // 通知hmssdk，activity onPause了
        HuaweiApiClient client = getApiClient();
        if (client != null) {
            client.onPause(activity);
        }
    }

    /**
     * Activity onPause回调
     *
     * @param activityDestroyed 发生 onDestroyed 事件的activity
     * @param activityNxt       下个要显示的activity
     */
    @Override
    public void onActivityDestroyed(Activity activityDestroyed, Activity activityNxt) {
        if (activityNxt == null) {
            // 所有activity销毁后，重置client，否则公告的标志位还在，下次弹不出来
            resetApiClient();
        }
    }

    /**
     * connect fail 解决结果回调， 由 HMSAgentActivity 在 onActivityResult 中调用
     * @param result 解决结果
     */
    void onResolveErrorRst(int result) {
        HMSAgentLog.d("result="+result);
        isResolving = false;
        resolveActivity = null;
        hasOverActivity = false;

        if(result == ConnectionResult.SUCCESS) {
            HuaweiApiClient client =  getApiClient();
            if (client != null && !client.isConnecting() && !client.isConnected() && curLeftResolveTimes > 0) {
                startConnect();
                return;
            }
        }

        onConnectEnd(result);
    }

    /**
     * HMSAgentActivity 拉起拉了（走了onCreate）
     */
    void onActivityLunched(){
        HMSAgentLog.d("resolve onActivityLunched");
        // 拉起界面回调，移除拉起界面超时
        timeoutHandler.removeMessages(APICLIENT_STARTACTIVITY_TIMEOUT_HANDLE_MSG);
        isResolving = true;
    }

    /**
     * Huawe Api Client 连接成功回到
     */
    @Override
    public void onConnected() {
        HMSAgentLog.d("connect success");
        timeoutHandler.removeMessages(APICLIENT_TIMEOUT_HANDLE_MSG);
        onConnectEnd(ConnectionResult.SUCCESS);
    }

    /**
     * 当client变成断开状态时会被调用。这有可能发生在远程服务出现问题时（例如：出现crash或资源问题导致服务被系统杀掉）。
     * 当被调用时，所有的请求都会被取消，任何listeners都不会被执行。需要 CP 开发代码尝试恢复连接（connect）。
     * 应用程序应该禁用需要服务的相关UI组件，等待{@link #onConnected()} 回调后重新启用他们。<br>
     *
     * @param cause 断开的原因. 常量定义： CAUSE_*.
     */
    @Override
    public void onConnectionSuspended(int cause) {
        HMSAgentLog.d("connect suspended");
        connect(new EmptyConnectCallback("onConnectionSuspended try end:"), true);
    }

    /**
     * 建立client到service的连接失败时调用
     *
     * @param result 连接结果，用于解决错误和知道什么类型的错误
     */
    @Override
    public void onConnectionFailed(ConnectionResult result) {
        timeoutHandler.removeMessages(APICLIENT_TIMEOUT_HANDLE_MSG);

        if (result == null) {
            HMSAgentLog.e("result is null");
            onConnectEnd(HMSAgent.AgentResultCode.RESULT_IS_NULL);
            return;
        }

        int errCode = result.getErrorCode();
        HMSAgentLog.d("errCode=" + errCode + " allowResolve=" + allowResolveConnectError);

        if(HuaweiApiAvailability.getInstance().isUserResolvableError(errCode) && allowResolveConnectError) {
            Activity activity = ActivityMgr.INST.getLastActivity();
            if (activity != null) {
                try {
                    timeoutHandler.sendEmptyMessageDelayed(APICLIENT_STARTACTIVITY_TIMEOUT_HANDLE_MSG, APICLIENT_STARTACTIVITY_TIMEOUT);
                    Intent intent = new Intent(activity, HMSAgentActivity.class);
                    intent.putExtra(HMSAgentActivity.CONN_ERR_CODE_TAG, errCode);
                    intent.putExtra(BaseAgentActivity.EXTRA_IS_FULLSCREEN, UIUtils.isActivityFullscreen(activity));
                    activity.startActivity(intent);
                    return;
                } catch (Exception e) {
                    HMSAgentLog.e("start HMSAgentActivity exception:" + e.getMessage());
                    timeoutHandler.removeMessages(APICLIENT_STARTACTIVITY_TIMEOUT_HANDLE_MSG);
                    onConnectEnd(HMSAgent.AgentResultCode.START_ACTIVITY_ERROR);
                    return;
                }
            } else {
                // 当前没有界面处理不了错误
                HMSAgentLog.d("no activity");
                onConnectEnd(HMSAgent.AgentResultCode.NO_ACTIVITY_FOR_USE);
                return;
            }
        } else {
            //其他错误码直接透传
        }

        onConnectEnd(errCode);
    }

    private static void disConnectClientDelay(final HuaweiApiClient clientTmp, int delay) {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                clientTmp.disconnect();
            }
        }, delay);
    }
}
