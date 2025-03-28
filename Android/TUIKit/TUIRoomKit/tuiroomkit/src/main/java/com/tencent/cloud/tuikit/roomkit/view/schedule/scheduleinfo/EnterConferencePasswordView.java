package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.PasswordTransformationMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

public class EnterConferencePasswordView extends DialogFragment {
    private static final String TAG             = "EnterPasswordView";
    private static final String KEY_HUAWEI      = "HUAWEI";
    public static final  String PASSWORD_FORMAT = "[^a-zA-Z0-9~`!@#$%^&*()-_=+\\{\\}\\[\\]\\\\|;:'\",<.>/?]";

    private static final int VERSION_O_MR1 = 27;

    private View                    mDialogView;
    private EditText                mEtInputPassword;
    private ImageView               mClearPassword;
    private Button                  mCancelPassword;
    private Button                  mConfirmPassword;
    private PasswordPopViewCallback mCallback;

    public interface PasswordPopViewCallback {
        void onCancel();

        void onConfirm(String password);
    }

    public void setCallback(PasswordPopViewCallback callback) {
        mCallback = callback;
    }

    public void enableJoinRoomButton(boolean enable) {
        float alpha = enable ? 1 : 0.5f;
        mConfirmPassword.setAlpha(alpha);
        mConfirmPassword.setEnabled(enable);
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
        mDialogView = inflater.inflate(R.layout.tuiroomkit_dialog_conference_password, container, false);
        return mDialogView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mEtInputPassword = mDialogView.findViewById(R.id.et_conference_password);
        mCancelPassword = mDialogView.findViewById(R.id.btn_cancel_input_password);
        mConfirmPassword = mDialogView.findViewById(R.id.btn_confirm_input_password);
        mClearPassword = mDialogView.findViewById(R.id.img_clear_password);
        mClearPassword.setVisibility(TextUtils.isEmpty(mEtInputPassword.getText().toString()) ? View.GONE : View.VISIBLE);
        mClearPassword.setVisibility(View.GONE);
        enableJoinRoomButton(false);

        InputFilter[] passwordFilter = new InputFilter[]{new PasswordMaxLength()};
        mEtInputPassword.setFilters(passwordFilter);
        if (isHUAWEI() && TUIBuild.getVersionInt() >= VERSION_O_MR1) {
            mEtInputPassword.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_NUMBER_VARIATION_NORMAL);
            mEtInputPassword.setTransformationMethod(PasswordTransformationMethod.getInstance());
        }

        mClearPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!TextUtils.isEmpty(mEtInputPassword.getText().toString())) {
                    mEtInputPassword.setText("");
                }
            }
        });
        mEtInputPassword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                boolean isEmpty = TextUtils.isEmpty(mEtInputPassword.getText().toString());
                mClearPassword.setVisibility(isEmpty ? View.GONE : View.VISIBLE);
                enableJoinRoomButton(!isEmpty);
            }
        });

        mConfirmPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCallback != null) {
                    mCallback.onConfirm(mEtInputPassword.getText().toString());
                }
            }
        });

        mCancelPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCallback != null) {
                    mCallback.onCancel();
                }
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        Window window = getDialog().getWindow();
        window.setBackgroundDrawableResource(android.R.color.transparent);
    }


    public static boolean isHUAWEI() {
        return KEY_HUAWEI.equalsIgnoreCase(TUIBuild.getManufacturer());
    }

    private class PasswordMaxLength implements InputFilter {
        private static final int NAME_MAX_LENGTH = 32;

        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int destStart, int destEnd) {
            int currentBytes = countBytes(dest.toString());
            int inputBytes = countBytes(source.toString().substring(start, end));
            int newBytes = currentBytes + inputBytes;
            Pattern pattern = Pattern.compile(PASSWORD_FORMAT);
            if (newBytes > NAME_MAX_LENGTH || pattern.matcher(source).find()) {
                return "";
            }
            return null;
        }

        private int countBytes(String str) {
            return str.getBytes(StandardCharsets.UTF_8).length;
        }
    }
}
