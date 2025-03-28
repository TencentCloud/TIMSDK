package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view;

import static android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputConnectionWrapper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatEditText;

import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service.IEmojiResource;


public class EmojiEditText extends AppCompatEditText implements EmojiLayout.EmojiListener {

    private       IEmojiResource mEmojiResource;
    private final Rect           mEmojiBounds = new Rect();

    public EmojiEditText(Context context) {
        this(context, null);
    }

    public EmojiEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        Paint.FontMetrics fontMetrics = getPaint().getFontMetrics();
        mEmojiBounds.right = (int) (Math.abs(fontMetrics.top) + Math.abs(fontMetrics.bottom));
        mEmojiBounds.bottom = mEmojiBounds.right;
    }

    public void setEmojiResource(IEmojiResource emojiResource) {
        mEmojiResource = emojiResource;
    }

    @Override
    public void onDelete() {
        int action = KeyEvent.ACTION_DOWN;
        int code = KeyEvent.KEYCODE_DEL;
        KeyEvent event = new KeyEvent(action, code);
        onKeyDown(KeyEvent.KEYCODE_DEL, event);
    }

    @Override
    public void onAddEmoji(int resId) {
        String imageSource = mEmojiResource.getEncodeValue(resId);
        if (TextUtils.isEmpty(imageSource)) {
            return;
        }
        Drawable emojiDrawable = mEmojiResource.getDrawable(getContext(), resId, mEmojiBounds);
        if (emojiDrawable == null) {
            return;
        }
        int oldSelection = getSelectionStart();
        ImageSpan imageSpan = new ImageSpan(emojiDrawable, imageSource);
        Editable editable = getText();
        editable = editable == null ? new SpannableStringBuilder() : editable;
        editable.insert(oldSelection, imageSource);
        editable.setSpan(imageSpan, oldSelection, oldSelection + imageSource.length(), SPAN_EXCLUSIVE_EXCLUSIVE);
        setText(editable);
        setSelection(oldSelection + imageSource.length());
    }

    @Nullable
    @Override
    public InputConnection onCreateInputConnection(@NonNull EditorInfo outAttrs) {
        return new MyInputConnectionWrapper(super.onCreateInputConnection(outAttrs), true);
    }

    private class MyInputConnectionWrapper extends InputConnectionWrapper {
        public MyInputConnectionWrapper(InputConnection target, boolean mutable) {
            super(target, mutable);
        }

        @Override
        public boolean deleteSurroundingText(int beforeLength, int afterLength) {
            if (beforeLength == 1 && afterLength == 0) {
                onDelete();
                return true;
            }
            return super.deleteSurroundingText(beforeLength, afterLength);
        }
    }
}
