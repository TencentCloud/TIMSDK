package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.bean.BaseIndexPinyinBean;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.helper.IIndexBarDataHelper;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.helper.IndexBarDataHelperImpl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class IndexBar extends View {
    private static final String TAG = IndexBar.class.getSimpleName();

    public static String[] INDEX_STRING = {"A", "B", "C", "D", "E", "F", "G", "H", "I",
            "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
            "W", "X", "Y", "Z", "#"};
    // 是否需要根据实际的数据来生成索引数据源（例如 只有 A B C 三种tag，那么索引栏就 A B C 三项）
    // Whether the index data source needs to be generated based on the actual data
    private boolean isNeedRealIndex;

    private List<String> mIndexDatas;

    private int mWidth, mHeight;

    private int mGapHeight;

    private Paint mPaint;

    // 手指按下时的背景色
    // background color when finger is pressed
    private int mPressedBackground;

    private IIndexBarDataHelper mDataHelper;

    //以下边变量是外部set进来的  // The following side variables are imported from external set
    private TextView mPressedShowTextView;// 用于特写显示正在被触摸的index值 // Used to close-up display the index value that is being touched
    private boolean isSourceDatasAlreadySorted;
    private List<? extends BaseIndexPinyinBean> mSourceDatas;
    private CustomLinearLayoutManager mLayoutManager;
    private int mHeaderViewCount = 0;
    private onIndexPressedListener mOnIndexPressedListener;

    public IndexBar(Context context) {
        this(context, null);
    }

    public IndexBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public IndexBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs, defStyleAttr);
    }

    public int getHeaderViewCount() {
        return mHeaderViewCount;
    }

    public IndexBar setHeaderViewCount(int headerViewCount) {
        mHeaderViewCount = headerViewCount;
        return this;
    }

    public boolean isSourceDatasAlreadySorted() {
        return isSourceDatasAlreadySorted;
    }

    public IndexBar setSourceDatasAlreadySorted(boolean sourceDatasAlreadySorted) {
        isSourceDatasAlreadySorted = sourceDatasAlreadySorted;
        return this;
    }

    public IIndexBarDataHelper getDataHelper() {
        return mDataHelper;
    }

    public IndexBar setDataHelper(IIndexBarDataHelper dataHelper) {
        mDataHelper = dataHelper;
        return this;
    }

    private void init(Context context, AttributeSet attrs, int defStyleAttr) {
        int textSize = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP, 12, getResources().getDisplayMetrics());
        mPressedBackground = Color.BLACK;
        TypedArray typedArray = context.getTheme().obtainStyledAttributes(attrs, R.styleable.IndexBar, defStyleAttr, 0);
        int n = typedArray.getIndexCount();
        for (int i = 0; i < n; i++) {
            int attr = typedArray.getIndex(i);
            if (attr == R.styleable.IndexBar_indexBarTextSize) {
                textSize = typedArray.getDimensionPixelSize(attr, textSize);
            } else if (attr == R.styleable.IndexBar_indexBarPressBackground) {
                mPressedBackground = typedArray.getColor(attr, mPressedBackground);
            }
        }
        typedArray.recycle();

        initIndexDatas();


        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setTextSize(textSize);
        mPaint.setColor(0xff888888);

        setOnIndexPressedListener(new onIndexPressedListener() {
            @Override
            public void onIndexPressed(int index, String text) {
                if (mPressedShowTextView != null) {
                    mPressedShowTextView.setVisibility(View.VISIBLE);
                    mPressedShowTextView.setText(text);
                }

                if (mLayoutManager != null) {
                    int position = getPosByTag(text);
                    if (position != -1) {
                        mLayoutManager.scrollToPositionWithOffset(position, 0);
                    }
                }
            }

            @Override
            public void onMotionEventEnd() {
                if (mPressedShowTextView != null) {
                    mPressedShowTextView.setVisibility(View.GONE);
                }
            }
        });

        mDataHelper = new IndexBarDataHelperImpl();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int wMode = MeasureSpec.getMode(widthMeasureSpec);
        int wSize = MeasureSpec.getSize(widthMeasureSpec);
        int hMode = MeasureSpec.getMode(heightMeasureSpec);
        int hSize = MeasureSpec.getSize(heightMeasureSpec);
        int measureWidth = 0, measureHeight = 0;

        Rect indexBounds = new Rect();// 存放每个绘制的index的Rect区域 // The Rect area that stores each drawn index 
        String index;// 每个要绘制的index内容 // Each index content to be drawn
        for (int i = 0; i < mIndexDatas.size(); i++) {
            index = mIndexDatas.get(i);
            mPaint.getTextBounds(index, 0, index.length(), indexBounds);
            measureWidth = Math.max(indexBounds.width(), measureWidth);
            measureHeight = Math.max(indexBounds.height(), measureHeight);
        }
        measureHeight *= mIndexDatas.size();
        switch (wMode) {
            case MeasureSpec.EXACTLY:
                measureWidth = wSize;
                break;
            case MeasureSpec.AT_MOST:
                measureWidth = Math.min(measureWidth, wSize);
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
        }

        switch (hMode) {
            case MeasureSpec.EXACTLY:
                measureHeight = hSize;
                break;
            case MeasureSpec.AT_MOST:
                measureHeight = Math.min(measureHeight, hSize);
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
        }

        setMeasuredDimension(measureWidth, measureHeight);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int t = getPaddingTop();
        String index;
        for (int i = 0; i < mIndexDatas.size(); i++) {
            index = mIndexDatas.get(i);
            // 获得画笔的FontMetrics，用来计算baseLine。因为drawText的y坐标，代表的是绘制的文字的baseLine的位置
            // Get the FontMetrics of the brush, used to calculate the baseLine. Because the y coordinate of drawText represents the position of the baseLine of the drawn text
            Paint.FontMetrics fontMetrics = mPaint.getFontMetrics();
            // 计算出在每格index区域，竖直居中的baseLine值
            // Calculate the baseLine value centered vertically in the index area of each grid
            int baseline = (int) ((mGapHeight - fontMetrics.bottom - fontMetrics.top) / 2);
            // 调用drawText，居中显示绘制index
            // Call drawText to center the drawing index
            canvas.drawText(index, mWidth / 2 - mPaint.measureText(index) / 2, t + mGapHeight * i + baseline, mPaint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                setBackgroundColor(mPressedBackground);
                // 注意这里没有break，因为down时，也要计算落点 回调监听器
                // Note that there is no break here, because when down, the drop point is also calculated. Callback listener
            case MotionEvent.ACTION_MOVE:
                float y = event.getY();
                // 通过计算判断落点在哪个区域：
                // Determine which area the landing point is in by calculating:
                int pressI = (int) ((y - getPaddingTop()) / mGapHeight);
                // 边界处理（在手指move时，有可能已经移出边界，防止越界）
                // Boundary processing (when the finger moves, it may have moved out of the boundary to prevent crossing the boundary)
                if (pressI < 0) {
                    pressI = 0;
                } else if (pressI >= mIndexDatas.size()) {
                    pressI = mIndexDatas.size() - 1;
                }

                if (null != mOnIndexPressedListener && pressI > -1 && pressI < mIndexDatas.size()) {
                    mOnIndexPressedListener.onIndexPressed(pressI, mIndexDatas.get(pressI));
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
            default:
                setBackgroundResource(android.R.color.transparent);

                if (null != mOnIndexPressedListener) {
                    mOnIndexPressedListener.onMotionEventEnd();
                }
                break;
        }
        return true;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mWidth = w;
        mHeight = h;

        if (null == mIndexDatas || mIndexDatas.isEmpty()) {
            return;
        }
        computeGapHeight();
    }

    public onIndexPressedListener getOnIndexPressedListener() {
        return mOnIndexPressedListener;
    }

    public void setOnIndexPressedListener(onIndexPressedListener mOnIndexPressedListener) {
        this.mOnIndexPressedListener = mOnIndexPressedListener;
    }

    /**
     * 显示当前被按下的index的TextView
     * 
     * Displays the TextView of the currently pressed index
     *
     * @return
     */
    public IndexBar setPressedShowTextView(TextView mPressedShowTextView) {
        this.mPressedShowTextView = mPressedShowTextView;
        return this;
    }

    public IndexBar setLayoutManager(CustomLinearLayoutManager mLayoutManager) {
        this.mLayoutManager = mLayoutManager;
        return this;
    }

    /**
     * 一定要在设置数据源{@link #setSourceDatas(List)}之前调用
     * 
     * Be sure to call before setting the data source {@link #setSourceDatas(List)}
     *
     * @param needRealIndex
     * @return
     */
    public IndexBar setNeedRealIndex(boolean needRealIndex) {
        isNeedRealIndex = needRealIndex;
        initIndexDatas();
        return this;
    }

    private void initIndexDatas() {
        if (isNeedRealIndex) {
            mIndexDatas = new ArrayList<>();
        } else {
            mIndexDatas = Arrays.asList(INDEX_STRING);
        }
    }

    public IndexBar setSourceDatas(List<? extends BaseIndexPinyinBean> mSourceDatas) {
        this.mSourceDatas = mSourceDatas;
        initSourceDatas();
        return this;
    }

    /**
     * 初始化原始数据源，并取出索引数据源
     * 
     * Initialize the original data source and take out the index data source
     *
     * @return
     */
    private void initSourceDatas() {
        if (null == mSourceDatas || mSourceDatas.isEmpty()) {
            return;
        }
        if (!isSourceDatasAlreadySorted) {
            mDataHelper.sortSourceDatas(mSourceDatas);
        } else {
            mDataHelper.convert(mSourceDatas);
            mDataHelper.fillInexTag(mSourceDatas);
        }
        if (isNeedRealIndex) {
            mDataHelper.getSortedIndexDatas(mSourceDatas, mIndexDatas);
            computeGapHeight();
        }
        //sortData();
    }

    /**
     * 以下情况调用：
     * 1 在数据源改变
     * 2 控件size改变时
     * 计算gapHeight
     * 
     * 
     * Called when:
     * 1 change in data source
     * 2 When the control size changes
     * Calculate gapHeight
     */
    private void computeGapHeight() {
        mGapHeight = (mHeight - getPaddingTop() - getPaddingBottom()) / mIndexDatas.size();
    }


    private void sortData() {

    }

    private int getPosByTag(String tag) {
        if (null == mSourceDatas || mSourceDatas.isEmpty()) {
            return -1;
        }
        if (TextUtils.isEmpty(tag)) {
            return -1;
        }
        for (int i = 0; i < mSourceDatas.size(); i++) {
            if (tag.equals(mSourceDatas.get(i).getBaseIndexTag())) {
                return i + getHeaderViewCount();
            }
        }
        return -1;
    }

    public interface onIndexPressedListener {
        void onIndexPressed(int index, String text);//当某个Index被按下 // When an Index is pressed

        void onMotionEventEnd();//当触摸事件结束（UP CANCEL） // When the touch event ends (UP CANCEL)
    }

}
