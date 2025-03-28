package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import com.tencent.cloud.tuikit.roomkit.R;

public class BaseDialogFragment extends DialogFragment {
    private static final String TAG = "BaseDialogFragment";

    private View mRootView;

    private String mTitle;
    private String mContent;
    private String mNegativeName;
    private String mPositiveName;
    private int    mPositiveButtonColor = 0;

    private boolean mIsHideNegativeView;

    private ClickListener mNegativeListener;
    private ClickListener mPositiveListener;

    public interface ClickListener {
        void onClick();
    }

    public static BaseDialogFragment build() {
        BaseDialogFragment dialog = new BaseDialogFragment();
        return dialog;
    }

    public BaseDialogFragment setTitle(String title) {
        mTitle = title;
        return this;
    }

    public BaseDialogFragment setContent(String content) {
        mContent = content;
        return this;
    }

    public BaseDialogFragment setNegativeName(String negativeName) {
        mNegativeName = negativeName;
        return this;
    }

    public BaseDialogFragment setPositiveName(String positiveName) {
        mPositiveName = positiveName;
        return this;
    }

    public BaseDialogFragment setNegativeListener(ClickListener negativeListener) {
        mNegativeListener = negativeListener;
        return this;
    }

    public BaseDialogFragment setPositiveListener(ClickListener positiveListener) {
        mPositiveListener = positiveListener;
        return this;
    }

    public BaseDialogFragment hideNegativeView() {
        mIsHideNegativeView = true;
        return this;
    }

    public BaseDialogFragment setPositiveButtonColor(int color) {
        mPositiveButtonColor = color;
        return this;
    }

    public void showDialog(@NonNull Context context, @Nullable String tag) {
        if (!(context instanceof FragmentActivity)) {
            Log.e(TAG, "context is not instance of FragmentActivity");
            return;
        }
        FragmentManager manager = ((FragmentActivity) context).getSupportFragmentManager();
        Fragment fragment = manager.findFragmentByTag(tag);
        if (fragment != null && fragment instanceof DialogFragment) {
            return;
        }
        setCancelable(false);
        this.show(manager, tag);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.tuiroomkit_dialog_base, container, false);
        return mRootView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        TextView tvTitle = mRootView.findViewById(R.id.tuiroomkit_dialog_title);
        if (TextUtils.isEmpty(mTitle)) {
            tvTitle.setVisibility(View.GONE);
        } else {
            tvTitle.setText(mTitle);
        }
        TextView tvContent = mRootView.findViewById(R.id.tuiroomkit_dialog_content);
        if (TextUtils.isEmpty(mContent)) {
            tvContent.setVisibility(View.GONE);
        } else {
            tvContent.setText(mContent);
        }

        Button btnNegative = mRootView.findViewById(R.id.tuiroomkit_btn_dialog_negative);
        if (mIsHideNegativeView) {
            btnNegative.setVisibility(View.GONE);
        } else {
            if (!TextUtils.isEmpty(mNegativeName)) {
                btnNegative.setText(mNegativeName);
            }
            btnNegative.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    btnNegative.setClickable(false);
                    if (mNegativeListener != null) {
                        mNegativeListener.onClick();
                    }
                    dismissAllowingStateLoss();
                }
            });
        }

        Button btnPositive = mRootView.findViewById(R.id.tuiroomkit_btn_dialog_positive);
        if (!TextUtils.isEmpty(mPositiveName)) {
            btnPositive.setText(mPositiveName);
        }
        if (mPositiveButtonColor != 0) {
            btnPositive.setTextColor(mPositiveButtonColor);
        }
        btnPositive.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                btnPositive.setClickable(false);
                if (mPositiveListener != null) {
                    mPositiveListener.onClick();
                }
                dismissAllowingStateLoss();
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        Window window = getDialog().getWindow();
        window.setBackgroundDrawableResource(android.R.color.transparent);
    }
}
