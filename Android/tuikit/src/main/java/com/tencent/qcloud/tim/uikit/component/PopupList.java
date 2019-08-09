package com.tencent.qcloud.tim.uikit.component;

import android.app.Activity;
import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import java.util.List;

/**
 * This utility class can show a edit menu easily
 */
public class PopupList {

    public static final int DEFAULT_NORMAL_TEXT_COLOR = Color.WHITE;
    public static final int DEFAULT_PRESSED_TEXT_COLOR = Color.WHITE;
    public static final float DEFAULT_TEXT_SIZE_DP = 14;
    public static final float DEFAULT_TEXT_PADDING_LEFT_DP = 10.0f;
    public static final float DEFAULT_TEXT_PADDING_TOP_DP = 5.0f;
    public static final float DEFAULT_TEXT_PADDING_RIGHT_DP = 10.0f;
    public static final float DEFAULT_TEXT_PADDING_BOTTOM_DP = 5.0f;
    public static final int DEFAULT_NORMAL_BACKGROUND_COLOR = 0xCC000000;
    public static final int DEFAULT_PRESSED_BACKGROUND_COLOR = 0xE7777777;
    public static final int DEFAULT_BACKGROUND_RADIUS_DP = 8;
    public static final int DEFAULT_DIVIDER_COLOR = 0x9AFFFFFF;
    public static final float DEFAULT_DIVIDER_WIDTH_DP = 0.5f;
    public static final float DEFAULT_DIVIDER_HEIGHT_DP = 40.0f;

    private Context mContext;
    private PopupWindow mPopupWindow;
    private View mAnchorView;
    private View mAdapterView;
    private View mContextView;
    private View mIndicatorView;
    private List<String> mPopupItemList;
    private PopupListListener mPopupListListener;
    private int mContextPosition;
    private float mOffsetX;
    private float mOffsetY;
    private StateListDrawable mLeftItemBackground;
    private StateListDrawable mRightItemBackground;
    private StateListDrawable mCornerItemBackground;
    private ColorStateList mTextColorStateList;
    private GradientDrawable mCornerBackground;
    private int mIndicatorWidth;
    private int mIndicatorHeight;
    private int mPopupWindowWidth;
    private int mPopupWindowHeight;
    private int mNormalTextColor;
    private int mPressedTextColor;
    private float mTextSize;
    private int mTextPaddingLeft;
    private int mTextPaddingTop;
    private int mTextPaddingRight;
    private int mTextPaddingBottom;
    private int mNormalBackgroundColor;
    private int mPressedBackgroundColor;
    private int mBackgroundCornerRadius;
    private int mDividerColor;
    private int mDividerWidth;
    private int mDividerHeight;

    public PopupList(Context context) {
        this.mContext = context;
        this.mNormalTextColor = DEFAULT_NORMAL_TEXT_COLOR;
        this.mPressedTextColor = DEFAULT_PRESSED_TEXT_COLOR;
        this.mTextSize = dp2px(DEFAULT_TEXT_SIZE_DP);
        this.mTextPaddingLeft = dp2px(DEFAULT_TEXT_PADDING_LEFT_DP);
        this.mTextPaddingTop = dp2px(DEFAULT_TEXT_PADDING_TOP_DP);
        this.mTextPaddingRight = dp2px(DEFAULT_TEXT_PADDING_RIGHT_DP);
        this.mTextPaddingBottom = dp2px(DEFAULT_TEXT_PADDING_BOTTOM_DP);
        this.mNormalBackgroundColor = DEFAULT_NORMAL_BACKGROUND_COLOR;
        this.mPressedBackgroundColor = DEFAULT_PRESSED_BACKGROUND_COLOR;
        this.mBackgroundCornerRadius = dp2px(DEFAULT_BACKGROUND_RADIUS_DP);
        this.mDividerColor = DEFAULT_DIVIDER_COLOR;
        this.mDividerWidth = dp2px(DEFAULT_DIVIDER_WIDTH_DP);
        this.mDividerHeight = dp2px(DEFAULT_DIVIDER_HEIGHT_DP);
        this.mIndicatorView = getDefaultIndicatorView(mContext);
        refreshBackgroundOrRadiusStateList();
        refreshTextColorStateList(mPressedTextColor, mNormalTextColor);
    }

    /**
     * Popup a window when anchorView is clicked and held.
     * That method will call {@link View#setOnTouchListener(View.OnTouchListener)} and
     * {@link View#setOnLongClickListener(View.OnLongClickListener)}(or
     * {@link AbsListView#setOnItemLongClickListener(AdapterView.OnItemLongClickListener)}
     * if anchorView is a instance of AbsListView), so you can only use
     * {@link PopupList#showPopupListWindow(View, int, float, float, List, PopupListListener)}
     * if you called those method before.
     *
     * @param anchorView        the view on which to pin the popup window
     * @param popupItemList     the list of the popup menu
     * @param popupListListener the Listener
     */
    public void show(View anchorView, List<String> popupItemList, PopupListListener popupListListener) {
        this.mAnchorView = anchorView;
        this.mPopupItemList = popupItemList;
        this.mPopupListListener = popupListListener;
        this.mPopupWindow = null;
        mOffsetX = anchorView.getX() + anchorView.getWidth() / 2;
        mOffsetY = anchorView.getY();
        if (mPopupListListener != null && !mPopupListListener.showPopupList(anchorView, anchorView, 0)) {
            return ;
        }
        mContextView = anchorView;
        mContextPosition = 0;
        showPopupListWindow(mOffsetX, mOffsetY);
    }

    /**
     * show a popup window in a bubble style.
     *
     * @param anchorView        the view on which to pin the popup window
     * @param contextPosition   context position
     * @param rawX              the original raw X coordinate
     * @param rawY              the original raw Y coordinate
     * @param popupItemList     the list of the popup menu
     * @param popupListListener the Listener
     */
    public void showPopupListWindow(View anchorView, int contextPosition, float rawX, float rawY,
                                    List<String> popupItemList, PopupListListener popupListListener) {
        mAnchorView = anchorView;
        mContextPosition = contextPosition;
        mPopupItemList = popupItemList;
        mPopupListListener = popupListListener;
        mPopupWindow = null;
        mContextView = anchorView;
        if (mPopupListListener != null
                && !mPopupListListener.showPopupList(mContextView, mContextView, contextPosition)) {
            return;
        }
        int[] location = new int[2];
        mAnchorView.getLocationOnScreen(location);
        showPopupListWindow(rawX - location[0], rawY - location[1]);
    }

    private void showPopupListWindow(float offsetX, float offsetY) {
        if (mContext instanceof Activity && ((Activity) mContext).isFinishing()) {
            return;
        }
        if (mPopupWindow == null || mPopupListListener instanceof AdapterPopupListListener) {
            LinearLayout contentView = new LinearLayout(mContext);
            contentView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            contentView.setOrientation(LinearLayout.VERTICAL);
            LinearLayout popupListContainer = new LinearLayout(mContext);
            popupListContainer.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            popupListContainer.setOrientation(LinearLayout.HORIZONTAL);
            popupListContainer.setBackgroundDrawable(mCornerBackground);
            contentView.addView(popupListContainer);
            if (mIndicatorView != null) {
                LinearLayout.LayoutParams layoutParams;
                if (mIndicatorView.getLayoutParams() == null) {
                    layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                } else {
                    layoutParams = (LinearLayout.LayoutParams) mIndicatorView.getLayoutParams();
                }
                layoutParams.gravity = Gravity.CENTER;
                mIndicatorView.setLayoutParams(layoutParams);
                ViewParent viewParent = mIndicatorView.getParent();
                if (viewParent instanceof ViewGroup) {
                    ((ViewGroup) viewParent).removeView(mIndicatorView);
                }
                contentView.addView(mIndicatorView);
            }
            for (int i = 0; i < mPopupItemList.size(); i++) {
                TextView textView = new TextView(mContext);
                LinearLayout.LayoutParams textlayoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, mDividerHeight);
                textlayoutParams.gravity = Gravity.CENTER;
                textView.setLayoutParams(textlayoutParams);
                textView.setTextColor(mTextColorStateList);
                textView.setGravity(Gravity.CENTER_VERTICAL);
                textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, mTextSize);
                textView.setPadding(mTextPaddingLeft, mTextPaddingTop, mTextPaddingRight, mTextPaddingBottom);
                textView.setClickable(true);
                final int finalI = i;
                textView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mPopupListListener != null) {
                            mPopupListListener.onPopupListClick(mContextView, mContextPosition, finalI);
                            hidePopupListWindow();
                        }
                    }
                });
                if (mPopupListListener instanceof AdapterPopupListListener) {
                    AdapterPopupListListener adapterPopupListListener = (AdapterPopupListListener) mPopupListListener;
                    textView.setText(adapterPopupListListener.formatText(mAdapterView, mContextView, mContextPosition, i, mPopupItemList.get(i)));
                } else {
                    textView.setText(mPopupItemList.get(i));
                }
                if (mPopupItemList.size() > 1 && i == 0) {
                    textView.setBackgroundDrawable(mLeftItemBackground);
                } else if (mPopupItemList.size() > 1 && i == mPopupItemList.size() - 1) {
                    textView.setBackgroundDrawable(mRightItemBackground);
                } else if (mPopupItemList.size() == 1) {
                    textView.setBackgroundDrawable(mCornerItemBackground);
                } else {
                    textView.setBackgroundDrawable(getCenterItemBackground());
                }
                popupListContainer.addView(textView);
                if (mPopupItemList.size() > 1 && i != mPopupItemList.size() - 1) {
                    View divider = new View(mContext);
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(mDividerWidth, mDividerHeight);
                    layoutParams.gravity = Gravity.CENTER;
                    divider.setLayoutParams(layoutParams);
                    divider.setBackgroundColor(mDividerColor);
                    popupListContainer.addView(divider);
                }
            }
            if (mPopupWindowWidth == 0) {
                mPopupWindowWidth = getViewWidth(popupListContainer);
            }
            if (mIndicatorView != null && mIndicatorWidth == 0) {
                if (mIndicatorView.getLayoutParams().width > 0) {
                    mIndicatorWidth = mIndicatorView.getLayoutParams().width;
                } else {
                    mIndicatorWidth = getViewWidth(mIndicatorView);
                }
            }
            if (mIndicatorView != null && mIndicatorHeight == 0) {
                if (mIndicatorView.getLayoutParams().height > 0) {
                    mIndicatorHeight = mIndicatorView.getLayoutParams().height;
                } else {
                    mIndicatorHeight = getViewHeight(mIndicatorView);
                }
            }
            if (mPopupWindowHeight == 0) {
                mPopupWindowHeight = getViewHeight(popupListContainer) + mIndicatorHeight;
            }
            mPopupWindow = new PopupWindow(contentView, mPopupWindowWidth, mPopupWindowHeight, true);
            mPopupWindow.setTouchable(true);
            mPopupWindow.setBackgroundDrawable(new BitmapDrawable());
        }
        int[] location = new int[2];
        mAnchorView.getLocationOnScreen(location);
        if (mIndicatorView != null) {
            float leftTranslationLimit = mIndicatorWidth / 2f + mBackgroundCornerRadius - mPopupWindowWidth / 2f;
            float rightTranslationLimit = mPopupWindowWidth / 2f - mIndicatorWidth / 2f - mBackgroundCornerRadius;
            float maxWidth = mContext.getResources().getDisplayMetrics().widthPixels;
            if (location[0] + offsetX < mPopupWindowWidth / 2f) {
                mIndicatorView.setTranslationX(Math.max(location[0] + offsetX - mPopupWindowWidth / 2f, leftTranslationLimit));
            } else if (location[0] + offsetX + mPopupWindowWidth / 2f > maxWidth) {
                mIndicatorView.setTranslationX(Math.min(location[0] + offsetX + mPopupWindowWidth / 2f - maxWidth, rightTranslationLimit));
            } else {
                mIndicatorView.setTranslationX(0);
            }
        }
        if (!mPopupWindow.isShowing()) {
            int x = (int) (location[0] + offsetX - mPopupWindowWidth / 2f + 0.5f);
            int y = (int) (location[1] + offsetY - mPopupWindowHeight + 0.5f);
            mPopupWindow.showAtLocation(mAnchorView, Gravity.NO_GRAVITY, x, y);
        }
    }

    private void refreshBackgroundOrRadiusStateList() {
        // left
        GradientDrawable leftItemPressedDrawable = new GradientDrawable();
        leftItemPressedDrawable.setColor(mPressedBackgroundColor);
        leftItemPressedDrawable.setCornerRadii(new float[]{
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                0, 0,
                0, 0,
                mBackgroundCornerRadius, mBackgroundCornerRadius});
        GradientDrawable leftItemNormalDrawable = new GradientDrawable();
        leftItemNormalDrawable.setColor(Color.TRANSPARENT);
        leftItemNormalDrawable.setCornerRadii(new float[]{
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                0, 0,
                0, 0,
                mBackgroundCornerRadius, mBackgroundCornerRadius});
        mLeftItemBackground = new StateListDrawable();
        mLeftItemBackground.addState(new int[]{android.R.attr.state_pressed}, leftItemPressedDrawable);
        mLeftItemBackground.addState(new int[]{}, leftItemNormalDrawable);
        // right
        GradientDrawable rightItemPressedDrawable = new GradientDrawable();
        rightItemPressedDrawable.setColor(mPressedBackgroundColor);
        rightItemPressedDrawable.setCornerRadii(new float[]{
                0, 0,
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                0, 0});
        GradientDrawable rightItemNormalDrawable = new GradientDrawable();
        rightItemNormalDrawable.setColor(Color.TRANSPARENT);
        rightItemNormalDrawable.setCornerRadii(new float[]{
                0, 0,
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                mBackgroundCornerRadius, mBackgroundCornerRadius,
                0, 0});
        mRightItemBackground = new StateListDrawable();
        mRightItemBackground.addState(new int[]{android.R.attr.state_pressed}, rightItemPressedDrawable);
        mRightItemBackground.addState(new int[]{}, rightItemNormalDrawable);
        // corner
        GradientDrawable cornerItemPressedDrawable = new GradientDrawable();
        cornerItemPressedDrawable.setColor(mPressedBackgroundColor);
        cornerItemPressedDrawable.setCornerRadius(mBackgroundCornerRadius);
        GradientDrawable cornerItemNormalDrawable = new GradientDrawable();
        cornerItemNormalDrawable.setColor(Color.TRANSPARENT);
        cornerItemNormalDrawable.setCornerRadius(mBackgroundCornerRadius);
        mCornerItemBackground = new StateListDrawable();
        mCornerItemBackground.addState(new int[]{android.R.attr.state_pressed}, cornerItemPressedDrawable);
        mCornerItemBackground.addState(new int[]{}, cornerItemNormalDrawable);
        mCornerBackground = new GradientDrawable();
        mCornerBackground.setColor(mNormalBackgroundColor);
        mCornerBackground.setCornerRadius(mBackgroundCornerRadius);
    }

    private StateListDrawable getCenterItemBackground() {
        StateListDrawable centerItemBackground = new StateListDrawable();
        GradientDrawable centerItemPressedDrawable = new GradientDrawable();
        centerItemPressedDrawable.setColor(mPressedBackgroundColor);
        GradientDrawable centerItemNormalDrawable = new GradientDrawable();
        centerItemNormalDrawable.setColor(Color.TRANSPARENT);
        centerItemBackground.addState(new int[]{android.R.attr.state_pressed}, centerItemPressedDrawable);
        centerItemBackground.addState(new int[]{}, centerItemNormalDrawable);
        return centerItemBackground;
    }

    private void refreshTextColorStateList(int pressedTextColor, int normalTextColor) {
        int[][] states = new int[2][];
        states[0] = new int[]{android.R.attr.state_pressed};
        states[1] = new int[]{};
        int[] colors = new int[]{pressedTextColor, normalTextColor};
        mTextColorStateList = new ColorStateList(states, colors);
    }

    public void hidePopupListWindow() {
        if (mContext instanceof Activity && ((Activity) mContext).isFinishing()) {
            return;
        }
        if (mPopupWindow != null && mPopupWindow.isShowing()) {
            mPopupWindow.dismiss();
        }
    }

    public View getIndicatorView() {
        return mIndicatorView;
    }

    public View getDefaultIndicatorView(Context context) {
        return getTriangleIndicatorView(context, dp2px(16), dp2px(8), DEFAULT_NORMAL_BACKGROUND_COLOR);
    }

    public View getTriangleIndicatorView(Context context, final float widthPixel, final float heightPixel,
                                         final int color) {
        ImageView indicator = new ImageView(context);
        Drawable drawable = new Drawable() {
            @Override
            public void draw(Canvas canvas) {
                Path path = new Path();
                Paint paint = new Paint();
                paint.setColor(color);
                paint.setStyle(Paint.Style.FILL);
                path.moveTo(0f, 0f);
                path.lineTo(widthPixel, 0f);
                path.lineTo(widthPixel / 2, heightPixel);
                path.close();
                canvas.drawPath(path, paint);
            }

            @Override
            public void setAlpha(int alpha) {

            }

            @Override
            public void setColorFilter(ColorFilter colorFilter) {

            }

            @Override
            public int getOpacity() {
                return PixelFormat.TRANSLUCENT;
            }

            @Override
            public int getIntrinsicWidth() {
                return (int) widthPixel;
            }

            @Override
            public int getIntrinsicHeight() {
                return (int) heightPixel;
            }
        };
        indicator.setImageDrawable(drawable);
        return indicator;
    }

    public void setIndicatorView(View indicatorView) {
        this.mIndicatorView = indicatorView;
    }

    public void setIndicatorSize(int widthPixel, int heightPixel) {
        this.mIndicatorWidth = widthPixel;
        this.mIndicatorHeight = heightPixel;
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(mIndicatorWidth, mIndicatorHeight);
        layoutParams.gravity = Gravity.CENTER;
        if (mIndicatorView != null) {
            mIndicatorView.setLayoutParams(layoutParams);
        }
    }

    public int getNormalTextColor() {
        return mNormalTextColor;
    }

    public void setNormalTextColor(int normalTextColor) {
        this.mNormalTextColor = normalTextColor;
        refreshTextColorStateList(mPressedTextColor, mNormalTextColor);
    }

    public int getPressedTextColor() {
        return mPressedTextColor;
    }

    public void setPressedTextColor(int pressedTextColor) {
        this.mPressedTextColor = pressedTextColor;
        refreshTextColorStateList(mPressedTextColor, mNormalTextColor);
    }

    public float getTextSize() {
        return mTextSize;
    }

    public void setTextSize(float textSizePixel) {
        this.mTextSize = textSizePixel;
    }

    public int getTextPaddingLeft() {
        return mTextPaddingLeft;
    }

    public void setTextPaddingLeft(int textPaddingLeft) {
        this.mTextPaddingLeft = textPaddingLeft;
    }

    public int getTextPaddingTop() {
        return mTextPaddingTop;
    }

    public void setTextPaddingTop(int textPaddingTop) {
        this.mTextPaddingTop = textPaddingTop;
    }

    public int getTextPaddingRight() {
        return mTextPaddingRight;
    }

    public void setTextPaddingRight(int textPaddingRight) {
        this.mTextPaddingRight = textPaddingRight;
    }

    public int getTextPaddingBottom() {
        return mTextPaddingBottom;
    }

    public void setTextPaddingBottom(int textPaddingBottom) {
        this.mTextPaddingBottom = textPaddingBottom;
    }

    /**
     * @param left   the left padding in pixels
     * @param top    the top padding in pixels
     * @param right  the right padding in pixels
     * @param bottom the bottom padding in pixels
     */
    public void setTextPadding(int left, int top, int right, int bottom) {
        this.mTextPaddingLeft = left;
        this.mTextPaddingTop = top;
        this.mTextPaddingRight = right;
        this.mTextPaddingBottom = bottom;
    }

    public int getNormalBackgroundColor() {
        return mNormalBackgroundColor;
    }

    public void setNormalBackgroundColor(int normalBackgroundColor) {
        this.mNormalBackgroundColor = normalBackgroundColor;
        refreshBackgroundOrRadiusStateList();
    }

    public int getPressedBackgroundColor() {
        return mPressedBackgroundColor;
    }

    public void setPressedBackgroundColor(int pressedBackgroundColor) {
        this.mPressedBackgroundColor = pressedBackgroundColor;
        refreshBackgroundOrRadiusStateList();
    }

    public int getBackgroundCornerRadius() {
        return mBackgroundCornerRadius;
    }

    public void setBackgroundCornerRadius(int backgroundCornerRadiusPixel) {
        this.mBackgroundCornerRadius = backgroundCornerRadiusPixel;
        refreshBackgroundOrRadiusStateList();
    }

    public int getDividerColor() {
        return mDividerColor;
    }

    public void setDividerColor(int dividerColor) {
        this.mDividerColor = dividerColor;
    }

    public int getDividerWidth() {
        return mDividerWidth;
    }

    public void setDividerWidth(int dividerWidthPixel) {
        this.mDividerWidth = dividerWidthPixel;
    }

    public int getDividerHeight() {
        return mDividerHeight;
    }

    public void setDividerHeight(int dividerHeightPixel) {
        this.mDividerHeight = dividerHeightPixel;
    }

    public Resources getResources() {
        if (mContext == null) {
            return Resources.getSystem();
        } else {
            return mContext.getResources();
        }
    }

    private int getViewWidth(View view) {
        view.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        return view.getMeasuredWidth();
    }

    private int getViewHeight(View view) {
        view.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
        return view.getMeasuredHeight();
    }

    public int dp2px(float value) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                value, getResources().getDisplayMetrics());
    }

    public int sp2px(float value) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP,
                value, getResources().getDisplayMetrics());
    }

    public interface PopupListListener {

        /**
         * Whether the PopupList should be bound to the special view
         *
         * @param adapterView     The context view(The AbsListView where the click happened or normal view).
         * @param contextView     The view within the AbsListView that was clicked or normal view
         * @param contextPosition The position of the view in the list
         * @return true if the view should show the PopupList, false otherwise
         */
        boolean showPopupList(View adapterView, View contextView, int contextPosition);

        /**
         * The callback to be invoked with an item in this PopupList has
         * been clicked
         *
         * @param contextView     The context view(The AbsListView where the click happened or normal view).
         * @param contextPosition The position of the view in the list
         * @param position        The position of the view in the PopupList
         */
        void onPopupListClick(View contextView, int contextPosition, int position);
    }

    public interface AdapterPopupListListener extends PopupListListener {
        String formatText(View adapterView, View contextView, int contextPosition, int position, String text);
    }

}

