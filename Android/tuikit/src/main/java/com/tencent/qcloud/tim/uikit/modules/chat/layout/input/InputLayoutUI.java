package com.tencent.qcloud.tim.uikit.modules.chat.layout.input;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IInputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreActionUnit;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.List;

abstract class InputLayoutUI extends LinearLayout implements IInputLayout {

    private static String TAG = InputLayoutUI.class.getSimpleName();

    protected static final int CAPTURE = 1;
    protected static final int AUDIO_RECORD = 2;
    protected static final int VIDEO_RECORD = 3;
    protected static final int SEND_PHOTO = 4;
    protected static final int SEND_FILE = 5;

    /**
     * 语音/文字切换输入控件
     */
    protected ImageView mAudioInputSwitchButton;
    protected boolean mAudioInputDisable;

    /**
     * 表情按钮
     */
    protected ImageView mEmojiInputButton;
    protected boolean mEmojiInputDisable;

    /**
     * 更多按钮
     */
    protected ImageView mMoreInputButton;
    protected Object mMoreInputEvent;
    protected boolean mMoreInputDisable;

    /**
     * 消息发送按钮
     */
    protected Button mSendTextButton;

    /**
     * 语音长按按钮
     */
    protected Button mSendAudioButton;

    /**
     * 文本输入框
     */
    protected EditText mTextInput;

    protected Activity mActivity;
    protected View mInputMoreLayout;
    private AlertDialog mPermissionDialog;

    //    protected ShortcutArea mShortcutArea;
    protected View mInputMoreView;

    private boolean mSendPhotoDisable;
    private boolean mCaptureDisable;
    private boolean mVideoRecordDisable;
    private boolean mSendFileDisable;
    protected List<InputMoreActionUnit> mInputMoreActionList = new ArrayList<>();
    protected List<InputMoreActionUnit> mInputMoreCustomActionList = new ArrayList<>();

    public InputLayoutUI(Context context) {
        super(context);
        initViews();
    }

    public InputLayoutUI(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initViews();
    }

    public InputLayoutUI(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initViews();
    }

    private void initViews() {
        mActivity = (Activity) getContext();
        inflate(mActivity, R.layout.chat_input_layout, this);
//        mShortcutArea = findViewById(R.id.shortcut_area);
        mInputMoreView = findViewById(R.id.more_groups);
        mSendAudioButton = findViewById(R.id.chat_voice_input);
        mAudioInputSwitchButton = findViewById(R.id.voice_input_switch);
        mEmojiInputButton = findViewById(R.id.face_btn);
        mMoreInputButton = findViewById(R.id.more_btn);
        mSendTextButton = findViewById(R.id.send_btn);
        mTextInput = findViewById(R.id.chat_message_input);

        // 子类实现所有的事件处理
        init();
    }

    protected void assembleActions() {
        mInputMoreActionList.clear();
        InputMoreActionUnit action = new InputMoreActionUnit();
        if (!mSendPhotoDisable) {
            action.setIconResId(R.drawable.ic_more_picture);
            action.setTitleId(R.string.pic);
            action.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    startSendPhoto();
                }
            });
            mInputMoreActionList.add(action);
        }

        if (!mCaptureDisable) {
            action = new InputMoreActionUnit();
            action.setIconResId(R.drawable.ic_more_camera);
            action.setTitleId(R.string.photo);
            action.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    startCapture();
                }
            });
            mInputMoreActionList.add(action);
        }

        if (!mVideoRecordDisable) {
            action = new InputMoreActionUnit();
            action.setIconResId(R.drawable.ic_more_video);
            action.setTitleId(R.string.video);
            action.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    startVideoRecord();
                }
            });
            mInputMoreActionList.add(action);
        }

        if (!mSendFileDisable) {
            action = new InputMoreActionUnit();
            action.setIconResId(R.drawable.ic_more_file);
            action.setTitleId(R.string.file);
            action.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    startSendFile();
                }
            });
            mInputMoreActionList.add(action);
        }
        mInputMoreActionList.addAll(mInputMoreCustomActionList);

    }

    protected boolean checkPermission(Context context, String permission) {
        TUIKitLog.i(TAG, "checkPermission permission:" + permission + "|sdk:" + Build.VERSION.SDK_INT);
        boolean flag = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int result = ActivityCompat.checkSelfPermission(context, permission);
            if (PackageManager.PERMISSION_GRANTED != result) {
                showPermissionDialog();
                flag = false;
            }
        }
        return flag;
    }

    protected boolean checkPermission(int type) {
        if (!checkPermission(mActivity, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            return false;
        }
        if (!checkPermission(mActivity, Manifest.permission.READ_EXTERNAL_STORAGE)) {
            return false;
        }
        if (type == SEND_FILE || type == SEND_PHOTO) {
            return true;
        } else if (type == CAPTURE) {
            return checkPermission(mActivity, Manifest.permission.CAMERA);
        } else if (type == AUDIO_RECORD) {
            return checkPermission(mActivity, Manifest.permission.RECORD_AUDIO);
        } else if (type == VIDEO_RECORD) {
            return checkPermission(mActivity, Manifest.permission.CAMERA)
                    && checkPermission(mActivity, Manifest.permission.RECORD_AUDIO);
        }
        return true;
    }

    private void showPermissionDialog() {
        if (mPermissionDialog == null) {
            mPermissionDialog = new AlertDialog.Builder(mActivity)
                    .setMessage("使用该功能，需要开启权限，鉴于您禁用相关权限，请手动设置开启权限")
                    .setPositiveButton("设置", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            cancelPermissionDialog();
                            Uri packageURI = Uri.parse("package:" + mActivity.getPackageName());
                            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageURI);
                            mActivity.startActivity(intent);
                        }
                    })
                    .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            //关闭页面或者做其他操作
                            cancelPermissionDialog();
                        }
                    })
                    .create();
        }
        mPermissionDialog.show();
    }

    private void cancelPermissionDialog() {
        mPermissionDialog.cancel();
    }

    protected abstract void init();

    protected abstract void startSendPhoto();

    protected abstract void startCapture();

    protected abstract void startVideoRecord();

    protected abstract void startSendFile();

    @Override
    public void disableAudioInput(boolean disable) {
        mAudioInputDisable = disable;
        if (disable) {
            mAudioInputSwitchButton.setVisibility(GONE);
        } else {
            mAudioInputSwitchButton.setVisibility(VISIBLE);
        }
    }

    @Override
    public void disableEmojiInput(boolean disable) {
        mEmojiInputDisable = disable;
        if (disable) {
            mEmojiInputButton.setVisibility(GONE);
        } else {
            mEmojiInputButton.setVisibility(VISIBLE);
        }
    }

    @Override
    public void disableMoreInput(boolean disable) {
        mMoreInputDisable = disable;
        if (disable) {
            mMoreInputButton.setVisibility(GONE);
            mSendTextButton.setVisibility(VISIBLE);
        } else {
            mMoreInputButton.setVisibility(VISIBLE);
            mSendTextButton.setVisibility(GONE);
        }
    }

    @Override
    public void replaceMoreInput(BaseInputFragment fragment) {
        mMoreInputEvent = fragment;
    }

    @Override
    public void replaceMoreInput(OnClickListener listener) {
        mMoreInputEvent = listener;
    }

    @Override
    public void disableSendPhotoAction(boolean disable) {
        mSendPhotoDisable = disable;
    }

    @Override
    public void disableCaptureAction(boolean disable) {
        mCaptureDisable = disable;
    }

    @Override
    public void disableVideoRecordAction(boolean disable) {
        mVideoRecordDisable = disable;
    }

    @Override
    public void disableSendFileAction(boolean disable) {
        mSendFileDisable = disable;
    }

    @Override
    public void addAction(InputMoreActionUnit action) {
        mInputMoreCustomActionList.add(action);
    }

    protected void showMoreInputButton(int visibility) {
        if (mMoreInputDisable) {
            return;
        }
        mMoreInputButton.setVisibility(visibility);
    }

    protected void showSendTextButton(int visibility) {
        if (mMoreInputDisable) {
            mSendTextButton.setVisibility(VISIBLE);
        } else {
            mSendTextButton.setVisibility(visibility);
        }
    }

    protected void showEmojiInputButton(int visibility) {
        if (mEmojiInputDisable) {
            return;
        }
        mEmojiInputButton.setVisibility(visibility);
    }
}
