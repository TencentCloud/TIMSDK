package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDialogFragment;
import androidx.fragment.app.FragmentManager;
import com.tencent.qcloud.tuikit.tuicontact.R;

public class ContactToast {
    public static final int TOAST_ICON_NONE = 0;
    public static final int TOAST_ICON_POSITIVE = 1;
    public static final int TOAST_ICON_NEGATIVE = 2;

    private final Handler handler;
    private ToastFragment toast;

    private static class ContactToastHolder {
        private static final ContactToast instance = new ContactToast();
    }

    private static ContactToast getInstance() {
        return ContactToastHolder.instance;
    }

    private ContactToast() {
        handler = new Handler(Looper.getMainLooper());
    }

    public static void showToast(Context context, String toastContent) {
        showToast(context, toastContent, true, TOAST_ICON_NONE);
    }

    public static void showToast(Context context, String toastContent, int iconType) {
        showToast(context, toastContent, true, iconType);
    }

    public static void showToast(Context context, String toastContent, boolean isShortTime, int iconType) {
        long time = 3000;
        if (isShortTime) {
            time = 1500;
        }
        getInstance().showToast(context, toastContent, time, iconType);
    }

    private void showToast(Context context, String toastContent, long time, int iconType) {
        if (context instanceof AppCompatActivity) {
            if (toast != null) {
                dismiss();
            }
            toast = new ToastFragment();
            toast.iconType = iconType;
            toast.text = toastContent;
            FragmentManager fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
            toast.show(fragmentManager, "ContactToast");
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    dismiss();
                }
            }, time);
        }
    }

    private void dismiss() {
        if (toast != null) {
            toast.dismiss();
            toast = null;
        }
        handler.removeCallbacksAndMessages(null);
    }

    public static class ToastFragment extends AppCompatDialogFragment {
        int iconType = TOAST_ICON_NONE;
        String text;

        @NonNull
        @Override
        public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
            Dialog dialog = super.onCreateDialog(savedInstanceState);
            dialog.setCancelable(false);
            dialog.setCanceledOnTouchOutside(false);
            Window window = dialog.getWindow();
            window.setBackgroundDrawableResource(R.drawable.contact_custom_toast_border);
            return dialog;
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            View view = inflater.inflate(R.layout.contact_custom_toast_layout, container);
            TextView textView = view.findViewById(R.id.text_tv);
            ImageView iconView = view.findViewById(R.id.icon_iv);
            textView.setText(text);
            if (iconType == TOAST_ICON_POSITIVE) {
                iconView.setBackgroundResource(R.drawable.contact_toast_postive_icon);
            } else if (iconType == TOAST_ICON_NEGATIVE) {
                iconView.setBackgroundResource(R.drawable.contact_toast_negative_icon);
            } else {
                iconView.setVisibility(View.GONE);
            }
            return view;
        }
    }
}
