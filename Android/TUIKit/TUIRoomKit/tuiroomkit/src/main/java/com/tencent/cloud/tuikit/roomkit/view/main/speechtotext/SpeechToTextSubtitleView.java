package com.tencent.cloud.tuikit.roomkit.view.main.speechtotext;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.ASRState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.LinkedList;

public class SpeechToTextSubtitleView extends ScrollView {
    private static final String TAG = "SpeechToTextSubtitleView";

    private static final int MAX_ITEM_COUNT           = 3;
    private static final int MESSAGE_SHOW_TIME_MS     = 5 * 1000;
    private static final int MESSAGE_MIN_SHOW_TIME_MS = 5 * 100;

    private final LinkedList<MessageHolder> mMessageHolders    = new LinkedList<>();
    private final LinkedList<MessageHolder> mMessageHolderPool = new LinkedList<>();

    private final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private final LinearLayout mRootView;

    private final LiveListObserver<ASRState.SpeechToText> mTextObserver = new LiveListObserver<ASRState.SpeechToText>() {
        @Override
        public void onItemChanged(int position, ASRState.SpeechToText item) {
            if (item.isSpeechEnd) {
                addMessage(item);
            }
        }
    };

    public SpeechToTextSubtitleView(Context context) {
        this(context, null);
    }

    public SpeechToTextSubtitleView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setVerticalScrollBarEnabled(false);
        mRootView = new LinearLayout(context);
        mRootView.setOrientation(LinearLayout.VERTICAL);
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        addView(mRootView, layoutParams);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        int count = mMessageHolders.size();
        for (int i = 0; i < count; i++) {
            MessageHolder holder = mMessageHolders.get(i);
            long showTime = MESSAGE_SHOW_TIME_MS - (SystemClock.elapsedRealtime() - holder.receivedTimeMs);
            showTime = Math.max(MESSAGE_MIN_SHOW_TIME_MS, showTime);
            mMainHandler.postDelayed(holder.dismissRun, showTime);
        }
        ConferenceController.sharedInstance().getASRState().speechToTexts.observe(mTextObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getASRState().speechToTexts.removeObserver(mTextObserver);
        for (MessageHolder item : mMessageHolders) {
            mMainHandler.removeCallbacks(item.dismissRun);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        return false;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return false;
    }

    private void addMessage(ASRState.SpeechToText message) {
        if (message == null) {
            return;
        }
        if (mMessageHolders.size() >= MAX_ITEM_COUNT) {
            recycleFirstItem();
        }
        addItem(message);
    }

    private void recycleFirstItem() {
        removeFirstView();
        recycleMessageHolder();
    }

    private void addItem(ASRState.SpeechToText message) {
        MessageHolder messageHolder = obtainMessageHolder();
        messageHolder.userView.setText(message.userName + ":");
        messageHolder.messageView.setText(message.text);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 16, 0, 0);
        messageHolder.parent.setLayoutParams(params);
        mRootView.addView(messageHolder.parent);
        post(new Runnable() {
            @Override
            public void run() {
                fullScroll(View.FOCUS_DOWN);
            }
        });
    }

    private MessageHolder obtainMessageHolder() {
        MessageHolder messageHolder;
        if (mMessageHolderPool.isEmpty()) {
            messageHolder = new MessageHolder();
            messageHolder.parent = LayoutInflater.from(getContext()).inflate(R.layout.tuiroomkit_item_speech_to_text_float_subtitle, null);
            messageHolder.userView = messageHolder.parent.findViewById(R.id.tuiroomkit_tv_speech_to_text_float_subtitle_user);
            messageHolder.messageView = messageHolder.parent.findViewById(R.id.tuiroomkit_tv_speech_to_text_float_subtitle_msg);
            messageHolder.dismissRun = this::recycleFirstItem;
        } else {
            messageHolder = mMessageHolderPool.remove(0);
        }
        messageHolder.receivedTimeMs = SystemClock.elapsedRealtime();
        mMessageHolders.add(messageHolder);
        mMainHandler.postDelayed(messageHolder.dismissRun, MESSAGE_SHOW_TIME_MS);
        return messageHolder;
    }

    private void recycleMessageHolder() {
        if (mMessageHolders.isEmpty()) {
            Log.w(TAG, "recycleMessageHolder at no child");
            return;
        }
        MessageHolder messageHolder = mMessageHolders.remove(0);
        mMainHandler.removeCallbacks(messageHolder.dismissRun);
        mMessageHolderPool.add(messageHolder);
    }

    private void removeFirstView() {
        int count = mRootView.getChildCount();
        if (count <= 0) {
            Log.w(TAG, "removeFirstView at no child");
            return;
        }
        mRootView.removeViewAt(0);
    }

    private static class MessageHolder {
        View     parent;
        TextView userView;
        TextView messageView;
        long     receivedTimeMs;
        Runnable dismissRun;
    }
}
