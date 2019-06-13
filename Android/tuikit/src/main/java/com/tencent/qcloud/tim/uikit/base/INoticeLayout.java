package com.tencent.qcloud.tim.uikit.base;

import android.view.View;
import android.widget.TextView;

/**
 * 通知区域接口
 */
public interface INoticeLayout {

    /**
     * 获取通知的主题信息View
     *
     * @return
     */
    TextView getContent();


    /**
     * 获取通知的进一步操作View
     *
     * @return
     */
    TextView getContentExtra();

    /**
     * 设置通知的点击事件
     *
     * @param l
     */
    void setOnNoticeClickListener(View.OnClickListener l);

    /**
     * 设置通知区域是否一直显示
     *
     * @param show 一直显示为true
     */
    void alwaysShow(boolean show);

}
