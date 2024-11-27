package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnFaceInputListener;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FaceUtil;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.CustomHelloMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreItem;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IChatLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore.InputMoreFragment;
import com.tencent.qcloud.tuikit.tuichat.component.album.AlbumPicker;
import com.tencent.qcloud.tuikit.tuichat.component.album.VideoRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.audio.AudioRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceFragment;
import com.tencent.qcloud.tuikit.tuichat.component.inputedittext.TIMMentionEditText;
import com.tencent.qcloud.tuikit.tuichat.config.GeneralConfig;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;
import com.tencent.qcloud.tuikit.tuichat.interfaces.AlbumPickerListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMultimediaRecorder;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
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

    /**
     *
     * Voice/text switch input controls
     */
    protected ImageView mAudioInputSwitchButton;
    protected boolean mAudioInputDisable;

    /**
     *
     * emoji button
     */
    protected ImageView mEmojiInputButton;
    protected boolean mEmojiInputDisable;

    /**
     *
     * more button
     */
    protected ImageView mMoreInputButton;
    protected Object mMoreInputEvent;
    protected boolean mMoreInputDisable;

    /**
     *
     * message send button
     */
    protected TextView mSendTextButton;

    /**
     *
     * voice send button
     */
    protected Button mSendAudioButton;

    /**
     *
     * input text
     */
    protected TIMMentionEditText mTextInput;
    private boolean mIsSending = false;

    protected FragmentActivity mActivity;
    protected View mInputMoreView;
    protected ChatInfo mChatInfo;
    protected List<InputMoreItem> mInputMoreActionList = new ArrayList<>();

    private FaceFragment mFaceFragment;
    private ChatInputHandler mChatInputHandler;
    private MessageHandler mMessageHandler;
    private FragmentManager mFragmentManager;
    private InputMoreFragment mInputMoreFragment;
    private IChatLayout mChatLayout;
    private boolean mSendEnable;
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
    private IMultimediaRecorder defaultVideoRecorder;
    private IMultimediaRecorder extVideoRecorder;
    private AudioRecorder defaultAudioRecorder;

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
        mActivity = (FragmentActivity) getContext();
        inflate(mActivity, R.layout.chat_input_layout, this);
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
            private boolean readyToCancel = false;

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                switch (motionEvent.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        mStartRecordY = motionEvent.getY();
                        startRecordAudio();
                        break;
                    case MotionEvent.ACTION_MOVE:
                        if (motionEvent.getY() - mStartRecordY < -100) {
                            readyToCancel = true;
                            readyToCancelRecordAudio();
                        } else {
                            if (readyToCancel) {
                                continueRecordAudio();
                            }
                            readyToCancel = false;
                        }
                        break;
                    case MotionEvent.ACTION_CANCEL:
                    case MotionEvent.ACTION_UP:
                        if (readyToCancel) {
                            cancelRecordAudio();
                        } else {
                            stopRecordAudio();
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
                FaceUtil.handlerEmojiText(mTextInput, text, true);
                mTextInput.setSelection(selectedIndex + insertStr.length());
            }
            showSoftInput();
        }
    }

    private void startRecordAudio() {
        AudioRecorder.startRecord(new AudioRecorder.AudioRecorderCallback() {
            @Override
            public void onStarted() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.release_end));
            }

            @Override
            public void onFailed(int errorCode, String errorMessage) {
                if (errorCode == AudioRecorder.ERROR_CODE_MIC_IS_BEING_USED || errorCode == TUIConstants.TUICalling.ERROR_STATUS_IN_CALL) {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_mic_is_being_used_cant_record));
                } else {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_record_audio_failed));
                }
                TUIChatLog.e(TAG, "record audio failed, errorCode " + errorCode + ", errorMessage " + errorMessage);
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_FAILED);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }

            @Override
            public void onFinished(String outputPath) {
                int duration = AudioRecorder.getDuration(outputPath);
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
                if (duration < 1000) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_TOO_SHORT);
                    return;
                }
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
                }
                sendAudioMessage(outputPath, duration);
            }

            @Override
            public void onCanceled() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }
        });
    }

    private void sendAudioMessage(String outputPath, int duration) {
        if (mMessageHandler != null) {
            mMessageHandler.sendMessage(ChatMessageBuilder.buildAudioMessage(outputPath, duration));
        }
    }

    private void readyToCancelRecordAudio() {
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_READY_TO_CANCEL);
        }
    }

    private void continueRecordAudio() {
        if (mChatInputHandler != null) {
            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CONTINUE);
        }
    }

    private void cancelRecordAudio() {
        AudioRecorder.cancelRecord();
    }

    private void stopRecordAudio() {
        AudioRecorder.stopRecord();
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
        AlbumPicker.pickMedia(mInputMoreFragment.getActivity(), new AlbumPickerListener() {
            @Override
            public void onFinished(Uri originalUri, Uri transcodeUri) {
                sendPhotoVideoMessage(originalUri, transcodeUri);
            }

            @Override
            public void onProgress(Uri originalUri, int progress)  {
                presenter.updateMessageProgress(originalUri, progress);
            }

            @Override
            public void onOriginalMediaPicked(Uri originalUri) {
                presenter.addPlaceholderMessage(originalUri);
                hideSoftInput();
            }

            @Override
            public void onCancel() {

            }
        });
    }

    private void sendPhotoVideoMessage(Uri uri) {
        presenter.sendPhotoVideoMessages(uri, null);
        hideSoftInput();
    }

    private void sendPhotoVideoMessage(Uri original, Uri transcodeUri) {
        presenter.sendPhotoVideoMessages(original, transcodeUri);
        ThreadUtils.runOnUiThread(this::hideSoftInput);
    }

    protected void takePhoto() {
        TUIChatLog.i(TAG, "takePhoto");

        VideoRecorder.openCamera(mInputMoreFragment, new TUIValueCallback<Uri>() {

            @Override
            public void onSuccess(Uri uri) {
                sendPhotoVideoMessage(uri);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "takePhoto errorCode: " + errorCode + " errorMessage: " + errorMessage);
            }
        });
    }

    protected void recordVideo() {
        TUIChatLog.i(TAG, "openVideoRecord");

        VideoRecorder.openVideoRecorder(mInputMoreFragment, new TUIValueCallback<Uri>() {
            @Override
            public void onSuccess(Uri uri) {
                sendPhotoVideoMessage(uri);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.i(TAG, "openVideoRecord errorCode: " + errorCode + " errorMessage: " + errorMessage);
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
            sendTextMessage();
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

    public void showSoftInput() {
        TUIChatLog.i(TAG, "showSoftInput");
        mCurrentState = STATE_SOFT_INPUT;
        mTextInput.requestFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(mTextInput, 0);
        ThreadUtils.postOnUiThreadDelayed(new Runnable() {
            @Override
            public void run() {
                hideInputMoreLayout();
                mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                mEmojiInputButton.setImageResource(R.drawable.chat_input_face);
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
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

    public void hideSoftInput() {
        TUIChatLog.i(TAG, "hideSoftInput");
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
        hideSoftInput();
        mCurrentState = STATE_SOFT_INPUT;
        hideInputMoreLayout();
        mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
        mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
        mSendAudioButton.setVisibility(GONE);
        mTextInput.setVisibility(VISIBLE);
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
        mFaceFragment.setBackgroundColor(getResources().getColor(R.color.tuichat_face_view_bg));
        mFaceFragment.setListener(new OnFaceInputListener() {
            @Override
            public void onDeleteClicked() {
                mTextInput.getInputConnection().sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
            }

            @Override
            public void onEmojiClicked(String emojiKey) {
                int index = mTextInput.getSelectionStart();
                Editable editable = mTextInput.getText();
                editable.insert(index, emojiKey);
                FaceUtil.handlerEmojiText(mTextInput, editable, true);
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
                FaceUtil.handlerEmojiText(mTextInput, mTextInput.getText(), true);
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

        List<Integer> excludeItems = new ArrayList<>();
        TUIChatConfigClassic.ChatInputMoreDataSource dataSource = TUIChatConfigClassic.getChatInputMoreDataSource();
        if (dataSource != null) {
            excludeItems.addAll(dataSource.inputBarShouldHideItemsInMoreMenuOfInfo(mChatInfo));
            mInputMoreActionList.addAll(dataSource.inputBarShouldAddNewItemToMoreMenuOfInfo(mChatInfo));
        }

        InputMoreItem actionUnit;
        if (TUIChatConfigClassic.isShowInputBarAlbum()
                && getChatInfo().isEnableAlbum()
                && !excludeItems.contains(TUIChatConfigClassic.ALBUM)) {
            actionUnit = new InputMoreItem() {
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

        if (TUIChatConfigClassic.isShowInputBarTakePhoto()
                && getChatInfo().isEnableTakePhoto()
                && !excludeItems.contains(TUIChatConfigClassic.TAKE_PHOTO)) {
            actionUnit = new InputMoreItem() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    takePhoto();
                }
            };
            actionUnit.setIconResId(R.drawable.ic_more_camera);
            actionUnit.setName(getString(R.string.photo));
            actionUnit.setPriority(900);
            mInputMoreActionList.add(actionUnit);
        }

        if (TUIChatConfigClassic.isShowInputBarRecordVideo()
                && getChatInfo().isEnableRecordVideo()
                && !excludeItems.contains(TUIChatConfigClassic.RECORD_VIDEO)) {
            actionUnit = new InputMoreItem() {
                @Override
                public void onAction(String chatInfoId, int chatType) {
                    recordVideo();
                }
            };
            actionUnit.setIconResId(R.drawable.ic_more_video);
            actionUnit.setPriority(800);
            actionUnit.setName(getString(R.string.video));
            mInputMoreActionList.add(actionUnit);
        }

        if (TUIChatConfigClassic.isShowInputBarFile()
                && getChatInfo().isEnableFile()
                && !excludeItems.contains(TUIChatConfigClassic.FILE)) {
            actionUnit = new InputMoreItem() {
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

        // Add a welcome prompt with rich text
        if (TUIChatConfigClassic.isShowInputBarCustom()
                && getChatInfo().isEnableCustomHelloMessage()
                && !excludeItems.contains(TUIChatConfigClassic.CUSTOM)) {
            actionUnit = new InputMoreItem() {};
            actionUnit.setIconResId(R.drawable.custom);
            actionUnit.setName(getResources().getString(R.string.test_custom_action));
            actionUnit.setActionId(CustomHelloMessage.CUSTOM_HELLO_ACTION_ID);
            actionUnit.setPriority(10);
            actionUnit.setOnClickListener(actionUnit.new OnActionClickListener() {
                @Override
                public void onClick() {
                    Gson gson = new Gson();
                    CustomHelloMessage customHelloMessage = new CustomHelloMessage();
                    customHelloMessage.version = TUIChatConstants.version;

                    String data = gson.toJson(customHelloMessage);
                    TUIMessageBean info = ChatMessageBuilder.buildCustomMessage(data, customHelloMessage.text, customHelloMessage.text.getBytes());
                    mChatLayout.sendMessage(info, false);
                }
            });
            mInputMoreActionList.add(actionUnit);
        }

        List<InputMoreItem> extensionList = getExtensionInputMoreList();
        mInputMoreActionList.addAll(extensionList);

        Collections.sort(mInputMoreActionList, new Comparator<InputMoreItem>() {
            @Override
            public int compare(InputMoreItem o1, InputMoreItem o2) {
                return o2.getPriority() - o1.getPriority();
            }
        });
    }

    private String getString(int stringID) {
        return getResources().getString(stringID);
    }

    private List<InputMoreItem> getExtensionInputMoreList() {
        List<InputMoreItem> list = new ArrayList<>();
        List<Integer> excludeItems = new ArrayList<>();
        TUIChatConfigClassic.ChatInputMoreDataSource dataSource = TUIChatConfigClassic.getChatInputMoreDataSource();
        if (dataSource != null) {
            excludeItems.addAll(dataSource.inputBarShouldHideItemsInMoreMenuOfInfo(mChatInfo));
        }
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
                !TUIChatConfigClassic.isShowInputBarVideoCall() || !getChatInfo().isEnableVideoCall()
                    || excludeItems.contains(TUIChatConfigClassic.VIDEO_CALL));
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL,
                !TUIChatConfigClassic.isShowInputBarAudioCall() || !getChatInfo().isEnableAudioCall()
                    || excludeItems.contains(TUIChatConfigClassic.AUDIO_CALL));
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_ROOM,
                !TUIChatConfigClassic.isShowInputBarRoomKit() || !getChatInfo().isEnableRoom() || excludeItems.contains(TUIChatConfigClassic.ROOM_KIT));
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_GROUP_NOTE,
                !TUIChatConfigClassic.isShowInputBarGroupNote() || !getChatInfo().isEnableGroupNote()
                    || excludeItems.contains(TUIChatConfigClassic.GROUP_NOTE));
            param.put(TUIConstants.TUIChat.Extension.InputMore.FILTER_POLL,
                !TUIChatConfigClassic.isShowInputBarPoll() || !getChatInfo().isEnablePoll() || excludeItems.contains(TUIChatConfigClassic.POLL));
        }
        param.put(TUIConstants.TUIChat.Extension.InputMore.INPUT_MORE_LISTENER, chatInputMoreListener);
        List<TUIExtensionInfo> extensionList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, param);
        for (TUIExtensionInfo extensionInfo : extensionList) {
            if (extensionInfo != null) {
                String name = extensionInfo.getText();
                int icon = (int) extensionInfo.getIcon();
                int priority = extensionInfo.getWeight();
                InputMoreItem unit = new InputMoreItem() {
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
        text = FaceUtil.emojiJudge(text);
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

        void onUpdateChatBackground();
    }
}
