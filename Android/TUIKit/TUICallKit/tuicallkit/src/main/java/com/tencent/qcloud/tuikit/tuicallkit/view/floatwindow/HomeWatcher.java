package com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

public class HomeWatcher {
    private Context               mContext;
    private IntentFilter          mFilter;
    private OnHomePressedListener mListener;
    private InnerReceiver         mReceiver;
    private boolean               mIsRegisted;

    public HomeWatcher(Context context) {
        mContext = context.getApplicationContext();
        mFilter = new IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
        mReceiver = new InnerReceiver();
    }

    public void setOnHomePressedListener(OnHomePressedListener listener) {
        mListener = listener;
    }

    public void startWatch() {
        if (null != mReceiver && !mIsRegisted) {
            mContext.registerReceiver(mReceiver, mFilter);
            mIsRegisted = true;
        }
    }

    public void stopWatch() {
        try {
            if (null != mReceiver) {
                mIsRegisted = false;
                mContext.unregisterReceiver(mReceiver);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    class InnerReceiver extends BroadcastReceiver {
        private static final String SYSTEM_DIALOG_REASON_KEY            = "reason";
        private static final String SYSTEM_DIALOG_REASON_GLOBAL_ACTIONS = "globalactions";
        private static final String SYSTEM_DIALOG_REASON_RECENT_APPS    = "recentapps";
        private static final String SYSTEM_DIALOG_REASON_HOME_KEY       = "homekey";

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action != null && action.equals(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)) {
                String reason = intent.getStringExtra(SYSTEM_DIALOG_REASON_KEY);
                if (mListener != null) {
                    if (SYSTEM_DIALOG_REASON_HOME_KEY.equals(reason)) {
                        mListener.onHomePressed();
                    } else if (SYSTEM_DIALOG_REASON_RECENT_APPS.equals(reason)) {
                        mListener.onRecentAppsPressed();
                    }
                }
            }
        }
    }

    public interface OnHomePressedListener {
        void onHomePressed();

        void onRecentAppsPressed();
    }
}

