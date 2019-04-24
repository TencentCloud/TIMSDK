package com.tencent.qcloud.uikit.common.component.info;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ListView;

public class InfoItemListView extends ListView {

    public InfoItemListView(Context context) {
        super(context);
    }

    public InfoItemListView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public InfoItemListView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
                MeasureSpec.AT_MOST);
        super.onMeasure(widthMeasureSpec, expandSpec);
    }
}
