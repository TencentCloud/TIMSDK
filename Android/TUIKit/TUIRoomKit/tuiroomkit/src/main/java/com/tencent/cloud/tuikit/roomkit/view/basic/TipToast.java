package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.cloud.tuikit.roomkit.R;

public class TipToast {
    private String mMessage;

    private int mDuration = Toast.LENGTH_SHORT;

    private int mGravity = Gravity.TOP;

    public static TipToast build() {
        TipToast toast = new TipToast();
        return toast;
    }

    public TipToast setMessage(String message) {
        mMessage = message;
        return this;
    }

    public TipToast setDuration(int duration) {
        mDuration = duration;
        return this;
    }

    public TipToast setGravity(int gravity) {
        mGravity = gravity;
        return this;
    }

    public void show(Context context) {
        View tipView = LayoutInflater.from(context).inflate(R.layout.tuiroomkit_toast_tip, null);
        TextView tvMessage = tipView.findViewById(R.id.tuiroomkit_tv_toast_tip_message);
        tvMessage.setText(mMessage);

        Toast toast = new Toast(context.getApplicationContext());
        toast.setGravity(Gravity.CENTER_HORIZONTAL | mGravity, 0, 80);
        toast.setDuration(mDuration);
        toast.setView(tipView);
        toast.show();
    }
}
