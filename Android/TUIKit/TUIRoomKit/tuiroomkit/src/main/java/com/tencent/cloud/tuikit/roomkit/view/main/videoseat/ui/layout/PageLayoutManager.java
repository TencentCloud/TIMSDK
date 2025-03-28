package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.layout;

import static androidx.recyclerview.widget.RecyclerView.SCROLL_STATE_IDLE;

import android.graphics.PointF;
import android.graphics.Rect;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.IntDef;
import androidx.annotation.IntRange;
import androidx.recyclerview.widget.LinearSmoothScroller;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

public class PageLayoutManager extends RecyclerView.LayoutManager implements
        RecyclerView.SmoothScroller.ScrollVectorProvider {
    private static final String TAG = "PageLayoutManager";

    public static final int SPEAKER_PAGE_INDEX = 0;

    public static final int VERTICAL   = 0;
    public static final int HORIZONTAL = 1;

    private static final int SPEAKER_PAGE_ITEM_COUNT = 1;
    private static final int ITEM_MARGIN_DP          = 8;

    protected int mLastPageCount;
    protected int mLastPageIndex;

    @IntDef({VERTICAL, HORIZONTAL})
    public @interface OrientationType {
    }

    @OrientationType
    private int mOrientation = HORIZONTAL;

    protected int mOffsetX = 0;
    protected int mOffsetY = 0;

    protected int mRows;
    protected int mColumns;
    protected int mOnePageSize;
    protected int mMarginBetweenItem;

    private SparseArray<Rect> mItemFrames;

    protected int mViewSizeSmall;
    protected int mViewSizeMiddle;

    protected int mItemWidth  = 0;
    protected int mItemHeight = 0;

    protected int mWidthUsed  = 0;
    protected int mHeightUsed = 0;

    protected int mMaxScrollX;
    protected int mMaxScrollY;
    private   int mScrollState = SCROLL_STATE_IDLE;

    private boolean mAllowContinuousScroll = true;

    protected RecyclerView mRecyclerView;

    protected boolean mIsSpeakerModeOn;
    protected boolean mIsTwoPersonVideoOn;
    protected boolean mIsTwoPersonSwitched;

    public PageLayoutManager(@IntRange(from = 1, to = 100) int rows,
                             @IntRange(from = 1, to = 100) int columns,
                             @OrientationType int orientation) {
        mItemFrames = new SparseArray<>();
        mOrientation = orientation;
        mRows = rows;
        mColumns = columns;
        mOnePageSize = mRows * mColumns;
    }

    public void enableSpeakerMode(boolean enable) {
        mIsSpeakerModeOn = enable;
        mOffsetX = 0;
        mLastPageIndex = 1;
    }

    public void enableTwoPersonMeeting(boolean isTwoPersonVideoOn, boolean isPersonSwitch) {
        mIsTwoPersonVideoOn = isTwoPersonVideoOn;
        mIsTwoPersonSwitched = isPersonSwitch;
    }

    @Override
    public void onAttachedToWindow(RecyclerView view) {
        super.onAttachedToWindow(view);
        mRecyclerView = view;
        mMarginBetweenItem = ScreenUtil.dip2px(ITEM_MARGIN_DP);
        mViewSizeSmall =
                (int) view.getContext().getResources().getDimension(R.dimen.tuivideoseat_video_view_size_small);
        mViewSizeMiddle =
                (int) view.getContext().getResources().getDimension(R.dimen.tuivideoseat_video_view_size_middle);
    }

    @Override
    public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {

    }

    @Override
    public void onLayoutCompleted(RecyclerView.State state) {
        super.onLayoutCompleted(state);
        if (state.isPreLayout()) {
            return;
        }
        setPageCount(getTotalPageCount());
        setPageIndex(getPageIndexByOffset());
    }

    protected void recycleAndFillItems(RecyclerView.Recycler recycler, RecyclerView.State state, boolean isStart) {
        if (state.isPreLayout()) {
            return;
        }

        Rect displayRect = new Rect(mOffsetX - mItemWidth, mOffsetY - mItemHeight,
                getUsableWidth() + mOffsetX + mItemWidth, getUsableHeight() + mOffsetY + mItemHeight);
        int startPos;
        int pageIndex = getPageIndexByOffset();

        if (mIsSpeakerModeOn) {
            if (pageIndex < 1) {
                return;
            }
            startPos = (pageIndex - 1) * mOnePageSize + SPEAKER_PAGE_ITEM_COUNT;
        } else {
            startPos = pageIndex * mOnePageSize;
        }

        startPos = startPos - mOnePageSize * 2;
        int minStartPos = mIsSpeakerModeOn ? SPEAKER_PAGE_ITEM_COUNT : 0;
        if (startPos < minStartPos) {
            startPos = minStartPos;
        }
        int stopPos = startPos + mOnePageSize * 4;
        if (stopPos >= getItemCount()) {
            stopPos = getItemCount() - 1;
        }

        detachAndScrapAttachedViews(recycler);
        if (pageIndex == SPEAKER_PAGE_ITEM_COUNT + 1 && mIsSpeakerModeOn) {
            layoutForSpeakerPreview(recycler);
        }
        if (isStart) {
            for (int i = startPos; i <= stopPos; i++) {
                addOrRemove(recycler, displayRect, i);
            }
        } else {
            for (int i = stopPos; i >= startPos; i--) {
                addOrRemove(recycler, displayRect, i);
            }
        }
        if (mIsSpeakerModeOn) {
            if (pageIndex < 1) {
                return;
            }
            startPos = (pageIndex - 1) * mOnePageSize + SPEAKER_PAGE_ITEM_COUNT;
        } else {
            startPos = pageIndex * mOnePageSize;
        }
        stopPos = startPos + mOnePageSize - 1;
        if (stopPos >= getItemCount()) {
            stopPos = getItemCount() - 1;
        }
        if (mPageListener != null) {
            mPageListener.onItemVisible(startPos, stopPos);
        }
    }

    private void layoutForSpeakerPreview(RecyclerView.Recycler recycler) {
        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = pageWidth;
        int itemHeight = pageHeight;
        View speakerView = recycler.getViewForPosition(0);
        measureChildWithMargins(speakerView, pageWidth - itemWidth, pageHeight - itemHeight);
        addView(speakerView);
        int centerVerticalMargin = (pageHeight - itemHeight) >> 1;
        int centerHorizontalMargin = (pageWidth - itemWidth) >> 1;
        layoutDecorated(speakerView, centerHorizontalMargin - mOffsetX, centerVerticalMargin,
                centerHorizontalMargin + itemWidth - mOffsetX, centerVerticalMargin + itemHeight);
    }

    private void addOrRemove(RecyclerView.Recycler recycler, Rect displayRect, int i) {
        View child = recycler.getViewForPosition(i);
        Rect rect = getItemFrameByPosition(i);
        if (!Rect.intersects(displayRect, rect)) {
            removeAndRecycleView(child, recycler);
        } else {
            addView(child);
            measureChildWithMargins(child, mWidthUsed, mHeightUsed);
            RecyclerView.LayoutParams lp = (RecyclerView.LayoutParams) child.getLayoutParams();
            layoutDecorated(child,
                    rect.left - mOffsetX + lp.leftMargin + getPaddingLeft(),
                    rect.top - mOffsetY + lp.topMargin + getPaddingTop(),
                    rect.right - mOffsetX - lp.rightMargin + getPaddingLeft(),
                    rect.bottom - mOffsetY - lp.bottomMargin + getPaddingTop());
        }
    }

    @Override
    public int scrollHorizontallyBy(int dx, RecyclerView.Recycler recycler, RecyclerView.State state) {
        int newX = mOffsetX + dx;
        int result = dx;
        if (newX > mMaxScrollX) {
            result = mMaxScrollX - mOffsetX;
        } else if (newX < 0) {
            result = 0 - mOffsetX;
        }
        mOffsetX += result;
        setPageIndex(getPageIndexByOffset());
        offsetChildrenHorizontal(-result);

        onLayoutChildren(recycler, state);
        return result;
    }

    @Override
    public int scrollVerticallyBy(int dy, RecyclerView.Recycler recycler, RecyclerView.State
            state) {
        int newY = mOffsetY + dy;
        int result = dy;
        if (newY > mMaxScrollY) {
            result = mMaxScrollY - mOffsetY;
        } else if (newY < 0) {
            result = 0 - mOffsetY;
        }
        mOffsetY += result;
        setPageIndex(getPageIndexByOffset());
        offsetChildrenVertical(-result);
        if (result > 0) {
            recycleAndFillItems(recycler, state, true);
        } else {
            recycleAndFillItems(recycler, state, false);
        }
        return result;
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        mScrollState = state;
        if (state == SCROLL_STATE_IDLE) {
            setPageIndex(getPageIndexByOffset());
        }
    }

    private boolean isScrolling() {
        return mScrollState != SCROLL_STATE_IDLE;
    }

    private int getPageByPosition(int pos) {
        if (pos == 0) {
            return 0;
        }
        if (mIsSpeakerModeOn) {
            return 1 + (pos - 1) / mOnePageSize;
        }
        return pos / mOnePageSize;
    }

    protected Rect getItemFrameByPosition(int pos) {
        int page = getPageByPosition(pos);
        int offsetX = 0;
        int offsetY = 0;
        if (canScrollHorizontally()) {
            offsetX += getUsableWidth() * page;
        } else {
            offsetY += getUsableHeight() * page;
        }

        pos -= mIsSpeakerModeOn ? 1 : 0;
        int pagePos = pos % mOnePageSize;
        int row = pagePos / mColumns;
        int col = pagePos - (row * mColumns);

        offsetX += col * mItemWidth;
        offsetY += row * mItemHeight;

        int centerHorizontalMargin =
                (getUsableWidth() - mItemWidth * mColumns - mMarginBetweenItem * (mColumns + 1)) >> 1;
        offsetX += (col + 1) * mMarginBetweenItem + centerHorizontalMargin;
        int centerVerticalMargin = (getUsableHeight() - mItemHeight * mRows - mMarginBetweenItem * (mRows + 1)) >> 1;
        offsetY += (row + 1) * mMarginBetweenItem + centerVerticalMargin;

        Rect rect = new Rect();
        rect.left = offsetX;
        rect.top = offsetY;
        rect.right = offsetX + mItemWidth;
        rect.bottom = offsetY + mItemHeight;
        return rect;
    }

    protected int getUsableWidth() {
        return getWidth() - getPaddingLeft() - getPaddingRight();
    }

    protected int getUsableHeight() {
        return getHeight() - getPaddingTop() - getPaddingBottom();
    }

    public int getTotalPageCount() {
        int itemCount = getItemCount();
        int pageCount = 0;
        if (itemCount <= 0) {
            return 1;
        }

        if (mIsSpeakerModeOn) {
            pageCount++;
            itemCount--;
        }
        pageCount += itemCount / mOnePageSize;
        pageCount += itemCount % mOnePageSize != 0 ? 1 : 0;
        return pageCount;
    }

    private int getPageIndexByPos(int pos) {
        int pageIndex;
        if (mIsSpeakerModeOn) {
            pageIndex = pos < SPEAKER_PAGE_ITEM_COUNT ? 0 :
                    (pos - SPEAKER_PAGE_ITEM_COUNT) / mOnePageSize + 1;
        } else {
            pageIndex = pos / mOnePageSize;
        }
        return pageIndex;
    }

    protected int getPageIndexByOffset() {
        int pageIndex;
        if (canScrollVertically()) {
            int pageHeight = getUsableHeight();
            if (mOffsetY <= 0 || pageHeight <= 0) {
                pageIndex = 0;
            } else {
                pageIndex = mOffsetY / pageHeight;
                if (mOffsetY % pageHeight > pageHeight / 2) {
                    pageIndex++;
                }
            }
        } else {
            int pageWidth = getUsableWidth();
            if (mOffsetX <= 0 || pageWidth <= 0) {
                pageIndex = 0;
            } else {
                pageIndex = mOffsetX / pageWidth;
                if (mOffsetX % pageWidth > pageWidth / 2) {
                    pageIndex++;
                }
            }
        }
        return pageIndex;
    }

    @Override
    public RecyclerView.LayoutParams generateDefaultLayoutParams() {
        return new RecyclerView.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    @Override
    public boolean canScrollHorizontally() {
        return mOrientation == HORIZONTAL;
    }

    @Override
    public boolean canScrollVertically() {
        return mOrientation == VERTICAL;
    }

    public int findNextPageFirstPos() {
        int nextPageIndex = mLastPageIndex + 1;
        int maxPageIndex = getTotalPageCount() - 1;
        if (nextPageIndex > maxPageIndex) {
            nextPageIndex = maxPageIndex;
        }
        int nextPageFirstPos;
        if (mIsSpeakerModeOn) {
            nextPageFirstPos = 1 + (nextPageIndex - 1) * mOnePageSize;
        } else {
            nextPageFirstPos = nextPageIndex * mOnePageSize;
        }

        return nextPageFirstPos;
    }


    public int findPrePageFirstPos() {
        int page = mLastPageIndex - 1;
        if (page < 0) {
            page = 0;
        }
        if (page == 0) {
            return 0;
        }
        int prePageFirstPost;
        if (mIsSpeakerModeOn) {
            prePageFirstPost = 1 + (page - 1) * mOnePageSize;
        } else {
            prePageFirstPost = page * mOnePageSize;
        }
        return prePageFirstPost;
    }

    @Override
    public PointF computeScrollVectorForPosition(int targetPosition) {
        PointF vector = new PointF();
        int[] pos = getSnapOffset(targetPosition);
        vector.x = pos[0];
        vector.y = pos[1];
        return vector;
    }

    public int[] getSnapOffset(int targetPosition) {
        int[] offset = new int[2];
        int[] pos = getPageLeftTopByPosition(targetPosition);
        offset[0] = pos[0] - mOffsetX;
        offset[1] = pos[1] - mOffsetY;
        return offset;
    }

    private int[] getPageLeftTopByPosition(int pos) {
        int[] leftTop = new int[2];
        int page = getPageIndexByPos(pos);
        if (canScrollHorizontally()) {
            leftTop[0] = page * getUsableWidth();
            leftTop[1] = 0;
        } else {
            leftTop[0] = 0;
            leftTop[1] = page * getUsableHeight();
        }
        return leftTop;
    }

    public View findSnapView() {
        if (null != getFocusedChild()) {
            return getFocusedChild();
        }
        if (getChildCount() <= 0) {
            return null;
        }

        int pageIndexByOffset = getPageIndexByOffset();
        int targetPos;
        if (mIsSpeakerModeOn) {
            targetPos = pageIndexByOffset == 0 ? 0 : 1 + (pageIndexByOffset - 1) * mOnePageSize;
        } else {
            targetPos = pageIndexByOffset * mOnePageSize;
        }
        for (int i = 0; i < getChildCount(); i++) {
            int childPos = getPosition(getChildAt(i));
            if (childPos == targetPos) {
                return getChildAt(i);
            }
        }
        return getChildAt(0);
    }


    protected void setPageCount(int pageCount) {
        if (pageCount >= 0) {
            if (mPageListener != null && pageCount != mLastPageCount) {
                mPageListener.onPageSizeChanged(pageCount);
            }
            mLastPageCount = pageCount;
        }
    }

    public int getCurrentPageIndex() {
        return mLastPageIndex;
    }

    protected void setPageIndex(int pageIndex) {
        if (pageIndex == mLastPageIndex) {
            return;
        }
        if (isAllowContinuousScroll() || !isScrolling()) {
            mLastPageIndex = pageIndex;
        }
        if (isScrolling()) {
            return;
        }
        if (mPageListener != null) {
            mPageListener.onPageSelect(pageIndex);
        }
    }

    @OrientationType
    public int setOrientationType(@OrientationType int orientation) {
        if (mOrientation == orientation || mScrollState != SCROLL_STATE_IDLE) {
            return mOrientation;
        }
        mOrientation = orientation;
        mItemFrames.clear();
        int x = mOffsetX;
        int y = mOffsetY;
        mOffsetX = y / getUsableHeight() * getUsableWidth();
        mOffsetY = x / getUsableWidth() * getUsableHeight();
        int mx = mMaxScrollX;
        int my = mMaxScrollY;
        mMaxScrollX = my / getUsableHeight() * getUsableWidth();
        mMaxScrollY = mx / getUsableWidth() * getUsableHeight();
        return mOrientation;
    }

    @Override
    public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state, int position) {
        int targetPageIndex = getPageIndexByPos(position);
        smoothScrollToPage(targetPageIndex);
    }

    public void smoothScrollToPage(int pageIndex) {
        if (pageIndex < 0 || pageIndex >= mLastPageCount) {
            Log.e(TAG, "pageIndex is outOfIndex, must in [0, " + mLastPageCount + ").");
            return;
        }
        if (null == mRecyclerView) {
            Log.e(TAG, "RecyclerView Not Found!");
            return;
        }

        int currentPageIndex = getPageIndexByOffset();
        if (Math.abs(pageIndex - currentPageIndex) > 3) {
            if (pageIndex > currentPageIndex) {
                scrollToPage(pageIndex - 3);
            } else if (pageIndex < currentPageIndex) {
                scrollToPage(pageIndex + 3);
            }
        }

        LinearSmoothScroller smoothScroller = new PagerGridSmoothScroller(mRecyclerView);
        int position = pageIndex * mOnePageSize;
        smoothScroller.setTargetPosition(position);
        startSmoothScroll(smoothScroller);
    }

    @Override
    public void scrollToPosition(int position) {
        int pageIndex = getPageIndexByPos(position);
        scrollToPage(pageIndex);
    }

    public void scrollToPage(int pageIndex) {
        if (pageIndex < 0 || pageIndex >= mLastPageCount) {
            Log.e(TAG, "pageIndex = " + pageIndex + " is out of bounds, mast in [0, " + mLastPageCount + ")");
            return;
        }

        if (null == mRecyclerView) {
            Log.e(TAG, "RecyclerView Not Found!");
            return;
        }

        int mTargetOffsetXBy;
        int mTargetOffsetYBy;
        if (canScrollVertically()) {
            mTargetOffsetXBy = 0;
            mTargetOffsetYBy = pageIndex * getUsableHeight() - mOffsetY;
        } else {
            mTargetOffsetXBy = pageIndex * getUsableWidth() - mOffsetX;
            mTargetOffsetYBy = 0;
        }
        mRecyclerView.scrollBy(mTargetOffsetXBy, mTargetOffsetYBy);
        setPageIndex(pageIndex);
    }

    public boolean isAllowContinuousScroll() {
        return mAllowContinuousScroll;
    }

    public void setAllowContinuousScroll(boolean allowContinuousScroll) {
        mAllowContinuousScroll = allowContinuousScroll;
    }

    protected PageListener mPageListener = null;

    public void setPageListener(PageListener pageListener) {
        mPageListener = pageListener;
    }

    public interface PageListener {

        void onPageSizeChanged(int pageSize);

        void onPageSelect(int pageIndex);

        void onItemVisible(int fromItem, int toItem);
    }
}
