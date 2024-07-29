package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
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
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnFaceInputListener;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FaceUtil;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.audio.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceFragment;
import com.tencent.qcloud.tuikit.tuichat.component.inputedittext.TIMMentionEditText;
import com.tencent.qcloud.tuikit.tuichat.config.GeneralConfig;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.inputmore.InputMoreDialogFragment;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.waveview.VoiceWaveView;
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
 *
 * Chat interface, send pictures, take pictures, video, file panels at the bottom
 */

public class InputView extends LinearLayout implements View.OnClickListener, TextWatcher {
    private static final String TAG = InputView.class.getSimpleName();

    protected ImageView faceKeyboardInputButton;
    protected ImageView inputMoreBtn;
    protected ImageView voiceBtn;
    protected ImageView imageBtn;
    protected boolean mEmojiInputDisable;
    protected ImageView voiceDeleteImage;

    protected Object mMoreInputEvent;
    protected boolean mMoreInputDisable;

    /**
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
    private int mLastMsgLineCount;
    private float mStartRecordX;
    private String mInputContent;
    private OnInputViewListener mOnInputViewListener;

    private Map<String, String> atUserInfoMap = new HashMap<>();
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

    private ChatInputMoreListener chatInputMoreListener;

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

    public void setChatInputMoreListener(ChatInputMoreListener chatInputMoreListener) {
        this.chatInputMoreListener = chatInputMoreListener;
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
                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
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
            private boolean readyToCancel = false;

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                int action = motionEvent.getAction();
                TUIChatLog.i(TAG, "mSendAudioButton onTouch action:" + action);

                boolean isRTL = LayoutUtil.isRTL();
                switch (action) {
                    case MotionEvent.ACTION_DOWN:
                        mStartRecordX = motionEvent.getX();
                        inputMachine.execute(InputAction.AUDIO_CLICKED);
                        break;
                    case MotionEvent.ACTION_MOVE:
                        readyToCancel = motionEvent.getX() - mStartRecordX < -100;
                        if (isRTL) {
                            readyToCancel = motionEvent.getX() - mStartRecordX > 100;
                        }
                        if (readyToCancel) {
                            readyToCancelRecord();
                        } else {
                            continueRecord();
                        }

                        break;
                    case MotionEvent.ACTION_CANCEL:
                    case MotionEvent.ACTION_UP:
                        if (readyToCancel) {
                            inputMachine.execute(InputAction.CANCEL_RECORD_AUDIO_CLICKED);
                        } else {
                            inputMachine.execute(InputAction.AUDIO_CLICKED);
                        }
                        break;
                    default:
                        break;
                }

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
                
                if (actionId == EditorInfo.IME_ACTION_SEND
                    || (actionId == EditorInfo.IME_ACTION_UNSPECIFIED && event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER
                        && event.getAction() == KeyEvent.ACTION_DOWN)) {
                    sendTextMessage();
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

    private void sendTextMessage() {
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
                            
                            //  When sending, get the ID list from the map by getting the nickname list that matches the @ in the input box.
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
        voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_icon);
        mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_blue));
    }

    private String formatMiss(int miss) {
        // String hh = miss / 3600 > 9 ? miss / 3600 + "" : "0" + miss / 3600;
        String mm = (miss % 3600) / 60 > 9 ? (miss % 3600) / 60 + "" : "0" + (miss % 3600) / 60;
        String ss = (miss % 3600) % 60 > 9 ? (miss % 3600) % 60 + "" : "0" + (miss % 3600) % 60;
        return mm + ":" + ss;
    }

    public void addInputText(String name, String id) {
        if (id == null || id.isEmpty()) {
            return;
        }

        ArrayList<String> nameList = new ArrayList<String>() {
            { add(name); }
        };
        ArrayList<String> idList = new ArrayList<String>() {
            { add(id); }
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
                FaceUtil.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + insertStr.length());
            }
            showSoftInput();
        }
    }

    public void updateInputText(ArrayList<String> names, ArrayList<String> ids) {
        if (ids == null || ids.isEmpty()) {
            return;
        }

        updateAtUserInfoMap(names, ids);
        if (mTextInput != null) {
            Map<String, String> displayAtNameList = getDisplayAtNameMap(names, ids);
            mTextInput.setMentionMap(displayAtNameList);

            int selectedIndex = mTextInput.getSelectionEnd();
            if (selectedIndex != -1) {
                String text = mTextInput.getText().insert(selectedIndex, displayInputString).toString();
                FaceUtil.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + displayInputString.length());
            }
            
            // Afterwards @, the soft keyboard is to be displayed. Activity does not have onResume, so the soft keyboard cannot be displayed
            ThreadUtils.postOnUiThreadDelayed(new Runnable() {
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

    private void updateAtUserInfoMap(ArrayList<String> names, ArrayList<String> ids) {
        displayInputString = "";

        for (int i = 0; i < ids.size(); i++) {
            atUserInfoMap.put(ids.get(i), names.get(i));

            // for display
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

        if (!displayInputString.isEmpty()) {
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
        mInputMoreFragment.dismiss();
        mInputMoreFragment = null;
        ActivityResultResolver.getMultipleContent(getActivity(),
            new String[] {ActivityResultResolver.CONTENT_TYPE_IMAGE, ActivityResultResolver.CONTENT_TYPE_VIDEO}, new TUIValueCallback<List<Uri>>() {
                @Override
                public void onSuccess(List<Uri> data) {
                    ThreadUtils.runOnUiThread(() -> sendPhotoVideoMessage(data));
                }

                @Override
                public void onError(int errorCode, String errorMessage) {}
            });
    }

    private void sendPhotoVideoMessage(List<Uri> uris) {
        List<TUIMessageBean> messageBeans = new ArrayList<>();
        for (Uri data : uris) {
            if (data == null) {
                TUIChatLog.e(TAG, "data is null");
                continue;
            }

            String uri = data.toString();
            if (TextUtils.isEmpty(uri)) {
                TUIChatLog.e(TAG, "uri is empty");
                continue;
            }

            String filePath = FileUtil.getPathFromUri(data);
            String fileName = FileUtil.getName(filePath);
            String fileExtension = FileUtil.getFileExtensionFromUrl(fileName);
            String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
            if (TextUtils.isEmpty(mimeType)) {
                TUIChatLog.e(TAG, "mimeType is empty.");
                continue;
            }
            if (mimeType.contains("video")) {
                if (FileUtil.isFileSizeExceedsLimit(data, GeneralConfig.VIDEO_MAX_SIZE)) {
                    ToastUtil.toastShortMessage(getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorFileTooLarge));
                    continue;
                }
                TUIMessageBean msg = buildVideoMessage(filePath);
                if (msg == null) {
                    ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                    TUIChatLog.e(TAG, "start send video error data: " + data);
                } else {
                    messageBeans.add(msg);
                }
            } else if (mimeType.contains("image")) {
                if (TextUtils.equals(mimeType, "image/gif")) {
                    if (FileUtil.isFileSizeExceedsLimit(data, GeneralConfig.GIF_IMAGE_MAX_SIZE)) {
                        ToastUtil.toastShortMessage(getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorFileTooLarge));
                        continue;
                    }
                } else {
                    if (FileUtil.isFileSizeExceedsLimit(data, GeneralConfig.IMAGE_MAX_SIZE)) {
                        ToastUtil.toastShortMessage(getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorFileTooLarge));
                        continue;
                    }
                }
                TUIMessageBean msg = ChatMessageBuilder.buildImageMessage(filePath);
                if (msg == null) {
                    TUIChatLog.e(TAG, "start send image error data: " + data);
                    ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                } else {
                    messageBeans.add(msg);
                }
            } else {
                TUIChatLog.e(TAG, "Send photo or video failed , invalid mimeType : " + mimeType);
            }
        }
        if (mMessageHandler != null) {
            mMessageHandler.sendMessages(messageBeans);
            resetInput();
        }
    }

    public TUIMessageBean buildVideoMessage(String path) {
        android.media.MediaMetadataRetriever mmr = new android.media.MediaMetadataRetriever();
        try {
            mmr.setDataSource(path);
            String sDuration = mmr.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION);
            Bitmap bitmap = mmr.getFrameAtTime(0, android.media.MediaMetadataRetriever.OPTION_NEXT_SYNC);

            if (bitmap == null) {
                TUIChatLog.e(TAG, "buildVideoMessage() bitmap is null");
                return null;
            }
            String bitmapPath = FileUtil.generateImageFilePath();
            boolean result = FileUtil.saveBitmap(bitmapPath, bitmap);
            if (!result) {
                TUIChatLog.e(TAG, "build video message, save bitmap failed.");
                return null;
            }
            String videoPath = path;
            int imgWidth = bitmap.getWidth();
            int imgHeight = bitmap.getHeight();
            long duration = Long.valueOf(sDuration);
            TUIMessageBean msg = ChatMessageBuilder.buildVideoMessage(bitmapPath, videoPath, imgWidth, imgHeight, duration);

            return msg;
        } catch (Exception ex) {
            TUIChatLog.e(TAG, "MediaMetadataRetriever exception " + ex);
        } finally {
            mmr.release();
        }

        return null;
    }

    private void startCapture() {
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isUseSystemCamera()) {
            if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        String path = FileUtil.generateExternalStorageImageFilePath();
                        systemCaptureAndSend(path);
                    }

                    @Override
                    public void onDenied() {
                        TUIChatLog.i(TAG, "startCapture checkPermission failed");
                    }
                });
            } else {
                String path = FileUtil.generateImageFilePath();
                systemCaptureAndSend(path);
            }
        } else {
            chatCaptureAndSend();
        }
        resetInput();
    }

    private void systemCaptureAndSend(String path) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            return;
        }
        ActivityResultResolver.takePicture(getActivity(), uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File imageFile = new File(path);
                if (imageFile.exists()) {
                    sendPhotoVideoMessage(Collections.singletonList(uri));
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private void chatCaptureAndSend() {
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_CAPTURE);
        TUICore.startActivityForResult(getActivity(), CameraActivity.class, bundle, result -> {
            if (result.getData() != null) {
                Uri uri = result.getData().getData();
                if (uri != null) {
                    sendPhotoVideoMessage(Collections.singletonList(uri));
                }
            }
        });
    }

    protected void startVideoRecordCheckPermission() {
        TUIChatLog.i(TAG, "startVideoRecordCheckPermission");

        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        startVideoRecord();
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

    private void startVideoRecord() {
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isUseSystemCamera()) {
            if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        String path = FileUtil.generateExternalStorageVideoFilePath();
                        systemRecordAndSend(path);
                    }

                    @Override
                    public void onDenied() {
                        TUIChatLog.i(TAG, "startVideoRecord checkPermission failed");
                    }
                });
            } else {
                String path = FileUtil.generateVideoFilePath();
                systemRecordAndSend(path);
            }
        } else {
            chatRecordAndSend();
        }
        resetInput();
    }

    private void systemRecordAndSend(String path) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            return;
        }
        ActivityResultResolver.takeVideo(getActivity(), uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File videoFile = new File(path);
                if (videoFile.exists()) {
                    sendPhotoVideoMessage(Collections.singletonList(uri));
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private void chatRecordAndSend() {
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_RECORDER);

        TUICore.startActivityForResult(getActivity(), CameraActivity.class, bundle, result -> {
            Intent data = result.getData();
            if (data == null) {
                return;
            }
            Uri uri = data.getData();
            if (uri != null) {
                sendPhotoVideoMessage(Collections.singletonList(uri));
            }
        });
    }

    protected void startSendFile() {
        TUIChatLog.i(TAG, "startSendFile");
        mInputMoreFragment.dismiss();
        mInputMoreFragment = null;
        ActivityResultResolver.getSingleContent(getActivity(), ActivityResultResolver.CONTENT_TYPE_ALL, new TUIValueCallback<Uri>() {
            @Override
            public void onSuccess(Uri data) {
                if (data == null) {
                    return;
                }
                if (FileUtil.isFileSizeExceedsLimit(data, GeneralConfig.FILE_MAX_SIZE)) {
                    ToastUtil.toastShortMessage(getResources().getString(com.tencent.qcloud.tuicore.R.string.TUIKitErrorFileTooLarge));
                    return;
                }
                TUIMessageBean info = ChatMessageBuilder.buildFileMessage(data);
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
            public void onError(int errorCode, String errorMessage) {}
        });
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
        static final int CANCEL_RECORD_AUDIO_CLICKED = 7;
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
            for (InputMachineTransaction transaction : transactionList) {
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
                .event(this::resetInput)
                .nextState(InputState.STATE_NONE),

            new InputMachineTransaction()
                .currentState(InputState.STATE_FACE_INPUT)
                .action(InputAction.MORE_CLICKED)
                .event(this::resetInput)
                .nextState(InputState.STATE_NONE),

            new InputMachineTransaction()
                .currentState(InputState.STATE_SOFT_INPUT)
                .action(InputAction.MORE_CLICKED)
                .event(this::resetInput)
                .nextState(InputState.STATE_NONE),

            new InputMachineTransaction()
                .currentState(InputState.STATE_AUDIO_INPUT)
                .action(InputAction.AUDIO_CLICKED)
                .event(this::stopAudioRecord)
                .nextState(InputState.STATE_NONE),

            new InputMachineTransaction()
                .currentState(InputState.STATE_AUDIO_INPUT)
                .action(InputAction.CANCEL_RECORD_AUDIO_CLICKED)
                .event(this::cancelAudioRecord)
                .nextState(InputState.STATE_NONE),

            /**
             *  transition to {@link InputState.STATE_AUDIO_INPUT}
             */
            new InputMachineTransaction()
                .currentState(InputState.STATE_SOFT_INPUT)
                .action(InputAction.AUDIO_CLICKED)
                .event(this::startAudioRecord)
                .nextState(InputState.STATE_AUDIO_INPUT),

            new InputMachineTransaction()
                .currentState(InputState.STATE_FACE_INPUT)
                .action(InputAction.AUDIO_CLICKED)
                .event(this::startAudioRecord)
                .nextState(InputState.STATE_AUDIO_INPUT),

            new InputMachineTransaction()
                .currentState(InputState.STATE_NONE)
                .action(InputAction.AUDIO_CLICKED)
                .event(this::startAudioRecord)
                .nextState(InputState.STATE_AUDIO_INPUT)

        );
        inputMachine = new InputMachine(InputState.STATE_NONE, transactionList);
    }

    private void showSoftInputAndHideFace() {
        showSoftInputAndThen(this::hideFace);
        faceKeyboardInputButton.setImageResource(R.drawable.chat_minimalist_input_face_icon);
    }

    private void hideSoftInputAndShowFace() {
        showFace();
        hideSoftInput();
        mTextInput.requestFocus();
        faceKeyboardInputButton.setImageResource(R.drawable.chat_input_keyboard);
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
        }
    }

    @FunctionalInterface
    interface Callback {
        void onCall();
    }

    public void showSoftInputAndThen(Callback callback) {
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        mTextInput.requestFocus();
        imm.showSoftInput(mTextInput, 0);
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
        faceKeyboardInputButton.setImageResource(R.drawable.chat_minimalist_input_face_icon);
        mTextInput.clearFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mTextInput.getWindowToken(), 0);
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
            faceFragment.setTabIndicatorColor(getResources().getColor(R.color.chat_bubble_other_color));
            faceFragment.setListener(new OnFaceInputListener() {
                @Override
                public void onEmojiClicked(String emojiKey) {
                    int index = mTextInput.getSelectionStart();
                    Editable editable = mTextInput.getText();
                    editable.insert(index, emojiKey);
                    FaceUtil.handlerEmojiText(mTextInput, editable, true);
                }

                @Override
                public void onDeleteClicked() {
                    mTextInput.getInputConnection().sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
                }

                @Override
                public void onSendClicked() {
                    sendTextMessage();
                }

                @Override
                public void onFaceClicked(ChatFace face) {
                    TUIMessageBean messageBean = ChatMessageBuilder.buildFaceMessage(face.getFaceGroup().getGroupID(), face.getFaceKey());
                    mMessageHandler.sendMessage(messageBean);
                }
            });
        }
        hideSoftInput();
        faceKeyboardInputButton.setImageResource(R.drawable.chat_input_keyboard);
        mTextInput.requestFocus();
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
        faceKeyboardInputButton.setImageResource(R.drawable.chat_minimalist_input_face_icon);
    }

    private void resetInput() {
        if (mInputMoreFragment != null) {
            mInputMoreFragment.dismiss();
        }
        mInputMoreLayout.setVisibility(GONE);
        faceKeyboardInputButton.setImageResource(R.drawable.chat_minimalist_input_face_icon);
        hideSoftInput();
    }

    private void stopAudioRecord() {
        AudioRecorder.stopRecord();
    }

    private void cancelAudioRecord() {
        AudioRecorder.cancelRecord();
    }

    private void hideVoiceLayout() {
        resetVoiceView();
        voiceBtn.setVisibility(VISIBLE);
        mSendAudioButtonLayout.setVisibility(GONE);
        showInputMoreButton();
        showTextInputLayout();
        showImageButton();
        hideVoiceDeleteImage();
    }

    private void showVoiceLayout() {
        initVoiceWaveView();
        mSendAudioButtonLayout.setVisibility(VISIBLE);
        voiceBtn.setVisibility(GONE);
        hideInputMoreButton();
        hideTextInputLayout();
        hideImageButton();
        showVoiceDeleteImage();
    }

    private void startAudioRecord() {
        AudioRecorder.startRecord(new AudioRecorder.AudioRecorderCallback() {
            @Override
            public void onStarted() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                }
                showVoiceLayout();
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                }
                if (mTimer == null) {
                    mTimer = new Timer();
                }
                mTimer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        ThreadUtils.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                times++;
                                String s = formatMiss(times);
                                mSendAudioButton.setText(s);
                            }
                        });
                    }
                }, 0, 1000);
            }

            @Override
            public void onFinished(String outputPath) {
                hideVoiceLayout();
                int duration = AudioRecorder.getDuration(outputPath);
                if (duration < 1000) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_TOO_SHORT);
                    return;
                }
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
                }
                if (mVoiceWaveView != null) {
                    mVoiceWaveView.stop();
                }
                sendAudioMessage(outputPath, duration);
            }

            @Override
            public void onFailed(int errorCode, String errorMessage) {
                if (errorCode == AudioRecorder.ERROR_CODE_MIC_IS_BEING_USED || errorCode == TUIConstants.TUICalling.ERROR_STATUS_IN_CALL) {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_mic_is_being_used_cant_record));
                } else {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_record_audio_failed));
                }
                hideVoiceLayout();
                TUIChatLog.e(TAG, "record audio failed, errorCode " + errorCode + ", errorMessage " + errorMessage);
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_FAILED);
                }
                if (mVoiceWaveView != null) {
                    mVoiceWaveView.stop();
                }
            }

            @Override
            public void onCanceled() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                }
                if (mVoiceWaveView != null) {
                    mVoiceWaveView.stop();
                }
                hideVoiceLayout();
            }

            @Override
            public void onVoiceDb(double db) {
                if (mSendAudioButtonLayout.getVisibility() == VISIBLE) {
                    if (db == 0) {
                        db = 2;
                    }
                    mVoiceWaveView.addBody((int) db);
                    mVoiceWaveView.start();
                }
            }
        });
    }

    private void resetVoiceView() {
        initVoiceWaveView();
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
        mSendAudioButton.setText("0:00");
        times = 0;
    }

    private void sendAudioMessage(String outputPath, int duration) {
        if (mMessageHandler != null) {
            mMessageHandler.sendMessage(ChatMessageBuilder.buildAudioMessage(outputPath, duration));
        }
    }

    private void readyToCancelRecord() {
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_READY_TO_CANCEL);
        }
        voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_start_icon);
        voiceDeleteImage.getBackground().setAutoMirrored(true);
        mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_red));
    }

    private void continueRecord() {
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CONTINUE);
        }
        voiceDeleteImage.setBackgroundResource(R.drawable.minimalist_delete_icon);
        mSendAudioButton.setBackground(getResources().getDrawable(R.drawable.minimalist_corner_bg_blue));
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

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        mInputContent = s.toString();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {}

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
            actionUnit.setName(getResources().getString(R.string.pic));
            actionUnit.setActionType(1);
            actionUnit.setPriority(1000);
            mInputMoreActionList.add(actionUnit);
        }

        if (!mCaptureDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startCaptureCheckPermission();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_camera_icon);
            actionUnit.setActionType(1);
            actionUnit.setPriority(900);
            actionUnit.setName(getResources().getString(R.string.photo));
            mInputMoreActionList.add(actionUnit);
        }

        if (!mVideoRecordDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startVideoRecordCheckPermission();
                }
            };
            actionUnit.setIconResId(R.drawable.chat_minimalist_more_action_record_icon);
            actionUnit.setActionType(1);
            actionUnit.setPriority(800);
            actionUnit.setName(getResources().getString(R.string.video));
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
            actionUnit.setPriority(700);
            actionUnit.setName(getResources().getString(R.string.file));
            mInputMoreActionList.add(actionUnit);
        }

        mInputMoreActionList.addAll(mInputMoreCustomActionList);
        mInputMoreActionList.addAll(getExtensionInputMoreList());
        Collections.sort(mInputMoreActionList, new Comparator<InputMoreActionUnit>() {
            @Override
            public int compare(InputMoreActionUnit o1, InputMoreActionUnit o2) {
                return o2.getPriority() - o1.getPriority();
            }
        });
    }

    private List<InputMoreActionUnit> getExtensionInputMoreList() {
        List<InputMoreActionUnit> list = new ArrayList<>();

        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.InputMore.CONTEXT, getContext());
        if (ChatInfo.TYPE_C2C == mChatInfo.getType()) {
            param.put(TUIConstants.TUIChat.Extension.InputMore.USER_ID, mChatInfo.getId());
        } else {
            param.put(TUIConstants.TUIChat.Extension.InputMore.GROUP_ID, mChatInfo.getId());
        }
        if (mChatInfo.getType() == ChatInfo.TYPE_GROUP && TUIChatUtils.isTopicGroup(mChatInfo.getId())) {
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VIDEO_CALL, true);
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL, true);
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_ROOM, true);
        } else {
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VIDEO_CALL,
                    !TUIChatConfigs.getGeneralConfig().isEnableVideoCall() || !getChatInfo().isEnableVideoCall());
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL,
                    !TUIChatConfigs.getGeneralConfig().isEnableAudioCall() || !getChatInfo().isEnableAudioCall());
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_ROOM,
                    !TUIChatConfigs.getGeneralConfig().isEnableRoomKit() || !getChatInfo().isEnableRoom());
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_GROUP_NOTE,
                    !TUIChatConfigs.getGeneralConfig().isEnableGroupNote() || !getChatInfo().isEnableGroupNote());
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_POLL,
                    !TUIChatConfigs.getGeneralConfig().isEnablePoll() || !getChatInfo().isEnablePoll());
        }
        param.put(TUIConstants.TUIChat.Extension.InputMore.INPUT_MORE_LISTENER, chatInputMoreListener);
        List<TUIExtensionInfo> extensionList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.InputMore.MINIMALIST_EXTENSION_ID, param);
        for (TUIExtensionInfo extensionInfo : extensionList) {
            if (extensionInfo != null) {
                String name = extensionInfo.getText();
                int icon = (int) extensionInfo.getIcon();
                int priority = extensionInfo.getWeight();
                InputMoreActionUnit unit = new InputMoreActionUnit() {
                    @Override
                    public void onAction(String chatInfoId, int chatType) {
                        TUIExtensionEventListener extensionListener = extensionInfo.getExtensionListener();
                        if (extensionListener != null) {
                            extensionListener.onClicked(null);
                        }
                    }
                };
                unit.setName(name);
                unit.setIconResId(icon);
                unit.setPriority(priority);
                list.add(unit);
            }
        }
        return list;
    }

    public void startCaptureCheckPermission() {
        TUIChatLog.i(TAG, "startCaptureCheckPermission");

        PermissionHelper.requestPermission(PermissionHelper.PERMISSION_CAMERA, new PermissionHelper.PermissionCallback() {
            @Override
            public void onGranted() {
                startCapture();
            }

            @Override
            public void onDenied() {
                TUIChatLog.i(TAG, "startCapture checkPermission failed");
            }
        });
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

    protected void showMoreInputButton(int visibility) {}

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

        default void sendMessages(List<TUIMessageBean> messageBeans) {}

        void scrollToEnd();
    }

    public interface ChatInputHandler {
        int RECORD_START = 1;
        int RECORD_STOP = 2;
        int RECORD_CANCEL = 3;
        int RECORD_TOO_SHORT = 4;
        int RECORD_FAILED = 5;
        int RECORD_CONTINUE = 6;
        int RECORD_READY_TO_CANCEL = 7;

        void onInputAreaClick();

        void onRecordStatusChanged(int status);

        void onUserTyping(boolean status, long time);
    }

    public interface OnInputViewListener {
        void onStartGroupMemberSelectActivity();

        void onClickCapture();

        void onUpdateChatBackground();
    }
}
