package com.tencent.qcloud.tim.uikit.component.indexlib.suspension;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.TypedValue;
import android.view.View;

import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.List;

/**
 * 介绍：分类、悬停的Decoration
 */

public class SuspensionDecoration extends RecyclerView.ItemDecoration {

    private static final String TAG = SuspensionDecoration.class.getSimpleName();

    private List<? extends ISuspensionInterface> mDatas;
    private Paint mPaint;
    private Rect mBounds;//用于存放测量文字Rect

    private int mTitleHeight;//title的高
    private static int COLOR_TITLE_BG = Color.parseColor("#EDEDED");
    private static int COLOR_TITLE_FONT = Color.parseColor("#FF999999");
    private static int mTitleFontSize;//title字体大小

    private int mHeaderViewCount = 0;


    public SuspensionDecoration(Context context, List<? extends ISuspensionInterface> datas) {
        super();
        mDatas = datas;
        mPaint = new Paint();
        mBounds = new Rect();
        mTitleHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, context.getResources().getDisplayMetrics());
        mTitleFontSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 12, context.getResources().getDisplayMetrics());
        mPaint.setTextSize(mTitleFontSize);
        mPaint.setAntiAlias(true);
    }


    public SuspensionDecoration setTitleHeight(int mTitleHeight) {
        this.mTitleHeight = mTitleHeight;
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
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child
                    .getLayoutParams();
            int position = params.getViewLayoutPosition();
            position -= getHeaderViewCount();
            //pos为1，size为1，1>0? true
            if (mDatas == null || mDatas.isEmpty() || position > mDatas.size() - 1 || position < 0 || !mDatas.get(position).isShowSuspension()) {
                continue;//越界
            }
            //我记得Rv的item position在重置时可能为-1.保险点判断一下吧
            if (position > -1) {
                if (position == 0) {//等于0肯定要有title的
                    drawTitleArea(c, left, right, child, params, position);

                } else {//其他的通过判断
                    if (null != mDatas.get(position).getSuspensionTag() && !mDatas.get(position).getSuspensionTag().equals(mDatas.get(position - 1).getSuspensionTag())) {
                        //不为空 且跟前一个tag不一样了，说明是新的分类，也要title
                        drawTitleArea(c, left, right, child, params, position);
                    } else {
                        //none
                    }
                }
            }
        }
    }

    /**
     * 绘制Title区域背景和文字的方法
     *
     * @param c
     * @param left
     * @param right
     * @param child
     * @param params
     * @param position
     */
    private void drawTitleArea(Canvas c, int left, int right, View child, RecyclerView.LayoutParams params, int position) {//最先调用，绘制在最下层
        mPaint.setColor(COLOR_TITLE_BG);
        c.drawRect(left, child.getTop() - params.topMargin - mTitleHeight, right, child.getTop() - params.topMargin, mPaint);
        mPaint.setColor(COLOR_TITLE_FONT);

        mPaint.getTextBounds(mDatas.get(position).getSuspensionTag(), 0, mDatas.get(position).getSuspensionTag().length(), mBounds);
        c.drawText(mDatas.get(position).getSuspensionTag(), child.getPaddingLeft() + 40, child.getTop() - params.topMargin - (mTitleHeight / 2 - mBounds.height() / 2), mPaint);
    }

    @Override
    public void onDrawOver(Canvas c, final RecyclerView parent, RecyclerView.State state) {//最后调用 绘制在最上层
        int pos = ((LinearLayoutManager) (parent.getLayoutManager())).findFirstVisibleItemPosition();
        pos -= getHeaderViewCount();
        //pos为1，size为1，1>0? true
        if (mDatas == null || mDatas.isEmpty() || pos > mDatas.size() - 1 || pos < 0 || !mDatas.get(pos).isShowSuspension()) {
            return;//越界
        }

        String tag = mDatas.get(pos).getSuspensionTag();
        //View child = parent.getChildAt(pos);
        View child = parent.findViewHolderForLayoutPosition(pos + getHeaderViewCount()).itemView;//出现一个奇怪的bug，有时候child为空，所以将 child = parent.getChildAt(i)。-》 parent.findViewHolderForLayoutPosition(pos).itemView

        boolean flag = false;//定义一个flag，Canvas是否位移过的标志
        if ((pos + 1) < mDatas.size()) {//防止数组越界（一般情况不会出现）
            if (null != tag && !tag.equals(mDatas.get(pos + 1).getSuspensionTag())) {//当前第一个可见的Item的tag，不等于其后一个item的tag，说明悬浮的View要切换了
//                TUIKitLog.d(TAG, "onDrawOver() called with: c = [" + child.getTop());//当getTop开始变负，它的绝对值，是第一个可见的Item移出屏幕的距离，
                if (child.getHeight() + child.getTop() < mTitleHeight) {//当第一个可见的item在屏幕中还剩的高度小于title区域的高度时，我们也该开始做悬浮Title的“交换动画”
                    c.save();//每次绘制前 保存当前Canvas状态，
                    flag = true;

                    //一种头部折叠起来的视效，个人觉得也还不错~
                    //可与123行 c.drawRect 比较，只有bottom参数不一样，由于 child.getHeight() + child.getTop() < mTitleHeight，所以绘制区域是在不断的减小，有种折叠起来的感觉
                    //c.clipRect(parent.getPaddingLeft(), parent.getPaddingTop(), parent.getRight() - parent.getPaddingRight(), parent.getPaddingTop() + child.getHeight() + child.getTop());

                    //类似饿了么点餐时,商品列表的悬停头部切换“动画效果”
                    //上滑时，将canvas上移 （y为负数） ,所以后面canvas 画出来的Rect和Text都上移了，有种切换的“动画”感觉
                    c.translate(0, child.getHeight() + child.getTop() - mTitleHeight);
                }
            }
        }
        mPaint.setColor(COLOR_TITLE_BG);
        c.drawRect(parent.getPaddingLeft(), parent.getPaddingTop(), parent.getRight() - parent.getPaddingRight(), parent.getPaddingTop() + mTitleHeight, mPaint);
        mPaint.setColor(COLOR_TITLE_FONT);
        mPaint.getTextBounds(tag, 0, tag.length(), mBounds);
        c.drawText(tag, child.getPaddingLeft() + 40,
                parent.getPaddingTop() + mTitleHeight - (mTitleHeight / 2 - mBounds.height() / 2),
                mPaint);
        if (flag)
            c.restore();//恢复画布到之前保存的状态
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        //super里会先设置0 0 0 0
        super.getItemOffsets(outRect, view, parent, state);
        int position = ((RecyclerView.LayoutParams) view.getLayoutParams()).getViewLayoutPosition();
        position -= getHeaderViewCount();
        if (mDatas == null || mDatas.isEmpty() || position > mDatas.size() - 1) {//pos为1，size为1，1>0? true
            return;//越界
        }
        //我记得Rv的item position在重置时可能为-1.保险点判断一下吧
        if (position > -1) {
            ISuspensionInterface titleCategoryInterface = mDatas.get(position);
            //等于0肯定要有title的,
            // 2016 11 07 add 考虑到headerView 等于0 也不应该有title
            // 2016 11 10 add 通过接口里的isShowSuspension() 方法，先过滤掉不想显示悬停的item
            if (titleCategoryInterface.isShowSuspension()) {
                if (position == 0) {
                    outRect.set(0, mTitleHeight, 0, 0);
                } else {//其他的通过判断
                    if (null != titleCategoryInterface.getSuspensionTag() && !titleCategoryInterface.getSuspensionTag().equals(mDatas.get(position - 1).getSuspensionTag())) {
                        //不为空 且跟前一个tag不一样了，说明是新的分类，也要title
                        outRect.set(0, mTitleHeight, 0, 0);
                    }
                }
            }
        }
    }

}
