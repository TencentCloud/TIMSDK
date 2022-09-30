package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.content.Context;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import java.util.ArrayList;

public class DisplayUtils {

    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    // init stack layout
    public static ArrayList<RelativeLayout.LayoutParams> initFloatParamList(Context context, int width, int height) {
        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<RelativeLayout.LayoutParams>();
        // the largest layout in the bottom
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        list.add(layoutParams0);

        final int midMargin = dip2px(context, 10);
        final int lrMargin = dip2px(context, 15);
        final int bottomMargin = dip2px(context, 50);
        final int subWidth = dip2px(context, 120);
        final int subHeight = dip2px(context, 180);
        for (int i = 2; i >= 0; i--) {
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(subWidth, subHeight);
            layoutParams.leftMargin = width - lrMargin - subWidth;
            layoutParams.topMargin = height - (bottomMargin + midMargin * (i + 1) + subHeight * i) - subHeight;
            list.add(layoutParams);
        }

        for (int i = 2; i >= 0; i--) {
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(subWidth, subHeight);
            layoutParams.leftMargin = lrMargin;
            layoutParams.topMargin = height - (bottomMargin + midMargin * (i + 1) + subHeight * i) - subHeight;
            list.add(layoutParams);
        }
        return list;
    }

    // init one grid layout ,center in the screen
    public static ArrayList<RelativeLayout.LayoutParams> initGrid1Param(Context context, int width, int height) {
        int margin = dip2px(context, 10);
        int grid4W = (width - margin * 2) / 2;
        int grid4H = (height - margin * 2) / 2;
        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.CENTER_IN_PARENT);

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        list.add(layoutParams0);
        return list;
    }

    // init two grid layout ,split the screen
    public static ArrayList<RelativeLayout.LayoutParams> initGrid2Param(Context context, int width, int height) {
        int margin = dip2px(context, 10);
        int grid4W = (width - margin * 2) / 2;
        int grid4H = (height - margin * 2) / 2;

        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams1.addRule(RelativeLayout.CENTER_VERTICAL);
        layoutParams1.rightMargin = margin;

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        list.add(layoutParams0);
        list.add(layoutParams1);
        return list;
    }

    // init three grid layout
    public static ArrayList<RelativeLayout.LayoutParams> initGrid3Param(Context context, int width, int height) {
        int margin = dip2px(context, 10);
        int grid3W = (width - margin * 2) / 2;
        int grid3H = (height - margin * 2) / 2;

        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid3W, grid3H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams0.topMargin = margin;
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid3W, grid3H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams1.topMargin = margin;
        layoutParams1.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(grid3W, grid3H);
        layoutParams2.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams2.bottomMargin = margin;
        layoutParams2.topMargin = margin + grid3H;

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        list.add(layoutParams0);
        list.add(layoutParams1);
        list.add(layoutParams2);
        return list;
    }

    // init four grid layout
    public static ArrayList<RelativeLayout.LayoutParams> initGrid4Param(Context context, int width, int height) {
        int margin = dip2px(context, 10);
        int grid4W = (width - margin * 2) / 2;
        int grid4H = (height - margin * 2) / 2;

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
        layoutParams2.bottomMargin = margin;
        layoutParams2.topMargin = margin + grid4H;
        layoutParams2.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams3 = new RelativeLayout.LayoutParams(grid4W, grid4H);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams3.bottomMargin = margin;
        layoutParams3.topMargin = margin + grid4H;
        layoutParams3.rightMargin = margin;

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
        list.add(layoutParams0);
        list.add(layoutParams1);
        list.add(layoutParams2);
        list.add(layoutParams3);
        return list;
    }

    // init nine grid layout
    public static ArrayList<RelativeLayout.LayoutParams> initGrid9Param(Context context, int width, int height) {
        int margin = dip2px(context, 10);
        int grid9W = (width - margin * 2) / 3;
        int grid9H = (height - margin * 2) / 3;

        RelativeLayout.LayoutParams layoutParams0 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams0.topMargin = margin;
        layoutParams0.leftMargin = margin;

        RelativeLayout.LayoutParams layoutParams1 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams1.topMargin = margin;
        layoutParams1.leftMargin = margin + grid9W;

        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        layoutParams2.topMargin = margin;
        layoutParams2.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams3 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams3.leftMargin = margin;
        layoutParams3.topMargin = margin + grid9H;

        RelativeLayout.LayoutParams layoutParams4 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams4.topMargin = margin + grid9H;
        layoutParams4.leftMargin = margin + grid9W;

        RelativeLayout.LayoutParams layoutParams5 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams5.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams5.topMargin = margin + grid9H;
        layoutParams5.rightMargin = margin;

        RelativeLayout.LayoutParams layoutParams6 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams6.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
        layoutParams6.bottomMargin = margin;
        layoutParams6.leftMargin = margin;
        layoutParams6.topMargin = margin + grid9H * 2;

        RelativeLayout.LayoutParams layoutParams7 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams7.bottomMargin = margin;
        layoutParams7.topMargin = margin + grid9H * 2;
        layoutParams7.leftMargin = margin + grid9W;

        RelativeLayout.LayoutParams layoutParams8 = new RelativeLayout.LayoutParams(grid9W, grid9H);
        layoutParams8.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        layoutParams8.bottomMargin = margin;
        layoutParams8.topMargin = margin + grid9H * 2;
        layoutParams8.rightMargin = margin;

        ArrayList<RelativeLayout.LayoutParams> list = new ArrayList<>();
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
