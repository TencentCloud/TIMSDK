package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.suspension;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.util.TypedValue;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;

import java.util.List;

public class SuspensionDecoration extends RecyclerView.ItemDecoration {
    private static final String TAG = SuspensionDecoration.class.getSimpleName();
    private static int COLOR_TITLE_BG = Color.parseColor("#FFF2F3F5");
    private static int COLOR_TITLE_BOTTOM_LINE = Color.parseColor("#FFCACACA");
    private static int COLOR_TITLE_FONT = Color.parseColor("#FF888888");
    private int mTitleFontSize;
    private List<? extends ISuspensionInterface> mDatas;
    private Paint mPaint;
    private Rect mBounds;
    private int mTitleHeight;
    private boolean isShowLine = true;
    private int mHeaderViewCount = 0;

    public SuspensionDecoration(Context context, List<? extends ISuspensionInterface> datas) {
        super();
        mDatas = datas;
        mPaint = new Paint();
        mBounds = new Rect();
        mTitleHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 33f, context.getResources().getDisplayMetrics());
        mTitleFontSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 13f, context.getResources().getDisplayMetrics());
        mPaint.setTextSize(mTitleFontSize);
        mPaint.setAntiAlias(true);
    }

    public SuspensionDecoration setTitleHeight(int mTitleHeight) {
        this.mTitleHeight = mTitleHeight;
        return this;
    }

    public SuspensionDecoration setShowLine(boolean isShowLine) {
        this.isShowLine = isShowLine;
        return this;
    }

    public SuspensionDecoration setColorTitleBg(int colorTitleBg) {
        COLOR_TITLE_BG = colorTitleBg;
        return this;
    }

    public SuspensionDecoration setColorTitleFont(int colorTitleFont) {
        COLOR_TITLE_FONT = colorTitleFont;
        return this;
    }

    public SuspensionDecoration setTitleFontSize(int mTitleFontSize) {
        mPaint.setTextSize(mTitleFontSize);
        return this;
    }

    public SuspensionDecoration setDatas(List<? extends ISuspensionInterface> mDatas) {
        this.mDatas = mDatas;
        return this;
    }

    public int getHeaderViewCount() {
        return mHeaderViewCount;
    }

    public SuspensionDecoration setHeaderViewCount(int headerViewCount) {
        mHeaderViewCount = headerViewCount;
        return this;
    }

    @Override
    public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
        super.onDraw(c, parent, state);
        final int left = parent.getPaddingLeft();
        final int right = parent.getWidth() - parent.getPaddingRight();
        final int childCount = parent.getChildCount();
        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child.getLayoutParams();
            int position = params.getViewLayoutPosition();
            position -= getHeaderViewCount();

            if (mDatas == null || mDatas.isEmpty() || position > mDatas.size() - 1 || position < 0 || !mDatas.get(position).isShowSuspension()) {
                continue;
            }

            if (position > -1) {
                if (position == 0) {
                    drawTitleArea(c, left, right, child, params, position);

                } else {
                    if (null != mDatas.get(position).getSuspensionTag()
                        && !mDatas.get(position).getSuspensionTag().equals(mDatas.get(position - 1).getSuspensionTag())) {
                        drawTitleArea(c, left, right, child, params, position);
                    } else {
                        // none
                    }
                }
            }
        }
    }

    /**
     * How to draw the background and text of the Title area
     *
     * @param c
     * @param left
     * @param right
     * @param child
     * @param params
     * @param position
     */
    private void drawTitleArea(Canvas c, int left, int right, View child, RecyclerView.LayoutParams params,
        int position) { 
        mPaint.setColor(COLOR_TITLE_BG);
        c.drawRect(left, child.getTop() - params.topMargin - mTitleHeight, right, child.getTop() - params.topMargin, mPaint);

        if (isShowLine) {
            mPaint.setColor(COLOR_TITLE_BOTTOM_LINE);
            c.drawRect(left, child.getTop() - params.topMargin - 1, right, child.getTop() - params.topMargin, mPaint);
        }

        mPaint.setColor(COLOR_TITLE_FONT);
        mPaint.getTextBounds(mDatas.get(position).getSuspensionTag(), 0, mDatas.get(position).getSuspensionTag().length(), mBounds);

        int x = child.getPaddingLeft() + 61;
        int y = child.getTop() - params.topMargin - (mTitleHeight / 2 - mBounds.height() / 2);
        if (LayoutUtil.isRTL()) {
            x = child.getWidth() - child.getPaddingRight() - mBounds.width() - 61;
        }
        c.drawText(mDatas.get(position).getSuspensionTag(), x, y, mPaint);
    }

    @Override public void onDrawOver(Canvas c, final RecyclerView parent, RecyclerView.State state) { 
        int pos = ((LinearLayoutManager) (parent.getLayoutManager())).findFirstVisibleItemPosition();
        pos -= getHeaderViewCount();

        if (mDatas == null || mDatas.isEmpty() || pos > mDatas.size() - 1 || pos < 0 || !mDatas.get(pos).isShowSuspension()) {
            return;
        }

        String tag = mDatas.get(pos).getSuspensionTag();
        // View child = parent.getChildAt(pos);
        View child = parent.findViewHolderForLayoutPosition(pos + getHeaderViewCount()).itemView;

        boolean flag = false; 
        if ((pos + 1) < mDatas.size()) {
            if (null != tag && !tag.equals(mDatas.get(pos + 1).getSuspensionTag())) {
                
                // The tag of the current first visible item is not equal to the tag of the next item, indicating that the floating View is about to be
                // switched.
                //                TUIKitLog.d(TAG, "onDrawOver() called with: c = [" + child.getTop());
                if (child.getHeight() + child.getTop() < mTitleHeight) {
                    
                    // When the remaining height of the first visible item on the screen is less than the height of the title area, we should also start to do
                    // the "swap animation" of the floating Title
                    c.save();
                    flag = true;

                    // parent.getRight() - parent.getPaddingRight(), parent.getPaddingTop() + child.getHeight() + child.getTop());

                    //  Similar to Ele.me ordering, the hover head of the product list switches the "animation effect"
                    //  When sliding up, move the canvas up (y is a negative number), so the Rect and Text drawn by the canvas are moved up, and there is a kind
                    //  of "animation" feeling of switching
                    c.translate(0, child.getHeight() + child.getTop() - mTitleHeight);
                }
            }
        }
        mPaint.setColor(COLOR_TITLE_BG);
        c.drawRect(
            parent.getPaddingLeft(), parent.getPaddingTop(), parent.getRight() - parent.getPaddingRight(), parent.getPaddingTop() + mTitleHeight, mPaint);
        mPaint.setColor(COLOR_TITLE_FONT);
        mPaint.getTextBounds(tag, 0, tag.length(), mBounds);

        int x = child.getPaddingLeft() + 61;
        int y = parent.getPaddingTop() + mTitleHeight - (mTitleHeight / 2 - mBounds.height() / 2);
        if (LayoutUtil.isRTL()) {
            x = child.getWidth() - child.getPaddingRight() - mBounds.width() - 61;
        }
        c.drawText(tag, x, y, mPaint);

        if (flag) {
            c.restore();
        }
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        int position = ((RecyclerView.LayoutParams) view.getLayoutParams()).getViewLayoutPosition();
        position -= getHeaderViewCount();
        if (mDatas == null || mDatas.isEmpty() || position > mDatas.size() - 1) {
            return;
        }

        if (position > -1) {
            ISuspensionInterface titleCategoryInterface = mDatas.get(position);
            if (titleCategoryInterface.isShowSuspension()) {
                if (position == 0) {
                    outRect.set(0, mTitleHeight, 0, 0);
                } else {
                    if (null != titleCategoryInterface.getSuspensionTag()
                            && !titleCategoryInterface.getSuspensionTag().equals(mDatas.get(position - 1).getSuspensionTag())) {
                        outRect.set(0, mTitleHeight, 0, 0);
                    }
                }
            }
        }
    }
}
