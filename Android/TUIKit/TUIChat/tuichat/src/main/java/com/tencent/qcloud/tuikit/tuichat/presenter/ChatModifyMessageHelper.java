package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.os.Handler;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

// A modify message task queue which has a retry mechanism
public class ChatModifyMessageHelper {
    private static final int RETRY_TIMES = 3;
    private static final int RETRY_MIN_TIME = 500;
    private static final int RETRY_MAX_TIME = 3000;

    private static final ChatModifyMessageHelper helper = new ChatModifyMessageHelper();
    private final Handler handler;
    private final ChatProvider provider;

    // a cache to get newest be modified message
    // it is visited in main thread , it is thread-safe
    private final Map<String, TUIMessageBean> cache = new HashMap<>();

    private ChatModifyMessageHelper() {
        provider = new ChatProvider();
        handler = new Handler();
        // Only need to register c2c listener can also receive group message
        C2CChatEventListener messageModifiedListener = new C2CChatEventListener() {
            @Override
            public void onRecvMessageModified(TUIMessageBean messageBean) {
                onUpdateCache(messageBean);
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(messageModifiedListener);
    }

    private void onUpdateCache(TUIMessageBean messageBean) {
        if (cache.get(messageBean.getId()) != null) {
            cache.put(messageBean.getId(), messageBean);
        }
    }

    public static void enqueueTask(ModifyMessageTask task) {
        enqueueTask(task, 0);
    }

    private static void enqueueTask(ModifyMessageTask task, long delay) {
        helper.handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (task.messageBean == null) {
                    TUIChatUtils.callbackOnError(task.callback, -1, "params error , message is null");
                    return;
                }
                TUIMessageBean beModifiedMessage = helper.cache.get(task.messageBean.getId());
                if (beModifiedMessage != null) {
                    task.messageBean = beModifiedMessage;
                }
                TUIMessageBean messageBean = task.packageMessage(task.messageBean);
                if (messageBean == null) {
                    helper.cache.remove(task.messageBean.getId());
                    TUIChatUtils.callbackOnError(task.callback, -1, "message is null");
                    return;
                }
                helper.provider.modifyMessage(messageBean, new IUIKitCallback<TUIMessageBean>() {
                    @Override
                    public void onSuccess(TUIMessageBean data) {
                        helper.cache.remove(task.messageBean.getId());
                        TUIChatUtils.callbackOnSuccess(task.callback, data);
                    }

                    @Override
                    public void onError(int errCode, String errMsg, TUIMessageBean data) {
                        // update message and post to task queue
                        helper.cache.put(data.getId(), data);
                        if (task.retryTimes <= RETRY_TIMES) {
                            int delay = helper.getRetryDelay();
                            task.retryTimes++;
                            task.messageBean = data;
                            ChatModifyMessageHelper.enqueueTask(task, delay);
                        } else {
                            helper.cache.remove(task.messageBean.getId());
                            TUIChatUtils.callbackOnError(task.callback, errCode, errMsg);
                        }
                    }
                });
            }
        }, delay);
    }

    // RETRY_MIN_TIME ~ RETRY_MAX_TIME ms
    private int getRetryDelay() {
        return new Random().nextInt(RETRY_MAX_TIME - RETRY_MIN_TIME + 1) + RETRY_MIN_TIME;
    }

    public abstract static class ModifyMessageTask {
        private int retryTimes = 0;
        private TUIMessageBean messageBean;
        private final IUIKitCallback<TUIMessageBean> callback;

        public ModifyMessageTask(TUIMessageBean messageBean, IUIKitCallback<TUIMessageBean> callback) {
            this.messageBean = messageBean;
            this.callback = callback;
        }

        public abstract TUIMessageBean packageMessage(TUIMessageBean originMessage);
    }
}
