package com.tencent.qcloud.tuikit.tuicommunity.component;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewParent;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import com.tencent.qcloud.tuikit.tuicommunity.R;

public class TextCountView extends AppCompatTextView implements TextWatcher {
    private int limit = 0;
    private int bindResID = 0;

    public TextCountView(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public TextCountView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public TextCountView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        if (attrs != null) {
            TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.TextCountView);
            limit = array.getInt(R.styleable.TextCountView_limit_count, limit);
            bindResID = array.getResourceId(R.styleable.TextCountView_bind_edit_text, 0);
        }
        if (limit != 0) {
            setText(0 + "/" + limit);
        }
    }

    public void setLimit(int limit) {
        this.limit = limit;
        if (limit != 0) {
            setText(0 + "/" + limit);
        }
    }

    public void bind(EditText editText) {
        if (editText == null) {
            return;
        }
        editText.addTextChangedListener(this);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ViewParent parent = getParent();
        View editText = null;
        while (parent instanceof View) {
            editText = ((View) parent).findViewById(bindResID);
            if (editText != null) {
                break;
            } else {
                parent = parent.getParent();
            }
        }

        if (editText instanceof EditText) {
            ((EditText) editText).addTextChangedListener(this);
        }
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {}

    @SuppressLint("SetTextI18n")
    @Override
    public void afterTextChanged(Editable s) {
        String text = s.toString();
        setText(text.length() + "/" + limit);
    }
}
