package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.os.Build;
import android.text.Layout;
import android.text.Selection;
import android.text.Spannable;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.BackgroundColorSpan;
import android.text.style.ClickableSpan;
import android.text.style.ImageSpan;
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

import com.tencent.qcloud.tuikit.tuichat.classicui.component.BeginnerGuidePage;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


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
    private int mTextViewMarginStart = 0;// textView的marginStart值

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
    private boolean mIsEmoji = false;
    private List<Pair<Integer, String>> itemTextList;
    private List<Builder.onSeparateItemClickListener> itemListenerList = new LinkedList<>();

    private BackgroundColorSpan mSpan;
    private boolean isHideWhenScroll;
    private boolean isHide = true;
    private boolean usedClickListener = false;

    private ViewTreeObserver.OnPreDrawListener mOnPreDrawListener;
    private ViewTreeObserver.OnScrollChangedListener mOnScrollChangedListener;
    private View.OnTouchListener mRootTouchListener;


    public interface OnSelectListener {
        void onClick(View v);// 点击textView

        void onLongClick(View v);// 长按textView

        void onTextSelected(CharSequence content);// 选中文本回调

        void onDismiss();// 解除弹窗回调

        void onClickUrl(String url);// 点击文本里的url回调

        void onSelectAllShowCustomPop();// 全选显示自定义弹窗回调

        void onReset();// 重置回调

        void onDismissCustomPop();// 解除自定义弹窗回调

        void onScrolling();// 正在滚动回调
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
        private boolean mIsEmoji = false;
        private List<Pair<Integer, String>> itemTextList = new LinkedList<>();
        private List<onSeparateItemClickListener> itemListenerList = new LinkedList<>();

        public Builder(TextView textView) {
            mTextView = textView;
        }

        /**
         * 选择游标颜色
         */
        public Builder setCursorHandleColor(@ColorInt int cursorHandleColor) {
            mCursorHandleColor = cursorHandleColor;
            return this;
        }

        /**
         * 选择游标大小
         */
        public Builder setCursorHandleSizeInDp(float cursorHandleSizeInDp) {
            mCursorHandleSizeInDp = cursorHandleSizeInDp;
            return this;
        }

        /**
         * 选中文本的颜色
         */
        public Builder setSelectedColor(@ColorInt int selectedBgColor) {
            mSelectedColor = selectedBgColor;
            return this;
        }

        /**
         * 全选
         */
        public Builder setSelectAll(boolean selectAll) {
            mSelectAll = selectAll;
            return this;
        }

        /**
         * 已经全选无弹窗
         */
        public Builder setSelectedAllNoPop(boolean selectedAllNoPop) {
            mSelectedAllNoPop = selectedAllNoPop;
            return this;
        }

        /**
         * 滑动依然显示弹窗
         */
        public Builder setScrollShow(boolean scrollShow) {
            mScrollShow = scrollShow;
            return this;
        }

        /**
         * 显示放大镜
         */
        public Builder setMagnifierShow(boolean magnifierShow) {
            mMagnifierShow = magnifierShow;
            return this;
        }

        /**
         * 弹窗每行个数
         */
        public Builder setPopSpanCount(int popSpanCount) {
            mPopSpanCount = popSpanCount;
            return this;
        }

        /**
         * 弹窗背景颜色、弹窗箭头
         */
        public Builder setPopStyle(int popBgResource, int popArrowImg) {
            mPopBgResource = popBgResource;
            mPopArrowImg = popArrowImg;
            return this;
        }

        public Builder setIsEmoji(boolean isEmoji) {
            mIsEmoji = isEmoji;
            return this;
        }

        public Builder addItem(@DrawableRes int drawableId, @StringRes int textResId, onSeparateItemClickListener listener) {
            itemTextList.add(new Pair<>(drawableId, mTextView.getContext().getResources().getString(textResId)));
            itemListenerList.add(listener);
            return this;
        }

        public Builder addItem(@DrawableRes int drawableId, String itemText, onSeparateItemClickListener listener) {
            itemTextList.add(new Pair<>(drawableId, itemText));
            itemListenerList.add(listener);
            return this;
        }

        public SelectTextHelper build() {
            return new SelectTextHelper(this);
        }

        public interface onSeparateItemClickListener {
            void onClick();
        }
    }

    public SelectTextHelper(Builder builder) {
        mTextView = builder.mTextView;
        mContext = mTextView.getContext();
        mSelectedColor = builder.mSelectedColor;
        mCursorHandleColor = builder.mCursorHandleColor;
        mSelectAll = builder.mSelectAll;
        mIsEmoji = builder.mIsEmoji;
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

    /**
     * 重置弹窗
     */
    public void reset() {
        TUIChatLog.d(TAG, "reset");
        hideSelectView();
        resetSelectionInfo();
        // 重置弹窗回调
        if (mSelectListener != null) {
            mSelectListener.onReset();
        }
    }


    /**
     * 选择文本监听
     */
    public void setSelectListener(OnSelectListener selectListener) {
        mSelectListener = selectListener;
    }

    /**
     * 销毁
     */
    public void destroy() {
        mTextView.getViewTreeObserver().removeOnScrollChangedListener(mOnScrollChangedListener);
        mTextView.getViewTreeObserver().removeOnPreDrawListener(mOnPreDrawListener);
        mTextView.getRootView().setOnTouchListener(null);
        reset();
        mStartHandle = null;
        mEndHandle = null;
    }

    /**
     * 全选
     */
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
                BeginnerGuidePage.showBeginnerGuideThen(mTextView, new Runnable() {
                    @Override
                    public void run() {
                        onLongTextViewClick();
                    }
                });
                return true;
            }

            private void onLongTextViewClick() {
                mTextView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                    @Override
                    public void onViewAttachedToWindow(View v) {
                    }

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
                        // 拿textView的x坐标
                        if (0 == mTextViewMarginStart) {
                            int[] location = new int[2];
                            mTextView.getLocationInWindow(location);
                            mTextViewMarginStart = location[0];
                        }
                        return true;
                    }
                };
                mTextView.getViewTreeObserver().addOnPreDrawListener(mOnPreDrawListener);

                // 根布局监听
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
        // 此setMovementMethod可被修改
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
            if (isHide) return;
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
            TUIChatLog.d(TAG, "mStartHandle.dismiss();");
            mStartHandle.dismiss();
        }
        if (mEndHandle != null) {
            TUIChatLog.d(TAG, "mEndHandle.dismiss();");
            mEndHandle.dismiss();
        }
    }

    private void resetSelectionInfo() {
        mSelectionInfo.mSelectionContent = null;
        if (mSpannable != null && mSpan != null) {
            TUIChatLog.d(TAG, "mSpannable.removeSpan(mSpan);");
            mSpannable.removeSpan(mSpan);
            mSpan = null;
        }
    }

    private void showSelectView(int x, int y) {
        reset();
        isHide = false;
        if (mStartHandle == null) mStartHandle = new CursorHandle(true);
        if (mEndHandle == null) mEndHandle = new CursorHandle(false);

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
     * 全选
     * Select all
     */
    private void showAllView() {
        reset();
        isHide = false;
        if (mStartHandle == null) mStartHandle = new CursorHandle(true);
        if (mEndHandle == null) mEndHandle = new CursorHandle(false);

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

        if (mSpannable != null) {
            if (mSpan == null) {
                mSpan = new BackgroundColorSpan(mSelectedColor);
            }
            mSelectionInfo.mSelectionContent = mSpannable.subSequence(mSelectionInfo.mStart, mSelectionInfo.mEnd).toString();
            mSpannable.setSpan(mSpan, mSelectionInfo.mStart, mSelectionInfo.mEnd, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            if (mSelectListener != null) {
                mSelectListener.onTextSelected(mSelectionInfo.mSelectionContent);
            }

            if (mIsEmoji) {
                //handlerEmojiSelectText();
            }
        }
    }

    private void handlerEmojiSelectText() {
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(mSelectionInfo.mSelectionContent);

        while (m.find()) {
            String emojiName = m.group();
            Bitmap bitmap = FaceManager.getEmoji(emojiName);
            if (bitmap != null) {

                Drawable drawable = new BitmapDrawable(bitmap);
                ShapeDrawable background = new ShapeDrawable();
                background.getPaint().setColor(mTextView.getContext().getResources().getColor(com.tencent.qcloud.tuicore.R.color.text_select_color));
                LayerDrawable layerDrawable = new LayerDrawable(new Drawable[]{background, drawable});
                layerDrawable.setBounds(0, 0, 64, 64);
                ImageSpan image = new ImageSpan(layerDrawable, ImageSpan.ALIGN_BASELINE);
                mSpannable.setSpan(image, mSelectionInfo.mStart, mSelectionInfo.mEnd, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }
        }
    }

    /**
     * 游标
     */
    private class CursorHandle extends View {

        private PopupWindow mPopupWindow;
        private Paint mPaint;

        private int mCircleRadius = mCursorHandleSize / 2;
        private int mWidth = mCursorHandleSize;
        private int mHeight = mCursorHandleSize;
        private int mPadding = 32;// 游标padding
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
                        // android 9 放大镜
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
                                && null != mMagnifier) {
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
                    // x y不准 x 减去textView距离x轴距离值  y减去字体大小的像素值
                    update(rawX + mAdjustX - mWidth - mTextViewMarginStart,
                            rawY + mAdjustY - mHeight - (int) mTextView.getTextSize());
                    if (mMagnifierShow) {
                        // android 9 放大镜功能
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

    /**
     * 处理内容链接跳转
     */
    private class LinkMovementMethodInterceptor extends LinkMovementMethod {

        private long downLinkTime;

        @Override
        public boolean onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
            int action = event.getAction();

            if (action == MotionEvent.ACTION_UP ||
                    action == MotionEvent.ACTION_DOWN) {
                int x = (int) event.getX();
                int y = (int) event.getY();

                x -= widget.getTotalPaddingLeft();
                y -= widget.getTotalPaddingTop();

                x += widget.getScrollX();
                y += widget.getScrollY();

                Layout layout = widget.getLayout();
                int line = layout.getLineForVertical(y);
                int off = layout.getOffsetForHorizontal(line, x);

                ClickableSpan[] links =
                        buffer.getSpans(off, off, ClickableSpan.class);

                if (links.length != 0) {
                    if (action == MotionEvent.ACTION_UP) {
                        // 长按
                        if (downLinkTime + ViewConfiguration.getLongPressTimeout() < System.currentTimeMillis()) {
                            return false;
                        }
                        // 点击
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
                        Selection.setSelection(buffer,
                                buffer.getSpanStart(links[0]),
                                buffer.getSpanEnd(links[0]));
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
        if (layout == null) return -1;

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
        if (((line == previousLine + 1) && ((y - previousLineBottom) < hysteresisThreshold)) || ((line == previousLine - 1) && ((
                previousLineTop
                        - y) < hysteresisThreshold))) {
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

    /**
     * 设置宽高
     *
     * @param v
     * @param w
     * @param h
     */
    public static void setWidthHeight(View v, int w, int h) {
        ViewGroup.LayoutParams params = v.getLayoutParams();
        params.width = w;
        params.height = h;
        v.setLayoutParams(params);
    }

    /**
     * 通知栏的高度
     */
    private static int STATUS_HEIGHT = 0;

    /**
     * 获取通知栏的高度
     */
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