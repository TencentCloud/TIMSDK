package com.tencent.qcloud.tuikit.timcommon.component.highlight;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.interfaces.HighlightListener;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HighlightPresenter {
    public static final int DEFAULT_DURATION = 250;
    public static final int DEFAULT_REPEAT_COUNT = 3;

    private static final class HighlightPresenterHolder {
        private static final HighlightPresenter INSTANCE = new HighlightPresenter();
    }

    private static HighlightPresenter getInstance() {
        return HighlightPresenterHolder.INSTANCE;
    }

    private final Map<String, WeakReference<HighlightListener>> highlightListenerMap = new HashMap<>();

    private final Map<String, ValueAnimator> highlightMap = new HashMap<>();

    private HighlightPresenter() {}

    // Use WeakReference, no need to unregister.
    public static void registerHighlightListener(String highlightID, HighlightListener listener) {
        if (listener == null) {
            return;
        }
        getInstance().highlightListenerMap.put(highlightID, new WeakReference<>(listener));
    }

    public static void startHighlight(String highlightID) {
        getInstance().internalStartHighlight(highlightID);
    }

    public static void stopHighlight(String highlightID) {
        getInstance().internalStopHighlight(highlightID);
    }

    private void internalStartHighlight(String highlightID) {
        ValueAnimator highlightAnimator = new ValueAnimator();
        int highLightColorDark = TIMCommonService.getAppContext().getResources().getColor(R.color.chat_message_bubble_high_light_dark_color);
        int highLightColorLight = TIMCommonService.getAppContext().getResources().getColor(R.color.chat_message_bubble_high_light_light_color);
        highlightAnimator.setIntValues(highLightColorDark, highLightColorLight);
        highlightAnimator.setEvaluator(new ArgbEvaluator());
        highlightAnimator.setRepeatCount(DEFAULT_REPEAT_COUNT);
        highlightAnimator.setDuration(DEFAULT_DURATION);
        highlightAnimator.setRepeatMode(ValueAnimator.REVERSE);
        highlightAnimator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                onHighlightStart(highlightID);
            }

            @Override
            public void onAnimationCancel(Animator animation) {
                onHighlightEnd(highlightID);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                onHighlightEnd(highlightID);
            }
        });
        highlightAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                onHighlightUpdate(highlightID, (Integer) animation.getAnimatedValue());
            }
        });
        highlightAnimator.start();
        highlightMap.put(highlightID, highlightAnimator);
    }

    private void internalStopHighlight(String highlightID) {
        ValueAnimator highlightAnimator = highlightMap.get(highlightID);
        if (highlightAnimator != null) {
            highlightAnimator.cancel();
        }
    }

    private void onHighlightStart(String highlightID) {
        HighlightListener lightListener = getInstance().getHighlightListener(highlightID);
        if (lightListener != null) {
            lightListener.onHighlightStart();
        }
    }

    private void onHighlightEnd(String highlightID) {
        highlightMap.remove(highlightID);
        HighlightListener lightListener = getInstance().getHighlightListener(highlightID);
        if (lightListener != null) {
            lightListener.onHighlightEnd();
        }
    }

    private void onHighlightUpdate(String highlightID, int color) {
        HighlightListener lightListener = getHighlightListener(highlightID);
        if (lightListener != null) {
            lightListener.onHighlightUpdate(color);
        }
    }

    private HighlightListener getHighlightListener(String highlightID) {
        WeakReference<HighlightListener> listener = highlightListenerMap.get(highlightID);
        if (listener != null) {
            return listener.get();
        }
        return null;
    }
}
