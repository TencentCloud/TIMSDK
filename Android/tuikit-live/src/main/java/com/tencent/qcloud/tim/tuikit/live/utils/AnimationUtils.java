package com.tencent.qcloud.tim.tuikit.live.utils;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.animation.TimeInterpolator;
import android.view.View;

public class AnimationUtils {


    /**
     * @param target
     * @param star     动画起始坐标
     * @param end      动画终止坐标
     * @param duration 持续时间
     * @return 创建一个从左到右的飞入动画
     */
    public static ObjectAnimator createFadesInFromLtoR(final View target, float star, float end,
                                                   int duration, TimeInterpolator interpolator) {
        ObjectAnimator animator = ObjectAnimator.ofFloat(target, "translationX",
                star, end);
        animator.setInterpolator(interpolator);
        animator.setDuration(duration);
        return animator;
    }


    /**
     * @param target
     * @param star     动画起始坐标
     * @param end      动画终止坐标
     * @param duration 持续时间
     * @param startDelay 延迟时间
     * @return 向上飞 淡出
     */
    public static ObjectAnimator createFadesOutAnimator(final View target, float star, float end,
                                                        int duration, int startDelay) {
        PropertyValuesHolder translationY = PropertyValuesHolder.ofFloat("translationY", star, end);
        PropertyValuesHolder alpha = PropertyValuesHolder.ofFloat("alpha", 1.0f, 0f);
        ObjectAnimator animator = ObjectAnimator.ofPropertyValuesHolder(target, translationY, alpha);
        animator.setStartDelay(startDelay);
        animator.setDuration(duration);
        return animator;
    }

    public static AnimatorSet startAnimation(ObjectAnimator animatorFirst, ObjectAnimator animatorSecond) {
        AnimatorSet animSet = new AnimatorSet();
        animSet.play(animatorFirst).before(animatorSecond);
        animSet.start();
        return animSet;
    }
}
