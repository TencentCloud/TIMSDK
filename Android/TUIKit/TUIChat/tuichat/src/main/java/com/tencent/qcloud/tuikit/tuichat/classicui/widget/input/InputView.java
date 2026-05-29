package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import io.trtc.tuikit.atomicx.albumpicker.AlbumMedia;
import android.os.SystemClock;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.LifecycleOwner;

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
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ChatInputMoreListener;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnFaceInputListener;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.timcommon.util.keyboard.KeyboardHeightObserver;
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
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore.InputMoreLayout;
import com.tencent.qcloud.tuikit.tuichat.component.album.AlbumPicker;
import com.tencent.qcloud.tuikit.tuichat.component.album.VideoRecorder;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceView;
import com.tencent.qcloud.tuikit.tuichat.component.inputedittext.TIMMentionEditText;
import com.tencent.qcloud.tuikit.tuichat.component.voiceinput.VoiceInputController;
import com.tencent.qcloud.tuikit.tuichat.component.voiceinput.VoiceInputStartPolicy;
import com.tencent.qcloud.tuikit.tuichat.config.GeneralConfig;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerListener;
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
    private static final long KEYBOARD_ANIMATION_DEBOUNCE_MS = 60L;
    private static final long PANEL_ANIMATION_DURATION_MS = 220L;

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
    protected ImageView mChatboxInterruptView;
    protected ChatInfo mChatInfo;
    protected List<InputMoreItem> mInputMoreActionList = new ArrayList<>();

    private FaceView mFaceView;
    private InputMoreLayout mInputMoreLayout;
    private ChatInputHandler mChatInputHandler;
    private MessageHandler mMessageHandler;
    private IChatLayout mChatLayout;
    private boolean mSendEnable;
    private int mCurrentState;
    private int mLastMsgLineCount;
    private String mInputContent;
    private OnInputViewListener mOnInputViewListener;
    private VoiceInputController voiceInputController;

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
    private boolean mIsInsertingEmoji = false;
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

    private KeyboardHeightObserver keyboardHeightObserver;
    private boolean isKeyboardShowing = false;
    private boolean isPanelShowing = false;
    private boolean isSwitchingToPanel = false;
    private boolean isSwitchingToKeyboard = false;
    private boolean hasKeyboardHeightChanging = false;
    private int currentKeyboardHeight = 0;
    private long lastKeyboardHeightChangingTime = 0L;
    private int lastAppliedBottomPadding = Integer.MIN_VALUE;
    private int lastAppliedPanelHeight = Integer.MIN_VALUE;
    private ValueAnimator panelHeightAnimator;
    private int lastLoggedAdjustedKeyboardHeight = Integer.MIN_VALUE;
    private int lastLoggedPanelHeight = Integer.MIN_VALUE;
    private int lastLoggedBottomPadding = Integer.MIN_VALUE;

    private void initViews() {
        mActivity = (FragmentActivity) getContext();
        inflate(mActivity, R.layout.chat_input_layout, this);
        mInputMoreView = findViewById(R.id.more_groups);
        mChatboxInterruptView = findViewById(R.id.chatbot_interrupt_button);
        Drawable drawable = mChatboxInterruptView.getDrawable();
        if (drawable != null) {
            drawable = DrawableCompat.wrap(drawable);
            DrawableCompat.setTint(drawable, 0xE0000000);
            mChatboxInterruptView.setImageDrawable(drawable);
        }
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

        setupKeyboardHeightObserver();
        init();
    }
    
    private void setupKeyboardHeightObserver() {
        keyboardHeightObserver = new KeyboardHeightObserver(mActivity);
        keyboardHeightObserver.setOnKeyboardHeightChangeListener(new KeyboardHeightObserver.OnKeyboardHeightChangeListener() {
            @Override
            public void onKeyboardHeightChanged(int height, boolean isVisible) {
                isKeyboardShowing = isVisible;
                hasKeyboardHeightChanging = false;
                currentKeyboardHeight = isVisible ? height : 0;
                updateInputHintVisibility();
                long now = SystemClock.uptimeMillis();
                if (now - lastKeyboardHeightChangingTime > KEYBOARD_ANIMATION_DEBOUNCE_MS) {
                    updateBottomPaddingForKeyboardHeight(currentKeyboardHeight);
                }

                if (!hasKeyboardHeightChanging) {
                    if (!isVisible && isSwitchingToPanel && height == 0) {
                        isSwitchingToPanel = false;
                        updateMoreViewHeight(getPanelTargetHeight());
                    } else if (isVisible && isSwitchingToKeyboard && adjustKeyboardHeight(height) >= getPanelTargetHeight()) {
                        isSwitchingToKeyboard = false;
                        hideInputMoreLayout();
                    }
                }
            }
            
            @Override
            public void onKeyboardHeightChanging(int currentHeight) {
                lastKeyboardHeightChangingTime = SystemClock.uptimeMillis();
                hasKeyboardHeightChanging = true;
                currentKeyboardHeight = currentHeight;
                updateInputHintVisibility();
                int adjusted = adjustKeyboardHeight(currentHeight);
                int saved = getPanelTargetHeight();
                updateBottomPaddingForKeyboardHeight(currentHeight);

                if (isSwitchingToPanel || isSwitchingToKeyboard) {
                    int savedKeyboardHeight = getPanelTargetHeight();
                    int adjustedCurrentHeight = adjustKeyboardHeight(currentHeight);
                    int targetHeight = savedKeyboardHeight - adjustedCurrentHeight;
                    if (targetHeight < 0) {
                        targetHeight = 0;
                    }
                    updateMoreViewHeight(targetHeight);
                    if (isSwitchingToPanel && adjustedCurrentHeight == 0) {
                        isSwitchingToPanel = false;
                        updateMoreViewHeight(savedKeyboardHeight);
                    } else if (isSwitchingToKeyboard && targetHeight == 0 && adjustedCurrentHeight > 0) {
                        isSwitchingToKeyboard = false;
                        hideInputMoreLayout();
                    }
                }
            }
        });
        keyboardHeightObserver.start();
    }
    
    private void updateMoreViewHeight() {
        updateMoreViewHeight(getPanelTargetHeight());
    }
    
    private void updateMoreViewHeight(int height) {
        if (lastAppliedPanelHeight == height) {
            return;
        }
        lastAppliedPanelHeight = height;
        ViewGroup.LayoutParams params = mInputMoreView.getLayoutParams();
        params.height = height;
        mInputMoreView.setLayoutParams(params);

    }

    private void updateBottomPaddingForKeyboardHeight(int keyboardHeight) {
        int bottomPadding = adjustKeyboardHeight(keyboardHeight);
        if (lastAppliedBottomPadding == bottomPadding) {
            return;
        }
        lastAppliedBottomPadding = bottomPadding;
        setPadding(getPaddingLeft(), getPaddingTop(), getPaddingRight(), bottomPadding);

    }

    private void cancelPanelHeightAnimator() {
        if (panelHeightAnimator != null) {
            panelHeightAnimator.cancel();
            panelHeightAnimator = null;
        }
    }

    private int getPanelHeight() {
        ViewGroup.LayoutParams params = mInputMoreView.getLayoutParams();
        if (params == null) {
            return 0;
        }
        return Math.max(params.height, 0);
    }

    private void animatePanelToHeight(int targetHeight, boolean showAfterAnimation) {
        cancelPanelHeightAnimator();
        mInputMoreView.setVisibility(VISIBLE);

        int startHeight = getPanelHeight();
        if (startHeight == targetHeight) {
            if (!showAfterAnimation && targetHeight == 0) {
                hideInputMoreLayout();
            }
            return;
        }

        panelHeightAnimator = ValueAnimator.ofInt(startHeight, targetHeight);
        panelHeightAnimator.setDuration(PANEL_ANIMATION_DURATION_MS);
        panelHeightAnimator.setInterpolator(targetHeight > startHeight ? new DecelerateInterpolator() : new AccelerateInterpolator());
        panelHeightAnimator.addUpdateListener(animation -> updateMoreViewHeight((Integer) animation.getAnimatedValue()));
        panelHeightAnimator.addListener(new AnimatorListenerAdapter() {
            private boolean cancelled;

            @Override
            public void onAnimationCancel(Animator animation) {
                cancelled = true;
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (cancelled) {
                    return;
                }
                if (!showAfterAnimation && targetHeight == 0) {
                    hideInputMoreLayout();
                }
            }
        });
        panelHeightAnimator.start();
    }

    private void hideImeOnly() {
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mTextInput.getWindowToken(), 0);
    }

    private int adjustKeyboardHeight(int keyboardHeight) {
        int bottomInset = getBottomInsetForKeyboard();
        int adjusted = keyboardHeight - bottomInset;
        return Math.max(adjusted, 0);
    }

    private int getBottomInsetForKeyboard() {
        if (keyboardHeightObserver == null || !keyboardHeightObserver.isEdgeToEdge()) {
            return 0;
        }
        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(this);
        if (insets == null) {
            return 0;
        }
        return insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
    }

    private int getPanelTargetHeight() {
        if (keyboardHeightObserver == null) {
            return 0;
        }
        return adjustKeyboardHeight(keyboardHeightObserver.getKeyboardHeight());
    }
    
    private void showPanelView(View panelView) {
        if (mInputMoreView instanceof ViewGroup) {
            ViewGroup container = (ViewGroup) mInputMoreView;
            container.removeAllViews();
            if (panelView.getParent() != null) {
                ((ViewGroup) panelView.getParent()).removeView(panelView);
            }
            container.addView(panelView, new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            ));
            mInputMoreView.setVisibility(View.VISIBLE);
        }
    }

    private void switchPanelViewWithFade(View panelView) {
        if (!(mInputMoreView instanceof ViewGroup)) {
            showPanelView(panelView);
            return;
        }
        ViewGroup container = (ViewGroup) mInputMoreView;

        // Ensure we don't accumulate multiple children if user taps quickly.
        while (container.getChildCount() > 1) {
            View child = container.getChildAt(0);
            child.animate().cancel();
            child.setAlpha(1f);
            container.removeViewAt(0);
        }

        View oldView = container.getChildCount() > 0 ? container.getChildAt(0) : null;
        if (oldView == panelView) {
            mInputMoreView.setVisibility(View.VISIBLE);
            return;
        }

        if (oldView != null) {
            oldView.animate().cancel();
            oldView.setAlpha(1f);
        }
        panelView.animate().cancel();
        panelView.setAlpha(1f);

        if (panelView.getParent() != null) {
            ((ViewGroup) panelView.getParent()).removeView(panelView);
        }

        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        );

        if (oldView == null) {
            container.removeAllViews();
            container.addView(panelView, lp);
            mInputMoreView.setVisibility(View.VISIBLE);
            return;
        }

        // Cross-fade between panel contents without changing the panel container height (no slide-from-bottom).
        container.addView(panelView, lp);
        panelView.bringToFront();
        panelView.setAlpha(0f);
        mInputMoreView.setVisibility(View.VISIBLE);

        long duration = 120;
        panelView.animate().alpha(1f).setDuration(duration).setListener(null).start();
        oldView.animate().alpha(0f).setDuration(duration).withEndAction(() -> {
            try {
                container.removeView(oldView);
            } catch (Throwable ignored) {
                // ignore
            }
            oldView.setAlpha(1f);
            panelView.setAlpha(1f);
        }).start();
    }

    protected void init() {
        initVoiceInputController();
        applyAtomicxInputTint();
        mAudioInputSwitchButton.setOnClickListener(this);
        mEmojiInputButton.setOnClickListener(this);
        mMoreInputButton.setOnClickListener(this);
        mSendTextButton.setOnClickListener(this);
        mTextInput.addTextChangedListener(this);
        mTextInput.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (voiceInputController != null && voiceInputController.onTextInputTouch(motionEvent, mTextInput)) {
                    return true;
                }
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
                return voiceInputController != null && voiceInputController.onPressToTalkTouch(motionEvent, mSendAudioButton);
            }
        });

        mTextInput.setOnMentionInputListener(new TIMMentionEditText.OnMentionInputListener() {
            @Override
            public void onMentionCharacterInput(String tag) {
                if ((tag.equals(TIMMentionEditText.TIM_MENTION_TAG) || tag.equals(TIMMentionEditText.TIM_MENTION_TAG_FULL))
                    && TUIChatUtils.isGroupChat(getChatInfo().getType())) {
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

    private void initVoiceInputController() {
        voiceInputController = new VoiceInputController(this, new VoiceInputController.Listener() {
            @Override
            public boolean canStartRecordFromTextInput() {
                return VoiceInputStartPolicy.canStartFromTextInput(
                    isKeyboardShowing || currentKeyboardHeight > 0,
                    mCurrentState == STATE_FACE_INPUT,
                    mCurrentState == STATE_ACTION_INPUT || (mInputMoreView != null && mInputMoreView.getVisibility() == VISIBLE && getPanelHeight() > 0),
                    !TextUtils.isEmpty(mTextInput.getText())
                );
            }

            @Override
            public void onTextInputTap() {
                if (presenter != null) {
                    presenter.scrollToNewestMessage();
                }
                showSoftInput();
            }

            @Override
            public void onBeforeRecordFromTextInput() {
                hideSoftInput();
                hideInputMoreLayout();
            }

            @Override
            public void onSendAudio(String filePath, int durationMs) {
                sendAudioMessage(filePath, durationMs);
            }

            @Override
            public void onSendText(String text) {
                sendVoiceInputTextMessage(text);
            }

            @Override
            public void onRecordStart() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_START);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.release_end));
            }

            @Override
            public void onRecordReadyToCancel() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_READY_TO_CANCEL);
                }
            }

            @Override
            public void onRecordContinue() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CONTINUE);
                }
            }

            @Override
            public void onRecordReadyToTranscribe() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CONTINUE);
                }
            }

            @Override
            public void onRecordCancel() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_CANCEL);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }

            @Override
            public void onRecordTooShort() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_TOO_SHORT);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }

            @Override
            public void onRecordStop() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_STOP);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }

            @Override
            public void onRecordFailed() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onRecordStatusChanged(ChatInputHandler.RECORD_FAILED);
                }
                mSendAudioButton.setText(TUIChatService.getAppContext().getString(R.string.hold_say));
            }
        });
    }

    private void applyAtomicxInputTint() {
        GradientDrawable background = new GradientDrawable();
        background.setColor(0xFFF2F3F5);
        background.setCornerRadius(dpToPx(4));
        mTextInput.setBackground(background);
        mTextInput.setHint(R.string.voice_input_edit_text_hint);
        mTextInput.setHintTextColor(0x66000000);
        updateInputHintVisibility();
    }

    private int dpToPx(int value) {
        return (int) (value * getResources().getDisplayMetrics().density);
    }

    private void updateInputHintVisibility() {
        boolean panelShowing = isPanelShowing
            && mInputMoreView != null
            && mInputMoreView.getVisibility() == VISIBLE
            && getPanelHeight() > 0;
        boolean shouldHideHint = isKeyboardShowing || currentKeyboardHeight > 0 || panelShowing || isSwitchingToPanel || isSwitchingToKeyboard;
        CharSequence nextHint = shouldHideHint ? "" : getResources().getString(R.string.voice_input_edit_text_hint);
        if (!TextUtils.equals(mTextInput.getHint(), nextHint)) {
            mTextInput.setHint(nextHint);
        }
    }

    private void hideInputHint() {
        if (!TextUtils.isEmpty(mTextInput.getHint())) {
            mTextInput.setHint("");
        }
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

    private void initChatbot() {
        if (TIMCommonUtil.isChatbot(mChatInfo.getId())) {
            disableAudioInput(true);
            disableEmojiInput(true);
            mMoreInputDisable = true;
            mMoreInputButton.setVisibility(GONE);
            presenter.isChatbotMessageFinished.observe((LifecycleOwner) getContext(), isChatbotMessageStopped -> {
                if (isChatbotMessageStopped) {
                    mChatboxInterruptView.setVisibility(View.GONE);
                    if (!TextUtils.isEmpty(mTextInput.getText())) {
                        mSendTextButton.setVisibility(VISIBLE);
                    }
                } else {
                    mChatboxInterruptView.setVisibility(View.VISIBLE);
                    mSendTextButton.setVisibility(GONE);
                }
            });
            mChatboxInterruptView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    presenter.sendChatbotInterruptMessage();
                }
            });
        }
    }

    private void sendAudioMessage(String outputPath, int duration) {
        if (mMessageHandler != null) {
            mMessageHandler.sendMessage(ChatMessageBuilder.buildAudioMessage(outputPath, duration));
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
        if (keyboardHeightObserver != null) {
            keyboardHeightObserver.stop();
        }
        if (voiceInputController != null) {
            voiceInputController.dismiss();
        }
        
        if (mInputMoreView instanceof ViewGroup) {
            ((ViewGroup) mInputMoreView).removeAllViews();
        }
        mFaceView = null;
        mInputMoreLayout = null;
    }

    protected void startSendPhoto() {
        TUIChatLog.i(TAG, "startSendPhoto");
        AlbumPicker.getInstance().pickMedia(mActivity, new AlbumPickerListener() {
            @Override
            public void onPickConfirm(List<AlbumMedia> pickedAlbumMedias, String textMessage) {
                for (AlbumMedia media : pickedAlbumMedias) {
                    if (media.getUri() != null) {
                        presenter.addPlaceholderMessage(media.getUri());
                    }
                }
            }

            @Override
            public void onMediaProcessing(AlbumMedia albumMedia, float progress, boolean error) {
                if (albumMedia.getUri() == null) {
                    return;
                }

                presenter.updateMessageProgress(albumMedia.getUri(), (int) (progress * 100));

                if (error) {
                    sendPhotoVideoMessage(albumMedia.getUri(), null);
                }

                if (progress >= 1.0 && !error && albumMedia.getMediaPath() != null) {
                    sendPhotoVideoMessage(albumMedia.getUri(), albumMedia.getMediaPath());
                }
            }

            @Override
            public void onMediaProcessed() {
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

    private void sendPhotoVideoMessage(Uri original, String transcodePath) {
        presenter.sendPhotoVideoMessages(original, transcodePath);
        ThreadUtils.runOnUiThread(this::hideSoftInput);
    }

    protected void takePhoto() {
        TUIChatLog.i(TAG, "takePhoto");

        VideoRecorder.openCamera(mActivity, new TUIValueCallback<Uri>() {

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

        VideoRecorder.openVideoRecorder(mActivity, new TUIValueCallback<Uri>() {
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
        ActivityResultResolver.getSingleContent(mActivity, ActivityResultResolver.CONTENT_TYPE_ALL, new TUIValueCallback<Uri>() {
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
            if (mMoreInputEvent instanceof View.OnClickListener) {
                hideImeOnly();
                ((View.OnClickListener) mMoreInputEvent).onClick(view);
            } else if (mMoreInputEvent instanceof View) {
                showCustomInputMoreView();
            } else {
                if (mCurrentState == STATE_ACTION_INPUT) {
                    mCurrentState = STATE_NONE_INPUT;
                    hideInputMoreLayout();
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

    private void sendVoiceInputTextMessage(String text) {
        if (TextUtils.isEmpty(text) || TextUtils.isEmpty(text.trim())) {
            return;
        }
        if (mMessageHandler != null) {
            mMessageHandler.sendMessage(ChatMessageBuilder.buildTextMessage(text));
        }
    }

    public void showSoftInput() {
        TUIChatLog.i(TAG, "showSoftInput");
        hideInputHint();
        cancelPanelHeightAnimator();
        isSwitchingToPanel = false;
        if (mInputMoreView.getVisibility() == VISIBLE && getPanelHeight() > 0) {
            isSwitchingToKeyboard = true;
        } else {
            isSwitchingToKeyboard = false;
        }
        mCurrentState = STATE_SOFT_INPUT;
        mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
        mEmojiInputButton.setImageResource(R.drawable.chat_input_face);
        mSendAudioButton.setVisibility(GONE);
        mTextInput.setVisibility(VISIBLE);
        
        mTextInput.requestFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(mTextInput, 0);
        
        postDelayed(new Runnable() {
            @Override
            public void run() {
                if (mChatInputHandler != null) {
                    mChatInputHandler.onInputAreaClick();
                }
            }
        }, 100);
    }

    public void hideSoftInput() {
        TUIChatLog.i(TAG, "hideSoftInput");
        mTextInput.clearFocus();
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mTextInput.getWindowToken(), 0);
        updateInputHintVisibility();
    }

    public void onEmptyClick() {
        hideSoftInput();
        mCurrentState = STATE_SOFT_INPUT;
        mEmojiInputButton.setImageResource(R.drawable.action_face_selector);
        mAudioInputSwitchButton.setImageResource(R.drawable.action_audio_selector);
        mSendAudioButton.setVisibility(GONE);
        mTextInput.setVisibility(VISIBLE);

        boolean imeShowingOrAnimating = currentKeyboardHeight > 0 || isKeyboardShowing;
        boolean panelVisible = isPanelShowing
            && mInputMoreView != null
            && mInputMoreView.getVisibility() == VISIBLE
            && getPanelHeight() > 0;
        if (!imeShowingOrAnimating && panelVisible && !isSwitchingToPanel && !isSwitchingToKeyboard) {
            isPanelShowing = false;
            animatePanelToHeight(0, false);
        } else {
            hideInputMoreLayout();
        }
        updateInputHintVisibility();
    }

    public void disableShowCustomFace(boolean disable) {
        isShowCustomFace = !disable;
    }

    private void showFaceViewGroup() {
        TUIChatLog.i(TAG, "showFaceViewGroup");
        hideInputHint();
        
        if (mFaceView == null) {
            mFaceView = new FaceView(getContext(), isShowCustomFace);
            mFaceView.setBackgroundColor(getResources().getColor(R.color.tuichat_face_view_bg));
            mFaceView.setOnFaceInputListener(new OnFaceInputListener() {
                @Override
                public void onDeleteClicked() {
                    mTextInput.getInputConnection().sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
                }

                @Override
                public void onEmojiClicked(String emojiKey) {
                    int index = mTextInput.getSelectionStart();
                    mIsInsertingEmoji = true;
                    FaceManager.insertEmoji(mTextInput, emojiKey, index);
                    mIsInsertingEmoji = false;
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
        
        cancelPanelHeightAnimator();
        mTextInput.requestFocus();

        boolean imeShowingOrAnimating = currentKeyboardHeight > 0 || isKeyboardShowing;
        boolean canSwitchContentOnly = !imeShowingOrAnimating
            && isPanelShowing
            && mInputMoreView != null
            && mInputMoreView.getVisibility() == VISIBLE
            && !isSwitchingToPanel
            && !isSwitchingToKeyboard
            && getPanelHeight() > 0;

        isPanelShowing = true;
        isSwitchingToKeyboard = false;
        if (canSwitchContentOnly) {
            isSwitchingToPanel = false;
            updateMoreViewHeight(getPanelTargetHeight());
            switchPanelViewWithFade(mFaceView);
        } else if (imeShowingOrAnimating) {
            isSwitchingToPanel = true;
            updateMoreViewHeight(0);
            showPanelView(mFaceView);
            hideImeOnly();
        } else {
            isSwitchingToPanel = false;
            updateMoreViewHeight(0);
            showPanelView(mFaceView);
            animatePanelToHeight(getPanelTargetHeight(), true);
        }
        if (mChatInputHandler != null) {
            postDelayed(new Runnable() {
                @Override
                public void run() {
                    mChatInputHandler.onInputAreaClick();
                }
            }, 100);
        }
    }

    private void showCustomInputMoreView() {
        TUIChatLog.i(TAG, "showCustomInputMoreView");
        hideInputHint();
        
        if (mMoreInputEvent instanceof View) {
            cancelPanelHeightAnimator();
            View customView = (View) mMoreInputEvent;

            boolean imeShowingOrAnimating = currentKeyboardHeight > 0 || isKeyboardShowing;
            boolean canSwitchContentOnly = !imeShowingOrAnimating
                && isPanelShowing
                && mInputMoreView != null
                && mInputMoreView.getVisibility() == VISIBLE
                && !isSwitchingToPanel
                && !isSwitchingToKeyboard
                && getPanelHeight() > 0;

            isPanelShowing = true;
            isSwitchingToKeyboard = false;
            if (canSwitchContentOnly) {
                isSwitchingToPanel = false;
                updateMoreViewHeight(getPanelTargetHeight());
                switchPanelViewWithFade(customView);
            } else if (imeShowingOrAnimating) {
                isSwitchingToPanel = true;
                updateMoreViewHeight(0);
                showPanelView(customView);
                hideImeOnly();
            } else {
                isSwitchingToPanel = false;
                updateMoreViewHeight(0);
                showPanelView(customView);
                animatePanelToHeight(getPanelTargetHeight(), true);
            }
            if (mChatInputHandler != null) {
                postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mChatInputHandler.onInputAreaClick();
                    }
                }, 100);
            }
        }
    }

    private void showInputMoreLayout() {
        TUIChatLog.i(TAG, "showInputMoreLayout");
        hideInputHint();
        
        if (mInputMoreLayout == null) {
            mInputMoreLayout = new InputMoreLayout(getContext());
        }
        
        assembleActions();
        mInputMoreLayout.init(mInputMoreActionList);
        
        cancelPanelHeightAnimator();

        boolean imeShowingOrAnimating = currentKeyboardHeight > 0 || isKeyboardShowing;
        boolean canSwitchContentOnly = !imeShowingOrAnimating
            && isPanelShowing
            && mInputMoreView != null
            && mInputMoreView.getVisibility() == VISIBLE
            && !isSwitchingToPanel
            && !isSwitchingToKeyboard
            && getPanelHeight() > 0;

        isPanelShowing = true;
        isSwitchingToKeyboard = false;
        if (canSwitchContentOnly) {
            isSwitchingToPanel = false;
            updateMoreViewHeight(getPanelTargetHeight());
            switchPanelViewWithFade(mInputMoreLayout);
        } else if (imeShowingOrAnimating) {
            isSwitchingToPanel = true;
            updateMoreViewHeight(0);
            showPanelView(mInputMoreLayout);
            hideImeOnly();
        } else {
            isSwitchingToPanel = false;
            updateMoreViewHeight(0);
            showPanelView(mInputMoreLayout);
            animatePanelToHeight(getPanelTargetHeight(), true);
        }
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
        cancelPanelHeightAnimator();
        isPanelShowing = false;
        isSwitchingToPanel = false;
        isSwitchingToKeyboard = false;
        updateMoreViewHeight(0);
        mInputMoreView.setVisibility(View.GONE);
        if (mInputMoreView instanceof ViewGroup) {
            ((ViewGroup) mInputMoreView).removeAllViews();
        }
        updateInputHintVisibility();
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
            mSendTextButton.setVisibility(GONE);
            showMoreInputButton(View.VISIBLE);
            if (mChatInputHandler != null) {
                mChatInputHandler.onUserTyping(false, V2TIMManager.getInstance().getServerTime());
            }
        } else {
            mSendEnable = true;
            showSendTextButton();
            showMoreInputButton(View.GONE);
            if (mTextInput.getLineCount() != mLastMsgLineCount) {
                mLastMsgLineCount = mTextInput.getLineCount();
                if (mChatInputHandler != null) {
                    mChatInputHandler.onInputAreaClick();
                }
            }
            if (!mIsInsertingEmoji && !TextUtils.equals(mInputContent, mTextInput.getText().toString())) {
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
            draftMap.put("quotedMessageID", replyPreviewBean.getMessageID());
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
                        Object contentObj = draftJsonMap.get("content");
                        if (contentObj instanceof String) {
                            content = (String) contentObj;
                        }
                        Object quotedMessageIDObj = draftJsonMap.get("quotedMessageID");
                        if (quotedMessageIDObj instanceof String && presenter != null) {
                            String quotedMessageID = (String) quotedMessageIDObj;
                            if (!TextUtils.isEmpty(quotedMessageID)) {
                                ChatInfo draftChatInfo = chatInfo;
                                presenter.findMessage(quotedMessageID, new IUIKitCallback<TUIMessageBean>() {
                                    @Override
                                    public void onSuccess(TUIMessageBean data) {
                                        if (data != null && mChatInfo == draftChatInfo && ViewCompat.isAttachedToWindow(InputView.this)) {
                                            showReplyPreview(ChatMessageBuilder.buildReplyPreviewBean(data));
                                        }
                                    }
                                });
                            }
                        }
                    }
                } catch (JsonSyntaxException e) {
                    TUIChatLog.e(TAG, " getCustomJsonMap error ");
                }

                mTextInput.setText(content);
                mTextInput.setSelection(mTextInput.getText().length());
            }
        }
        initChatbot();
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
            actionUnit.setIconResId(R.drawable.chat_more_input_custom_message);
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

    public void replaceMoreInput(View customView) {
        mMoreInputEvent = customView;
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

    protected void showSendTextButton() {
        boolean isChatbotMessageFinished = true;
        if (presenter != null) {
            isChatbotMessageFinished = presenter.isChatbotMessageFinished.getValue();
        }
        if (isChatbotMessageFinished) {
            mSendTextButton.setVisibility(VISIBLE);
        } else {
            mSendTextButton.setVisibility(GONE);
        }
    }

    public void showReplyPreview(ReplyPreviewBean previewBean) {
        exitReply();
        replyPreviewBean = previewBean;
        String replyMessageAbstract = previewBean.getMessageAbstract();
        String msgTypeStr = ChatMessageParser.getMsgTypeStr(previewBean.getMessageType());
        CharSequence text = previewBean.getMessageSenderName() + " : " + msgTypeStr + " " + replyMessageAbstract;
        text = FaceManager.emojiJudge(text);
        // If replying to a text message, the middle part of the file name is displayed in abbreviated form
        isQuoteModel = true;
        quoteTv.setText(text);
        quotePreviewBar.setVisibility(View.VISIBLE);

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
