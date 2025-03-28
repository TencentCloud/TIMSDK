package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.tencent.qcloud.tuicore.TUILogin;

/**
 * App are kept alive to ensure that process are not killed by the system in the background.
 * You can delete them if they are not needed.
 */
public class KeepAliveService extends Service {
    private static final String TAG         = "KeepAliveService";
    private static final String TITLE       = "title";
    private static final String DESCRIPTION = "description";

    private static final int NOTIFICATION_ID = 1001;

    public static void startKeepAliveService(String title, String description) {
        Log.d(TAG, "start keep alive service title=" + title + " description=" + description);
        Context context = TUILogin.getAppContext();
        Intent intent = new Intent(context, KeepAliveService.class);
        intent.putExtra(TITLE, title);
        intent.putExtra(DESCRIPTION, description);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent);
        } else {
            context.startService(intent);
        }
    }

    public static void stopKeepAliveService() {
        Log.d(TAG, "stop keep alive service");
        Context context = TUILogin.getAppContext();
        Intent intent = new Intent(context, KeepAliveService.class);
        context.stopService(intent);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) {
            return START_NOT_STICKY;
        }
        String title = intent.getStringExtra(TITLE);
        String description = intent.getStringExtra(DESCRIPTION);
        if (TextUtils.isEmpty(title) || TextUtils.isEmpty(description)) {
            Log.e(TAG, "on start command wrong params");
            return START_NOT_STICKY;
        }
        Notification notification = createForegroundNotification(title, description);
        startForeground(NOTIFICATION_ID, notification);
        return START_NOT_STICKY;
    }

    private Notification createForegroundNotification(String title, String description) {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        String notificationChannelId = "notification_channel_id_01";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = "RTC Room Foreground Service";
            int importance = NotificationManager.IMPORTANCE_LOW;
            NotificationChannel notificationChannel =
                    new NotificationChannel(notificationChannelId, channelName, importance);
            notificationChannel.setDescription("Channel description");
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(notificationChannel);
            }
        }

        Context appContext = TUILogin.getAppContext();
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, notificationChannelId);
        builder.setSmallIcon(appContext.getApplicationInfo().icon);
        builder.setContentTitle(title);
        builder.setContentText(description);
        builder.setWhen(System.currentTimeMillis());
        return builder.build();
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        stopSelf();
    }
}
