package com.tencent.liteav.trtccalling.ui.videocall.videolayout;

import android.content.Context;
import android.widget.RelativeLayout;

import java.util.ArrayList;

public class Utils2 {

    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 一宫格布局，整体居中
     *
     * @param context
     * @param layoutWidth
     * @param layoutHeight
     * @return
     */
    public static ArrayList<RelativeLayout.LayoutParams> initGrid1Param(Context context, int layoutWidth, int layoutHeight) {
        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();

        int margin = dip2px(context, 10);
        int grid4W = (layoutWidth - margin * 2) / 2;
        int grid4H = (layoutHeight - margin * 2) / 2;
        // 使用四宫格的大小
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.CENTER_IN_PARENT);
        list.add(layoutParams0);
        return list;
    }

    /**
     * 二宫格布局，两个layout平分
     *
     * @param context
     * @param layoutWidth
     * @param layoutHeight
     * @return
     */
    public static ArrayList<RelativeLayout.LayoutParams> initGrid2Param(Context context, int layoutWidth, int layoutHeight) {
        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        int margin = dip2px(context, 10);
        int grid4W = (layoutWidth - margin * 2) / 2;
        int grid4H = (layoutHeight - margin * 2) / 2;
        // 使用四宫格的大小
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams1.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams1.rightMargin = margin;

        list.add(layoutParams0);
        list.add(layoutParams1);
        return list;
    }

    /**
     * 三宫格布局，品字形
     *
     * @param context
     * @param layoutWidth
     * @param layoutHeight
     * @return
     */
    public static ArrayList<RelativeLayout.LayoutParams> initGrid3Param(Context context, int layoutWidth, int layoutHeight) {
        int margin = dip2px(context, 10);

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        int grid4W = (layoutWidth - margin * 2) / 2;
        int grid4H = (layoutHeight - margin * 2) / 2;
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams0.topMargin = margin;
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams1.topMargin = margin;
        layoutParams1.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams2.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams2.leftMargin = margin;
        layoutParams2.bottomMargin = margin;

        list.add(layoutParams0);
        list.add(layoutParams1);
        list.add(layoutParams2);
        return list;
    }

    /**
     * 四宫格布局参数
     *
     * @param context
     * @param layoutWidth
     * @param layoutHeight
     * @return
     */
    public static ArrayList<RelativeLayout.LayoutParams> initGrid4Param(Context context, int layoutWidth, int layoutHeight) {
        int margin = dip2px(context, 10);

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        int grid4W = (layoutWidth - margin * 2) / 2;
        int grid4H = (layoutHeight - margin * 2) / 2;
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams0.topMargin = margin;
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams1.topMargin = margin;
        layoutParams1.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams2.bottomMargin = margin;
        layoutParams2.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams3 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams3.bottomMargin = margin;
        layoutParams3.rightMargin = margin;

        list.add(layoutParams0);
        list.add(layoutParams1);
        list.add(layoutParams2);
        list.add(layoutParams3);
        return list;
    }

    /**
     * 九宫格布局参数
     *
     * @param context
     * @param layoutWidth
     * @param layoutHeight
     * @return
     */
    public static ArrayList<RelativeLayout.LayoutParams> initGrid9Param(Context context, int layoutWidth, int layoutHeight) {
        int margin = dip2px(context, 10);

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();

        int grid9W = (layoutWidth - margin * 2) / 3;
        int grid9H = (layoutHeight - margin * 2) / 3;
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams0.topMargin = margin;
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams1.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams1.topMargin = margin;

        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams2.topMargin = margin;
        layoutParams2.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams3 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams3.leftMargin = margin;
        layoutParams3.topMargin = margin + grid9H;

        RelativeLayout.LayoutParams layoutParams4 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams4.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams4.topMargin = margin + grid9H;

        RelativeLayout.LayoutParams layoutParams5 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams5.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams5.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams5.topMargin = margin + grid9H;
        layoutParams5.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams6 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams6.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams6.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams6.bottomMargin = margin;
        layoutParams6.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams7 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams7.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams7.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams7.bottomMargin = margin;

        RelativeLayout.LayoutParams layoutParams8 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams8.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams8.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layoutParams8.bottomMargin = margin;
        layoutParams8.rightMargin = margin;

        list.add(layoutParams0);
        list.add(layoutParams1);
        list.add(layoutParams2);
        list.add(layoutParams3);
        list.add(layoutParams4);
        list.add(layoutParams5);
        list.add(layoutParams6);
        list.add(layoutParams7);
        list.add(layoutParams8);
        return list;
    }

}
