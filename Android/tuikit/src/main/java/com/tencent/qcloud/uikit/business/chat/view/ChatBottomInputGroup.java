package com.tencent.qcloud.uikit.business.chat.view;

import android.app.Activity;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfoUtil;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatActionsFragment;
import com.tencent.qcloud.uikit.business.chat.view.widget.MessageOperaUnit;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.component.audio.UIKitAudioArmMachine;
import com.tencent.qcloud.uikit.common.component.face.Emoji;
import com.tencent.qcloud.uikit.common.component.face.FaceFragment;
import com.tencent.qcloud.uikit.common.component.face.FaceManager;
import com.tencent.qcloud.uikit.common.component.picture.Matisse;
import com.tencent.qcloud.uikit.common.component.video.CameraActivity;
import com.tencent.qcloud.uikit.common.component.video.JCameraView;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class ChatBottomInputGroup extends LinearLayout implements View.OnClickListener, UIKitAudioArmMachine.AudioRecordCallback, TextWatcher {

    /**
     * 语音/文字切换输入按钮
     */
    public ImageView switchBtn;
    /**
     * 表情按钮
     */
    public ImageView faceBtn;
    /**
     * 更多按钮
     */
    public ImageView moreBtn;

    /**
     * 消息发送按钮
     */
    public Button sendBtn;

    /**
     * 语音长按按钮
     */
    public Button voiceBtn;
    /**
     * 文本输入框
     */
    public EditText msgEditor;

    private ChatActionsFragment actionsFragment;

    private FaceFragment faceFragment;

    private View moreGroup;
    private ChatInputHandler inputHandler;
    private MessageHandler msgHandler;
    private Activity activity;
    private FragmentManager fragmentManager;
    private List<MessageOperaUnit> actions = new ArrayList<>();

    private static final int STATE_NONE_INPUT = -1;
    private static final int STATE_SOFT_INPUT = 0;
    private static final int STATE_VOICE_INPUT = 1;
    private static final int STATE_FACE_INPUT = 2;
    private static final int STATE_ACTION_INPUT = 3;
    private boolean sendAble, audioCancel;
    private int currentState;
    private int lastMsgLineCount;
    private float startRecordY;


    public ChatBottomInputGroup(Context context) {
        super(context);
        init();
    }

    public ChatBottomInputGroup(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ChatBottomInputGroup(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        activity = (Activity) getContext();
        inflate(getContext(), R.layout.chat_bottom_group, this);
        moreGroup = findViewById(R.id.more_groups);
        voiceBtn = findViewById(R.id.chat_voice_input);
        switchBtn = findViewById(R.id.voice_input_switch);
        switchBtn.setOnClickListener(this);
        faceBtn = findViewById(R.id.face_btn);
        faceBtn.setOnClickListener(this);
        moreBtn = findViewById(R.id.more_btn);
        moreBtn.setOnClickListener(this);
        sendBtn = findViewById(R.id.send_btn);
        sendBtn.setOnClickListener(this);
        msgEditor = findViewById(R.id.chat_message_input);
        msgEditor.addTextChangedListener(this);
        msgEditor.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                showSoftInput();
                return false;
            }
        });

        msgEditor.setOnKeyListener(new OnKeyListener() {
            @Override
            public boolean onKey(View view, int i, KeyEvent keyEvent) {
                return false;
            }
        });

        msgEditor.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                return false;
            }
        });

        voiceBtn.setOnTouchListener(new OnTouchListener() {
            private long start;

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {

                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
                    audioCancel = true;
                    startRecordY = motionEvent.getY();
                    if (inputHandler != null)
                        inputHandler.startRecording();
                    start = System.currentTimeMillis();
                    UIKitAudioArmMachine.getInstance().startRecord(ChatBottomInputGroup.this);

                } else if (motionEvent.getAction() == MotionEvent.ACTION_MOVE) {
                    if (motionEvent.getY() - startRecordY < -100) {
                        audioCancel = true;
                        if (inputHandler != null)
                            inputHandler.cancelRecording();
                    } else {
                        audioCancel = false;
                        if (inputHandler != null)
                            inputHandler.startRecording();
                    }

                } else if (motionEvent.getAction() == MotionEvent.ACTION_UP) {

                    if (motionEvent.getY() - startRecordY < -100) {
                        audioCancel = true;
                    } else {
                        audioCancel = false;
                    }
                    UIKitAudioArmMachine.getInstance().stopRecord();
                }
                return false;
            }
        });

        initDefaultActions();

    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        msgEditor.removeTextChangedListener(this);
    }

    private void initDefaultActions() {
        MessageOperaUnit action = new MessageOperaUnit();
        action.setIconResId(R.drawable.pic);
        action.setTitleId(R.string.pic);
        action.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                Matisse.defaultFrom(activity, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        if (data instanceof List) {
                            List<Uri> uris = (List<Uri>) data;
                            for (int i = 0; i < uris.size(); i++) {
                                MessageInfo info = MessageInfoUtil.buildImageMessage(uris.get(i), true, false);
                                if (msgHandler != null)
                                    msgHandler.sendMessage(info);
                            }
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                });
            }
        });
        actions.add(action);
        action = new MessageOperaUnit();
        action.setIconResId(R.drawable.action_video_selector);
        action.setTitleId(R.string.action_file);
        action.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("*/*");//设置类型，我这里是任意类型，任意后缀的可以这样写。
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                actionsFragment.setCallback(new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        MessageInfo info = MessageInfoUtil.buildFileMessage((Uri) data);
                        if (msgHandler != null)
                            msgHandler.sendMessage(info);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        UIUtils.toastLongMessage(errMsg);
                    }
                });
                actionsFragment.startActivityForResult(intent, ChatActionsFragment.REQUEST_CODE_FILE);
            }
        });


        action = new MessageOperaUnit();
        action.setIconResId(R.drawable.photo);
        action.setTitleId(R.string.photo);
        action.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent captureIntent = new Intent(getContext(), CameraActivity.class);
                captureIntent.putExtra(UIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_CAPTURE);
                CameraActivity.mCallBack = new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        Uri contentUri = Uri.fromFile(new File(data.toString()));
                        MessageInfo msg = MessageInfoUtil.buildImageMessage(contentUri, true, true);
                        if (msgHandler != null)
                            msgHandler.sendMessage(msg);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                };
                getContext().startActivity(captureIntent);
            }
        });
        actions.add(action);

        action = new MessageOperaUnit();
        action.setIconResId(R.drawable.video);
        action.setTitleId(R.string.video);
        action.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent captureIntent = new Intent(getContext(), CameraActivity.class);
                captureIntent.putExtra(UIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_RECORDER);
                CameraActivity.mCallBack = new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        Intent videoData = (Intent) data;
                        String imgPath = videoData.getStringExtra(UIKitConstants.CAMERA_IMAGE_PATH);
                        String videoPath = videoData.getStringExtra(UIKitConstants.CAMERA_VIDEO_PATH);
                        int imgWidth = videoData.getIntExtra(UIKitConstants.IMAGE_WIDTH, 0);
                        int imgHeight = videoData.getIntExtra(UIKitConstants.IMAGE_HEIGHT, 0);
                        long duration = videoData.getLongExtra(UIKitConstants.VIDEO_TIME, 0);
                        MessageInfo msg = MessageInfoUtil.buildVideoMessage(imgPath, videoPath, imgWidth, imgHeight, duration);
                        if (msgHandler != null)
                            msgHandler.sendMessage(msg);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                };
                getContext().startActivity(captureIntent);
            }
        });
        actions.add(action);

        action = new MessageOperaUnit();
        action.setIconResId(R.drawable.file);
        action.setTitleId(R.string.file);
        action.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("*/*");//设置类型，我这里是任意类型，任意后缀的可以这样写。
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                actionsFragment.setCallback(new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        MessageInfo info = MessageInfoUtil.buildFileMessage((Uri) data);
                        if (msgHandler != null)
                            msgHandler.sendMessage(info);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        UIUtils.toastLongMessage(errMsg);
                    }
                });
                actionsFragment.startActivityForResult(intent, ChatActionsFragment.REQUEST_CODE_FILE);
                //UIUtils.toastLongMessage("文件");
            }
        });
        actions.add(action);
    }

    public void setMoreOperaUnits(List<MessageOperaUnit> actions, boolean isAdd) {
        if (isAdd) {
            this.actions.addAll(actions);
        } else {
            this.actions = actions;
        }
        actionsFragment.setActions(actions);
    }


    public void setInputHandler(ChatInputHandler handler) {
        this.inputHandler = handler;
    }


    public void setMsgHandler(MessageHandler handler) {
        this.msgHandler = handler;
    }


    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.voice_input_switch) {
            if (currentState == STATE_SOFT_INPUT)
                currentState = STATE_VOICE_INPUT;
            else
                currentState = STATE_SOFT_INPUT;
            if (currentState == STATE_VOICE_INPUT) {
                switchBtn.setImageResource(R.drawable.action_textinput_selector);
                voiceBtn.setVisibility(VISIBLE);
                msgEditor.setVisibility(GONE);
                faceBtn.setVisibility(View.GONE);
                hideSoftInput();
            } else {
                switchBtn.setImageResource(R.drawable.action_audio_selector);
                voiceBtn.setVisibility(GONE);
                msgEditor.setVisibility(VISIBLE);
                faceBtn.setVisibility(View.VISIBLE);
                showSoftInput();
            }

        } else if (view.getId() == R.id.face_btn) {
            if (currentState == STATE_FACE_INPUT) {
                currentState = STATE_NONE_INPUT;
                moreGroup.setVisibility(View.GONE);
            } else {
                showFaceViewGroup();
                currentState = STATE_FACE_INPUT;
            }
        } else if (view.getId() == R.id.more_btn) {
            if (currentState == STATE_ACTION_INPUT) {
                currentState = STATE_NONE_INPUT;
                moreGroup.setVisibility(View.GONE);
            } else {
                showActionsGroup();
                currentState = STATE_ACTION_INPUT;
            }
        } else if (view.getId() == R.id.send_btn) {
            if (sendAble) {
                if (msgHandler != null)
                    msgHandler.sendMessage(MessageInfoUtil.buildTextMessage(msgEditor.getText().toString()));
                msgEditor.setText("");
            }
        }
    }

    private void showSoftInput() {
        hideActionsGroup();
     /*   if (moreGroup.getVisibility() == VISIBLE) {
            activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING | WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        } else {
            activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        }*/
        currentState = STATE_SOFT_INPUT;
        switchBtn.setImageResource(R.drawable.action_audio_selector);
        faceBtn.setImageResource(R.drawable.bottom_action_face_normal);
        msgEditor.requestFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(msgEditor, 0);
        if (inputHandler != null)
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    inputHandler.popupAreaShow();
                }
            }, 200);

    }


    public void hideSoftInput() {
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(msgEditor.getWindowToken(), 0);
        msgEditor.clearFocus();
        if (inputHandler != null)
            inputHandler.popupAreaHide();
        moreGroup.setVisibility(View.GONE);
        currentState = STATE_NONE_INPUT;
    }

    private void showFaceViewGroup() {
        if (fragmentManager == null)
            fragmentManager = activity.getFragmentManager();
        if (faceFragment == null)
            faceFragment = new FaceFragment();
        hideSoftInput();
//        postDelayed(new Runnable() {
//            @Override
//            public void run() {
        moreGroup.setVisibility(View.VISIBLE);
        msgEditor.requestFocus();
        faceFragment.setListener(new FaceFragment.OnEmojiClickListener() {
            @Override
            public void onEmojiDelete() {
                int index = msgEditor.getSelectionStart();
                Editable editable = msgEditor.getText();
                boolean isFace = false;
                if (index <= 0)
                    return;
                if (editable.charAt(index - 1) == ']') {
                    for (int i = index - 2; i >= 0; i--) {
                        if (editable.charAt(i) == '[') {
                            String faceChar = editable.subSequence(i, index).toString();
                            if (FaceManager.isFaceChar(faceChar)) {
                                editable.delete(i, index);
                                isFace = true;
                            }
                            break;
                        }
                    }
                }
                if (!isFace) {
                    editable.delete(index - 1, index);
                }
            }

            @Override
            public void onEmojiClick(Emoji emoji) {
                int index = msgEditor.getSelectionStart();
                Editable editable = msgEditor.getText();
                editable.insert(index, emoji.getFilter());
                FaceManager.handlerEmojiText(msgEditor, editable.toString());
            }

            @Override
            public void onCustomFaceClick(int groupIndex, Emoji emoji) {
                msgHandler.sendMessage(MessageInfoUtil.buildCustomFaceMessage(groupIndex, emoji.getFilter()));
            }
        });
        fragmentManager.beginTransaction().replace(R.id.more_groups, faceFragment).commitAllowingStateLoss();
        if (inputHandler != null)
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    inputHandler.popupAreaShow();
                }
            }, 100);

        //      }
        //  }, 100);

    }

    private void showActionsGroup() {
        if (fragmentManager == null)
            fragmentManager = activity.getFragmentManager();
        if (actionsFragment == null)
            actionsFragment = new ChatActionsFragment();

        actionsFragment.setActions(actions);
        hideSoftInput();
        moreGroup.setVisibility(View.VISIBLE);
        fragmentManager.beginTransaction().replace(R.id.more_groups, actionsFragment).commitAllowingStateLoss();
        if (inputHandler != null)
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    inputHandler.popupAreaShow();
                }
            }, 100);
    }

    private void hideActionsGroup() {
        moreGroup.setVisibility(View.GONE);
    }

    @Override
    public void recordComplete(long duration) {
        if (inputHandler != null) {
            if (audioCancel) {
                inputHandler.stopRecording();
                return;
            }
            if (duration < 500) {
                inputHandler.tooShortRecording();
                return;
            }
            inputHandler.stopRecording();
        }

        if (msgHandler != null)
            msgHandler.sendMessage(MessageInfoUtil.buildAudioMessage(UIKitAudioArmMachine.getInstance().getRecordAudioPath(), (int) duration));
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void afterTextChanged(Editable s) {
        if (s.length() > TUIKit.getBaseConfigs().getMaxInputTextLength()) {
            msgEditor.setText(s.subSequence(1, s.length()));
            UIUtils.toastLongMessage("已达最大消息长度");
            return;
        }


        if (!TextUtils.isEmpty(s.toString())) {
            sendAble = true;
            sendBtn.setVisibility(View.VISIBLE);
            moreBtn.setVisibility(View.GONE);
            if (msgEditor.getLineCount() != lastMsgLineCount) {
                lastMsgLineCount = msgEditor.getLineCount();
                if (inputHandler != null)
                    inputHandler.popupAreaShow();
            }
        } else {
            sendAble = false;
            sendBtn.setVisibility(View.GONE);
            moreBtn.setVisibility(View.VISIBLE);

        }
    }


    public interface MessageHandler {
        public void sendMessage(MessageInfo msg);
    }


    public interface ChatInputHandler {

        void popupAreaShow();

        void popupAreaHide();

        void startRecording();

        void stopRecording();

        void tooShortRecording();

        void cancelRecording();
    }

}
