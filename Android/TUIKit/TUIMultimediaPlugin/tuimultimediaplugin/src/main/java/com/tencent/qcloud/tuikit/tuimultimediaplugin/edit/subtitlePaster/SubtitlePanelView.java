package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIHorizontalScrollView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;

public class SubtitlePanelView extends RelativeLayout {

    private final static int MAX_SHOW_LINES = 8;
    private final String TAG = SubtitlePanelView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final TUIMultimediaData<Integer> mTuiDataSelectedTextColor = new TUIMultimediaData<>(Color.WHITE);
    private EditText mInputEditText;
    private View mDecorView;
    private boolean mIsSoftKeypadShow = false;
    private SubtitleInputListener mSubtitleInputListener;
    private final OnGlobalLayoutListener onGlobalLayoutListener = this::softKeypadLayoutListener;

    public SubtitlePanelView(Context context) {
        super(context);
        mContext = context;
    }

    public void inputText(SubtitleInfo subtitleInfo, SubtitleInputListener subtitleInputListener) {
        mSubtitleInputListener = subtitleInputListener;

        String text = subtitleInfo != null ? subtitleInfo.getText() : "";
        mInputEditText.setText(text);
        mInputEditText.setSelection(text.length());

        if (subtitleInfo != null) {
            mInputEditText.setTextColor(subtitleInfo.textColor);
            mTuiDataSelectedTextColor.set(subtitleInfo.textColor);
        }

        showInputView();
    }

    public int getTextViewWidth() {
        if (mInputEditText != null) {
            return mInputEditText.getLayoutParams().width;
        }
        return 720;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        super.onDetachedFromWindow();
        removeAllViews();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) mInputEditText.getLayoutParams();
        layoutParams.width = getWidth() * 2 / 3;
        layoutParams.height = LayoutParams.WRAP_CONTENT;
        layoutParams.topMargin = getHeight() / 6;
        layoutParams.leftMargin = getWidth() / 6;
        mInputEditText.setLayoutParams(layoutParams);
        mInputEditText.requestFocus();
    }

    private void initView() {
        View root = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_subtitle_input_view, this, true);
        mDecorView = ((Activity) mContext).getWindow().getDecorView();

        mInputEditText = findViewById(R.id.subtitle_input_edit_text);
        mInputEditText.setVisibility(VISIBLE);
        mInputEditText.requestFocus();
        mInputEditText.setLines(MAX_SHOW_LINES);

        TUIHorizontalScrollView colorSelectScrollItemView = findViewById(R.id.input_text_color_scroll_view);
        colorSelectScrollItemView.setAdapter(new SubtitleColorItemAdapter(mContext, mTuiDataSelectedTextColor));
        mTuiDataSelectedTextColor.observe(color -> {
            mInputEditText.setTextColor(color);
            colorSelectScrollItemView.setClicked(SubtitleColorItemAdapter.getColorIndex(color));
        });

        root.setOnClickListener(v -> completeTextInput(true));
        findViewById(R.id.subtitle_input_confirm).setOnClickListener(v -> completeTextInput(true));
        findViewById(R.id.subtitle_input_cancel).setOnClickListener(v -> completeTextInput(false));
    }

    private void softKeypadLayoutListener() {
        if (mDecorView == null) {
            return;
        }

        Rect r = new Rect();
        mDecorView.getWindowVisibleDisplayFrame(r);
        int screenHeight = mDecorView.getRootView().getHeight();
        int keypadHeight = screenHeight - r.bottom;
        if (keypadHeight < screenHeight * 0.15) {
            if (mIsSoftKeypadShow) {
                mIsSoftKeypadShow = false;
                completeTextInput(true);
            }
            return;
        }
        mIsSoftKeypadShow = true;
        softKeypadLayoutListener(keypadHeight);
    }

    private void softKeypadLayoutListener(int keypadHeight) {
        LinearLayout colorLayout = findViewById(R.id.color_select_layout);
        if (colorLayout != null) {
            RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) colorLayout.getLayoutParams();
            layoutParams.bottomMargin = keypadHeight + 30;
            colorLayout.setLayoutParams(layoutParams);
        }
    }

    private void completeTextInput(boolean isConfirm) {
        LiteavLog.i(TAG, (isConfirm ? "confirm" : "cancel") + " text input");
        SubtitleInfo subtitleInfo = null;
        if (isConfirm) {
            subtitleInfo = getSubtitleInfo();
        }
        hideInputView();
        if (mSubtitleInputListener != null) {
            mSubtitleInputListener.onSubtitleInputCompeted(subtitleInfo);
        }
    }

    private SubtitleInfo getSubtitleInfo() {
        SubtitleInfo subtitleInfo = new SubtitleInfo();
        String text = mInputEditText.getText().toString();
        int lineCount = mInputEditText.getLineCount();
        for (int i = 0; i < lineCount; i++) {
            int start = mInputEditText.getLayout().getLineStart(i);
            int end = mInputEditText.getLayout().getLineEnd(i);
            String lineText = text.substring(start, end);
            subtitleInfo.textList.add(lineText);
        }
        subtitleInfo.textColor = mTuiDataSelectedTextColor.get();
        subtitleInfo.textSize = (int) mInputEditText.getTextSize();
        return subtitleInfo;
    }

    private void hideInputView() {
        mIsSoftKeypadShow = false;
        if (mDecorView != null) {
            mDecorView.getViewTreeObserver().removeOnGlobalLayoutListener(onGlobalLayoutListener);
        }
        InputMethodManager inputMethodManager = (InputMethodManager) mContext
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        if (inputMethodManager != null) {
            inputMethodManager.hideSoftInputFromWindow(getWindowToken(), InputMethodManager.HIDE_IMPLICIT_ONLY);
        }
        setVisibility(GONE);
    }

    private void showInputView() {
        setVisibility(VISIBLE);
        if (mDecorView != null) {
            mDecorView.getViewTreeObserver().addOnGlobalLayoutListener(onGlobalLayoutListener);
        }
        InputMethodManager inputMethodManager = (InputMethodManager) mContext
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        if (inputMethodManager != null) {
            inputMethodManager.showSoftInput(mInputEditText, InputMethodManager.SHOW_IMPLICIT);
        }
    }

    public interface SubtitleInputListener {

        void onSubtitleInputCompeted(SubtitleInfo subtitleInfo);
    }
}
