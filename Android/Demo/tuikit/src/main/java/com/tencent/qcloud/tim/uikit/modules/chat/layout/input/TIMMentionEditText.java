package com.tencent.qcloud.tim.uikit.modules.chat.layout.input;

import android.content.Context;
import android.graphics.Color;
import android.text.Editable;
import android.text.Spannable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputConnectionWrapper;
import android.widget.EditText;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class TIMMentionEditText extends EditText {
    public static final String TIM_METION_TAG = "@";
    public static final String TIM_METION_TAG_FULL = "＠";
    public static final Pattern TIM_MENTION_PATTERN = Pattern.compile("@[^\\s]+\\s");
    public static final Pattern TIM_MENTION_PATTERN_FULL = Pattern.compile("＠[^\\s]+\\s");

    private Map<String, Pattern> mPatternMap = new HashMap<>();
    private int mTIMMentionTextColor;

    private boolean mIsSelected;
    private Range mLastSelectedRange;
    private List<Range> mRangeArrayList = new ArrayList<>();

    private OnMentionInputListener mOnMentionInputListener;

    public TIMMentionEditText(Context context) {
        super(context);
        init();
    }

    public TIMMentionEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TIMMentionEditText(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @Override
    public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
        return new HackInputConnection(super.onCreateInputConnection(outAttrs), true, this);
    }

    @Override
    protected void onTextChanged(CharSequence text, int start, int lengthBefore, int lengthAfter) {
        colorMentionString();
    }

    @Override
    protected void onSelectionChanged(int selStart, int selEnd) {
        super.onSelectionChanged(selStart, selEnd);

        if (mLastSelectedRange != null && mLastSelectedRange.isEqual(selStart, selEnd)) {
            return;
        }

        Range closestRange = getRangeOfClosestMentionString(selStart, selEnd);
        if (closestRange != null && closestRange.to == selEnd) {
            mIsSelected = false;
        }

        Range nearbyRange = getRangeOfNearbyMentionString(selStart, selEnd);
        if (nearbyRange == null) {
            return;
        }

        //forbid cursor located in the mention string.
        if (selStart == selEnd) {
            setSelection(nearbyRange.getAnchorPosition(selStart));
        } else {
            if (selEnd < nearbyRange.to) {
                setSelection(selStart, nearbyRange.to);
            }
            if (selStart > nearbyRange.from) {
                setSelection(nearbyRange.from, selEnd);
            }
        }
    }

    public void setTIMMentionTextColor(int color) {
        mTIMMentionTextColor = color;
    }

    public List<String> getMentionList(boolean excludeMentionCharacter) {
        List<String> mentionList = new ArrayList<>();
        if (TextUtils.isEmpty(getText().toString())) {
            return mentionList;
        }

        for (Map.Entry<String, Pattern> entry : mPatternMap.entrySet()) {
            Matcher matcher = entry.getValue().matcher(getText().toString());
            while (matcher.find()) {
                String mentionText = matcher.group();
                if (excludeMentionCharacter) {
                    mentionText = mentionText.substring(1, mentionText.length()-1);
                }
                if (!mentionList.contains(mentionText)) {
                    mentionList.add(mentionText);
                }
            }
        }
        return mentionList;
    }

    public void setOnMentionInputListener(OnMentionInputListener onMentionInputListener) {
        mOnMentionInputListener = onMentionInputListener;
    }

    private void init() {
        //mTIMMentionTextColor = Color.RED;
        mPatternMap.clear();
        mPatternMap.put(TIM_METION_TAG, TIM_MENTION_PATTERN);
        mPatternMap.put(TIM_METION_TAG_FULL, TIM_MENTION_PATTERN_FULL);
        //setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        addTextChangedListener(new MentionTextWatcher());
    }

    private void colorMentionString() {
        mIsSelected = false;
        if (mRangeArrayList != null) {
            mRangeArrayList.clear();
        }

        Editable spannableText = getText();
        if (spannableText == null || TextUtils.isEmpty(spannableText.toString())) {
            return;
        }

        //clear
        ForegroundColorSpan[] oldSpans = spannableText.getSpans(0, spannableText.length(), ForegroundColorSpan.class);
        for (ForegroundColorSpan oldSpan : oldSpans) {
            spannableText.removeSpan(oldSpan);
        }

        String text = spannableText.toString();
        int lastMentionIndex = -1;
        for (Map.Entry<String, Pattern> entry : mPatternMap.entrySet()) {
            Matcher matcher = entry.getValue().matcher(text);
            while (matcher.find()) {
                String mentionText = matcher.group();
                int start;
                if (lastMentionIndex != -1) {
                    start = text.indexOf(mentionText, lastMentionIndex);
                } else {
                    start = text.indexOf(mentionText);
                }
                int end = start + mentionText.length();
                spannableText.setSpan(null/*new ForegroundColorSpan(mTIMMentionTextColor)*/, start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                lastMentionIndex = end;
                mRangeArrayList.add(new Range(start, end));
            }
        }
    }

    private Range getRangeOfClosestMentionString(int selStart, int selEnd) {
        if (mRangeArrayList == null) {
            return null;
        }
        for (Range range : mRangeArrayList) {
            if (range.contains(selStart, selEnd)) {
                return range;
            }
        }
        return null;
    }

    private Range getRangeOfNearbyMentionString(int selStart, int selEnd) {
        if (mRangeArrayList == null) {
            return null;
        }
        for (Range range : mRangeArrayList) {
            if (range.isWrappedBy(selStart, selEnd)) {
                return range;
            }
        }
        return null;
    }


    private class MentionTextWatcher implements TextWatcher {
        @Override
        public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        }

        @Override
        public void onTextChanged(CharSequence charSequence, int index, int i1, int count) {
            if (count == 1 && !TextUtils.isEmpty(charSequence)) {
                char mentionChar = charSequence.toString().charAt(index);
                for (Map.Entry<String, Pattern> entry : mPatternMap.entrySet()) {
                    if (entry.getKey().equals(String.valueOf(mentionChar)) && mOnMentionInputListener != null) {
                        mOnMentionInputListener.onMentionCharacterInput(entry.getKey());
                    }
                }
            }
        }

        @Override
        public void afterTextChanged(Editable editable) {
        }
    }


    private class HackInputConnection extends InputConnectionWrapper {
        private EditText editText;

        HackInputConnection(InputConnection target, boolean mutable, TIMMentionEditText editText) {
            super(target, mutable);
            this.editText = editText;
        }

        @Override
        public boolean sendKeyEvent(KeyEvent event) {
            if (event.getAction() == KeyEvent.ACTION_DOWN && event.getKeyCode() == KeyEvent.KEYCODE_DEL) {
                int selectionStart = editText.getSelectionStart();
                int selectionEnd = editText.getSelectionEnd();
                Range closestRange = getRangeOfClosestMentionString(selectionStart, selectionEnd);
                if (closestRange == null) {
                    mIsSelected = false;
                    return super.sendKeyEvent(event);
                }

                if (mIsSelected || selectionStart == closestRange.from) {
                    mIsSelected = false;
                    return super.sendKeyEvent(event);
                } else {
                    mIsSelected = true;
                    mLastSelectedRange = closestRange;
                    setSelection(closestRange.to, closestRange.from);
                    sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
                }

                return true;
            }
            return super.sendKeyEvent(event);
        }

        @Override
        public boolean deleteSurroundingText(int beforeLength, int afterLength) {
            if (beforeLength == 1 && afterLength == 0) {
                return sendKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL))
                        && sendKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_DEL));
            }
            return super.deleteSurroundingText(beforeLength, afterLength);
        }
    }

    private class Range {
        int from;
        int to;

        Range(int from, int to) {
            this.from = from;
            this.to = to;
        }

        boolean isWrappedBy(int start, int end) {
            return (start > from && start < to) || (end > from && end < to);
        }

        boolean contains(int start, int end) {
            return from <= start && to >= end;
        }

        boolean isEqual(int start, int end) {
            return (from == start && to == end) || (from == end && to == start);
        }

        int getAnchorPosition(int value) {
            if ((value - from) - (to - value) >= 0) {
                return to;
            } else {
                return from;
            }
        }
    }

    public interface OnMentionInputListener {
        void onMentionCharacterInput(String tag);
    }

}
