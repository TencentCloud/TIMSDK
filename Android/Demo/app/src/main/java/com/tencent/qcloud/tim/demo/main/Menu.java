package com.tencent.qcloud.tim.demo.main;

import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAdapter;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.List;

public class Menu {
    private static final int SHADOW_WIDTH = 10;
    private static final int Y_OFFSET = 4;

    private ListView mMenuList;
    private PopMenuAdapter mMenuAdapter;
    private PopupWindow mMenuWindow;
    private List<PopMenuAction> mActions = new ArrayList<>();
    private Activity mActivity;
    private View mAttachView;

    public Menu(Activity activity, View attach) {
        mActivity = activity;
        mAttachView = attach;
    }

    public void setMenuAction(List<PopMenuAction> menuActions) {
        mActions.clear();
        mActions.addAll(menuActions);
    }

    public boolean isShowing() {
        if (mMenuWindow == null) {
            return false;
        }
        return mMenuWindow.isShowing();
    }

    public void hide() {
        mMenuWindow.dismiss();
    }

    public void show() {
        if (mActions == null || mActions.size() == 0) {
            return;
        }
        mMenuWindow = new PopupWindow(mActivity);
        mMenuWindow.setWidth(ViewGroup.LayoutParams.WRAP_CONTENT);
        mMenuWindow.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        mMenuWindow.setBackgroundDrawable(new ColorDrawable());

        mMenuAdapter = new PopMenuAdapter();
        mMenuAdapter.setDataSource(mActions);
        View menuView = LayoutInflater.from(mActivity).inflate(R.layout.core_pop_menu, null);
        menuView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        mMenuWindow.setContentView(menuView);
        mMenuList = menuView.findViewById(R.id.menu_pop_list);
        mMenuList.setAdapter(mMenuAdapter);
        mMenuList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = (PopMenuAction) mMenuAdapter.getItem(position);
                if (action != null && action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(position, mActions.get(position));
                }
            }
        });

        int paddingLeftRight = ScreenUtil.dip2px(15.0f);
        int paddingTopBottom = ScreenUtil.dip2px(12.0f);

        int itemWidth = mActivity.getResources().getDimensionPixelSize(R.dimen.core_pop_menu_item_width);
        int itemHeight = mActivity.getResources().getDimensionPixelSize(R.dimen.core_pop_menu_item_height);

        mMenuWindow.getContentView().measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);

        int[] location = new int[2];
        mAttachView.getLocationOnScreen(location);
        int rowCount = mActions.size();
        int indicatorHeight = mActivity.getResources().getDimensionPixelOffset(R.dimen.core_pop_menu_indicator_height);

        int popWidth = itemWidth + paddingLeftRight * 2 - SHADOW_WIDTH;
        int popHeight = itemHeight * rowCount + paddingTopBottom * 2 - SHADOW_WIDTH;
        float anchorWidth = mAttachView.getWidth();
        float indicatorX = anchorWidth / 2;
        int screenWidth = ScreenUtil.getScreenWidth(mActivity);
        int x = location[0];
        int y;
        float xOffset = anchorWidth / 2;
        // If it is on the right, the x-coordinate of the small arrow and the x-position of the pop-up window will change
        if (location[0] * 2 + anchorWidth > screenWidth) {
            indicatorX = popWidth - anchorWidth / 2 - xOffset;
            x = (int) (location[0] + anchorWidth - popWidth + xOffset);
        }
        float anchorHeight = mAttachView.getHeight();
        y = (int) (location[1] + anchorHeight) + Y_OFFSET;
        popHeight = popHeight - indicatorHeight;

        Drawable backgroundDrawable = getBackgroundDrawable(popWidth, popHeight, indicatorX, indicatorHeight, 16);
        menuView.setBackground(backgroundDrawable);

        mMenuWindow.setFocusable(true);
        mMenuWindow.setTouchable(true);
        mMenuWindow.setOutsideTouchable(true);
        mMenuWindow.showAtLocation(mAttachView, Gravity.NO_GRAVITY, x, y);
    }

    /**
     * Draw a popup background with small triangles
     */
    public Drawable getBackgroundDrawable(final float widthPixel, final float heightPixel, float indicatorX, float indicatorHeight, float radius) {
        int borderWidth = SHADOW_WIDTH;

        Path path = new Path();
        Drawable drawable = new Drawable() {
            @Override
            public void draw(@NonNull Canvas canvas) {
                Paint paint = new Paint();
                paint.setColor(Color.WHITE);
                paint.setStyle(Paint.Style.FILL);
                paint.setShadowLayer(borderWidth, 0, 0, 0xFFAAAAAA);
                path.addRoundRect(new RectF(borderWidth, indicatorHeight + borderWidth, widthPixel - borderWidth, heightPixel + indicatorHeight - borderWidth),
                    radius, radius, Path.Direction.CW);
                path.moveTo(indicatorX - indicatorHeight, indicatorHeight + borderWidth);
                path.lineTo(indicatorX, borderWidth);
                path.lineTo(indicatorX + indicatorHeight, indicatorHeight + borderWidth);
                path.close();
                canvas.drawPath(path, paint);
            }

            @Override
            public void setAlpha(int alpha) {}

            @Override
            public void setColorFilter(@Nullable ColorFilter colorFilter) {}

            @Override
            public int getOpacity() {
                return PixelFormat.TRANSLUCENT;
            }
        };
        return drawable;
    }
}
