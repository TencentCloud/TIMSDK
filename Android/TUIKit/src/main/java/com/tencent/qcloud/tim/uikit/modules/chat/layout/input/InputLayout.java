package com.tencent.qcloud.tim.uikit.modules.chat.layout.input;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.webkit.MimeTypeMap;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMManager;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.AudioPlayer;
import com.tencent.qcloud.tim.uikit.component.face.Emoji;
import com.tencent.qcloud.tim.uikit.component.face.FaceFragment;
import com.tencent.qcloud.tim.uikit.component.face.FaceManager;
import com.tencent.qcloud.tim.uikit.component.video.CameraActivity;
import com.tencent.qcloud.tim.uikit.component.video.JCameraView;
import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreFragment;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.DraftInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 聊天界面，底部发送图片、拍照、摄像、文件面板
 */

public class InputLayout extends InputLayoutUI implements View.OnClickListener, TextWatcher {

    private static final String TAG = InputLayout.class.getSimpleName();
    private static final int STATE_NONE_INPUT = -1;
    private static final int STATE_SOFT_INPUT = 0;
    private static final int STATE_VOICE_INPUT = 1;
    private static final int STATE_FACE_INPUT = 2;
    private static final int STATE_ACTION_INPUT = 3;
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
    private OnStartActivityListener mStartActivityListener;

    private Map<String,String> atUserInfoMap = new HashMap<>();
    private String displayInputString;

    public InputLayout(Context context) {
        super(context);
    }

    public InputLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public InputLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void init() {

        mAudioInputSwitchButton.setOnClickListener(this);
        mEmojiInputButton.setOnClickListener(this);
        mMoreInputButton.setOnClickListener(this);
        mSendTextButton.setOnClickListener(this);
        mTextInput.addTextChangedListener(this);
        mTextInput.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                showSoftInput();
                return false;
            }
        });
        mTextInput.setOnKeyListener(new OnKeyListener() {
            @Override
            public boolean onKey(View view, int i, KeyEvent keyEvent) {
                return false;
            }
        });
        mTextInput.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                return false;
            }
        });

        mSendAudioButton.setOnTouchListener(new OnTouchListener() {

            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                TUIKitLog.i(TAG, "mSendAudioButton onTouch action:" + motionEvent.getAction());
                if (!checkPermission(AUDIO_RECORD)) {
                    TUIKitLog.i(TAG, "audio record checkPermission failed");
                    return false;
                }
                switch (motionEvent.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        mAudioCancel = true;
                        mStartRecordY = motionEvent.getY();
                        if (mChatInputHandler != null) {
                            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                        }
                        mSendAudioButton.setText(TUIKit.getAppContext().getString(R.string.release_end));
                        AudioPlayer.getInstance().startRecord(new AudioPlayer.Callback() {
                            @Override
                            public void onCompletion(Boolean success) {
                                recordComplete(success);
                            }
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
                        mSendAudioButton.setText(TUIKit.getAppContext().getString(R.string.release_end));
                        break;
                    case MotionEvent.ACTION_CANCEL:
                    case MotionEvent.ACTION_UP:
                        mAudioCancel = motionEvent.getY() - mStartRecordY < -100;
                        if (mChatInputHandler != null) {
                            mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
                        }
                        AudioPlayer.getInstance().stopRecord();
                        mSendAudioButton.setText(TUIKit.getAppContext().getString(R.string.hold_say));
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
                if ((tag.equals(TIMMentionEditText.TIM_METION_TAG) || tag.equals(TIMMentionEditText.TIM_METION_TAG_FULL))
                        && mChatLayout.getChatInfo().getType() == V2TIMConversation.V2TIM_GROUP) {
                    if (mStartActivityListener != null) {
                        mStartActivityListener.onStartGroupMemberSelectActivity();
                    }
                }
            }
        });
    }

    public void updateInputText(String names, String ids){
        if (names == null || ids == null || names.isEmpty() || ids.isEmpty()){
            return;
        }

        updateAtUserInfoMap(names, ids);
        if (mTextInput != null) {
            mTextInput.setText(mTextInput.getText() + displayInputString);
            mTextInput.setSelection(mTextInput.getText().length());
        }
    }

    private void updateAtUserInfoMap(String names, String ids){
        displayInputString = "";

        if (ids.equals(V2TIMGroupAtInfo.AT_ALL_TAG)){
            atUserInfoMap.put(names, ids);

            //for display
            displayInputString += names;
            displayInputString += " ";
            displayInputString += TIMMentionEditText.TIM_METION_TAG;
        } else {
            String[] listName = names.split(" ");
            String[] listId = ids.split(" ");

            //此处防止昵称和ID不对等
            boolean isListName = (listName.length >= listId.length ? true : false);
            int i = 0;
            if (isListName) {
                for (i = 0; i < listId.length; i++) {
                    atUserInfoMap.put(listName[i], listId[i]);

                    //for display
                    displayInputString += listName[i];
                    displayInputString += " ";
                    displayInputString += TIMMentionEditText.TIM_METION_TAG;
                }
            } else {
                for (i = 0; i < listName.length; i++) {
                    atUserInfoMap.put(listName[i], listId[i]);

                    //for display
                    displayInputString += listName[i];
                    displayInputString += " ";
                    displayInputString += TIMMentionEditText.TIM_METION_TAG;
                }
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
    }

    @Override
    protected void startSendPhoto() {
        TUIKitLog.i(TAG, "startSendPhoto");
        if (!checkPermission(SEND_PHOTO)) {
            TUIKitLog.i(TAG, "startSendPhoto checkPermission failed");
            return;
        }

        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        String[] mimetypes = {"image/*", "video/*"};
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimetypes);

        setOpenPhotoCallback();
        mInputMoreFragment.startActivityForResult(intent, InputMoreFragment.REQUEST_CODE_PHOTO);
    }

    private void setOpenPhotoCallback() {
        mInputMoreFragment.setCallback(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                TUIKitLog.i(TAG, "onSuccess: " + data);
                if (data == null){
                    TUIKitLog.e(TAG, "data is null");
                    return;
                }

                String uri = data.toString();
                if (TextUtils.isEmpty(uri)){
                    TUIKitLog.e(TAG, "uri is empty");
                    return;
                }

                String videoPath = FileUtil.getPathFromUri((Uri) data);
                String fileExtension = FileUtil.getFileExtensionFromUrl(videoPath);
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
                if (TextUtils.isEmpty(mimeType)) {
                    TUIKitLog.e(TAG, "mimeType is empty.");
                    return;
                }
                if (mimeType.contains("video")){
                    MessageInfo msg = buildVideoMessage(FileUtil.getPathFromUri((Uri) data));
                    if (msg == null){
                        TUIKitLog.e(TAG, "start send video error data: " + data);
                    } else if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(msg);
                        hideSoftInput();
                    }
                } else if (mimeType.contains("image")){
                    MessageInfo info = MessageInfoUtil.buildImageMessage((Uri) data, true);
                    if (mMessageHandler != null) {
                        mMessageHandler.sendMessage(info);
                        hideSoftInput();
                    }
                } else {
                    TUIKitLog.e(TAG, "Send photo or video failed , invalid mimeType : " + mimeType);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIKitLog.i(TAG, "errCode: " + errCode);
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    private MessageInfo buildVideoMessage(String mUri)
    {
        android.media.MediaMetadataRetriever mmr = new android.media.MediaMetadataRetriever();
        try {
            mmr.setDataSource(mUri);
            String sDuration = mmr.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION);//时长(毫秒)
            Bitmap bitmap = mmr.getFrameAtTime(0, android.media.MediaMetadataRetriever.OPTION_NEXT_SYNC);//缩略图

            if (bitmap == null){
                TUIKitLog.e(TAG, "buildVideoMessage() bitmap is null");
                return null;
            }

            String imgPath = FileUtil.saveBitmap("JCamera", bitmap);
            String videoPath = mUri;
            int imgWidth = bitmap.getWidth();
            int imgHeight = bitmap.getHeight();
            long duration = Long.valueOf(sDuration);
            MessageInfo msg = MessageInfoUtil.buildVideoMessage(imgPath, videoPath, imgWidth, imgHeight, duration);

            return msg;
        } catch (Exception ex)
        {
            TUIKitLog.e(TAG, "MediaMetadataRetriever exception " + ex);
        } finally {
            mmr.release();
        }

        return null;
    }

    @Override
    protected void startCapture() {
        TUIKitLog.i(TAG, "startCapture");
        if (!checkPermission(CAPTURE)) {
            TUIKitLog.i(TAG, "startCapture checkPermission failed");
            return;
        }
        Intent captureIntent = new Intent(getContext(), CameraActivity.class);
        captureIntent.putExtra(TUIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_CAPTURE);
        CameraActivity.mCallBack = new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                Uri contentUri = Uri.fromFile(new File(data.toString()));
                MessageInfo msg = MessageInfoUtil.buildImageMessage(contentUri, true);
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
        mInputMoreFragment.startActivityForResult(captureIntent, InputMoreFragment.REQUEST_CODE_PHOTO);
    }

    @Override
    protected void startVideoRecord() {
        TUIKitLog.i(TAG, "startVideoRecord");
        if (!checkPermission(VIDEO_RECORD)) {
            TUIKitLog.i(TAG, "startVideoRecord checkPermission failed");
            return;
        }
        Intent captureIntent = new Intent(getContext(), CameraActivity.class);
        captureIntent.putExtra(TUIKitConstants.CAMERA_TYPE, JCameraView.BUTTON_STATE_ONLY_RECORDER);
        CameraActivity.mCallBack = new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                Intent videoData = (Intent) data;
                String imgPath = videoData.getStringExtra(TUIKitConstants.CAMERA_IMAGE_PATH);
                String videoPath = videoData.getStringExtra(TUIKitConstants.CAMERA_VIDEO_PATH);
                int imgWidth = videoData.getIntExtra(TUIKitConstants.IMAGE_WIDTH, 0);
                int imgHeight = videoData.getIntExtra(TUIKitConstants.IMAGE_HEIGHT, 0);
                long duration = videoData.getLongExtra(TUIKitConstants.VIDEO_TIME, 0);
                MessageInfo msg = MessageInfoUtil.buildVideoMessage(imgPath, videoPath, imgWidth, imgHeight, duration);
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
        mInputMoreFragment.startActivityForResult(captureIntent, InputMoreFragment.REQUEST_CODE_PHOTO);
    }

    @Override
    protected void startSendFile() {
        TUIKitLog.i(TAG, "startSendFile");
        if (!checkPermission(SEND_FILE)) {
            TUIKitLog.i(TAG, "startSendFile checkPermission failed");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        mInputMoreFragment.setCallback(new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                MessageInfo info = MessageInfoUtil.buildFileMessage((Uri) data);
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
        mInputMoreFragment.startActivityForResult(intent, InputMoreFragment.REQUEST_CODE_FILE);
    }

    public void setChatInputHandler(ChatInputHandler handler) {
        this.mChatInputHandler = handler;
    }

    public void setMessageHandler(MessageHandler handler) {
        this.mMessageHandler = handler;
    }

    public void setStartActivityListener(OnStartActivityListener listener) {
        this.mStartActivityListener = listener;
    }

    @Override
    public void onClick(View view) {
        TUIKitLog.i(TAG, "onClick id:" + view.getId()
                + "|voice_input_switch:" + R.id.voice_input_switch
                + "|face_btn:" + R.id.face_btn
                + "|more_btn:" + R.id.more_btn
                + "|send_btn:" + R.id.send_btn
                + "|mCurrentState:" + mCurrentState
                + "|mSendEnable:" + mSendEnable
                + "|mMoreInputEvent:" + mMoreInputEvent);
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
                mAudioInputSwitchButton.setImageResource(R.drawable.action_textinput_selector);
                mSendAudioButton.setVisibility(VISIBLE);
                mTextInput.setVisibility(GONE);
                hideSoftInput();
            } else {
                mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
                showSoftInput();
            }
        } else if (view.getId() == R.id.face_btn) {
            if (mCurrentState == STATE_VOICE_INPUT) {
                mCurrentState = STATE_NONE_INPUT;
                mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
                mSendAudioButton.setVisibility(GONE);
                mTextInput.setVisibility(VISIBLE);
            }
            if (mCurrentState == STATE_FACE_INPUT) {
                mCurrentState = STATE_NONE_INPUT;
                mInputMoreView.setVisibility(View.GONE);
                mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
                mTextInput.setVisibility(VISIBLE);
            } else {
                mCurrentState = STATE_FACE_INPUT;
                mEmojiInputButton.setImageResource(R.drawable.action_textinput_selector);
                showFaceViewGroup();
            }
        } else if (view.getId() == R.id.more_btn) {//若点击右边的“+”号按钮
            hideSoftInput();
            if (mMoreInputEvent instanceof View.OnClickListener) {
                ((View.OnClickListener) mMoreInputEvent).onClick(view);
            } else if (mMoreInputEvent instanceof BaseInputFragment) {
                showCustomInputMoreFragment();
            } else {
                if (mCurrentState == STATE_ACTION_INPUT) {
                    mCurrentState = STATE_NONE_INPUT;
                    //以下是zanhanding添加的代码，用于fix有时需要两次点击加号按钮才能呼出富文本选择布局的问题
                    //判断富文本选择布局是否已经被呼出，并反转相应的状态
                    if (mInputMoreView.getVisibility() == View.VISIBLE) {
                        mInputMoreView.setVisibility(View.GONE);
                    } else {
                        mInputMoreView.setVisibility(View.VISIBLE);
                    }
                    //以上是zanhanding添加的代码，用于fix有时需要两次点击加号按钮才能呼出富文本选择布局的问题
                } else {
                    showInputMoreLayout();//显示“更多”消息发送布局
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
                    if(mChatLayout.getChatInfo().getType() == V2TIMConversation.V2TIM_GROUP && !atUserInfoMap.isEmpty()) {
                        //发送时通过获取输入框匹配上@的昵称list，去从map中获取ID list。
                        List<String> atUserList = updateAtUserList(mTextInput.getMentionList(true));
                        if (atUserList == null || atUserList.isEmpty()) {
                            mMessageHandler.sendMessage(MessageInfoUtil.buildTextMessage(mTextInput.getText().toString().trim()));
                        }else {
                            mMessageHandler.sendMessage(MessageInfoUtil.buildTextAtMessage(atUserList, mTextInput.getText().toString().trim()));
                        }
                    }else {
                        mMessageHandler.sendMessage(MessageInfoUtil.buildTextMessage(mTextInput.getText().toString().trim()));
                    }
                }
                mTextInput.setText("");
            }
        }
    }

    private List<String> updateAtUserList(List<String> atMentionList){
        if (atMentionList == null || atMentionList.isEmpty()){
            return null;
        }

        List<String> atUserIdList = new ArrayList<>();
        for (String name : atMentionList){
            if (atUserInfoMap.containsKey(name)){
                atUserIdList.add(atUserInfoMap.get(name));
            }
        }
        atUserInfoMap.clear();

        return atUserIdList;
    }

    private void showSoftInput() {
        TUIKitLog.v(TAG, "showSoftInput");
        hideInputMoreLayout();
        mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
        mEmojiInputButton.setImageResource(R.drawable.ic_input_face_normal);
        mTextInput.requestFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(mTextInput, 0);
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
        TUIKitLog.i(TAG, "hideSoftInput");
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mTextInput.getWindowToken(), 0);
        mTextInput.clearFocus();
        mInputMoreView.setVisibility(View.GONE);
    }

    private void showFaceViewGroup() {
        TUIKitLog.i(TAG, "showFaceViewGroup");
        if (mFragmentManager == null) {
            mFragmentManager = mActivity.getSupportFragmentManager();
        }
        if (mFaceFragment == null) {
            mFaceFragment = new FaceFragment();
        }
        hideSoftInput();
        mInputMoreView.setVisibility(View.VISIBLE);
        mTextInput.requestFocus();
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
                editable.insert(index, emoji.getFilter());
                FaceManager.handlerEmojiText(mTextInput, editable.toString(), true);
            }

            @Override
            public void onCustomFaceClick(int groupIndex, Emoji emoji) {
                mMessageHandler.sendMessage(MessageInfoUtil.buildCustomFaceMessage(groupIndex, emoji.getFilter()));
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
        TUIKitLog.i(TAG, "showCustomInputMoreFragment");
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
        TUIKitLog.i(TAG, "showInputMoreLayout");
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
        int duration = AudioPlayer.getInstance().getDuration();
        TUIKitLog.i(TAG, "recordComplete duration:" + duration);
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
            mMessageHandler.sendMessage(MessageInfoUtil.buildAudioMessage(AudioPlayer.getInstance().getPath(), duration));
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
            showSendTextButton(View.GONE);
            showMoreInputButton(View.VISIBLE);
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
                FaceManager.handlerEmojiText(mTextInput, mTextInput.getText().toString(), true);
            }
        }

    }

    public void setDraft() {
        if (mChatInfo == null) {
            TUIKitLog.e(TAG, "set drafts error :  chatInfo is null");
            return;
        }
        if (mTextInput == null) {
            TUIKitLog.e(TAG, "set drafts error :  textInput is null");
            return;
        }
        String conversationIdPrefix = mChatInfo.getType() == V2TIMConversation.V2TIM_C2C ? "c2c_" : "group_";
        String conversationId = conversationIdPrefix + mChatInfo.getId();
        final String content = mTextInput.getText().toString();
        V2TIMManager.getConversationManager().setConversationDraft(conversationId, content, new V2TIMCallback() {
            @Override
            public void onSuccess() {
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "set drafts error : " + code + " " + desc);
            }
        });
    }

    @Override
    public void setChatInfo(ChatInfo chatInfo) {
        super.setChatInfo(chatInfo);
        if (chatInfo != null) {
            DraftInfo draftInfo = chatInfo.getDraft();
            if (draftInfo != null && !TextUtils.isEmpty(draftInfo.getDraftText()) && mTextInput != null) {
                mTextInput.setText(draftInfo.getDraftText());
                mTextInput.setSelection(mTextInput.getText().length());
            }
        }
    }

    public void setChatLayout(IChatLayout chatLayout) {
        mChatLayout = chatLayout;
    }

    public interface MessageHandler {
        void sendMessage(MessageInfo msg);
    }

    public interface ChatInputHandler {

        int RECORD_START = 1;
        int RECORD_STOP = 2;
        int RECORD_CANCEL = 3;
        int RECORD_TOO_SHORT = 4;
        int RECORD_FAILED = 5;

        void onInputAreaClick();

        void onRecordStatusChanged(int status);
    }

    public interface OnStartActivityListener {
        void onStartGroupMemberSelectActivity();
    }

}
