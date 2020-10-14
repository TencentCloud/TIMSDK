package com.tencent.qcloud.tim.tuikit.live.component.topbar.adapter;

import android.content.Context;
import android.graphics.Rect;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.tuikit.live.utils.UIUtil;

/**
 * 水平分隔符或垂直分隔符，用于recycleview组件
 * @author delanding
* */
public class SpacesDecoration extends RecyclerView.ItemDecoration {

    public static final int VERTICAL = 0;
    public static final int HORIZONTAL = 1;

    private int mSpace;
    private int mMode;

    /**constructor, 初始化参数，分隔距离与分隔模式
     * @param space 分隔距离，用dp标识
     * @param mode 分隔模式
     * */
    public SpacesDecoration(Context ctx, int space, int mode) {
        if (mode != VERTICAL && mode != HORIZONTAL) {
            throw new IllegalArgumentException("wrong mode parameter set...");
        }
        this.mSpace = UIUtil.dp2px(ctx, space);
        this.mMode = mode;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view,
                               RecyclerView parent, RecyclerView.State state) {
        if (mMode == HORIZONTAL) {
            outRect.left = mSpace;
            outRect.right = mSpace;
        } else {
            outRect.bottom = mSpace;
            if (parent.getChildPosition(view) == 0) {
                outRect.top = mSpace;
            }
        }
    }
}
