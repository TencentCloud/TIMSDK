package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputConnectionWrapper;
import android.widget.EditText;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TIMMentionEditText extends EditText {
    public static final String TIM_MENTION_TAG = "@";
    public static final String TIM_MENTION_TAG_FULL = "＠";

    private List<String> mentionTagList = new ArrayList<>();

    private boolean mIsSelected;
    private Range mLastSelectedRange;
    private List<Range> mRangeArrayList = new ArrayList<>();
    private Map<String, String> mentionMap = new HashMap<>();

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
        setMentionStringRange();
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

    public void setOnMentionInputListener(OnMentionInputListener onMentionInputListener) {
        mOnMentionInputListener = onMentionInputListener;
    }

    private void init() {
        mentionTagList.clear();
        mentionTagList.add(TIM_MENTION_TAG);
        mentionTagList.add(TIM_MENTION_TAG_FULL);
        addTextChangedListener(new MentionTextWatcher());
    }

    public void setMentionMap(Map<String, String> mentionList) {
        this.mentionMap.putAll(mentionList);
    }

    public List<String> getMentionIdList() {
        List<String> mentionIDList = new ArrayList<>();
        for (Range range : mRangeArrayList) {
            mentionIDList.add(range.userID);
        }
        return mentionIDList;
    }

    private void setMentionStringRange() {
        updateMentionList();
        mIsSelected = false;
        if (mRangeArrayList != null) {
            mRangeArrayList.clear();
        }

        Editable spannableText = getText();
        if (spannableText == null || TextUtils.isEmpty(spannableText.toString())) {
            return;
        }

        String text = spannableText.toString();
        if (TextUtils.isEmpty(text)) {
            return;
        }
        for (String name : mentionMap.keySet()) {
            if (TextUtils.isEmpty(name)) {
                continue;
            }
            int nameStartIndex = 0;
            while (true) {
                int findIndex = text.indexOf(name, nameStartIndex);
                if (findIndex == -1) {
                    break;
                } else {
                    int end = findIndex + name.length();
                    mRangeArrayList.add(new Range(findIndex, end, mentionMap.get(name)));
                    nameStartIndex = end;
                }
            }
        }

        Collections.sort(mRangeArrayList, new Comparator<Range>() {
            @Override
            public int compare(Range lhs, Range rhs) {
                return lhs.from - rhs.from;
            }
        });
    }

    private void updateMentionList() {
        if (mentionMap == null) {
            return;
        }
        Editable spannableText = getText();
        if (spannableText == null) {
            return;
        }
        String text = spannableText.toString();
        if (TextUtils.isEmpty(text)) {
            mentionMap.clear();
        }
        for (String name : new ArrayList<>(mentionMap.keySet())) {
            if (!text.contains(name)) {
                mentionMap.remove(name);
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
            if (count == 1 && !TextUtils.isEmpty(charSequence) && hasFocus()) {
                char mentionChar = charSequence.toString().charAt(index);
                for (String mentionTag: mentionTagList) {
                    if (mentionTag.equals(String.valueOf(mentionChar)) && mOnMentionInputListener != null) {
                        mOnMentionInputListener.onMentionCharacterInput(mentionTag);
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
        String userID;

        Range(int from, int to, String userID) {
            this.from = from;
            this.to = to;
            this.userID = userID;
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
