package com.tencent.qcloud.tuikit.tuichat.classicui.component;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.ImageView;
import android.widget.PopupWindow;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuicore.util.SoftKeyBoardUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;

public class BeginnerGuidePage {

    private PopupWindow popupWindow;
    private ViewPager2 viewPager;
    private OnFinishListener onFinishListener;
    private int[] resIDs;
    public BeginnerGuidePage(Activity activity) {
        View popupView = LayoutInflater.from(activity).inflate(R.layout.layout_beginner_guide, null);
        viewPager = popupView.findViewById(R.id.view_pager);

        popupWindow = new PopupWindow(popupView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT, true) {
            @Override
            public void showAtLocation(View anchor, int gravity, int x, int y) {
                if (activity != null && !activity.isFinishing()) {
                    Window dialogWindow = activity.getWindow();
                    startAnimation(dialogWindow, true);
                }
                super.showAtLocation(anchor, gravity, x, y);
            }

            @Override
            public void dismiss() {
                if (activity != null && !activity.isFinishing()) {
                    Window dialogWindow = activity.getWindow();
                    startAnimation(dialogWindow, false);
                }

                super.dismiss();
            }
        };
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(false);
        popupWindow.setAnimationStyle(R.style.BeginnerGuidePopupAnimation);
        viewPager.setUserInputEnabled(false);
        viewPager.setAdapter(new GuideAdapter());
    }

    private void startAnimation(Window window, boolean isShow) {
        LinearInterpolator interpolator = new LinearInterpolator();
        ValueAnimator animator;
        if (isShow) {
            animator = ValueAnimator.ofFloat(1.0f, 0.5f);
        } else {
            animator = ValueAnimator.ofFloat(0.5f, 1.0f);
        }
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                WindowManager.LayoutParams lp = window.getAttributes();
                lp.alpha = (float) animation.getAnimatedValue();
                window.setAttributes(lp);
            }
        });

        animator.setDuration(200);
        animator.setInterpolator(interpolator);
        animator.start();
    }

    public void setPagesResIDs(int... imageResIDs) {
        resIDs = imageResIDs;
        viewPager.setOffscreenPageLimit(resIDs.length);
        viewPager.getAdapter().notifyDataSetChanged();
        viewPager.setCurrentItem(0, false);
    }

    public void setOnFinishListener(OnFinishListener onFinishListener) {
        this.onFinishListener = onFinishListener;
    }

    public void show(View rootView, int gravity) {
        if (popupWindow != null) {
            popupWindow.showAtLocation(rootView, gravity, 0, 0);
        }
    }

    class GuideAdapter extends RecyclerView.Adapter<GuideAdapter.GuideViewHolder> {
        @NonNull
        @Override
        public GuideViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new GuideViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_beginner_guide_item, parent ,false));
        }

        @Override
        public void onBindViewHolder(@NonNull GuideViewHolder holder, int position) {
            ViewGroup.LayoutParams params = holder.image.getLayoutParams();
            if (params != null) {
                params.width = ScreenUtil.getScreenWidth(holder.image.getContext());
                params.height = ScreenUtil.getScreenHeight(holder.image.getContext());
                holder.image.setLayoutParams(params);
            }
            GlideEngine.loadImage(holder.image, resIDs[position]);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (viewPager != null) {
                        int currentPos = holder.getBindingAdapterPosition();
                        if (currentPos < getItemCount() - 1) {
                            viewPager.setCurrentItem(currentPos + 1, true);
                        } else {
                            if (onFinishListener != null) {
                                onFinishListener.onFinish();
                            }
                            if (popupWindow != null && popupWindow.isShowing()) {
                                popupWindow.dismiss();
                            }
                        }
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (resIDs == null) {
                return 0;
            }
            return resIDs.length;
        }

        class GuideViewHolder extends RecyclerView.ViewHolder {
            private final ImageView image;
            public GuideViewHolder(@NonNull View itemView) {
                super(itemView);
                image = itemView.findViewById(R.id.center_image);
            }
        }
    }


    public static void showBeginnerGuideThen(View view, Runnable runnable) {
        boolean isShowGuide = SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME).getBoolean(TUIChatConstants.CHAT_REPLY_GUIDE_SHOW_SP_KEY, true);
        if (isShowGuide) {
            SoftKeyBoardUtil.hideKeyBoard(view.getWindowToken());
            SPUtils.getInstance(TUIChatConstants.CHAT_SETTINGS_SP_NAME).put(TUIChatConstants.CHAT_REPLY_GUIDE_SHOW_SP_KEY, false);

            BeginnerGuidePage guidePage = new BeginnerGuidePage((Activity) view.getContext());
            guidePage.setPagesResIDs(R.drawable.chat_reply_guide, R.drawable.chat_quote_guide);
            guidePage.setOnFinishListener(new BeginnerGuidePage.OnFinishListener() {
                @Override
                public void onFinish() {
                    runnable.run();
                }
            });
            guidePage.show(view, Gravity.NO_GRAVITY);
        } else {
            runnable.run();
        }
    }

    @FunctionalInterface
    public interface OnFinishListener {
        void onFinish();
    }
}
