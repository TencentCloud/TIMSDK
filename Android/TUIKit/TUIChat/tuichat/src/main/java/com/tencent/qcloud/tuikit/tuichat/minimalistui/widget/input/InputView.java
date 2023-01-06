package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.webkit.MimeTypeMap;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.AudioPlayer;
import com.tencent.qcloud.tuikit.tuichat.component.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFace;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.JCameraView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.face.FaceFragment;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.inputmore.InputMoreDialogFragment;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.waveview.VoiceWaveView.VoiceWaveView;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

/**
 * 聊天界面，底部发送图片、拍照、摄像、文件面板
 * 
 * Chat interface, send pictures, take pictures, video, file panels at the bottom
 */

public class InputView extends LinearLayout implements View.OnClickListener, TextWatcher {
    private static final String TAG = InputView.class.getSimpleName();

    // 音视频通话成员数限制
    // Membership limit for audio and video calls
    protected static final int CALL_MEMBER_LIMIT = 8;

    protected ImageView faceKeyboardInputButton;
    protected ImageView inputMoreBtn;
    protected Button voiceBtn;
    protected ImageView imageBtn;
    protected boolean mEmojiInputDisable;
    protected ImageView voiceDeleteImage;

    protected Object mMoreInputEvent;
    protected boolean mMoreInputDisable;

    /**
     * 文本输入框
     * 
     * input text
     */
    protected TIMMentionEditText mTextInput;
    private LinearLayout mTextInputLayout;
    private boolean mIsSending = false;

    protected View mInputMoreLayout;
    protected Button mSendAudioButton;
    protected ViewGroup mSendAudioButtonLayout;
    protected VoiceWaveView mVoiceWaveView;
    private Timer mTimer;
    private int times;

    protected ChatInfo mChatInfo;
    protected List<InputMoreActionUnit> mInputMoreActionList = new ArrayList<>();
    protected List<InputMoreActionUnit> mInputMoreCustomActionList = new ArrayList<>();
    private AlertDialog mPermissionDialog;
    private boolean mSendPhotoDisable;
    private boolean mCaptureDisable;
    private boolean mVideoRecordDisable;
    private boolean mSendFileDisable;

    private InputMoreDialogFragment mInputMoreFragment;
    private FaceFragment faceFragment;
    private ChatInputHandler mChatInputHandler;
    private MessageHandler mMessageHandler;
    private IChatLayout mChatLayout;
    private boolean mSendEnable;
    private boolean mAudioCancel;
    private int mCurrentState;
    private int mLastMsgLineCount;
    private float mStartRecordY;
    private float mStartRecordX;
    private String mInputContent;
    private OnInputViewListener mOnInputViewListener;

    private Map<String,String> atUserInfoMap = new HashMap<>();
    private String displayInputString;

    private ChatPresenter presenter;

    private boolean isReplyModel = false;
    private boolean isQuoteModel = false;
    private ReplyPreviewBean replyPreviewBean;
    private View replyPreviewBar;
    private ImageView replyCloseBtn;
    private TextView replyTv;
    private TextView replyUserNameTv;
    private View quotePreviewBar;
    private TextView quoteTv;
    private ImageView quoteCloseBtn;
    private boolean isShowCustomFace = true;
    private FragmentManager fragmentManager;
    // Input state machine
    private InputMachine inputMachine;
    public InputView(Context context) {
        super(context);
        initViews();
    }

    public InputView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initViews();
    }

    public InputView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initViews();
    }

    public void setPresenter(ChatPresenter presenter) {
        this.presenter = presenter;
    }

    private void initViews() {
        inflate(getContext(), R.layout.chat_minimalist_input_layout, this);
        faceKeyboardInputButton = findViewById(R.id.input_face_btn);
        mTextInput = findViewById(R.id.input_edit_text);
        inputMoreBtn = findViewById(R.id.input_more_btn);
        voiceBtn = findViewById(R.id.input_voice_btn);
        imageBtn = findViewById(R.id.input_image_btn);
        mInputMoreLayout = findViewById(R.id.more_groups);
        mSendAudioButton = findViewById(R.id.chat_voice_input);
        mSendAudioButtonLayout = findViewById(R.id.chat_voice_input_layout);
        mTextInputLayout = findViewById(R.id.text_input_layout);
        voiceDeleteImage = findViewById(R.id.voice_delete);
        mSendAudioButton.setTextColor(getResources().getColor(R.color.white));
        mVoiceWaveView = findViewById(R.id.voice_wave_view);

        replyPreviewBar = findViewById(R.id.reply_preview_bar);
        replyTv = replyPreviewBar.findViewById(R.id.reply_preview_bar_text);
        replyUserNameTv = findViewById(R.id.reply_preview_bar_name);
        replyCloseBtn = findViewById(R.id.reply_preview_bar_close_btn);
        quotePreviewBar = findViewById(R.id.quote_preview_bar);
        quoteTv = quotePreviewBar.findViewById(R.id.quote_text);
        quoteCloseBtn = quotePreviewBar.findViewById(R.id.quote_close_btn);
        mIsSending = false;
        times = 0;

        init();
    }

    @SuppressLint("ClickableViewAccessibility")
    protected void init() {
        initInputMachine();
        fragmentManager = getActivity().getSupportFragmentManager();
        faceKeyboardInputButton.setOnClickListener(this);
        mTextInput.setMaxLines(6);
        mTextInput.setInputType(EditorInfo.TYPE_TEXT_FLAG_MULTI_LINE);
        mTextInput.setSingleLine(false);
        mTextInput.setImeOptions(EditorInfo.IME_ACTION_SEND);
        mTextInput.addTextChangedListener(this);

        inputMoreBtn.setOnClickListener(this);
        imageBtn.setOnClickListener(this);

        mTextInput.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if(motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
                    if (presenter != null) {
                        presenter.scrollToNewestMessage();
                    }
                    inputMachine.execute(InputAction.INPUT_CLICKED);
                }
                return false;
            }
        });

        mTextInput.setOnKeyListener(new OnKeyListener() {
            @Override
            public boolean onKey(View view, int keyCode, KeyEvent keyEvent) {
                if (keyCode == KeyEvent.KEYCODE_DEL && keyEvent.getAction() == KeyEvent.ACTION_DOWN) {
                    if ((isQuoteModel || isReplyModel) && TextUtils.isEmpty(mTextInput.getText().toString())) {
                        exitReply();
                    }
                }
                return false;
            }
        });

        mTextInput.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                return false;
            }
        });

        mTextInput.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean focus) {
                if (!focus && mChatInputHandler != null) {
                    mChatInputHandler.onUserTyping(false, V2TIMManager.getInstance().getServerTime());
                }
            }
        });

        voiceBtn.setOnTouchListener(new OnTouchListener() {

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                int action = motionEvent.getAction();
                TUIChatLog.i(TAG, "mSendAudioButton onTouch action:" + action);

                if (action == MotionEvent.ACTION_CANCEL || action == MotionEvent.ACTION_UP) {
                    inputMachine.execute(InputAction.AUDIO_CLICKED);
                }
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        switch (action) {
                            case MotionEvent.ACTION_DOWN:
                                mAudioCancel = true;
                                mStartRecordY = motionEvent.getY();
                                mStartRecordX = motionEvent.getX();
                                inputMachine.execute(InputAction.AUDIO_CLICKED);
                                voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_icon);
                                mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_blue));
                                break;
                            case MotionEvent.ACTION_MOVE:
                                if (motionEvent.getX() - mStartRecordX < -100) {
                                    mAudioCancel = true;
                                    if (mChatInputHandler != null) {
                                        mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                                    }
                                    voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_start_icon);
                                    mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_red));
                                } else {
                                    if (mAudioCancel) {
                                        if (mChatInputHandler != null) {
                                            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                                        }
                                    }
                                    mAudioCancel = false;
                                    voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_icon);
                                    mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_blue));
                                }
                                //mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.release_end));
                                break;
                            case MotionEvent.ACTION_CANCEL:
                            case MotionEvent.ACTION_UP:
                                mAudioCancel = motionEvent.getX() - mStartRecordX < -100;
                                break;
                            default:
                                break;
                        }
                    }

                    @Override
                    public void onDenied() {
                        TUIChatLog.i(TAG, "audio record checkPermission failed");

                    }
                });
                return false;
            }
        });

        mTextInput.setOnMentionInputListener(new TIMMentionEditText.OnMentionInputListener() {
            @Override
            public void onMentionCharacterInput(String tag) {
                if ((tag.equals(TIMMentionEditText.TIM_MENTION_TAG) || tag.equals(TIMMentionEditText.TIM_MENTION_TAG_FULL))
                        && TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType())) {
                    if (mOnInputViewListener != null) {
                        mOnInputViewListener.onStartGroupMemberSelectActivity();
                    }
                }
            }
        });

        mTextInput.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEND) {
                    send();
                }
                return true;
            }
        });


        replyCloseBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                exitReply();
            }
        });

        quoteCloseBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                exitReply();
            }
        });
    }

    private void updateChatBackground() {
        if (mOnInputViewListener != null) {
            mOnInputViewListener.onUpdateChatBackground();
        }
    }
    
    private void send() {
        if (mSendEnable) {
            if (mMessageHandler != null) {
                if (mChatLayout == null) {
                    mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString()));
                } else {
                    if ((isQuoteModel || isReplyModel) && replyPreviewBean != null) {
                        if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                            List<String> atUserList = new ArrayList<>(mTextInput.getMentionIdList());
                            mMessageHandler.sendMessage(ChatMessageBuilder.buildAtReplyMessage(mTextInput.getText().toString(), atUserList, replyPreviewBean));
                        } else {
                            mMessageHandler.sendMessage(ChatMessageBuilder.buildReplyMessage(mTextInput.getText().toString(), replyPreviewBean));
                        }
                        exitReply();
                    } else {
                        if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                            //发送时通过获取输入框匹配上@的昵称list，去从map中获取ID list。
                            // When sending, get the ID list from the map by getting the nickname list that matches the @ in the input box.
                            List<String> atUserList = new ArrayList<>(mTextInput.getMentionIdList());
                            if (atUserList.isEmpty()) {
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString()));
                            } else {
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildTextAtMessage(atUserList, mTextInput.getText().toString()));
                            }
                        } else {
                            mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString()));
                        }
                    }
                }
            }
            mIsSending = true;
            mTextInput.setText("");
        }
    }

    private void initVoiceWaveView() {
        if (mVoiceWaveView == null) {
            return;
        }

        mVoiceWaveView.addHeader(2);
        for (int i = 0; i < 100; i++) {
            mVoiceWaveView.addBody(2);
        }
        mVoiceWaveView.addFooter(2);
    }

    private String formatMiss(int miss) {
        //String hh = miss / 3600 > 9 ? miss / 3600 + "" : "0" + miss / 3600;
        String mm = (miss % 3600) / 60 > 9 ? (miss % 3600) / 60 + "" : "0" + (miss % 3600) / 60;
        String ss = (miss % 3600) % 60 > 9 ? (miss % 3600) % 60 + "" : "0" + (miss % 3600) % 60;
        return mm + ":" + ss;
    }

    public void addInputText(String name, String id){
        if (id == null || id.isEmpty()){
            return;
        }

        ArrayList<String> nameList = new ArrayList<String>() {
            {
                add(name);
            }
        };
        ArrayList<String> idList = new ArrayList<String>() {
            {
                add(id);
            }
        };

        updateAtUserInfoMap(nameList, idList);
        if (mTextInput != null) {
            Map<String, String> displayAtNameMap = new HashMap<>();
            displayAtNameMap.put(TIMMentionEditText.TIM_MENTION_TAG + displayInputString, id);
            mTextInput.setMentionMap(displayAtNameMap);
            int selectedIndex = mTextInput.getSelectionEnd();
            if (selectedIndex != -1) {
                String insertStr = TIMMentionEditText.TIM_MENTION_TAG + displayInputString;
                String text = mTextInput.getText().insert(selectedIndex, insertStr).toString();
                FaceManager.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + insertStr.length());
            }
            showSoftInput();
        }
    }

    public void updateInputText(ArrayList<String> names, ArrayList<String> ids){
        if (ids == null || ids.isEmpty()){
            return;
        }

        updateAtUserInfoMap(names, ids);
        if (mTextInput != null) {
            Map<String, String> displayAtNameList = getDisplayAtNameMap(names, ids);
            mTextInput.setMentionMap(displayAtNameList);

            int selectedIndex = mTextInput.getSelectionEnd();
            if (selectedIndex != -1) {
                String text = mTextInput.getText().insert(selectedIndex, displayInputString).toString();
                FaceManager.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + displayInputString.length());
            }
            // @ 之后要显示软键盘。Activity 没有 onResume 导致无法显示软键盘
            // Afterwards @, the soft keyboard is to be displayed. Activity does not have onResume, so the soft keyboard cannot be displayed
            BackgroundTasks.getInstance().postDelayed(new Runnable() {
                @Override
                public void run() {
                    showSoftInput();
                }
            }, 200);
        }
    }

    private Map<String, String> getDisplayAtNameMap(List<String> names, List<String> ids) {
        Map<String, String> displayNameList = new HashMap<>();
        String mentionTag = TIMMentionEditText.TIM_MENTION_TAG;
        if (mTextInput != null) {
            Editable editable = mTextInput.getText();
            int selectionIndex = mTextInput.getSelectionEnd();
            if (editable != null && selectionIndex > 0) {
                String text = editable.toString();
                if (!TextUtils.isEmpty(text)) {
                    mentionTag = text.substring(selectionIndex - 1, selectionIndex);
                }
            }
        }

        for (int i = 0; i < ids.size(); i++) {
            if (i == 0) {
                if (TextUtils.isEmpty(names.get(0))) {
                    displayNameList.put(mentionTag + ids.get(0) + " ", ids.get(0));
                } else {
                    displayNameList.put(mentionTag + names.get(0) + " ", ids.get(0));
                }
                continue;
            }
            String str = TIMMentionEditText.TIM_MENTION_TAG;
            if (TextUtils.isEmpty(names.get(i))) {
                str += ids.get(i);
            } else {
                str += names.get(i);
            }
            str += " ";
            displayNameList.put(str, ids.get(i));
        }
        return displayNameList;
    }

    private void updateAtUserInfoMap(ArrayList<String> names, ArrayList<String> ids){
        displayInputString = "";

        for (int i = 0; i < ids.size(); i++) {
            atUserInfoMap.put(ids.get(i), names.get(i));

            //for display
            if (TextUtils.isEmpty(names.get(i))) {
                displayInputString += ids.get(i);
                displayInputString += " ";
                displayInputString += TIMMentionEditText.TIM_MENTION_TAG;
            } else {
                displayInputString += names.get(i);
                displayInputString += " ";
                displayInputString += TIMMentionEditText.TIM_MENTION_TAG;
            }
        }

        if(!displayInputString.isEmpty()) {
            displayInputString = displayInputString.substring(0, displayInputString.length() - 1);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mTextInput.removeTextChangedListener(this);
        atUserInfoMap.clear();

        if (mChatInputHandler != null) {
            mChatInputHandler.onUserTyping(false, V2TIMManager.getInstance().getServerTime());
        }
    }

    protected void startSendPhoto() {
        TUIChatLog.i(TAG, "startSendPhoto");

        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        String[] mimetypes = {"image/*", "video/*"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimetypes);

        setOpenPhotoCallback();
        mInputMoreFragment.startActivityForResult(intent, InputMoreDialogFragment.REQUEST_CODE_PHOTO);
    }

    private void setOpenPhotoCallback() {
        mInputMoreFragment.setCallback(new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                TUIChatLog.i(TAG, "onSuccess: " + data);
                if (data == null){
                    TUIChatLog.e(TAG, "data is null");
                    return;
                }

                String uri = data.toString();
                if (TextUtils.isEmpty(uri)){
                    TUIChatLog.e(TAG, "uri is empty");
                    return;
                }

                String fileName = FileUtil.getFileName(TUIChatService.getAppContext(), (Uri) data);
                String fileExtension = FileUtil.getFileExtensionFromUrl(fileName);
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
                if (TextUtils.isEmpty(mimeType)) {
                    TUIChatLog.e(TAG, "mimeType is empty.");
                    return;
                }
                if (mimeType.contains("video")){
                    String videoPath = FileUtil.getPathFromUri((Uri) data);
                    TUIMessageBean msg = buildVideoMessage(videoPath);
                    if (msg == null){
                        ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                        TUIChatLog.e(TAG, "start send video error data: " + data);
                    } else if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(msg);
                        hideSoftInput();
                    }
                } else if (mimeType.contains("image")){
                    TUIMessageBean info = ChatMessageBuilder.buildImageMessage((Uri) data);
                    if (info == null) {
                        TUIChatLog.e(TAG, "start send image error data: " + data);
                        ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                        return;
                    }
                    if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(info);
                        hideSoftInput();
                    }
                } else {
                    TUIChatLog.e(TAG, "Send photo or video failed , invalid mimeType : " + mimeType);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.i(TAG, "errCode: " + errCode);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public TUIMessageBean buildVideoMessage(String mUri) {
        android.media.MediaMetadataRetriever mmr = new android.media.MediaMetadataRetriever();
        try {
            mmr.setDataSource(mUri);
            String sDuration = mmr.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION);
            Bitmap bitmap = mmr.getFrameAtTime(0, android.media.MediaMetadataRetriever.OPTION_NEXT_SYNC);

            if (bitmap == null){
                TUIChatLog.e(TAG, "buildVideoMessage() bitmap is null");
                return null;
            }

            String imgPath = FileUtil.saveBitmap("JCamera", bitmap);
            String videoPath = mUri;
            int imgWidth = bitmap.getWidth();
            int imgHeight = bitmap.getHeight();
            long duration = Long.valueOf(sDuration);
            TUIMessageBean msg = ChatMessageBuilder.buildVideoMessage(imgPath, videoPath, imgWidth, imgHeight, duration);

            return msg;
        } catch (Exception ex) {
            TUIChatLog.e(TAG, "MediaMetadataRetriever exception " + ex);
        } finally {
            mmr.release();
        }

        return null;
    }

    protected void startCapture() {
        TUIChatLog.i(TAG, "startCapture");

        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                Intent captureIntent = new Intent(getContext(), CameraActivity.class);
                captureIntent.putExtra(TUIChatConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_CAPTURE);
                CameraActivity.mCallBack = new IUIKitCallback() {
                    @Override
                    public void onSuccess(Object data) {
                        Uri contentUri = Uri.fromFile(new File(data.toString()));
                        TUIMessageBean msg = ChatMessageBuilder.buildImageMessage(contentUri);
                        if (mMessageHandler != null) {
                            mMessageHandler.sendMessage(msg);
                            hideSoftInput();
                        }
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                };
                setOpenPhotoCallback();
                mInputMoreFragment.startActivityForResult(captureIntent, mInputMoreFragment.REQUEST_CODE_PHOTO);
            }

            @Override
            public void onDenied() {
                TUIChatLog.i(TAG, "startCapture checkPermission failed");
            }
        });
    }

    protected void startVideoRecord() {
        TUIChatLog.i(TAG, "startVideoRecord");

        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        Intent captureIntent = new Intent(getContext(), CameraActivity.class);
                        captureIntent.putExtra(TUIChatConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_RECORDER);
                        CameraActivity.mCallBack = new IUIKitCallback() {
                            @Override
                            public void onSuccess(Object data) {
                                Intent videoData = (Intent) data;
                                String imgPath = videoData.getStringExtra(TUIChatConstants.CAMERA_IMAGE_PATH);
                                String videoPath = videoData.getStringExtra(TUIChatConstants.CAMERA_VIDEO_PATH);
                                int imgWidth = videoData.getIntExtra(TUIChatConstants.IMAGE_WIDTH, 0);
                                int imgHeight = videoData.getIntExtra(TUIChatConstants.IMAGE_HEIGHT, 0);
                                long duration = videoData.getLongExtra(TUIChatConstants.VIDEO_TIME, 0);
                                TUIMessageBean msg = ChatMessageBuilder.buildVideoMessage(imgPath, videoPath, imgWidth, imgHeight, duration);
                                if (mMessageHandler != null) {
                                    mMessageHandler.sendMessage(msg);
                                    hideSoftInput();
                                }
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {

                            }
                        };
                        setOpenPhotoCallback();
                        mInputMoreFragment.startActivityForResult(captureIntent, mInputMoreFragment.REQUEST_CODE_PHOTO);
                    }

                    @Override
                    public void onDenied() {
                        TUIChatLog.i(TAG, "startVideoRecord checkPermission failed");
                    }
                });
            }

            @Override
            public void onDenied() {
                TUIChatLog.i(TAG, "startVideoRecord checkPermission failed");
            }
        });

    }

    protected void startSendFile() {
        TUIChatLog.i(TAG, "startSendFile");

        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        mInputMoreFragment.setCallback(new IUIKitCallback() {
            @Override
            public void onSuccess(Object data) {
                TUIMessageBean info = ChatMessageBuilder.buildFileMessage((Uri) data);
                if (info == null) {
                    ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                    return;
                }
                if (mMessageHandler != null) {
                    mMessageHandler.sendMessage(info);
                    hideSoftInput();
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
        mInputMoreFragment.startActivityForResult(intent, InputMoreDialogFragment.REQUEST_CODE_FILE);
    }

    public void setChatInputHandler(ChatInputHandler handler) {
        this.mChatInputHandler = handler;
    }

    public void setMessageHandler(MessageHandler handler) {
        this.mMessageHandler = handler;
    }

    public void setOnInputViewListener(OnInputViewListener listener) {
        this.mOnInputViewListener = listener;
    }

    static class InputAction {
        static final int MORE_CLICKED = 1;
        static final int INPUT_CLICKED = 2;
        static final int FACE_KEYBOARD_CLICKED = 3;
        static final int AUDIO_CLICKED = 4;
        static final int IMAGE_CLICKED = 5;
        static final int EMPTY_CLICKED = 6;
    }

    static class InputState {
        static final int STATE_NONE = 1;
        static final int STATE_MORE_INPUT = 2;
        static final int STATE_SOFT_INPUT = 3;
        static final int STATE_FACE_INPUT = 4;
        static final int STATE_AUDIO_INPUT = 5;
        static final int STATE_IMAGE_INPUT = 6;
    }


    @FunctionalInterface
    interface InputMachineEvent {
        void onEvent();
    }

    static class InputMachineTransaction {
        int currentState;
        int nextState;
        int action;
        InputMachineEvent event;

        InputMachineTransaction currentState(int currentState) {
            this.currentState = currentState;
            return this;
        }

        InputMachineTransaction nextState(int nextState) {
            this.nextState = nextState;
            return this;
        }

        InputMachineTransaction action(int action) {
            this.action = action;
            return this;
        }

        InputMachineTransaction event(InputMachineEvent event) {
            this.event = event;
            return this;
        }

    }

    static class InputMachine {

        private final List<InputMachineTransaction> transactionList;
        private int currentState;

        public InputMachine(int currentState, List<InputMachineTransaction> transactionList) {
            this.currentState = currentState;
            this.transactionList = transactionList;
        }

        void execute(int action) {
            for(InputMachineTransaction transaction : transactionList) {
                if (transaction.currentState == currentState && transaction.action == action) {
                    transaction.event.onEvent();
                    currentState = transaction.nextState;
                    break;
                }
            }
        }

        public void clean() {
            if (transactionList != null) {
                transactionList.clear();
            }

            currentState = InputState.STATE_NONE;
        }
    }

    public void initInputMachine() {
        if (inputMachine != null) {
            inputMachine.clean();
        }
        List<InputMachineTransaction> transactionList = Arrays.asList(
                /**
                 *  transition to {@link InputState.STATE_FACE_INPUT}
                 */
                new InputMachineTransaction()
                        .currentState(InputState.STATE_SOFT_INPUT)
                        .action(InputAction.FACE_KEYBOARD_CLICKED)
                        .event(this::hideSoftInputAndShowFace)
                        .nextState(InputState.STATE_FACE_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_NONE)
                        .action(InputAction.FACE_KEYBOARD_CLICKED)
                        .event(this::showFace)
                        .nextState(InputState.STATE_FACE_INPUT),


                /**
                 *  transition to {@link InputState.STATE_SOFT_INPUT}
                 */
                new InputMachineTransaction()
                        .currentState(InputState.STATE_FACE_INPUT)
                        .action(InputAction.INPUT_CLICKED)
                        .event(this::showSoftInputAndHideFace)
                        .nextState(InputState.STATE_SOFT_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_FACE_INPUT)
                        .action(InputAction.FACE_KEYBOARD_CLICKED)
                        .event(this::showSoftInputAndHideFace)
                        .nextState(InputState.STATE_SOFT_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_NONE)
                        .action(InputAction.INPUT_CLICKED)
                        .event(this::showSoftInputAndHideFace)
                        .nextState(InputState.STATE_SOFT_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_SOFT_INPUT)
                        .action(InputAction.INPUT_CLICKED)
                        .event(this::showSoftInputAndHideFace)
                        .nextState(InputState.STATE_SOFT_INPUT),

                /**
                 *  transition to {@link InputState.STATE_NONE}
                 */
                new InputMachineTransaction()
                        .currentState(InputState.STATE_FACE_INPUT)
                        .action(InputAction.EMPTY_CLICKED)
                        .event(this::hideFace)
                        .nextState(InputState.STATE_NONE),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_SOFT_INPUT)
                        .action(InputAction.EMPTY_CLICKED)
                        .event(this::hideSoftInput)
                        .nextState(InputState.STATE_NONE),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_NONE)
                        .action(InputAction.EMPTY_CLICKED)
                        .event(this::restoreInput)
                        .nextState(InputState.STATE_NONE),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_FACE_INPUT)
                        .action(InputAction.MORE_CLICKED)
                        .event(this::restoreInput)
                        .nextState(InputState.STATE_NONE),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_SOFT_INPUT)
                        .action(InputAction.MORE_CLICKED)
                        .event(this::restoreInput)
                        .nextState(InputState.STATE_NONE),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_AUDIO_INPUT)
                        .action(InputAction.AUDIO_CLICKED)
                        .event(this::hideVoiceLayout)
                        .nextState(InputState.STATE_NONE),


                /**
                 *  transition to {@link InputState.STATE_AUDIO_INPUT}
                 */
                new InputMachineTransaction()
                        .currentState(InputState.STATE_SOFT_INPUT)
                        .action(InputAction.AUDIO_CLICKED)
                        .event(this::showVoiceLayout)
                        .nextState(InputState.STATE_AUDIO_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_FACE_INPUT)
                        .action(InputAction.AUDIO_CLICKED)
                        .event(this::showVoiceLayout)
                        .nextState(InputState.STATE_AUDIO_INPUT),

                new InputMachineTransaction()
                        .currentState(InputState.STATE_NONE)
                        .action(InputAction.AUDIO_CLICKED)
                        .event(this::showVoiceLayout)
                        .nextState(InputState.STATE_AUDIO_INPUT)

                );
        inputMachine = new InputMachine(InputState.STATE_NONE, transactionList);
    }

    private void showSoftInputAndHideFace() {
        showSoftInputAndThen(this::hideFace);
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_minimalist_input_face_icon);
    }

    private void hideSoftInputAndShowFace() {
        showFace();
        hideSoftInput();
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_input_keyboard);
    }

    @Override
    public void onClick(View view) {
        if (view == faceKeyboardInputButton) {
            inputMachine.execute(InputAction.FACE_KEYBOARD_CLICKED);
        } else if (view == inputMoreBtn) {
            inputMachine.execute(InputAction.MORE_CLICKED);
            showInputMoreLayout();
        } else if (view == imageBtn) {
            if (mOnInputViewListener != null) {
                mOnInputViewListener.onClickCapture();
            }
        }/*else if (view.getId() == R.id.send_btn) {
            if (mSendEnable) {
                if (mMessageHandler != null) {
                    if (mChatLayout == null) {
                        mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString().trim()));
                    } else {
                        if ((isQuoteModel || isReplyModel) && replyPreviewBean != null) {
                            if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                                List<String> atUserList = new ArrayList<>(mTextInput.getMentionIdList());
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildAtReplyMessage(mTextInput.getText().toString().trim(), atUserList, replyPreviewBean));
                            } else {
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildReplyMessage(mTextInput.getText().toString().trim(), replyPreviewBean));
                            }
                            exitReply();
                        } else {
                            if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                                //发送时通过获取输入框匹配上@的昵称list，去从map中获取ID list。
                                // When sending, get the ID list from the map by getting the nickname list that matches the @ in the input box.
                                List<String> atUserList = new ArrayList<>(mTextInput.getMentionIdList());
                                if (atUserList.isEmpty()) {
                                    mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString().trim()));
                                } else {
                                    mMessageHandler.sendMessage(ChatMessageBuilder.buildTextAtMessage(atUserList, mTextInput.getText().toString().trim()));
                                }
                            } else {
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString().trim()));
                            }
                        }
                    }
                }
                mIsSending = true;
                mTextInput.setText("");
            }
        }*/
    }

    @FunctionalInterface
    interface Callback {
        void onCall();
    }

    public void showSoftInputAndThen(Callback callback) {
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (!isSoftInputShown()) {
            imm.toggleSoftInput(0, 0);
        }
        mTextInput.requestFocus();
        postDelayed(new Runnable() {
            @Override
            public void run() {
                if (callback != null) {
                    callback.onCall();
                }
                Context context = getContext();
                if (context instanceof Activity) {
                    Window window = ((Activity) context).getWindow();
                    if (window != null) {
                        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
                    }
                }
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (mChatInputHandler != null) {
                            mChatInputHandler.onInputAreaClick();
                        }
                    }
                }, 100);
            }
        }, 180);
    }

    public void showSoftInput() {
        showSoftInputAndThen(null);
    }

    public void hideSoftInput() {
        TUIChatLog.i(TAG, "hideSoftInput");
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_minimalist_input_face_icon);
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mTextInput.getWindowToken(), 0);
        mTextInput.clearFocus();
        Context context = getContext();
        if (context instanceof Activity) {
            Window window = ((Activity) context).getWindow();
            if (window != null) {
                window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);
            }
        }
    }

    public void onEmptyClick() {
        inputMachine.execute(InputAction.EMPTY_CLICKED);
    }

    private boolean isSoftInputShown() {
        View decorView = ((Activity) getContext()).getWindow().getDecorView();
        int screenHeight = decorView.getHeight();
        Rect rect = new Rect();
        decorView.getWindowVisibleDisplayFrame(rect);
        return screenHeight - rect.bottom - getNavigateBarHeight() >= 0;
    }

    private int getNavigateBarHeight() {
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager windowManager  = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
        windowManager.getDefaultDisplay().getMetrics(metrics);
        int usableHeight = metrics.heightPixels;
        windowManager.getDefaultDisplay().getRealMetrics(metrics);
        int realHeight = metrics.heightPixels;
        if (realHeight > usableHeight) {
            return realHeight - usableHeight;
        } else {
            return 0;
        }
    }

    public void disableShowCustomFace(boolean disable) {
        isShowCustomFace = !disable;
    }

    private AppCompatActivity getActivity() {
        return (AppCompatActivity) getContext();
    }


    private void showFace() {
        TUIChatLog.i(TAG, "showFaceViewGroup");
        if (faceFragment == null) {
            faceFragment = new FaceFragment();
        }
        hideSoftInput();
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_input_keyboard);
        mTextInput.requestFocus();
        faceFragment.setShowCustomFace(isShowCustomFace);
        faceFragment.setListener(new FaceFragment.OnEmojiClickListener() {
            @Override
            public void onEmojiDelete() {
                int index = mTextInput.getSelectionStart();
                Editable editable = mTextInput.getText();
                boolean isFace = false;
                if (index <= 0) {
                    return;
                }
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
                int index = mTextInput.getSelectionStart();
                Editable editable = mTextInput.getText();
                editable.insert(index, emoji.getFaceKey());
                FaceManager.handlerEmojiText(mTextInput, editable, true);
            }

            @Override
            public void onCustomFaceClick(int groupIndex, CustomFace customFace) {
                mMessageHandler.sendMessage(ChatMessageBuilder.buildFaceMessage(groupIndex, customFace.getFaceKey()));
            }

            @Override
            public void sendEmoji() {
                send();
            }
        });
        mInputMoreLayout.setVisibility(VISIBLE);
        fragmentManager.beginTransaction().replace(R.id.more_groups, faceFragment).commitAllowingStateLoss();
        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 100);
        }
    }

    private void showInputMoreButton() {
        inputMoreBtn.setVisibility(VISIBLE);
    }

    private void hideInputMoreButton() {
        inputMoreBtn.setVisibility(GONE);
    }

    private void hideFace() {
        mInputMoreLayout.setVisibility(GONE);
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_minimalist_input_face_icon);
    }

    private void restoreInput() {
        if (mInputMoreLayout.getVisibility() == VISIBLE) {
            mInputMoreLayout.setVisibility(GONE);
        }
        faceKeyboardInputButton.setBackgroundResource(R.drawable.chat_minimalist_input_face_icon);
        hideSoftInput();
    }

    private void hideVoiceLayout() {
        voiceBtn.setVisibility(VISIBLE);
        mSendAudioButtonLayout.setVisibility(GONE);
        showInputMoreButton();
        showTextInputLayout();
        showImageButton();
        hideVoiceDeleteImage();
        stopAudioRecord();
    }

    private void showVoiceLayout() {
        mSendAudioButtonLayout.setVisibility(VISIBLE);
        voiceBtn.setVisibility(GONE);
        hideInputMoreButton();
        hideTextInputLayout();
        hideImageButton();
        showVoiceDeleteImage();
        startAudioRecord();
    }

    private void startAudioRecord() {
        initVoiceWaveView();
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
        }
        if (mTimer == null) {
            mTimer = new Timer();
        }
        mTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        times++;
                        String s = formatMiss(times);
                        mSendAudioButton.setText(s);
                    }
                });
            }
        }, 0, 1000);

        AudioRecorder.getInstance().startRecord(new AudioRecorder.Callback() {
            @Override
            public void onCompletion(Boolean success) {
                recordComplete(success);
            }

            @Override
            public void onVoiceDb(double db) {
                if (mSendAudioButtonLayout.getVisibility() == VISIBLE) {
                    if (db == 0) db = 2;
                    mVoiceWaveView.addBody((int) db);
                    mVoiceWaveView.start();
                }
            }
        });
    }

    private void stopAudioRecord() {
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
        }
        AudioRecorder.getInstance().stopRecord();
        if (mVoiceWaveView != null) {
            mVoiceWaveView.stop();
        }
        initVoiceWaveView();
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
        mSendAudioButton.setText("0:00");
        times = 0;
    }

    private void showVoiceDeleteImage() {
        voiceDeleteImage.setVisibility(VISIBLE);
    }

    private void hideVoiceDeleteImage() {
        voiceDeleteImage.setVisibility(GONE);
    }

    private void hideTextInputLayout() {
        mTextInputLayout.setVisibility(GONE);
    }

    private void showTextInputLayout() {
        mTextInputLayout.setVisibility(VISIBLE);
    }

    private void hideImageButton() {
        imageBtn.setVisibility(GONE);
    }

    private void showImageButton() {
        imageBtn.setVisibility(VISIBLE);
    }

    private void recordComplete(boolean success) {
        int duration = AudioRecorder.getInstance().getDuration();
        TUIChatLog.i(TAG, "recordComplete duration:" + duration);
        if (mChatInputHandler != null) {
            if (!success || duration == 0) {
                mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_FAILED);
                return;
            }
            if (mAudioCancel) {
                mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                return;
            }
            if (duration < 1000) {
                mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_TOO_SHORT);
                return;
            }
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
        }

        if (mMessageHandler != null && success) {
            mMessageHandler.sendMessage(ChatMessageBuilder.buildAudioMessage(AudioRecorder.getInstance().getPath(), duration));
        }
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        mInputContent = s.toString();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void afterTextChanged(Editable s) {
        if (TextUtils.isEmpty(s.toString().trim())) {
            mSendEnable = false;
            showMoreInputButton(View.VISIBLE);

            if (mChatInputHandler != null) {
                mChatInputHandler.onUserTyping(false, V2TIMManager.getInstance().getServerTime());
            }
        } else {
            mSendEnable = true;
            showMoreInputButton(View.GONE);
            if (mTextInput.getLineCount() != mLastMsgLineCount) {
                mLastMsgLineCount = mTextInput.getLineCount();
                if (mChatInputHandler != null) {
                    mChatInputHandler.onInputAreaClick();
                }
            }
            if (!TextUtils.equals(mInputContent, mTextInput.getText().toString())) {
                FaceManager.handlerEmojiText(mTextInput, mTextInput.getText(), true);
            }
        }

        if (mChatInputHandler != null && !mIsSending) {
            mChatInputHandler.onUserTyping(true, V2TIMManager.getInstance().getServerTime());
        }

        if (mIsSending) {
            mIsSending = false;
        }
    }

    public void setDraft() {
        if (mChatInfo == null) {
            TUIChatLog.e(TAG, "set drafts error :  chatInfo is null");
            return;
        }
        if (mTextInput == null) {
            TUIChatLog.e(TAG, "set drafts error :  textInput is null");
            return;
        }

        String draftText = mTextInput.getText().toString();
        if ((isQuoteModel || isReplyModel) && replyPreviewBean != null) {
            Gson gson = new Gson();
            Map<String, String> draftMap = new HashMap<>();
            draftMap.put("content", draftText);
            draftMap.put("reply", gson.toJson(replyPreviewBean));
            draftText = gson.toJson(draftMap);
        }
        if (presenter != null) {
            presenter.setDraft(draftText);
        }
    }

    public void appendText(String text) {
        if (mChatInfo == null) {
            TUIChatLog.e(TAG, "appendText error :  chatInfo is null");
            return;
        }
        if (mTextInput == null) {
            TUIChatLog.e(TAG, "appendText error :  textInput is null");
            return;
        }
        String draftText = mTextInput.getText().toString();
        draftText += text;
        mTextInput.setText(draftText);
        mTextInput.setSelection(mTextInput.getText().length());
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.mChatInfo = chatInfo;
        if (chatInfo != null) {
            DraftInfo draftInfo = chatInfo.getDraft();
            if (draftInfo != null && !TextUtils.isEmpty(draftInfo.getDraftText()) && mTextInput != null) {
                Gson gson = new Gson();
                HashMap draftJsonMap;
                String content = draftInfo.getDraftText();
                try {
                    draftJsonMap = gson.fromJson(draftInfo.getDraftText(), HashMap.class);
                    if (draftJsonMap != null) {
                        content = (String) draftJsonMap.get("content");
                        String draftStr = (String) draftJsonMap.get("reply");
                        ReplyPreviewBean bean = gson.fromJson(draftStr, ReplyPreviewBean.class);
                        if (bean != null) {
                            showReplyPreview(bean);
                        }
                    }
                } catch (JsonSyntaxException e) {
                    TUIChatLog.e(TAG, " getCustomJsonMap error ");
                }

                mTextInput.setText(content);
                mTextInput.setSelection(mTextInput.getText().length());
            }
        }
    }

    public void setChatLayout(IChatLayout chatLayout) {
        mChatLayout = chatLayout;
    }

    protected void assembleActions() {
        mInputMoreActionList.clear();
        InputMoreActionUnit actionUnit;
        if (!mSendPhotoDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startSendPhoto();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_picture_icon);
            actionUnit.setTitleId(R.string.pic);
            actionUnit.setActionType(1);
            mInputMoreActionList.add(actionUnit);
        }

        if (!mCaptureDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startCapture();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_camera_icon);
            actionUnit.setActionType(1);
            actionUnit.setTitleId(R.string.photo);
            mInputMoreActionList.add(actionUnit);
        }

        if (!mVideoRecordDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startVideoRecord();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_record_icon);
            actionUnit.setActionType(1);
            actionUnit.setTitleId(R.string.video);
            mInputMoreActionList.add(actionUnit);
        }

        if (!mSendFileDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startSendFile();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_file_icon);
            actionUnit.setActionType(1);
            actionUnit.setTitleId(R.string.file);
            mInputMoreActionList.add(actionUnit);
        }

        mInputMoreActionList.addAll(mInputMoreCustomActionList);
        Collections.sort(mInputMoreActionList, new Comparator<InputMoreActionUnit>() {
            @Override
            public int compare(InputMoreActionUnit o1, InputMoreActionUnit o2) {
                return o1.getPriority() - o2.getPriority();
            }
        });
    }

    private void addActionsFromListeners() {
        if (mChatInfo == null) {
            return;
        }

        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.CHAT_ID, mChatInfo.getId());
        param.put(TUIConstants.TUIChat.CHAT_NAME, mChatInfo.getChatName());
        param.put(TUIConstants.TUIChat.CHAT_TYPE, mChatInfo.getType());
        param.put(TUIConstants.TUIChat.CONTEXT, getContext());
        Map<String, Object> customMessageExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_CUSTOM_MESSAGE, param);
        if (customMessageExtension != null) {
            Integer icon = (Integer) customMessageExtension.get(TUIConstants.TUIChat.INPUT_MORE_ICON);
            Integer title = (Integer) customMessageExtension.get(TUIConstants.TUIChat.INPUT_MORE_TITLE);
            Integer id = (Integer) customMessageExtension.get(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID);
            InputMoreActionUnit unit = new InputMoreActionUnit();
            unit.setActionId(id);
            unit.setIconResId(icon);
            unit.setTitleId(title);
            unit.setPriority(10);
            unit.setOnClickListener(unit.new OnActionClickListener() {
                @Override
                public void onClick() {
                    onCustomActionClick(unit.getActionId());
                }
            });
            mInputMoreActionList.add(unit);
        }

        // topic not support call yet.
        if (TUIChatUtils.isTopicGroup(mChatInfo.getId())) {
            return;
        }

        Map<String, Object> audioCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, param);
        if (audioCallExtension != null) {
            View audioView = (View) audioCallExtension.get(TUIConstants.TUIChat.INPUT_MORE_VIEW);
            int audioActionId = (Integer) audioCallExtension.get(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID);
            InputMoreActionUnit audioUnit = new InputMoreActionUnit();
            audioUnit.setActionId(audioActionId);
            audioUnit.setUnitView(audioView);
            audioUnit.setPriority(2);
            audioUnit.setOnClickListener(audioUnit.new OnActionClickListener() {
                @Override
                public void onClick() {
                    PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                        @Override
                        public void onGranted() {
                            onCustomActionClick(audioUnit.getActionId());
                        }

                        @Override
                        public void onDenied() {

                        }
                    });
                }
            });
            mInputMoreActionList.add(audioUnit);
        }

        Map<String, Object> videoCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, param);
        if (videoCallExtension != null) {
            View videoView = (View) videoCallExtension.get(TUIConstants.TUIChat.INPUT_MORE_VIEW);
            int videoActionId = (Integer) videoCallExtension.get(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID);
            InputMoreActionUnit videoUnit = new InputMoreActionUnit();
            videoUnit.setActionId(videoActionId);
            videoUnit.setUnitView(videoView);
            videoUnit.setPriority(1);
            videoUnit.setOnClickListener(videoUnit.new OnActionClickListener() {
                @Override
                public void onClick() {
                    PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                        @Override
                        public void onGranted() {
                            PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
                                @Override
                                public void onGranted() {
                                    onCustomActionClick(videoUnit.getActionId());
                                }

                                @Override
                                public void onDenied() {

                                }
                            });
                        }

                        @Override
                        public void onDenied() {

                        }
                    });
                }
            });
            mInputMoreActionList.add(videoUnit);
        }

    }

    private void onCustomActionClick(int id) {
        if (id == TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL || id == TUIConstants.TUICalling.ACTION_ID_VIDEO_CALL) {
            String type = id == TUIConstants.TUICalling.ACTION_ID_AUDIO_CALL ? TUIConstants.TUICalling.TYPE_AUDIO
                    : TUIConstants.TUICalling.TYPE_VIDEO;
            if (TUIChatUtils.isGroupChat(getChatInfo().getType())) {
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUICalling.GROUP_ID, getChatInfo().getId());
                bundle.putString(TUIConstants.TUICalling.PARAM_NAME_TYPE, type);
                bundle.putString(TUIChatConstants.GROUP_ID, getChatInfo().getId());
                bundle.putBoolean(TUIChatConstants.SELECT_FOR_CALL, true);
                bundle.putInt(TUIChatConstants.Selection.LIMIT, CALL_MEMBER_LIMIT);
                TUICore.startActivity(getContext(), "StartGroupMemberSelectActivity", bundle, 11);
            }
            return;
        }
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.INPUT_MORE_ACTION_ID, id);
        param.put(TUIConstants.TUIChat.CHAT_ID, mChatInfo.getId());
        param.put(TUIConstants.TUIChat.CHAT_NAME, mChatInfo.getChatName());
        param.put(TUIConstants.TUIChat.CHAT_TYPE, mChatInfo.getType());
        TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_INPUT_MORE, TUIConstants.TUIChat.EVENT_SUB_KEY_ON_CLICK, param);
    }

    public void disableAudioInput(boolean disable) {

    }

    public void disableEmojiInput(boolean disable) {
        mEmojiInputDisable = disable;
        if (disable) {
            faceKeyboardInputButton.setVisibility(GONE);
        } else {
            faceKeyboardInputButton.setVisibility(VISIBLE);
        }
    }

    public void disableMoreInput(boolean disable) {
        mMoreInputDisable = disable;

    }

    public void replaceMoreInput(BaseInputFragment fragment) {
        mMoreInputEvent = fragment;
    }

    public void replaceMoreInput(OnClickListener listener) {
        mMoreInputEvent = listener;
    }

    public void disableSendPhotoAction(boolean disable) {
        mSendPhotoDisable = disable;
    }

    public void disableCaptureAction(boolean disable) {
        mCaptureDisable = disable;
    }

    public void disableVideoRecordAction(boolean disable) {
        mVideoRecordDisable = disable;
    }

    public void disableSendFileAction(boolean disable) {
        mSendFileDisable = disable;
    }

    public void addAction(InputMoreActionUnit action) {
        mInputMoreCustomActionList.add(action);
    }

    public EditText getInputText() {
        return mTextInput;
    }

    protected void showMoreInputButton(int visibility) {

    }

    public void showReplyPreview(ReplyPreviewBean previewBean) {
        exitReply();
        replyPreviewBean = previewBean;
        String replyMessageAbstract = previewBean.getMessageAbstract();
        String msgTypeStr = ChatMessageParser.getMsgTypeStr(previewBean.getMessageType());
        // If replying to a text message, the middle part of the file name is displayed in abbreviated form
        if (previewBean.isReplyMessage()) {
            String text = msgTypeStr + " " + replyMessageAbstract;
            text = FaceManager.emojiJudge(text);
            isReplyModel = true;
            replyTv.setText(text);
            replyUserNameTv.setText(previewBean.getMessageSender());
            replyPreviewBar.setVisibility(View.VISIBLE);
        } else {
            String text = previewBean.getMessageSender() + " : " + msgTypeStr + " " + replyMessageAbstract;
            text = FaceManager.emojiJudge(text);
            isQuoteModel = true;
            quoteTv.setText(text);
            quotePreviewBar.setVisibility(View.VISIBLE);
        }

        if (previewBean.getOriginalMessageBean() instanceof FileMessageBean) {
            replyTv.setEllipsize(TextUtils.TruncateAt.MIDDLE);
            quoteTv.setEllipsize(TextUtils.TruncateAt.MIDDLE);
        } else {
            replyTv.setEllipsize(TextUtils.TruncateAt.END);
            quoteTv.setEllipsize(TextUtils.TruncateAt.END);
        }

        if (mMessageHandler != null) {
            mMessageHandler.scrollToEnd();
        }

        inputMachine.execute(InputAction.INPUT_CLICKED);
    }

    public void exitReply() {
        isReplyModel = false;
        replyPreviewBean = null;
        replyPreviewBar.setVisibility(View.GONE);
        isQuoteModel = false;
        quotePreviewBar.setVisibility(View.GONE);
        updateChatBackground();
    }

    private void showInputMoreLayout() {
        TUIChatLog.i(TAG, "showInputMoreLayout");
        if (fragmentManager == null) {
            fragmentManager = getActivity().getSupportFragmentManager();
        }
        if (mInputMoreFragment == null) {
            mInputMoreFragment = new InputMoreDialogFragment();
            mInputMoreFragment.setMoreActionsListener(new OnMoreActionsClickLisener() {
                @Override
                public void startCapture() {
                    InputView.this.startCapture();
                }

                @Override
                public void startSendPhoto() {
                    InputView.this.startSendPhoto();
                }

                @Override
                public void startVideoRecord() {
                    InputView.this.startVideoRecord();
                }

                @Override
                public void startSendFile() {
                    InputView.this.startSendFile();
                }
            });
        }

        assembleActions();
        mInputMoreFragment.setActions(mInputMoreActionList);
        if (!mInputMoreFragment.isAdded() && null == fragmentManager.findFragmentByTag(mInputMoreFragment.getTag())) {
            mInputMoreFragment.show(fragmentManager, "mInputMoreFragment");
        }
    }

    public void clearCustomActionList() {
        mInputMoreCustomActionList.clear();
    }

    public ChatInfo getChatInfo() {
        return mChatInfo;
    }

    public interface MessageHandler {
        void sendMessage(TUIMessageBean msg);
        void scrollToEnd();
    }

    public interface ChatInputHandler {

        int RECORD_START = 1;
        int RECORD_STOP = 2;
        int RECORD_CANCEL = 3;
        int RECORD_TOO_SHORT = 4;
        int RECORD_FAILED = 5;

        void onInputAreaClick();

        void onRecordStatusChanged(int status);

        void onUserTyping(boolean status, long time);
    }

    public interface OnInputViewListener {
        void onStartGroupMemberSelectActivity();
        void onClickCapture();
        void onUpdateChatBackground();
    }

    public interface OnMoreActionsClickLisener {
        void startCapture();
        void startSendPhoto();
        void startVideoRecord();
        void startSendFile();
    }

}
