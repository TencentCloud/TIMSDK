package com.tencent.qcloud.tuikit.timcommon.classicui.widget.message;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.os.Build;
import android.text.Layout;
import android.text.Selection;
import android.text.Spannable;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.util.Pair;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Magnifier;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.ColorInt;
import androidx.annotation.DrawableRes;
import androidx.annotation.StringRes;
import java.util.LinkedList;
import java.util.List;

public class SelectTextHelper {
    private static final String TAG = SelectTextHelper.class.getSimpleName();

    private static int DEFAULT_SELECTION_LENGTH = 2;
    private static int DEFAULT_SHOW_DURATION = 100;

    private CursorHandle mStartHandle;
    private CursorHandle mEndHandle;
    private Magnifier mMagnifier;
    private SelectionInfo mSelectionInfo = new SelectionInfo();
    private OnSelectListener mSelectListener;

    private Context mContext;
    private TextView mTextView;
    private Spannable mSpannable;

    private int mTouchX;
    private int mTouchY;
    private int mTextViewMarginStart = 0; 

    private int mSelectedColor;
    private int mCursorHandleColor;
    private int mCursorHandleSize;
    private boolean mSelectAll;
    private boolean mSelectedAllNoPop;
    private boolean mScrollShow;
    private boolean mMagnifierShow;
    private int mPopSpanCount;
    private int mPopBgResource;
    private int mPopArrowImg;
    private List<Pair<Integer, String>> itemTextList;
    private List<Builder.OnSeparateItemClickListener> itemListenerList = new LinkedList<>();

    private boolean isHideWhenScroll;
    private boolean isHide = true;
    private boolean usedClickListener = false;

    private ViewTreeObserver.OnPreDrawListener mOnPreDrawListener;
    private ViewTreeObserver.OnScrollChangedListener mOnScrollChangedListener;
    private View.OnTouchListener mRootTouchListener;

    public interface OnSelectListener {
        void onClick(View v); 

        void onLongClick(View v); 

        void onTextSelected(CharSequence content); 

        void onDismiss(); 

        void onClickUrl(String url); 

        void onSelectAllShowCustomPop(); 

        void onReset(); 

        void onDismissCustomPop(); 

        void onScrolling(); 
    }

    public static class Builder {
        private TextView mTextView;
        private int mCursorHandleColor = 0xFF1379D6;
        private int mSelectedColor = 0xFFAFE1F4;
        private float mCursorHandleSizeInDp = 24;
        private boolean mSelectAll = true;
        private boolean mSelectedAllNoPop = false;
        private boolean mScrollShow = true;
        private boolean mMagnifierShow = true;
        private int mPopSpanCount = 5;
        private int mPopBgResource = 0;
        private int mPopArrowImg = 0;
        private List<Pair<Integer, String>> itemTextList = new LinkedList<>();
        private List<OnSeparateItemClickListener> itemListenerList = new LinkedList<>();

        public Builder(TextView textView) {
            mTextView = textView;
        }

        public Builder setCursorHandleColor(@ColorInt int cursorHandleColor) {
            mCursorHandleColor = cursorHandleColor;
            return this;
        }

        public Builder setCursorHandleSizeInDp(float cursorHandleSizeInDp) {
            mCursorHandleSizeInDp = cursorHandleSizeInDp;
            return this;
        }

        public Builder setSelectedColor(@ColorInt int selectedBgColor) {
            mSelectedColor = selectedBgColor;
            return this;
        }

        public Builder setSelectAll(boolean selectAll) {
            mSelectAll = selectAll;
            return this;
        }

        public Builder setSelectedAllNoPop(boolean selectedAllNoPop) {
            mSelectedAllNoPop = selectedAllNoPop;
            return this;
        }

        public Builder setScrollShow(boolean scrollShow) {
            mScrollShow = scrollShow;
            return this;
        }

        public Builder setMagnifierShow(boolean magnifierShow) {
            mMagnifierShow = magnifierShow;
            return this;
        }

        public Builder setPopSpanCount(int popSpanCount) {
            mPopSpanCount = popSpanCount;
            return this;
        }

        public Builder setPopStyle(int popBgResource, int popArrowImg) {
            mPopBgResource = popBgResource;
            mPopArrowImg = popArrowImg;
            return this;
        }

        public Builder addItem(@DrawableRes int drawableId, @StringRes int textResId, OnSeparateItemClickListener listener) {
            itemTextList.add(new Pair<>(drawableId, mTextView.getContext().getResources().getString(textResId)));
            itemListenerList.add(listener);
            return this;
        }

        public Builder addItem(@DrawableRes int drawableId, String itemText, OnSeparateItemClickListener listener) {
            itemTextList.add(new Pair<>(drawableId, itemText));
            itemListenerList.add(listener);
            return this;
        }

        public SelectTextHelper build() {
            return new SelectTextHelper(this);
        }

        public interface OnSeparateItemClickListener {
            void onClick();
        }
    }

    public SelectTextHelper(Builder builder) {
        mTextView = builder.mTextView;
        mContext = mTextView.getContext();
        mSelectedColor = builder.mSelectedColor;
        mCursorHandleColor = builder.mCursorHandleColor;
        mSelectAll = builder.mSelectAll;
        mScrollShow = builder.mScrollShow;
        mMagnifierShow = builder.mMagnifierShow;
        mPopSpanCount = builder.mPopSpanCount;
        mPopBgResource = builder.mPopBgResource;
        mPopArrowImg = builder.mPopArrowImg;
        mSelectedAllNoPop = builder.mSelectedAllNoPop;
        itemTextList = builder.itemTextList;
        itemListenerList = builder.itemListenerList;
        mCursorHandleSize = dp2px(builder.mCursorHandleSizeInDp);
        init();
    }

    public void reset() {
        hideSelectView();
        resetSelectionInfo();
        
        if (mSelectListener != null) {
            mSelectListener.onReset();
        }
    }

    public void setSelectListener(OnSelectListener selectListener) {
        mSelectListener = selectListener;
    }

    public void destroy() {
        mTextView.getViewTreeObserver().removeOnScrollChangedListener(mOnScrollChangedListener);
        mTextView.getViewTreeObserver().removeOnPreDrawListener(mOnPreDrawListener);
        mTextView.getRootView().setOnTouchListener(null);
        reset();
        mStartHandle = null;
        mEndHandle = null;
    }

    public void selectAll() {
        showAllView();
    }

    /**
     * public end
     */

    private void init() {
        mTextView.setText(mTextView.getText(), TextView.BufferType.SPANNABLE);

        mTextView.setOnTouchListener((v, event) -> {
            mTouchX = (int) event.getX();
            mTouchY = (int) event.getY();
            return false;
        });

        mTextView.setOnClickListener(v -> {
            if (usedClickListener) {
                usedClickListener = false;
                return;
            }
            if (null != mSelectListener) {
                mSelectListener.onDismiss();
            }
            reset();
            if (null != mSelectListener) {
                mSelectListener.onClick(mTextView);
            }
        });

        mTextView.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                onLongTextViewClick();
                return true;
            }

            private void onLongTextViewClick() {
                mTextView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                    @Override
                    public void onViewAttachedToWindow(View v) {}

                    @Override
                    public void onViewDetachedFromWindow(View v) {
                        destroy();
                    }
                });

                mOnPreDrawListener = new ViewTreeObserver.OnPreDrawListener() {
                    @Override
                    public boolean onPreDraw() {
                        if (isHideWhenScroll) {
                            isHideWhenScroll = false;
                            postShowSelectView(DEFAULT_SHOW_DURATION);
                        }
                        
                        if (0 == mTextViewMarginStart) {
                            int[] location = new int[2];
                            mTextView.getLocationInWindow(location);
                            mTextViewMarginStart = location[0];
                        }
                        return true;
                    }
                };
                mTextView.getViewTreeObserver().addOnPreDrawListener(mOnPreDrawListener);

                
                mRootTouchListener = new View.OnTouchListener() {
                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        reset();
                        mTextView.getRootView().setOnTouchListener(null);
                        return false;
                    }
                };
                mTextView.getRootView().setOnTouchListener(mRootTouchListener);

                mOnScrollChangedListener = new ViewTreeObserver.OnScrollChangedListener() {
                    @Override
                    public void onScrollChanged() {
                        if (mScrollShow) {
                            if (!isHideWhenScroll && !isHide) {
                                isHideWhenScroll = true;
                                if (mStartHandle != null) {
                                    mStartHandle.dismiss();
                                }
                                if (mEndHandle != null) {
                                    mEndHandle.dismiss();
                                }
                            }
                            if (null != mSelectListener) {
                                mSelectListener.onScrolling();
                            }
                        } else {
                            reset();
                        }
                    }
                };
                mTextView.getViewTreeObserver().addOnScrollChangedListener(mOnScrollChangedListener);

                if (mSelectAll) {
                    showAllView();
                } else {
                    showSelectView(mTouchX, mTouchY);
                }
                if (null != mSelectListener) {
                    mSelectListener.onLongClick(mTextView);
                }
            }
        });
        
        mTextView.setMovementMethod(new LinkMovementMethodInterceptor());
    }

    private void postShowSelectView(int duration) {
        mTextView.removeCallbacks(mShowSelectViewRunnable);
        if (duration <= 0) {
            mShowSelectViewRunnable.run();
        } else {
            mTextView.postDelayed(mShowSelectViewRunnable, duration);
        }
    }

    private final Runnable mShowSelectViewRunnable = new Runnable() {
        @Override
        public void run() {
            if (isHide) {
                return;
            }
            if (mStartHandle != null) {
                showCursorHandle(mStartHandle);
            }
            if (mEndHandle != null) {
                showCursorHandle(mEndHandle);
            }
        }
    };

    private void hideSelectView() {
        isHide = true;
        usedClickListener = false;
        if (mStartHandle != null) {
            mStartHandle.dismiss();
        }
        if (mEndHandle != null) {
            mEndHandle.dismiss();
        }
    }

    private void resetSelectionInfo() {
        mSelectionInfo.mSelectionContent = null;
        if (mSpannable != null) {
            Selection.removeSelection(mSpannable);
        }
    }

    private void showSelectView(int x, int y) {
        reset();
        isHide = false;
        if (mStartHandle == null) {
            mStartHandle = new CursorHandle(true);
        }
        if (mEndHandle == null) {
            mEndHandle = new CursorHandle(false);
        }

        int startOffset = getPreciseOffset(mTextView, x, y);
        int endOffset = startOffset + DEFAULT_SELECTION_LENGTH;
        if (mTextView.getText() instanceof Spannable) {
            mSpannable = (Spannable) mTextView.getText();
        }
        if (mSpannable == null || endOffset - 1 >= mTextView.getText().length()) {
            return;
        }
        selectText(startOffset, endOffset);
        showCursorHandle(mStartHandle);
        showCursorHandle(mEndHandle);
    }

    /**
     * Select all
     */
    private void showAllView() {
        reset();
        isHide = false;
        if (mStartHandle == null) {
            mStartHandle = new CursorHandle(true);
        }
        if (mEndHandle == null) {
            mEndHandle = new CursorHandle(false);
        }

        if (mTextView.getText() instanceof Spannable) {
            mSpannable = (Spannable) mTextView.getText();
        }
        if (mSpannable == null) {
            return;
        }
        selectText(0, mTextView.getText().length());
        showCursorHandle(mStartHandle);
        showCursorHandle(mEndHandle);
    }

    private void showCursorHandle(CursorHandle cursorHandle) {
        Layout layout = mTextView.getLayout();
        if (layout == null) {
            return;
        }
        int offset = cursorHandle.isLeft ? mSelectionInfo.mStart : mSelectionInfo.mEnd;
        cursorHandle.show((int) layout.getPrimaryHorizontal(offset), layout.getLineBottom(layout.getLineForOffset(offset)));
    }

    private void selectText(int startPos, int endPos) {
        if (startPos != -1) {
            mSelectionInfo.mStart = startPos;
        }
        if (endPos != -1) {
            mSelectionInfo.mEnd = endPos;
        }
        if (mSelectionInfo.mStart > mSelectionInfo.mEnd) {
            int temp = mSelectionInfo.mStart;
            mSelectionInfo.mStart = mSelectionInfo.mEnd;
            mSelectionInfo.mEnd = temp;
        }

        mTextView.requestFocus();
        mSelectionInfo.mSelectionContent = mSpannable.subSequence(mSelectionInfo.mStart, mSelectionInfo.mEnd).toString();
        Selection.setSelection(mSpannable, mSelectionInfo.mStart, mSelectionInfo.mEnd);
        if (mSelectListener != null) {
            mSelectListener.onTextSelected(mSelectionInfo.mSelectionContent);
        }
    }

    private class CursorHandle extends View {
        private PopupWindow mPopupWindow;
        private Paint mPaint;

        private int mCircleRadius = mCursorHandleSize / 2;
        private int mWidth = mCursorHandleSize;
        private int mHeight = mCursorHandleSize;
        private int mPadding = 32; 
        private boolean isLeft;

        public CursorHandle(boolean isLeft) {
            super(mContext);
            this.isLeft = isLeft;
            mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            mPaint.setColor(mCursorHandleColor);

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
                    mBeforeDragStart = mSelectionInfo.mStart;
                    mBeforeDragEnd = mSelectionInfo.mEnd;
                    mAdjustX = (int) event.getX();
                    mAdjustY = (int) event.getY();
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    if (mMagnifierShow) {
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && null != mMagnifier) {
                            mMagnifier.dismiss();
                        }
                    }
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (null != mSelectListener) {
                        mSelectListener.onDismissCustomPop();
                    }
                    int rawX = (int) event.getRawX();
                    int rawY = (int) event.getRawY();
                    
                    update(rawX + mAdjustX - mWidth - mTextViewMarginStart, rawY + mAdjustY - mHeight - (int) mTextView.getTextSize());
                    if (mMagnifierShow) {
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            if (null == mMagnifier) {
                                mMagnifier = new Magnifier(mTextView);
                                mMagnifier.getWidth();
                            }
                            final int[] viewPosition = new int[2];
                            mTextView.getLocationOnScreen(viewPosition);
                            int magnifierX = rawX - viewPosition[0];
                            int magnifierY = rawY - viewPosition[1] - dp2px(32);
                            mMagnifier.show(magnifierX, Math.max(magnifierY, 0));
                        }
                    }
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
            mPopupWindow.dismiss();
        }

        private int[] mTempCoors = new int[2];

        public void update(int x, int y) {
            mTextView.getLocationInWindow(mTempCoors);
            int oldOffset;
            if (isLeft) {
                oldOffset = mSelectionInfo.mStart;
            } else {
                oldOffset = mSelectionInfo.mEnd;
            }

            y -= mTempCoors[1];

            int offset = getHysteresisOffset(mTextView, x, y, oldOffset);

            if (offset != oldOffset) {
                resetSelectionInfo();
                if (isLeft) {
                    if (offset > mBeforeDragEnd) {
                        CursorHandle handle = getCursorHandle(false);
                        changeDirection();
                        handle.changeDirection();
                        mBeforeDragStart = mBeforeDragEnd;
                        selectText(mBeforeDragEnd, offset);
                        handle.updateCursorHandle();
                    } else {
                        selectText(offset, -1);
                    }
                    updateCursorHandle();
                } else {
                    if (offset < mBeforeDragStart) {
                        CursorHandle handle = getCursorHandle(true);
                        handle.changeDirection();
                        changeDirection();
                        mBeforeDragEnd = mBeforeDragStart;
                        selectText(offset, mBeforeDragStart);
                        handle.updateCursorHandle();
                    } else {
                        selectText(mBeforeDragStart, offset);
                    }
                    updateCursorHandle();
                }
            }
        }

        private void updateCursorHandle() {
            mTextView.getLocationInWindow(mTempCoors);
            Layout layout = mTextView.getLayout();
            if (isLeft) {
                mPopupWindow.update((int) layout.getPrimaryHorizontal(mSelectionInfo.mStart) - mWidth + getExtraX(),
                    layout.getLineBottom(layout.getLineForOffset(mSelectionInfo.mStart)) + getExtraY(), -1, -1);
            } else {
                mPopupWindow.update((int) layout.getPrimaryHorizontal(mSelectionInfo.mEnd) + getExtraX(),
                    layout.getLineBottom(layout.getLineForOffset(mSelectionInfo.mEnd)) + getExtraY(), -1, -1);
            }
        }

        public void show(int x, int y) {
            mTextView.getLocationInWindow(mTempCoors);
            int offset = isLeft ? mWidth : 0;
            mPopupWindow.showAtLocation(mTextView, Gravity.NO_GRAVITY, x - offset + getExtraX(), y + getExtraY());
        }

        public int getExtraX() {
            return mTempCoors[0] - mPadding + mTextView.getPaddingLeft();
        }

        public int getExtraY() {
            return mTempCoors[1] + mTextView.getPaddingTop();
        }
    }

    private CursorHandle getCursorHandle(boolean isLeft) {
        if (mStartHandle.isLeft == isLeft) {
            return mStartHandle;
        } else {
            return mEndHandle;
        }
    }

    private class SelectionInfo {
        public int mStart;
        public int mEnd;
        public String mSelectionContent;
    }

    private class LinkMovementMethodInterceptor extends LinkMovementMethod {
        private long downLinkTime;

        @Override
        public boolean onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
            int action = event.getAction();

            if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_DOWN) {
                int x = (int) event.getX();
                int y = (int) event.getY();

                x -= widget.getTotalPaddingLeft();
                y -= widget.getTotalPaddingTop();

                x += widget.getScrollX();
                y += widget.getScrollY();

                Layout layout = widget.getLayout();
                int line = layout.getLineForVertical(y);
                int off = layout.getOffsetForHorizontal(line, x);

                ClickableSpan[] links = buffer.getSpans(off, off, ClickableSpan.class);

                if (links.length != 0) {
                    if (action == MotionEvent.ACTION_UP) {
                        
                        if (downLinkTime + ViewConfiguration.getLongPressTimeout() < System.currentTimeMillis()) {
                            return false;
                        }
                        
                        if (links[0] instanceof URLSpan) {
                            URLSpan url = (URLSpan) links[0];
                            if (!TextUtils.isEmpty(url.getURL())) {
                                if (null != mSelectListener) {
                                    usedClickListener = true;
                                    mSelectListener.onClickUrl(url.getURL());
                                }
                                return true;
                            } else {
                                links[0].onClick(widget);
                            }
                        }
                    } else if (action == MotionEvent.ACTION_DOWN) {
                        downLinkTime = System.currentTimeMillis();
                        Selection.setSelection(buffer, buffer.getSpanStart(links[0]), buffer.getSpanEnd(links[0]));
                    }
                    return true;
                } else {
                    Selection.removeSelection(buffer);
                }
            }

            return super.onTouchEvent(widget, buffer, event);
        }
    }

    // util

    public static int getPreciseOffset(TextView textView, int x, int y) {
        Layout layout = textView.getLayout();
        if (layout != null) {
            int topVisibleLine = layout.getLineForVertical(y);
            int offset = layout.getOffsetForHorizontal(topVisibleLine, x);

            int offsetX = (int) layout.getPrimaryHorizontal(offset);

            if (offsetX > x) {
                return layout.getOffsetToLeftOf(offset);
            } else {
                return offset;
            }
        } else {
            return -1;
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

    public static int getDisplayWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    public static int getDisplayHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }

    public static int dp2px(float dpValue) {
        return (int) (dpValue * Resources.getSystem().getDisplayMetrics().density + 0.5f);
    }

    public static void setWidthHeight(View v, int w, int h) {
        ViewGroup.LayoutParams params = v.getLayoutParams();
        params.width = w;
        params.height = h;
        v.setLayoutParams(params);
    }

    private static int STATUS_HEIGHT = 0;

    public static int getStatusHeight() {
        if (0 != STATUS_HEIGHT) {
            return STATUS_HEIGHT;
        }
        int resid = Resources.getSystem().getIdentifier("status_bar_height", "dimen", "android");
        if (resid > 0) {
            STATUS_HEIGHT = Resources.getSystem().getDimensionPixelSize(resid);
            return STATUS_HEIGHT;
        }
        return -1;
    }
}