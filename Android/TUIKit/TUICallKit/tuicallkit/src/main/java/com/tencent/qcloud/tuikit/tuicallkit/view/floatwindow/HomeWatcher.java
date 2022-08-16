package com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;

public class HomeWatcher {
    private static final String TAG = "HomeWatcher";

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
            TUILog.e(TAG, "stopWatch, e: " + e);
            e.printStackTrace();
        }
    }

    class InnerReceiver extends BroadcastReceiver {
        final String SYSTEM_DIALOG_REASON_KEY            = "reason";
        final String SYSTEM_DIALOG_REASON_GLOBAL_ACTIONS = "globalactions";
        final String SYSTEM_DIALOG_REASON_RECENT_APPS    = "recentapps";
        final String SYSTEM_DIALOG_REASON_HOME_KEY       = "homekey";

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)) {
                String reason = intent.getStringExtra(SYSTEM_DIALOG_REASON_KEY);
                if (reason != null) {
                    if (mListener != null) {
                        if (reason.equals(SYSTEM_DIALOG_REASON_HOME_KEY)) {
                            mListener.onHomePressed();
                        } else if (reason.equals(SYSTEM_DIALOG_REASON_RECENT_APPS)) {
                            mListener.onRecentAppsPressed();
                        }
                    }
                }
            }
        }
    }

    public interface OnHomePressedListener {
        public void onHomePressed();

        public void onRecentAppsPressed();
    }
}

