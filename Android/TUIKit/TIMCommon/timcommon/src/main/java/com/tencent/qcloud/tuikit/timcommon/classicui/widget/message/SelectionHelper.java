package com.tencent.qcloud.tuikit.timcommon.classicui.widget.message;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.text.Layout;
import android.text.Spannable;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.BackgroundColorSpan;
import android.text.style.ClickableSpan;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.PopupWindow;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.component.face.CenterImageSpan;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class SelectionHelper {
    private static final String TAG = "SelectionHelper";

    private SelectionHandle startHandle;
    private SelectionHandle endHandle;
    private final SelectionInfo mSelectionInfo = new SelectionInfo();
    private OnSelectListener mSelectListener;

    private TextView textView;
    private Spannable spannable;

    private int mTextViewMarginStart = 0;
    private GestureDetector gestureDetector;
    private GestureDetector.SimpleOnGestureListener gestureListener;
    private int selectionColor;
    private int handleColor;
    private int handleSize;
    private BackgroundColorSpan bgSpan;
    private boolean frozen = false;

    private ViewTreeObserver.OnPreDrawListener mOnPreDrawListener;
    private View.OnAttachStateChangeListener onAttachStateChangeListener;
    private static WeakReference<SelectionHelper> selectedReference;

    public static void setSelected(SelectionHelper selected) {
        SelectionHelper oldSelected = getSelected();
        if (oldSelected != null && selected != oldSelected) {
            oldSelected.clearSelection();
        }
        selectedReference = new WeakReference<>(selected);
    }

    public static void resetSelected() {
        SelectionHelper selectionHelper = getSelected();
        if (selectionHelper != null) {
            selectionHelper.clearSelection();
        }
    }

    private static SelectionHelper getSelected() {
        if (selectedReference != null) {
            return selectedReference.get();
        }
        return null;
    }

    public void setFrozen(boolean frozen) {
        this.frozen = frozen;
    }

    public interface OnSelectListener {
        void onTextSelected(CharSequence content);

        void onDismiss();

        void onClickUrl(String url);

        void onShowPop();

        void onDismissPop();
    }

    public SelectionHelper() {
        selectionColor = 0x3f1470ff;
        handleColor = 0xff1470ff;
        handleSize = ScreenUtil.dip2px(16);
        gestureListener = new GestureDetector.SimpleOnGestureListener() {
            @Override
            public void onShowPress(MotionEvent e) {
                if (frozen) {
                    return;
                }
                initHandler();
                ClickableSpan[] spans = TextUtil.findSpansByLocation(textView, Math.round(e.getX()), Math.round(e.getY()));
                if (spans != null && spans.length > 0) {
                    ClickableSpan span = spans[0];
                    int spanStart = spannable.getSpanStart(span);
                    int spanEnd = spannable.getSpanEnd(span);
                    setSelection(spanStart, spanEnd);
                } else {
                    selectAll();
                }
            }

            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (frozen) {
                    return super.onSingleTapUp(e);
                }
                ClickableSpan[] spans = TextUtil.findSpansByLocation(textView, Math.round(e.getX()), Math.round(e.getY()));
                if (spans != null && spans.length > 0) {
                    ClickableSpan span = spans[0];
                    span.onClick(textView);
                }
                return false;
            }
        };
        gestureDetector = new GestureDetector(gestureListener);
    }

    public void setSelectListener(OnSelectListener selectListener) {
        mSelectListener = selectListener;
    }

    public void destroy() {
        if (textView == null) {
            return;
        }
        textView.removeOnAttachStateChangeListener(onAttachStateChangeListener);
        textView.getViewTreeObserver().removeOnPreDrawListener(mOnPreDrawListener);
        clearSelection();
    }

    public void selectAll() {
        initHandler();
        if (textView.getText() instanceof Spannable) {
            spannable = (Spannable) textView.getText();
        }
        if (spannable == null) {
            return;
        }
        setSelection(0, textView.getText().length());
    }

    public void setTextView(TextView textView) {
        this.textView = textView;
        if (textView.getText() instanceof Spannable) {
            this.spannable = (Spannable) textView.getText();
        }
        textView.removeOnAttachStateChangeListener(onAttachStateChangeListener);
        onAttachStateChangeListener = new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(View v) {}

            @Override
            public void onViewDetachedFromWindow(View v) {
                destroy();
            }
        };
        textView.addOnAttachStateChangeListener(onAttachStateChangeListener);
        textView.getViewTreeObserver().removeOnPreDrawListener(mOnPreDrawListener);
        mOnPreDrawListener = new ViewTreeObserver.OnPreDrawListener() {
            @Override
            public boolean onPreDraw() {
                int[] location = new int[2];
                textView.getLocationInWindow(location);
                mTextViewMarginStart = location[0];
                return true;
            }
        };
        textView.getViewTreeObserver().addOnPreDrawListener(mOnPreDrawListener);
        textView.setMovementMethod(new LinkMovementMethodInterceptor());
    }

    private void initHandler() {
        if (startHandle == null) {
            startHandle = new SelectionHandle(true);
        }
        if (endHandle == null) {
            endHandle = new SelectionHandle(false);
        }
    }

    private void showSelectionHandle(SelectionHandle selectionHandle) {
        Layout layout = textView.getLayout();
        if (layout == null) {
            return;
        }
        int offset = selectionHandle.isLeft ? mSelectionInfo.start : mSelectionInfo.end;
        selectionHandle.show((int) layout.getPrimaryHorizontal(offset), layout.getLineBottom(layout.getLineForOffset(offset)));
    }

    private void setSelection(int startPos, int endPos) {
        initHandler();

        if (startPos != -1) {
            mSelectionInfo.start = startPos;
        }
        if (endPos != -1) {
            mSelectionInfo.end = endPos;
        }
        if (mSelectionInfo.start > mSelectionInfo.end) {
            int temp = mSelectionInfo.start;
            mSelectionInfo.start = mSelectionInfo.end;
            mSelectionInfo.end = temp;
        }

        mSelectionInfo.selectionContent = spannable.subSequence(mSelectionInfo.start, mSelectionInfo.end).toString();
        setSelectionBg(spannable, mSelectionInfo.start, mSelectionInfo.end);
        showSelectionHandle(startHandle);
        showSelectionHandle(endHandle);
        if (mSelectListener != null) {
            mSelectListener.onTextSelected(mSelectionInfo.selectionContent);
        }
    }

    private void setSelectionBg(Spannable text, int start, int end) {
        if (bgSpan == null) {
            bgSpan = new BackgroundColorSpan(selectionColor);
        }
        text.setSpan(bgSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        CenterImageSpan[] allImageSpans = text.getSpans(0, text.length(), CenterImageSpan.class);
        CenterImageSpan[] imageSpans = text.getSpans(start, end, CenterImageSpan.class);
        if (allImageSpans != null) {
            for (CenterImageSpan imageSpan : allImageSpans) {
                imageSpan.setBgColor(-1);
            }
        }
        if (imageSpans != null) {
            for (CenterImageSpan imageSpan : imageSpans) {
                imageSpan.setBgColor(selectionColor);
            }
        }
    }

    private void clearSelection() {
        mSelectionInfo.selectionContent = null;
        clearSelectionBg();
    }

    private void clearSelectionBg() {
        if (spannable == null) {
            return;
        }
        if (bgSpan != null) {
            spannable.removeSpan(bgSpan);
        }
        CenterImageSpan[] imageSpans = spannable.getSpans(0, spannable.length(), CenterImageSpan.class);
        if (imageSpans != null) {
            for (CenterImageSpan imageSpan : imageSpans) {
                imageSpan.setBgColor(-1);
            }
        }
        if (startHandle != null) {
            startHandle.dismiss();
        }
        if (endHandle != null) {
            endHandle.dismiss();
        }
    }

    private class SelectionHandle extends View {
        private PopupWindow mPopupWindow;
        private Paint mPaint;

        private int mCircleRadius = handleSize / 2;
        private int mWidth = handleSize;
        private int mHeight = handleSize;
        private int mPadding = 32;
        private boolean isLeft;

        public SelectionHandle(boolean isLeft) {
            super(textView.getContext());
            this.isLeft = isLeft;
            mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            mPaint.setColor(handleColor);

            mPopupWindow = new PopupWindow(this);
            mPopupWindow.setClippingEnabled(false);
            mPopupWindow.setWidth(mWidth + mPadding * 2);
            mPopupWindow.setHeight(mHeight + mPadding / 2);
            invalidate();
        }

        @Override
        protected void onDraw(Canvas canvas) {
            canvas.drawCircle(mCircleRadius + mPadding, mCircleRadius, mCircleRadius, mPaint);
            if (isLeft) {
                canvas.drawRect(mCircleRadius + mPadding, 0, mCircleRadius * 2 + mPadding, mCircleRadius, mPaint);
            } else {
                canvas.drawRect(mPadding, 0, mCircleRadius + mPadding, mCircleRadius, mPaint);
            }
        }

        private int mAdjustX;
        private int mAdjustY;

        private int mBeforeDragStart;
        private int mBeforeDragEnd;

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    mBeforeDragStart = mSelectionInfo.start;
                    mBeforeDragEnd = mSelectionInfo.end;
                    mAdjustX = (int) event.getX();
                    mAdjustY = (int) event.getY();
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (null != mSelectListener) {
                        mSelectListener.onDismissPop();
                    }
                    int rawX = (int) event.getRawX();
                    int rawY = (int) event.getRawY();

                    update(rawX + mAdjustX - mWidth - mTextViewMarginStart, rawY + mAdjustY - mHeight - (int) textView.getTextSize());
                    break;
                default:
                    break;
            }
            return true;
        }

        private void changeDirection() {
            isLeft = !isLeft;
            invalidate();
        }

        public void dismiss() {
            Log.e(TAG, "handler dismiss");
            mPopupWindow.dismiss();
        }

        private int[] mTempCoors = new int[2];

        public void update(int x, int y) {
            textView.getLocationInWindow(mTempCoors);
            int oldOffset;
            if (isLeft) {
                oldOffset = mSelectionInfo.start;
            } else {
                oldOffset = mSelectionInfo.end;
            }

            y -= mTempCoors[1];

            int offset = getHysteresisOffset(textView, x, y, oldOffset);

            if (offset != oldOffset) {
                mSelectionInfo.selectionContent = null;
                if (isLeft) {
                    if (offset > mBeforeDragEnd) {
                        SelectionHandle handle = getSelectionHandle(false);
                        changeDirection();
                        handle.changeDirection();
                        mBeforeDragStart = mBeforeDragEnd;
                        setSelection(mBeforeDragEnd, offset);
                        handle.updateSelectionHandle();
                    } else {
                        setSelection(offset, -1);
                    }
                    updateSelectionHandle();
                } else {
                    if (offset < mBeforeDragStart) {
                        SelectionHandle handle = getSelectionHandle(true);
                        handle.changeDirection();
                        changeDirection();
                        mBeforeDragEnd = mBeforeDragStart;
                        setSelection(offset, mBeforeDragStart);
                        handle.updateSelectionHandle();
                    } else {
                        setSelection(mBeforeDragStart, offset);
                    }
                    updateSelectionHandle();
                }
            }
        }

        private void updateSelectionHandle() {
            textView.getLocationInWindow(mTempCoors);
            Layout layout = textView.getLayout();
            if (isLeft) {
                mPopupWindow.update((int) layout.getPrimaryHorizontal(mSelectionInfo.start) - mWidth + getExtraX(),
                    layout.getLineBottom(layout.getLineForOffset(mSelectionInfo.start)) + getExtraY(), -1, -1);
            } else {
                mPopupWindow.update((int) layout.getPrimaryHorizontal(mSelectionInfo.end) + getExtraX(),
                    layout.getLineBottom(layout.getLineForOffset(mSelectionInfo.end)) + getExtraY(), -1, -1);
            }
        }

        public void show(int x, int y) {
            textView.getLocationInWindow(mTempCoors);
            int offset = isLeft ? mWidth : 0;
            mPopupWindow.showAtLocation(textView, Gravity.NO_GRAVITY, x - offset + getExtraX(), y + getExtraY());
        }

        public int getExtraX() {
            return mTempCoors[0] - mPadding + textView.getPaddingLeft();
        }

        public int getExtraY() {
            return mTempCoors[1] + textView.getPaddingTop();
        }
    }

    private SelectionHandle getSelectionHandle(boolean isLeft) {
        if (startHandle.isLeft == isLeft) {
            return startHandle;
        } else {
            return endHandle;
        }
    }

    private static class SelectionInfo {
        public int start;
        public int end;
        public String selectionContent;
    }

    private class LinkMovementMethodInterceptor extends LinkMovementMethod {
        @Override
        public boolean onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
            return gestureDetector.onTouchEvent(event);
        }
    }

    public static int getHysteresisOffset(TextView textView, int x, int y, int previousOffset) {
        final Layout layout = textView.getLayout();
        if (layout == null) {
            return -1;
        }

        int line = layout.getLineForVertical(y);

        // The "HACK BLOCK"S in this function is required because of how Android Layout for
        // TextView works - if 'offset' equals to the last character of a line, then
        //
        // * getLineForOffset(offset) will result the NEXT line
        // * getPrimaryHorizontal(offset) will return 0 because the next insertion point is on the next line
        // * getOffsetForHorizontal(line, x) will not return the last offset of a line no matter where x is
        // These are highly undesired and is worked around with the HACK BLOCK
        //
        // @see Moon+ Reader/Color Note - see how it can't select the last character of a line unless you move
        // the cursor to the beginning of the next line.
        //
        ////////////////////HACK BLOCK////////////////////////////////////////////////////

        if (isEndOfLineOffset(layout, previousOffset)) {
            // we have to minus one from the offset so that the code below to find
            // the previous line can work correctly.
            int left = (int) layout.getPrimaryHorizontal(previousOffset - 1);
            int right = (int) layout.getLineRight(line);
            int threshold = (right - left) / 2; // half the width of the last character
            if (x > right - threshold) {
                previousOffset -= 1;
            }
        }
        ///////////////////////////////////////////////////////////////////////////////////

        final int previousLine = layout.getLineForOffset(previousOffset);
        final int previousLineTop = layout.getLineTop(previousLine);
        final int previousLineBottom = layout.getLineBottom(previousLine);
        final int hysteresisThreshold = (previousLineBottom - previousLineTop) / 2;

        // If new line is just before or after previous line and y position is less than
        // hysteresisThreshold away from previous line, keep cursor on previous line.
        if (((line == previousLine + 1) && ((y - previousLineBottom) < hysteresisThreshold))
            || ((line == previousLine - 1) && ((previousLineTop - y) < hysteresisThreshold))) {
            line = previousLine;
        }

        int offset = layout.getOffsetForHorizontal(line, x);

        // This allow the user to select the last character of a line without moving the
        // cursor to the next line. (As Layout.getOffsetForHorizontal does not return the
        // offset of the last character of the specified line)
        //
        // But this function will probably get called again immediately, must decrement the offset
        // by 1 to compensate for the change made below. (see previous HACK BLOCK)
        /////////////////////HACK BLOCK///////////////////////////////////////////////////
        if (offset < textView.getText().length() - 1) {
            if (isEndOfLineOffset(layout, offset + 1)) {
                int left = (int) layout.getPrimaryHorizontal(offset);
                int right = (int) layout.getLineRight(line);
                int threshold = (right - left) / 2; // half the width of the last character
                if (x > right - threshold) {
                    offset += 1;
                }
            }
        }
        //////////////////////////////////////////////////////////////////////////////////

        return offset;
    }

    private static boolean isEndOfLineOffset(Layout layout, int offset) {
        return offset > 0 && layout.getLineForOffset(offset) == layout.getLineForOffset(offset - 1) + 1;
    }
}