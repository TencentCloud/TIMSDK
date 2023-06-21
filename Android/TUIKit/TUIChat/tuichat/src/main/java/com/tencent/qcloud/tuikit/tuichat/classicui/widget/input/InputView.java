package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import android.annotation.SuppressLint;
import android.app.Activity;
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
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.CustomFace;
import com.tencent.qcloud.tuikit.timcommon.component.face.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.face.FaceFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore.InputMoreFragment;
import com.tencent.qcloud.tuikit.tuichat.component.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraActivity;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 聊天界面，底部发送图片、拍照、摄像、文件面板
 *
 * Chat interface, send pictures, take pictures, video, file panels at the bottom
 */

public class InputView extends LinearLayout implements View.OnClickListener, TextWatcher {
    private static final String TAG = InputView.class.getSimpleName();

    private static final int STATE_NONE_INPUT = -1;
    private static final int STATE_SOFT_INPUT = 0;
    private static final int STATE_VOICE_INPUT = 1;
    private static final int STATE_FACE_INPUT = 2;
    private static final int STATE_ACTION_INPUT = 3;

    // 音视频通话成员数限制
    // Membership limit for audio and video calls
    protected static final int CALL_MEMBER_LIMIT = 8;

    /**
     * 语音/文字切换输入控件
     *
     * Voice/text switch input controls
     */
    protected ImageView mAudioInputSwitchButton;
    protected boolean mAudioInputDisable;

    /**
     * 表情按钮
     *
     * emoji button
     */
    protected ImageView mEmojiInputButton;
    protected boolean mEmojiInputDisable;

    /**
     * 更多按钮
     *
     * more button
     */
    protected ImageView mMoreInputButton;
    protected Object mMoreInputEvent;
    protected boolean mMoreInputDisable;

    /**
     * 消息发送按钮
     *
     * message send button
     */
    protected TextView mSendTextButton;

    /**
     * 语音长按按钮
     *
     * voice send button
     */
    protected Button mSendAudioButton;

    /**
     * 文本输入框
     *
     * input text
     */
    protected TIMMentionEditText mTextInput;
    private boolean mIsSending = false;

    protected AppCompatActivity mActivity;
    protected View mInputMoreLayout;
    //    protected ShortcutArea mShortcutArea;
    protected View mInputMoreView;
    protected ChatInfo mChatInfo;
    protected List<InputMoreActionUnit> mInputMoreActionList = new ArrayList<>();
    protected List<InputMoreActionUnit> mInputMoreCustomActionList = new ArrayList<>();
    private boolean mSendPhotoDisable;
    private boolean mCaptureDisable;
    private boolean mVideoRecordDisable;
    private boolean mSendFileDisable;

    private FaceFragment mFaceFragment;
    private ChatInputHandler mChatInputHandler;
    private MessageHandler mMessageHandler;
    private FragmentManager mFragmentManager;
    private InputMoreFragment mInputMoreFragment;
    private IChatLayout mChatLayout;
    private boolean mSendEnable;
    private boolean mAudioCancel;
    private int mCurrentState;
    private int mLastMsgLineCount;
    private float mStartRecordY;
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
    private View quotePreviewBar;
    private TextView quoteTv;
    private ImageView quoteCloseBtn;
    private boolean isShowCustomFace = true;
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

    private void initViews() {
        mActivity = (AppCompatActivity) getContext();
        inflate(mActivity, R.layout.chat_input_layout, this);
        //        mShortcutArea = findViewById(R.id.shortcut_area);
        mInputMoreView = findViewById(R.id.more_groups);
        mSendAudioButton = findViewById(R.id.chat_voice_input);
        mAudioInputSwitchButton = findViewById(R.id.voice_input_switch);
        mEmojiInputButton = findViewById(R.id.face_btn);
        mMoreInputButton = findViewById(R.id.more_btn);
        mSendTextButton = findViewById(R.id.send_btn);
        mTextInput = findViewById(R.id.chat_message_input);
        replyPreviewBar = findViewById(R.id.reply_preview_bar);
        replyTv = replyPreviewBar.findViewById(R.id.reply_text);
        replyCloseBtn = replyPreviewBar.findViewById(R.id.reply_close_btn);
        quotePreviewBar = findViewById(R.id.quote_preview_bar);
        quoteTv = quotePreviewBar.findViewById(R.id.reply_text);
        quoteCloseBtn = quotePreviewBar.findViewById(R.id.reply_close_btn);

        int iconSize = getResources().getDimensionPixelSize(R.dimen.chat_input_icon_size);
        ViewGroup.LayoutParams layoutParams = mEmojiInputButton.getLayoutParams();
        layoutParams.width = iconSize;
        layoutParams.height = iconSize;
        mEmojiInputButton.setLayoutParams(layoutParams);

        layoutParams = mAudioInputSwitchButton.getLayoutParams();
        layoutParams.width = iconSize;
        layoutParams.height = iconSize;
        mAudioInputSwitchButton.setLayoutParams(layoutParams);

        layoutParams = mMoreInputButton.getLayoutParams();
        layoutParams.width = iconSize;
        layoutParams.height = iconSize;
        mMoreInputButton.setLayoutParams(layoutParams);

        mIsSending = false;

        init();
    }

    @SuppressLint("ClickableViewAccessibility")
    protected void init() {
        mAudioInputSwitchButton.setOnClickListener(this);
        mEmojiInputButton.setOnClickListener(this);
        mMoreInputButton.setOnClickListener(this);
        mSendTextButton.setOnClickListener(this);
        mTextInput.addTextChangedListener(this);
        mTextInput.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
                    if (presenter != null) {
                        presenter.scrollToNewestMessage();
                    }
                    showSoftInput();
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

        mSendAudioButton.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                PermissionHelper.requestPermission(PermissionHelper.PERMISSION_MICROPHONE, new PermissionHelper.PermissionCallback() {
                    @Override
                    public void onGranted() {
                        switch (motionEvent.getAction()) {
                            case MotionEvent.ACTION_DOWN:
                                mAudioCancel = true;
                                mStartRecordY = motionEvent.getY();
                                if (mChatInputHandler != null) {
                                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                                }
                                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.release_end));
                                AudioRecorder.getInstance().startRecord(new AudioRecorder.Callback() {
                                    @Override
                                    public void onCompletion(Boolean success) {
                                        recordComplete(success);
                                    }

                                    @Override
                                    public void onVoiceDb(double db) {}
                                });
                                break;
                            case MotionEvent.ACTION_MOVE:
                                if (motionEvent.getY() - mStartRecordY < -100) {
                                    mAudioCancel = true;
                                    if (mChatInputHandler != null) {
                                        mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                                    }
                                } else {
                                    if (mAudioCancel) {
                                        if (mChatInputHandler != null) {
                                            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                                        }
                                    }
                                    mAudioCancel = false;
                                }
                                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.release_end));
                                break;
                            case MotionEvent.ACTION_CANCEL:
                            case MotionEvent.ACTION_UP:
                                mAudioCancel = motionEvent.getY() - mStartRecordY < -100;
                                if (mChatInputHandler != null) {
                                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
                                }
                                AudioRecorder.getInstance().stopRecord();
                                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
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
                FaceManager.handlerEmojiText(mTextInput, text, true);
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
                FaceManager.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + displayInputString.length());
            }
            // @ 之后要显示软键盘。Activity 没有 onResume 导致无法显示软键盘
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
        ActivityResultResolver.getMultipleContent(mInputMoreFragment.getActivity(),
            new String[] {ActivityResultResolver.CONTENT_TYPE_IMAGE, ActivityResultResolver.CONTENT_TYPE_VIDEO}, new TUIValueCallback<List<Uri>>() {
                @Override
                public void onSuccess(List<Uri> uris) {
                    ThreadUtils.runOnUiThread(() -> sendPhotoVideoMessage(uris));
                }

                @Override
                public void onError(int errorCode, String errorMessage) {}
            });
    }

    private void sendPhotoVideoMessage(List<Uri> uris) {
        List<TUIMessageBean> messageBeans = new ArrayList<>();
        for (Uri data : uris) {
            TUIChatLog.i(TAG, "onSuccess: " + data);
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
                TUIMessageBean msg = buildVideoMessage(filePath);
                if (msg == null) {
                    ToastUtil.toastShortMessage(getResources().getString(R.string.send_failed_file_not_exists));
                    TUIChatLog.e(TAG, "start send video error data: " + data);
                } else {
                    messageBeans.add(msg);
                }
            } else if (mimeType.contains("image")) {
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
            hideSoftInput();
        }
    }

    private TUIMessageBean buildVideoMessage(String videoPath) {
        android.media.MediaMetadataRetriever mmr = new android.media.MediaMetadataRetriever();
        try {
            mmr.setDataSource(videoPath);
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
            int imgWidth = bitmap.getWidth();
            int imgHeight = bitmap.getHeight();
            long duration = Long.parseLong(sDuration);

            return ChatMessageBuilder.buildVideoMessage(bitmapPath, videoPath, imgWidth, imgHeight, duration);
        } catch (Exception ex) {
            TUIChatLog.e(TAG, "MediaMetadataRetriever exception " + ex);
        } finally {
            mmr.release();
        }

        return null;
    }

    protected void startCaptureCheckPermission() {
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
    }

    private void chatCaptureAndSend() {
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_CAPTURE);
        TUICore.startActivityForResult(mInputMoreFragment, CameraActivity.class, bundle, result -> {
            if (result.getData() != null) {
                Uri uri = result.getData().getData();
                if (uri != null) {
                    TUIMessageBean msg = ChatMessageBuilder.buildImageMessage(FileUtil.getPathFromUri(uri));
                    if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(msg);
                        hideSoftInput();
                    }
                }
            }
        });
    }

    private void systemCaptureAndSend(String path) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            return;
        }
        ActivityResultResolver.takePicture(mInputMoreFragment, uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File imageFile = new File(path);
                if (imageFile.exists()) {
                    TUIMessageBean msg = ChatMessageBuilder.buildImageMessage(path);
                    if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(msg);
                        hideSoftInput();
                    }
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
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
    }

    private void systemRecordAndSend(String path) {
        Uri uri = FileUtil.getUriFromPath(path);
        if (uri == null) {
            return;
        }
        ActivityResultResolver.takeVideo(mInputMoreFragment, uri, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                File videoFile = new File(path);
                if (videoFile.exists()) {
                    TUIMessageBean messageBean = buildVideoMessage(path);
                    if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(messageBean);
                        hideSoftInput();
                    }
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    private void chatRecordAndSend() {
        Bundle bundle = new Bundle();
        bundle.putInt(TUIChatConstants.CAMERA_TYPE, CameraActivity.BUTTON_STATE_ONLY_RECORDER);

        TUICore.startActivityForResult(mInputMoreFragment, CameraActivity.class, bundle, result -> {
            Intent videoData = result.getData();
            if (videoData == null) {
                return;
            }
            Uri videoUri = videoData.getData();
            if (videoUri != null) {
                TUIMessageBean messageBean = buildVideoMessage(FileUtil.getPathFromUri(videoUri));
                if (mMessageHandler != null) {
                    mMessageHandler.sendMessage(messageBean);
                    hideSoftInput();
                }
            }
        });
    }

    protected void startSendFile() {
        TUIChatLog.i(TAG, "startSendFile");
        ActivityResultResolver.getSingleContent(mInputMoreFragment.getActivity(), ActivityResultResolver.CONTENT_TYPE_ALL, new TUIValueCallback<Uri>() {
            @Override
            public void onSuccess(Uri data) {
                if (data == null) {
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

    public void setChatInputMoreListener(ChatInputMoreListener chatInputMoreListener) {
        this.chatInputMoreListener = chatInputMoreListener;
    }

    @Override
    public void onClick(View view) {
        TUIChatLog.i(TAG,
            "onClick id:" + view.getId() + "|voice_input_switch:" + R.id.voice_input_switch + "|face_btn:" + R.id.face_btn + "|more_btn:" + R.id.more_btn
                + "|send_btn:" + R.id.send_btn + "|mCurrentState:" + mCurrentState + "|mSendEnable:" + mSendEnable + "|mMoreInputEvent:" + mMoreInputEvent);
        if (view.getId() == R.id.voice_input_switch) {
            if (mCurrentState == STATE_FACE_INPUT || mCurrentState == STATE_ACTION_INPUT) {
                mCurrentState = STATE_VOICE_INPUT;
                mInputMoreView.setVisibility(View.GONE);
                mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
            } else if (mCurrentState == STATE_SOFT_INPUT) {
                mCurrentState = STATE_VOICE_INPUT;
            } else {
                mCurrentState = STATE_SOFT_INPUT;
            }
            if (mCurrentState == STATE_VOICE_INPUT) {
                mSendAudioButton.setVisibility(VISIBLE);
                mTextInput.setVisibility(GONE);
                mAudioInputSwitchButton.setImageResource(R.drawable.chat_input_keyboard);
                hideInputMoreLayout();
                hideSoftInput();
            } else {
                mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
                showSoftInput();
            }
        } else if (view.getId() == R.id.face_btn) {
            mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
            if (mCurrentState == STATE_VOICE_INPUT) {
                mCurrentState = STATE_NONE_INPUT;
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
            }
            if (mCurrentState == STATE_FACE_INPUT) {
                mCurrentState = STATE_SOFT_INPUT;
                mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
                mTextInput.setVisibility(VISIBLE);
                showSoftInput();
            } else {
                mCurrentState = STATE_FACE_INPUT;
                mEmojiInputButton.setImageResource(R.drawable.chat_input_keyboard);
                showFaceViewGroup();
            }
        } else if (view.getId() == R.id.more_btn) {
            hideSoftInput();
            if (mMoreInputEvent instanceof View.OnClickListener) {
                ((View.OnClickListener) mMoreInputEvent).onClick(view);
            } else if (mMoreInputEvent instanceof BaseInputFragment) {
                showCustomInputMoreFragment();
            } else {
                if (mCurrentState == STATE_ACTION_INPUT) {
                    mCurrentState = STATE_NONE_INPUT;
                    mInputMoreView.setVisibility(View.VISIBLE);
                } else {
                    showInputMoreLayout();
                    mCurrentState = STATE_ACTION_INPUT;
                    mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                    mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
                    mSendAudioButton.setVisibility(GONE);
                    mTextInput.setVisibility(VISIBLE);
                }
            }
        } else if (view.getId() == R.id.send_btn) {
            if (mSendEnable) {
                if (mMessageHandler != null) {
                    if (mChatLayout == null) {
                        mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(mTextInput.getText().toString()));
                    } else {
                        if ((isQuoteModel || isReplyModel) && replyPreviewBean != null) {
                            if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                                List<String> atUserList = new ArrayList<>(mTextInput.getMentionIdList());
                                mMessageHandler.sendMessage(
                                    ChatMessageBuilder.buildAtReplyMessage(mTextInput.getText().toString(), atUserList, replyPreviewBean));
                            } else {
                                mMessageHandler.sendMessage(ChatMessageBuilder.buildReplyMessage(mTextInput.getText().toString(), replyPreviewBean));
                            }
                            exitReply();
                        } else {
                            if (TUIChatUtils.isGroupChat(mChatLayout.getChatInfo().getType()) && !mTextInput.getMentionIdList().isEmpty()) {
                                // 发送时通过获取输入框匹配上@的昵称list，去从map中获取ID list。
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
    }

    public void showSoftInput() {
        TUIChatLog.i(TAG, "showSoftInput");
        mCurrentState = STATE_SOFT_INPUT;
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (!isSoftInputShown()) {
            imm.toggleSoftInput(0, 0);
        }
        ThreadUtils.postOnUiThreadDelayed(new Runnable() {
            @Override
            public void run() {
                hideInputMoreLayout();
                mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                mEmojiInputButton.setImageResource(R.drawable.chat_input_face);
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
                mTextInput.requestFocus();
                Context context = getContext();
                if (context instanceof Activity) {
                    Window window = ((Activity) context).getWindow();
                    if (window != null) {
                        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
                    }
                }
            }
        }, 200);

        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 200);
        }
    }

    public void hideSoftInput() {
        TUIChatLog.i(TAG, "hideSoftInput");
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
        hideSoftInput();
        mCurrentState = STATE_SOFT_INPUT;
        hideInputMoreLayout();
        mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
        mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
        mSendAudioButton.setVisibility(GONE);
        mTextInput.setVisibility(VISIBLE);
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
        WindowManager windowManager = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
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

    private void showFaceViewGroup() {
        TUIChatLog.i(TAG, "showFaceViewGroup");
        if (mFragmentManager == null) {
            mFragmentManager = mActivity.getSupportFragmentManager();
        }
        if (mFaceFragment == null) {
            mFaceFragment = new FaceFragment();
        }
        hideSoftInput();
        mInputMoreView.setVisibility(View.VISIBLE);
        mTextInput.requestFocus();
        mFaceFragment.setShowCustomFace(isShowCustomFace);
        mFaceFragment.setListener(new FaceFragment.OnEmojiClickListener() {
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
        });
        mFragmentManager.beginTransaction().replace(R.id.more_groups, mFaceFragment).commitAllowingStateLoss();
        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 100);
        }
    }

    private void showCustomInputMoreFragment() {
        TUIChatLog.i(TAG, "showCustomInputMoreFragment");
        if (mFragmentManager == null) {
            mFragmentManager = mActivity.getSupportFragmentManager();
        }
        BaseInputFragment fragment = (BaseInputFragment) mMoreInputEvent;
        hideSoftInput();
        mInputMoreView.setVisibility(View.VISIBLE);
        mFragmentManager.beginTransaction().replace(R.id.more_groups, fragment).commitAllowingStateLoss();
        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 100);
        }
    }

    private void showInputMoreLayout() {
        TUIChatLog.i(TAG, "showInputMoreLayout");
        if (mFragmentManager == null) {
            mFragmentManager = mActivity.getSupportFragmentManager();
        }
        if (mInputMoreFragment == null) {
            mInputMoreFragment = new InputMoreFragment();
        }

        assembleActions();
        mInputMoreFragment.setActions(mInputMoreActionList);
        hideSoftInput();
        mInputMoreView.setVisibility(View.VISIBLE);
        mFragmentManager.beginTransaction().replace(R.id.more_groups, mInputMoreFragment).commitAllowingStateLoss();
        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 100);
        }
    }

    private void hideInputMoreLayout() {
        mInputMoreView.setVisibility(View.GONE);
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
    public void onTextChanged(CharSequence s, int start, int before, int count) {}

    @Override
    public void afterTextChanged(Editable s) {
        if (TextUtils.isEmpty(s.toString().trim())) {
            mSendEnable = false;
            showSendTextButton(View.GONE);
            showMoreInputButton(View.VISIBLE);

            if (mChatInputHandler != null) {
                mChatInputHandler.onUserTyping(false, V2TIMManager.getInstance().getServerTime());
            }
        } else {
            mSendEnable = true;
            showSendTextButton(View.VISIBLE);
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
        mChatInfo = chatInfo;
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
            actionUnit.setIconResId(R.drawable.ic_more_picture);
            actionUnit.setName(getString(R.string.pic));
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
            actionUnit.setIconResId(R.drawable.ic_more_camera);
            actionUnit.setName(getString(R.string.photo));
            actionUnit.setPriority(900);
            mInputMoreActionList.add(actionUnit);
        }

        if (!mVideoRecordDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startVideoRecordCheckPermission();
                }
            };
            actionUnit.setIconResId(R.drawable.ic_more_video);
            actionUnit.setPriority(800);
            actionUnit.setName(getString(R.string.video));
            mInputMoreActionList.add(actionUnit);
        }

        if (!mSendFileDisable) {
            actionUnit = new InputMoreActionUnit() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    startSendFile();
                }
            };
            actionUnit.setIconResId(R.drawable.ic_more_file);
            actionUnit.setName(getString(R.string.file));
            actionUnit.setPriority(700);
            mInputMoreActionList.add(actionUnit);
        }

        mInputMoreActionList.addAll(mInputMoreCustomActionList);

        List<InputMoreActionUnit> extensionList = getExtensionInputMoreList();
        mInputMoreActionList.addAll(extensionList);
        Collections.sort(mInputMoreActionList, new Comparator<InputMoreActionUnit>() {
            @Override
            public int compare(InputMoreActionUnit o1, InputMoreActionUnit o2) {
                return o2.getPriority() - o1.getPriority();
            }
        });
    }

    private String getString(int stringID) {
        return getResources().getString(stringID);
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
        } else {
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VIDEO_CALL, !TUIChatConfigs.getConfigs().getGeneralConfig().isEnableVideoCall());
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL, !TUIChatConfigs.getConfigs().getGeneralConfig().isEnableVoiceCall());
        }
        param.put(TUIConstants.TUIChat.Extension.InputMore.INPUT_MORE_LISTENER, chatInputMoreListener);
        List<TUIExtensionInfo> extensionList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, param);
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

    public void disableAudioInput(boolean disable) {
        mAudioInputDisable = disable;
        if (disable) {
            mAudioInputSwitchButton.setVisibility(GONE);
        } else {
            mAudioInputSwitchButton.setVisibility(VISIBLE);
        }
    }

    public void disableEmojiInput(boolean disable) {
        mEmojiInputDisable = disable;
        if (disable) {
            mEmojiInputButton.setVisibility(GONE);
        } else {
            mEmojiInputButton.setVisibility(VISIBLE);
        }
    }

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

    public void showReplyPreview(ReplyPreviewBean previewBean) {
        exitReply();
        replyPreviewBean = previewBean;
        String replyMessageAbstract = previewBean.getMessageAbstract();
        String msgTypeStr = ChatMessageParser.getMsgTypeStr(previewBean.getMessageType());
        String text = previewBean.getMessageSender() + " : " + msgTypeStr + " " + replyMessageAbstract;
        text = FaceManager.emojiJudge(text);
        // If replying to a text message, the middle part of the file name is displayed in abbreviated form
        if (previewBean.isReplyMessage()) {
            isReplyModel = true;
            replyTv.setText(text);
            replyPreviewBar.setVisibility(View.VISIBLE);
        } else {
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

        showSoftInput();
    }

    public void exitReply() {
        isReplyModel = false;
        replyPreviewBean = null;
        replyPreviewBar.setVisibility(View.GONE);
        isQuoteModel = false;
        quotePreviewBar.setVisibility(View.GONE);
        updateChatBackground();
    }

    private void updateChatBackground() {
        if (mOnInputViewListener != null) {
            mOnInputViewListener.onUpdateChatBackground();
        }
    }

    protected void showEmojiInputButton(int visibility) {
        if (mEmojiInputDisable) {
            return;
        }
        mEmojiInputButton.setVisibility(visibility);
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

        void onInputAreaClick();

        void onRecordStatusChanged(int status);

        void onUserTyping(boolean status, long time);
    }

    public interface OnInputViewListener {
        void onStartGroupMemberSelectActivity();

        void onUpdateChatBackground();
    }
}
