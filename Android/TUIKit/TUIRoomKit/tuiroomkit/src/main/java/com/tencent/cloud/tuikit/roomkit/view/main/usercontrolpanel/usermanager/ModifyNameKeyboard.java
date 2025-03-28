package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.usermanager;

import android.app.Dialog;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.util.OnDecorViewListener;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;

import java.nio.charset.StandardCharsets;

public class ModifyNameKeyboard extends Dialog implements OnDecorViewListener.OnKeyboardCallback {
    private static final String FILE_NAME           = "keyboard.common";
    private static final String KEY_KEYBOARD_HEIGHT = "sp.key.keyboard.height";

    private final InputMethodManager mInputMethodManager;
    private final View               mLayoutOutSide;
    private final ViewGroup          mBottomPlaceholder;

    private Context             mContext;
    private EditText            mEditInputContent;
    private Button              mButtonModifyName;
    private int                 mKeyboardHeight;
    private int                 mLastScreenOrientation;
    private OnDecorViewListener mOnGlobalLayoutListener;
    private String              mTargetUserId;

    public ModifyNameKeyboard(@NonNull Context context, String userId, String userName) {
        super(context, R.style.RoomKitBarrageInputDialog);
        setContentView(R.layout.tuiroomkit_dialog_keyboard);
        mContext = context;
        mKeyboardHeight = SPUtils.getInstance(FILE_NAME).getInt(KEY_KEYBOARD_HEIGHT, ScreenUtil.dip2px(300));
        mInputMethodManager = (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        mLastScreenOrientation = getScreenOrientation(mContext);
        mLayoutOutSide = findViewById(R.id.rv_outside_view);
        mBottomPlaceholder = findViewById(R.id.fl_keyboard_bottom_placeholder);
        mEditInputContent = findViewById(R.id.edit_input);
        mButtonModifyName = findViewById(R.id.btn_modify_name);
        mEditInputContent.setText(userName);
        mTargetUserId = userId;
        InputFilter[] nameFilter = new InputFilter[]{new NameMaxLength()};
        mEditInputContent.setFilters(nameFilter);
        initListener();
    }

    private int getScreenOrientation(Context context) {
        Configuration screenConfig = context.getResources().getConfiguration();
        return screenConfig.orientation;
    }

    private void initListener() {
        mLayoutOutSide.addOnLayoutChangeListener((view, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
            int currentScreenOrientation = getScreenOrientation(mContext);
            if (mLastScreenOrientation != currentScreenOrientation) {
                mLastScreenOrientation = currentScreenOrientation;
                mInputMethodManager.hideSoftInputFromWindow(mEditInputContent.getWindowToken(), 0);
            }
        });

        mLayoutOutSide.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_DOWN) {
                View bottomView = findViewById(R.id.ll_keyboard_bottom);
                if (event.getY() < bottomView.getTop()) {
                    dismiss();
                    return true;
                }
            }
            return false;
        });

        mButtonModifyName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String userName = mEditInputContent.getText().toString();
                modifyNameCard(userName);
                dismiss();
            }
        });
    }

    private class NameMaxLength implements InputFilter {
        private static final int NAME_MAX_LENGTH = 32;

        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int destStart, int destEnd) {
            int currentBytes = countBytes(dest.toString());
            int inputBytes = countBytes(source.toString().substring(start, end));
            int newBytes = currentBytes + inputBytes;
            if (newBytes > NAME_MAX_LENGTH) {
                return "";
            }
            return null;
        }

        private int countBytes(String str) {
            return str.getBytes(StandardCharsets.UTF_8).length;
        }
    }

    @Override
    public void onKeyboardHeightUpdated(int keyboardHeight) {
        if (mKeyboardHeight != keyboardHeight) {
            mKeyboardHeight = keyboardHeight;
            SPUtils.getInstance(FILE_NAME).put(KEY_KEYBOARD_HEIGHT, mKeyboardHeight);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mEditInputContent.requestFocus();
        mInputMethodManager.showSoftInput(mEditInputContent, InputMethodManager.SHOW_FORCED);
    }

    @Override
    public void onAttachedToWindow() {
        addOnGlobalLayoutListener();
        super.onAttachedToWindow();
    }

    @Override
    public void onDetachedFromWindow() {
        removeOnGlobalLayoutListener();
        super.onDetachedFromWindow();
    }

    private void addOnGlobalLayoutListener() {
        Window window = getWindow();
        if (window != null) {
            final View decorView = window.getDecorView();
            if (mOnGlobalLayoutListener == null) {
                mOnGlobalLayoutListener = new OnDecorViewListener(decorView, this);
            }
            decorView.getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
        }
    }

    private void removeOnGlobalLayoutListener() {
        Window window = getWindow();
        if (window != null) {
            final View decorView = window.getDecorView();
            if (mOnGlobalLayoutListener != null) {
                mOnGlobalLayoutListener.clear();
                decorView.getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
            }
        }
    }

    private void modifyNameCard(String newNameCard) {
        if (TextUtils.isEmpty(newNameCard)) {
            return;
        }
        ConferenceController.sharedInstance().changeUserNameCard(mTargetUserId, newNameCard, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                RoomToast.toastShortMessage(mContext.getString(R.string.tuiroomkit_modify_name_success));
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                RoomToast.toastShortMessageCenter(s);
            }
        });
    }

    @Override
    public void dismiss() {
        ViewGroup.LayoutParams layoutParams = mBottomPlaceholder.getLayoutParams();
        layoutParams.height = 0;
        mBottomPlaceholder.setLayoutParams(layoutParams);
        mInputMethodManager.hideSoftInputFromWindow(mEditInputContent.getWindowToken(), 0);
        mEditInputContent.setText("");
        if (mOnGlobalLayoutListener != null) {
            mOnGlobalLayoutListener.clear();
        }
        super.dismiss();
    }
}
