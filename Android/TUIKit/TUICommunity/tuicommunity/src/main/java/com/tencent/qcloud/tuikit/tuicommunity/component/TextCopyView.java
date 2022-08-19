package com.tencent.qcloud.tuikit.tuicommunity.component;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewParent;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;

public class TextCopyView extends AppCompatTextView {

    private int bindResID = 0;
    private TextView bindTextView = null;

    public TextCopyView(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public TextCopyView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public TextCopyView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        if (attrs != null) {
            TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.TextCopyView);
            bindResID = array.getResourceId(R.styleable.TextCopyView_bind_copy_text, 0);
            array.recycle();
        }
    }

    public void bind(TextView textView) {
        if (textView == null) {
            return;
        }
        this.bindTextView = textView;
        setCopyAction();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ViewParent parent = getParent();
        View textView = null;
        while(parent instanceof View) {
            textView = ((View) parent).findViewById(bindResID);
            if (textView != null) {
                break;
            } else {
                parent = parent.getParent();
            }
        }

        if (textView instanceof TextView) {
            this.bindTextView = (TextView) textView;
            setCopyAction();
        }
    }

    private void setCopyAction() {
        if (this.bindTextView == null) {
            return;
        }
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                if (clipboard == null) {
                    return;
                }
                CharSequence charSequence = bindTextView.getText();
                ClipData clip = ClipData.newPlainText("message", charSequence);
                clipboard.setPrimaryClip(clip);

                if (!TextUtils.isEmpty(charSequence)) {
                    String copySuccess = getResources().getString(R.string.community_copy_success_tip);
                    ToastUtil.toastShortMessage(copySuccess);
                }
            }
        });
    }

}
