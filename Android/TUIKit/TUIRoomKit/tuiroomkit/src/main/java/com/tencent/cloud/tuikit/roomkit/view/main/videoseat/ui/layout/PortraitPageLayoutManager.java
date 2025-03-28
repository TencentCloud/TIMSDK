package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.layout;

import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.ScreenUtil;

public class PortraitPageLayoutManager extends PageLayoutManager {
    private static final int MAX_ROW_SHOW  = 3;
    private static final int MAX_LINE_SHOW = 2;

    public PortraitPageLayoutManager() {
        super(MAX_ROW_SHOW, MAX_LINE_SHOW, PageLayoutManager.HORIZONTAL);
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
        int centerVerticalMargin = (pageHeight - itemHeight) >> 1;
        layoutDecorated(speakerView, -mOffsetX, centerVerticalMargin, itemWidth - mOffsetX,
                centerVerticalMargin + itemHeight);

        mItemWidth = (getUsableWidth() - (mColumns + 1) * mMarginBetweenItem) / mColumns;
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

    private void layoutForGridMod(RecyclerView.Recycler recycler, RecyclerView.State state) {
        int itemCount = mRecyclerView.getAdapter().getItemCount();
        switch (itemCount) {
            case 0:
                layoutForNoItem(recycler);
                break;
            case 1:
                layoutForOneItem(recycler);
                break;
            case 2:
                layoutForTwoItem(recycler);
                break;
            case 3:
            case 4:
            case 5:
                layoutWithGrid(recycler);
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

    private void layoutForOneItem(RecyclerView.Recycler recycler) {
        detachAndScrapAttachedViews(recycler);
        View scrap = recycler.getViewForPosition(0);
        measureChildWithMargins(scrap, 0, 0);
        addView(scrap);
        layoutDecorated(scrap, 0, 0, getUsableWidth(), getUsableHeight());
        if (mPageListener != null) {
            mPageListener.onItemVisible(0, 0);
        }
    }

    private void layoutForTwoItem(RecyclerView.Recycler recycler) {
        detachAndScrapAttachedViews(recycler);

        if (mIsTwoPersonVideoOn) {
            View showView = mIsTwoPersonSwitched ? recycler.getViewForPosition(1) : recycler.getViewForPosition(0);
            layoutForTwoPersonVideoMeeting(showView);
        } else {
            View firstView = recycler.getViewForPosition(0);
            View secondView = recycler.getViewForPosition(1);
            layoutForTwoItemPureAudio(firstView, secondView);
        }

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

    private void layoutForTwoPersonVideoMeeting(View showView) {
        measureChildWithMargins(showView, 0, 0);
        addView(showView);
        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        layoutDecorated(showView, 0, 0, pageWidth, pageHeight);
    }

    private void layoutForTwoItemPureAudio(View firstView, View secondView) {
        int itemWidth = ScreenUtil.dip2px(120);
        int itemHeight = itemWidth;
        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;

        measureChildWithMargins(firstView, widthUsed, heightUsed);
        addView(firstView);
        int localLayoutLeft = (pageWidth - (itemWidth << 1) - mMarginBetweenItem) >> 1;
        int localLayoutTop = (pageHeight - itemHeight) >> 1;
        layoutDecorated(firstView, localLayoutLeft, localLayoutTop, localLayoutLeft + itemWidth,
                localLayoutTop + itemHeight);

        measureChildWithMargins(secondView, widthUsed, heightUsed);
        addView(secondView);
        int remoteLayoutLeft = localLayoutLeft + itemWidth + mMarginBetweenItem;
        layoutDecorated(secondView, remoteLayoutLeft, localLayoutTop, remoteLayoutLeft + itemWidth,
                localLayoutTop + itemHeight);
    }

    private void layoutWithGrid(RecyclerView.Recycler recycler) {
        int size = mRecyclerView.getAdapter().getItemCount();
        int pageWidth = getUsableWidth();
        int pageHeight = getUsableHeight();
        int itemWidth = (pageWidth - mMarginBetweenItem * 3) >> 1;
        int itemHeight = itemWidth;
        int widthUsed = pageWidth - itemWidth;
        int heightUsed = pageHeight - itemHeight;
        int totalRow = size / MAX_LINE_SHOW + ((size % MAX_LINE_SHOW == 0) ? 0 : 1);
        int centerVerticalMargin = (pageHeight - itemHeight * totalRow - mMarginBetweenItem * (totalRow + 1)) >> 1;

        detachAndScrapAttachedViews(recycler);

        int row;
        int line;
        int layoutLeft;
        int layoutTop;
        View scrap;
        for (int i = 0; i < size; i++) {
            row = i / MAX_LINE_SHOW;
            line = i % MAX_LINE_SHOW;
            scrap = recycler.getViewForPosition(i);
            measureChildWithMargins(scrap, widthUsed, heightUsed);
            addView(scrap);
            if (i == (size - 1) && line == 0) {
                layoutLeft = (pageWidth - itemWidth) >> 1;
            } else {
                layoutLeft = itemWidth * line + mMarginBetweenItem * (line + 1);
            }
            layoutTop = centerVerticalMargin + itemHeight * row + mMarginBetweenItem * (row + 1);
            layoutDecorated(scrap, layoutLeft, layoutTop, layoutLeft + itemWidth, layoutTop + itemHeight);
        }

        if (mPageListener != null) {
            mPageListener.onItemVisible(0, size - 1);
        }
    }

    private void layoutWithSixGrid(RecyclerView.Recycler recycler, RecyclerView.State state) {
        mItemWidth = (getUsableWidth() - (mColumns + 1) * mMarginBetweenItem) / mColumns;
        mItemHeight = mItemWidth;
        mWidthUsed = getUsableWidth() - mItemWidth;
        mHeightUsed = getUsableHeight() - mItemHeight;

        recycleAndFillItems(recycler, state, true);
    }
}
