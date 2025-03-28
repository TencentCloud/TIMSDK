package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.layout;

import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.constant.Constants;

public class LandscapePageLayoutManager extends PageLayoutManager {
    private static final int MAX_ROW_SHOW  = 2;
    private static final int MAX_LINE_SHOW = 3;

    public LandscapePageLayoutManager() {
        super(MAX_ROW_SHOW, MAX_LINE_SHOW, HORIZONTAL);
    }

    @Override
    public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
        if (state.isPreLayout() || getUsableWidth() == 0) {
            return;
        }
        mMaxScrollX = (getTotalPageCount() - 1) * getUsableWidth();
        mMaxScrollY = 0;
        if (mOffsetX > mMaxScrollX) {
            mOffsetX = mMaxScrollX;
        }

        if (mIsSpeakerModeOn) {
            layoutForSpeakerMode(recycler, state);
        } else if (mIsTwoPersonVideoOn) {
            layoutForTwoPersonVideoMeeting(recycler);
        } else {
            layoutForGridMod(recycler, state);
        }
        setPageCount(getTotalPageCount());
        setPageIndex(getPageIndexByOffset());
    }


    private void layoutForSpeakerMode(RecyclerView.Recycler recycler, RecyclerView.State state) {
        int pageIndexByOffset = getPageIndexByOffset();
        if (pageIndexByOffset == 0) {
            layoutForSpeakerPage(recycler);
        } else {
            layoutWithSixGrid(recycler, state);
        }
    }

    private void layoutForSpeakerPage(RecyclerView.Recycler recycler) {
        detachAndScrapAttachedViews(recycler);

        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = pageWidth;
        int itemHeight = pageHeight;
        View speakerView = recycler.getViewForPosition(0);
        measureChildWithMargins(speakerView, pageWidth - itemWidth, pageHeight - itemHeight);
        addView(speakerView);
        int centerHorizontalMargin = (pageWidth - itemWidth) >> 1;
        int centerVerticalMargin = (pageHeight - itemHeight) >> 1;
        layoutDecorated(speakerView, centerHorizontalMargin - mOffsetX, centerVerticalMargin,
                centerHorizontalMargin + itemWidth - mOffsetX, centerVerticalMargin + itemHeight);

        mItemWidth = (getUsableHeight() - (mRows + 1) * mMarginBetweenItem) / mRows;
        mItemHeight = mItemWidth;
        mWidthUsed = getUsableWidth() - mItemWidth;
        mHeightUsed = getUsableHeight() - mItemHeight;
        int itemCount = getItemCount();
        int previewPageItemCount = Math.min(itemCount - 1, mOnePageSize);
        for (int i = 1; i <= previewPageItemCount; i++) {
            Rect rect = getItemFrameByPosition(i);
            View child = recycler.getViewForPosition(i);

            addView(child);
            measureChildWithMargins(child, mWidthUsed, mHeightUsed);
            RecyclerView.LayoutParams lp = (RecyclerView.LayoutParams) child.getLayoutParams();
            layoutDecorated(child, rect.left - mOffsetX + lp.leftMargin + getPaddingLeft(),
                    rect.top - mOffsetY + lp.topMargin + getPaddingTop(),
                    rect.right - mOffsetX - lp.rightMargin + getPaddingLeft(),
                    rect.bottom - mOffsetY - lp.bottomMargin + getPaddingTop());
        }

        if (mPageListener != null) {
            mPageListener.onItemVisible(0, 0);
        }
    }

    private void layoutForTwoPersonVideoMeeting(RecyclerView.Recycler recycler) {
        int size = mRecyclerView.getAdapter().getItemCount();
        if (size != Constants.TWO_PERSON_VIDEO_CONFERENCE_MEMBER_COUNT) {
            return;
        }
        detachAndScrapAttachedViews(recycler);

        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = pageWidth;
        int itemHeight = pageHeight;
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;
        int centerVerticalTop = (pageHeight - itemHeight) >> 1;
        int centerHorizontalLeft = (pageWidth - itemWidth) >> 1;

        View showView = mIsTwoPersonSwitched ? recycler.getViewForPosition(1) : recycler.getViewForPosition(0);
        measureChildWithMargins(showView, widthUsed, heightUsed);
        addView(showView);
        layoutDecorated(showView, centerHorizontalLeft, centerVerticalTop, centerHorizontalLeft + itemWidth,
                centerVerticalTop + itemHeight);

        if (mPageListener != null) {
            int start = 0;
            int stop = 1;
            if (mIsTwoPersonVideoOn) {
                if (mIsTwoPersonSwitched) {
                    start = stop;
                } else {
                    stop = start;
                }
            }
            mPageListener.onItemVisible(start, stop);
        }
    }

    private void layoutForGridMod(RecyclerView.Recycler recycler, RecyclerView.State state) {
        int itemCount = mRecyclerView.getAdapter().getItemCount();
        switch (itemCount) {
            case 0:
                layoutForNoItem(recycler);
                break;
            case 1:
                layoutWithOneItem(recycler);
                break;
            case 2:
            case 3:
                layoutWithOneRow(recycler);
                break;
            case 4:
            case 5:
                layoutWithTwoRow(recycler);
                break;
            default:
                layoutWithSixGrid(recycler, state);
                break;
        }
    }

    private void layoutForNoItem(RecyclerView.Recycler recycler) {
        removeAndRecycleAllViews(recycler);
        if (mPageListener != null) {
            mPageListener.onItemVisible(-1, -1);
        }
    }

    private void layoutWithOneItem(RecyclerView.Recycler recycler) {
        detachAndScrapAttachedViews(recycler);

        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = pageWidth;
        int itemHeight = pageHeight;
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;
        int centerVerticalTop = (pageHeight - itemHeight) >> 1;
        int centerHorizontalLeft = (pageWidth - itemWidth) >> 1;

        View scrap = recycler.getViewForPosition(0);
        measureChildWithMargins(scrap, widthUsed, heightUsed);
        addView(scrap);
        layoutDecorated(scrap, centerHorizontalLeft, centerVerticalTop, centerHorizontalLeft + itemWidth,
                centerVerticalTop + itemHeight);

        if (mPageListener != null) {
            mPageListener.onItemVisible(0, 0);
        }
    }

    private void layoutWithOneRow(RecyclerView.Recycler recycler) {
        int size = mRecyclerView.getAdapter().getItemCount();
        if (size < 1 || size > 3) {
            return;
        }
        detachAndScrapAttachedViews(recycler);

        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = mViewSizeMiddle;
        int itemHeight = itemWidth;
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;
        int centerVerticalTop = (pageHeight - itemHeight) >> 1;
        int centerHorizontalLeft = (pageWidth - itemWidth * size - mMarginBetweenItem * (size + 1)) >> 1;

        View scrap;
        int layoutLeft;
        for (int i = 0; i < size; i++) {
            scrap = recycler.getViewForPosition(i);
            measureChildWithMargins(scrap, widthUsed, heightUsed);
            addView(scrap);
            layoutLeft = centerHorizontalLeft + i * itemWidth + (i + 1) * mMarginBetweenItem;
            layoutDecorated(scrap, layoutLeft, centerVerticalTop, layoutLeft + itemWidth,
                    centerVerticalTop + itemHeight);
        }

        if (mPageListener != null) {
            mPageListener.onItemVisible(0, size - 1);
        }
    }

    private void layoutWithTwoRow(RecyclerView.Recycler recycler) {
        int size = mRecyclerView.getAdapter().getItemCount();
        if (size < 4 || size > 6) {
            return;
        }
        detachAndScrapAttachedViews(recycler);

        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = (getUsableHeight() - (mRows + 1) * mMarginBetweenItem) / mRows;
        int itemHeight = itemWidth;
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;
        int centerVerticalTop = (pageHeight - itemHeight * 2 - mMarginBetweenItem * 3) >> 1;

        View scrap;
        int centerHorizontalLeft;
        int layoutLeft;
        int layoutTop;
        for (int i = 0; i < size; i++) {
            scrap = recycler.getViewForPosition(i);
            measureChildWithMargins(scrap, widthUsed, heightUsed);
            addView(scrap);
            if (i < 3) {
                centerHorizontalLeft =
                        (pageWidth - itemWidth * MAX_LINE_SHOW - mMarginBetweenItem * (MAX_LINE_SHOW + 1)) >> 1;
            } else {
                int rowTowItemNum = size - MAX_LINE_SHOW;
                centerHorizontalLeft =
                        (pageWidth - itemWidth * rowTowItemNum - mMarginBetweenItem * (rowTowItemNum + 1)) >> 1;
            }

            int line = i % MAX_LINE_SHOW;
            layoutLeft = centerHorizontalLeft + line * itemWidth + (line + 1) * mMarginBetweenItem;
            int row = i / MAX_LINE_SHOW;
            layoutTop = centerVerticalTop + row * itemHeight + (row + 1) * mMarginBetweenItem;
            layoutDecorated(scrap, layoutLeft, layoutTop, layoutLeft + itemWidth, layoutTop + itemHeight);
        }

        if (mPageListener != null) {
            mPageListener.onItemVisible(0, size - 1);
        }
    }

    private void layoutWithSixGrid(RecyclerView.Recycler recycler, RecyclerView.State state) {
        mItemWidth = (getUsableHeight() - (mRows + 1) * mMarginBetweenItem) / mRows;
        mItemHeight = mItemWidth;
        mWidthUsed = getUsableWidth() - mItemWidth;
        mHeightUsed = getUsableHeight() - mItemHeight;

        recycleAndFillItems(recycler, state, true);
    }
}
