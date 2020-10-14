package com.tencent.qcloud.tim.tuikit.live.component.like;

/**
 * Module:   FrequeControl
 * <p>
 * Function: 频率控制类
 * <p>
 * 用于控制一定时间内的触发次数不能过多
 * 规则为在设定时间内，最开始的nCounts次请求能触发；忽略后面超出的请求，距离上个时间段内首次触发时间超过设定时间后重启下一个时间段逻辑。
 */
public class LikeFrequencyControl {
    private int  mCounts           = 0; //设定时间内允许触发的次数
    private int  mSeconds          = 0; //设定的时间秒数
    private int  mCurrentCounts    = 0; //当前已经触发的次数
    private long mFirstTriggerTime = 0; //当前时间段内首次触发的时间

    public void init(int nCounts, int nSeconds) {
        this.mCounts = nCounts;
        this.mSeconds = nSeconds;
        this.mCurrentCounts = 0;
        this.mFirstTriggerTime = 0;
    }

    public boolean canTrigger() {
        long time = System.currentTimeMillis();

        //重置首次触发时间和已经触发次数
        if (mFirstTriggerTime == 0 || time - mFirstTriggerTime > 1000 * mSeconds) {
            mFirstTriggerTime = time;
            mCurrentCounts = 0;
        }

        //已经触发了mCounts次，本次不能触发
        if (mCurrentCounts >= mCounts) {
            return false;
        }

        ++mCurrentCounts;
        return true;
    }
}
