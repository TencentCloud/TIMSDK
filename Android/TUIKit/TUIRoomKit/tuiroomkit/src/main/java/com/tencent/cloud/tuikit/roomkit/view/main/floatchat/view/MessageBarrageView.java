package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view;

import static android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
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
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service.IEmojiResource;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.store.FloatChatStore;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MessageBarrageView extends ScrollView {
    private static final String TAG = "MessageBarrageView";

    private static final int MAX_ITEM_COUNT           = 5;
    private static final int MESSAGE_SHOW_TIME_MS     = 5 * 1000;
    private static final int MESSAGE_MIN_SHOW_TIME_MS = 5 * 100;

    private final LinkedList<MessageHolder> mMessageHolders    = new LinkedList<>();
    private final LinkedList<MessageHolder> mMessageHolderPool = new LinkedList<>();
    private final IEmojiResource            mEmojiResource     = FloatChatStore.sharedInstance().mEmojiResource;

    private final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private final LinearLayout mRootView;

    public MessageBarrageView(Context context) {
        this(context, null);
    }

    public MessageBarrageView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setVerticalScrollBarEnabled(false);
        mRootView = new LinearLayout(context);
        mRootView.setOrientation(LinearLayout.VERTICAL);
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        addView(mRootView, layoutParams);
    }

    public void addMessage(TUIFloatChat message) {
        if (message == null) {
            return;
        }
        if (mMessageHolders.size() >= MAX_ITEM_COUNT) {
            recycleFirstItem();
        }
        addItem(message);
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
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
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

    private void recycleFirstItem() {
        removeFirstView();
        recycleMessageHolder();
    }

    private void addItem(TUIFloatChat message) {
        MessageHolder messageHolder = obtainMessageHolder();
        messageHolder.messageView.setText(parseMessage(message, messageHolder.messageView));
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
            messageHolder.parent = LayoutInflater.from(getContext()).inflate(R.layout.tuiroomkit_float_chat_item_msg, null);
            messageHolder.messageView = messageHolder.parent.findViewById(R.id.tv_msg_content);
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

    private SpannableStringBuilder parseMessage(TUIFloatChat barrage, TextView tvMessage) {
        String userName = TextUtils.isEmpty(barrage.user.userName) ? barrage.user.userId : barrage.user.userName;
        userName = TextUtils.isEmpty(userName) ? "" : userName;
        String result = userName + ": " + barrage.content;

        SpannableStringBuilder builder = new SpannableStringBuilder(result);
        int userNameColor = getResources().getColor(R.color.tuiroomkit_color_float_chat_user_name_color);
        ForegroundColorSpan foreSpan = new ForegroundColorSpan(userNameColor);
        builder.setSpan(foreSpan, 0, userName.length() + 1, SPAN_EXCLUSIVE_EXCLUSIVE);

        Paint.FontMetrics fontMetrics = tvMessage.getPaint().getFontMetrics();
        int fontSize = (int) (Math.abs(fontMetrics.ascent) + Math.abs(fontMetrics.descent));
        Rect rect = new Rect(0, 0, fontSize, fontSize);
        processEmojiSpan(builder, mEmojiResource, rect);
        return builder;
    }

    private void processEmojiSpan(SpannableStringBuilder sb, IEmojiResource emojiResource, Rect rect) {
        if (sb == null || emojiResource == null) {
            return;
        }
        String text = sb.toString();
        Pattern pattern = Pattern.compile(emojiResource.getEncodePattern());
        List<String> matches = new ArrayList<>();
        Matcher matcher = pattern.matcher(sb);
        while (matcher.find()) {
            matches.add(matcher.group());
        }
        for (String item : matches) {
            int resId = emojiResource.getResId(item);
            if (resId == 0) {
                continue;
            }
            int fromIndex = 0;
            while (fromIndex < text.length()) {
                int index = text.indexOf(item, fromIndex);
                if (index == -1) {
                    break;
                }
                fromIndex = index + item.length();
                Drawable emojiDrawable = emojiResource.getDrawable(getContext(), resId, rect);
                if (emojiDrawable == null) {
                    continue;
                }
                ImageSpan imageSpan = new ImageSpan(emojiDrawable);
                sb.setSpan(imageSpan, index, index + item.length(), SPAN_EXCLUSIVE_EXCLUSIVE);
            }
        }
    }

    private static class MessageHolder {
        View     parent;
        TextView messageView;
        long     receivedTimeMs;
        Runnable dismissRun;
    }
}
