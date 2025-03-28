package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.view.Gravity;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.tuicore.ServiceInitializer;

public class RoomToast {
    public static void toastShortMessage(String message) {
        toastMessage(message, Toast.LENGTH_SHORT, Gravity.BOTTOM);
    }

    public static void toastLongMessage(String message) {
        toastMessage(message, Toast.LENGTH_LONG, Gravity.BOTTOM);
    }

    public static void toastLongMessageCenter(final String message) {
        toastMessage(message, Toast.LENGTH_LONG, Gravity.CENTER);
    }

    public static void toastShortMessageCenter(final String message) {
        toastMessage(message, Toast.LENGTH_SHORT, Gravity.CENTER);
    }

    private static void toastMessage(String message, int duration, int gravity) {
        Toast toast = Toast.makeText(ServiceInitializer.getAppContext(), message, duration);
        toast.setGravity(gravity, 0, 0);
        View view = toast.getView();
        if (view != null) {
            TextView textView = view.findViewById(android.R.id.message);
            if (textView != null) {
                textView.setGravity(Gravity.CENTER);
            }
        }
        toast.show();
    }
}
