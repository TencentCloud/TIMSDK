package com.tencent.qcloud.tuikit.tuichat.component.album;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;

import com.tencent.qcloud.tuicore.TUIThemeManager;

import io.trtc.tuikit.atomicx.albumpicker.AlbumMedia;
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerConfig;
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerListener;
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerTheme;
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerView;

import java.util.List;

public class AlbumPicker {
    private static final String TAG = AlbumPicker.class.getSimpleName();
    private static final long ANIM_DURATION_MS = 250;

    private static final AlbumPicker INSTANCE = new AlbumPicker();

    private AlbumPicker() {}

    public static AlbumPicker getInstance() {
        return INSTANCE;
    }

    public void pickMedia(Activity activity, AlbumPickerListener listener) {
        if (activity == null || listener == null) {
            return;
        }

        ViewGroup contentView = activity.findViewById(android.R.id.content);
        if (contentView == null) {
            return;
        }

        int screenHeight = activity.getResources().getDisplayMetrics().heightPixels;

        AlbumPickerView pickerView = new AlbumPickerView(activity);
        FrameLayout.LayoutParams pickerParams;
        pickerParams = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        pickerView.setLayoutParams(pickerParams);

        pickerView.setTranslationY(screenHeight);

        AlbumPickerConfig config = new AlbumPickerConfig();
        config.setMaxOutputFileSizeInMB(100);
        config.setMaxVideoDurationInSeconds(600);
        AlbumPickerTheme theme = new AlbumPickerTheme();
        theme.setCurrentPrimaryColor(getPrimaryColor(activity));

        pickerView.initialize(config, theme, new AlbumPickerListener() {
            @Override
            public void onPickConfirm(List<AlbumMedia> pickedAlbumMedias, String textMessage) {
                listener.onPickConfirm(pickedAlbumMedias, textMessage);
                animateOut(contentView, pickerView);
            }

            @Override
            public void onMediaProcessing(AlbumMedia albumMedia, float progress, boolean error) {
                listener.onMediaProcessing(albumMedia, progress, error);
            }

            @Override
            public void onMediaProcessed() {
                listener.onMediaProcessed();
            }

            @Override
            public void onCancel() {
                listener.onCancel();
                animateOut(contentView, pickerView);
            }
        });

        contentView.addView(pickerView);
        pickerView.animate()
                .translationY(0f)
                .setStartDelay(50)
                .setDuration(ANIM_DURATION_MS)
                .setInterpolator(new DecelerateInterpolator())
                .start();
    }

    private void animateOut(ViewGroup contentView, AlbumPickerView pickerView) {
        if (pickerView.getParent() == null) {
            return;
        }
        int screenHeight = contentView.getContext().getResources().getDisplayMetrics().heightPixels;
        float endY = pickerView.getHeight() > 0 ? pickerView.getHeight() : screenHeight;
        pickerView.animate()
                .translationY(endY)
                .setDuration(ANIM_DURATION_MS)
                .setInterpolator(new DecelerateInterpolator())
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        if (pickerView.getParent() != null) {
                            contentView.removeView(pickerView);
                        }
                    }
                })
                .start();
    }

    private int getPrimaryColor(Activity activity) {
        int resId = TUIThemeManager.getAttrResId(activity, com.tencent.qcloud.tuicore.R.attr.core_primary_color);
        if (resId != 0) {
            return activity.getResources().getColor(resId);
        }
        return 0xFF147AFF;
    }
}
