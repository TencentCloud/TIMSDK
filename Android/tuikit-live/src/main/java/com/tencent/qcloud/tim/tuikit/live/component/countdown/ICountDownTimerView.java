package com.tencent.qcloud.tim.tuikit.live.component.countdown;

import androidx.annotation.ColorRes;

/**
 * 定制化倒计时View
 */
public interface ICountDownTimerView {
    /**
     * 播放倒计时动画
     *
     * @param num
     */
    void countDownAnimation(int num);

    /**
     * 设置倒计时动画执行完成监听器
     *
     * @param listener
     */
    void setOnCountDownListener(ICountDownListener listener);

    interface ICountDownListener {
        /**
         * 倒计时动画执行完成
         */
        void onCountDownComplete();
    }

    /**
     * 设置倒计时动画文字颜色
     */
    void setCountDownTextColor(@ColorRes int color);

    /**
     * 设置从数字几开始倒计时
     */
    void setCountDownNumber(int number);

}
