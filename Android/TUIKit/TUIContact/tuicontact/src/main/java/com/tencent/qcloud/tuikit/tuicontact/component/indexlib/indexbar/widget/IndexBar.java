package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.widget;

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
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean.BaseIndexPinyinBean;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.helper.IIndexBarDataHelper;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.helper.IndexBarDataHelperImpl;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class IndexBar extends View {
    private static final String TAG = IndexBar.class.getSimpleName();

    public static String[] INDEX_STRING = {
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"};
    
    // Whether the index data source needs to be generated based on the actual data
    private boolean isNeedRealIndex;

    private List<String> mIndexDatas;

    private int mWidth;
    private int mHeight;

    private int mGapHeight;

    private Paint mPaint;

    // background color when finger is pressed
    private int mPressedBackground;

    private IIndexBarDataHelper mDataHelper;

    private TextView mPressedShowTextView;
    private boolean isSourceDatasAlreadySorted;
    private List<? extends BaseIndexPinyinBean> mSourceDatas;
    private CustomLinearLayoutManager mLayoutManager;
    private int mHeaderViewCount = 0;
    private OnIndexPressedListener mOnIndexPressedListener;

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

    private void init(Context context, AttributeSet attrs, int defStyleAttr) {
        int textSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 12, getResources().getDisplayMetrics());
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

        setOnIndexPressedListener(new OnIndexPressedListener() {
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
        int measureWidth = 0;
        int measureHeight = 0;

        Rect indexBounds = new Rect(); 
        String index; 
        for (int i = 0; i < mIndexDatas.size(); i++) {
            index = mIndexDatas.get(i);
            mPaint.getTextBounds(index, 0, index.length(), indexBounds);
            measureWidth = Math.max(indexBounds.width(), measureWidth);
            measureHeight = Math.max(indexBounds.height(), measureHeight);
        }
        int wMode = MeasureSpec.getMode(widthMeasureSpec);
        measureHeight *= mIndexDatas.size();
        int wSize = MeasureSpec.getSize(widthMeasureSpec);
        switch (wMode) {
            case MeasureSpec.EXACTLY:
                measureWidth = wSize;
                break;
            case MeasureSpec.AT_MOST:
                measureWidth = Math.min(measureWidth, wSize);
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
            default:
                break;
        }
        int hMode = MeasureSpec.getMode(heightMeasureSpec);
        int hSize = MeasureSpec.getSize(heightMeasureSpec);
        switch (hMode) {
            case MeasureSpec.EXACTLY:
                measureHeight = hSize;
                break;
            case MeasureSpec.AT_MOST:
                measureHeight = Math.min(measureHeight, hSize);
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
            default:
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
            
            // Get the FontMetrics of the brush, used to calculate the baseLine. Because the y coordinate of drawText represents the position of the baseLine of
            // the drawn text
            Paint.FontMetrics fontMetrics = mPaint.getFontMetrics();
            
            // Calculate the baseLine value centered vertically in the index area of each grid
            int baseline = (int) ((mGapHeight - fontMetrics.bottom - fontMetrics.top) / 2);
            
            // Call drawText to center the drawing index
            canvas.drawText(index, mWidth / 2 - mPaint.measureText(index) / 2, t + mGapHeight * i + baseline, mPaint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                setBackgroundColor(mPressedBackground);
                onTouchMove(event);
                break;
            case MotionEvent.ACTION_MOVE:
                onTouchMove(event);
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

    private void onTouchMove(MotionEvent event) {

        float y = event.getY();
        
        // Determine which area the landing point is in by calculating:
        int pressI = (int) ((y - getPaddingTop()) / mGapHeight);
        
        // Boundary processing (when the finger moves, it may have moved out of the boundary to prevent crossing the boundary)
        if (pressI < 0) {
            pressI = 0;
        } else if (pressI >= mIndexDatas.size()) {
            pressI = mIndexDatas.size() - 1;
        }

        if (null != mOnIndexPressedListener && pressI > -1 && pressI < mIndexDatas.size()) {
            mOnIndexPressedListener.onIndexPressed(pressI, mIndexDatas.get(pressI));
        }
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

    public OnIndexPressedListener getOnIndexPressedListener() {
        return mOnIndexPressedListener;
    }

    public void setOnIndexPressedListener(OnIndexPressedListener mOnIndexPressedListener) {
        this.mOnIndexPressedListener = mOnIndexPressedListener;
    }

    /**
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
        // sortData();
    }

    /**
     * Called when:
     * 1 change in data source
     * 2 When the control size changes
     * Calculate gapHeight
     */
    private void computeGapHeight() {
        mGapHeight = (mHeight - getPaddingTop() - getPaddingBottom()) / mIndexDatas.size();
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

    public interface OnIndexPressedListener {
        void onIndexPressed(int index, String text);

        void onMotionEventEnd();
    }
}
