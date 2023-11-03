package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.component;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.util.SoftKeyBoardUtil;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import java.util.ArrayList;
import java.util.List;

public class CommonPhrasesPopupCard {
    private PopupWindow popupWindow;
    private RecyclerView rvCommonPhrases;
    private CommonPhrasesAdapter commonPhrasesAdapter;
    private OnClickListener onClickListener;
    public CommonPhrasesPopupCard(Activity activity) {
        View popupView = LayoutInflater.from(activity).inflate(R.layout.popup_card_common_phrases, null);
        rvCommonPhrases = popupView.findViewById(R.id.rv_common_phrases);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(activity);
        linearLayoutManager.setOrientation(RecyclerView.VERTICAL);
        rvCommonPhrases.setLayoutManager(linearLayoutManager);

        commonPhrasesAdapter = new CommonPhrasesAdapter();
        rvCommonPhrases.setAdapter(commonPhrasesAdapter);
        popupWindow = new PopupWindow(popupView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT, true) {
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
        popupWindow.setBackgroundDrawable(null);
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(true);
        popupWindow.setAnimationStyle(com.tencent.qcloud.tuikit.timcommon.R.style.PopupInputCardAnim);
        popupWindow.setInputMethodMode(PopupWindow.INPUT_METHOD_NEEDED);
        popupWindow.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        popupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                if (activity.getWindow() != null) {
                    SoftKeyBoardUtil.hideKeyBoard(activity.getWindow());
                }
            }
        });
    }

    public void setDataList(List<String> dataList) {
        commonPhrasesAdapter.setDataList(dataList);
    }

    private void startAnimation(Window window, boolean isShow) {
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
        LinearInterpolator interpolator = new LinearInterpolator();
        animator.setDuration(200);
        animator.setInterpolator(interpolator);
        animator.start();
    }

    public void show(View rootView, int gravity) {
        if (popupWindow != null) {
            popupWindow.showAtLocation(rootView, gravity, 0, 0);
        }
    }

    public class CommonPhrasesAdapter extends RecyclerView.Adapter<CommonPhrasesAdapter.ViewHolder> {
        private List<String> mDataList = new ArrayList<>();

        public class ViewHolder extends RecyclerView.ViewHolder {
            TextView tvCommonPhrases;

            public ViewHolder(View itemView) {
                super(itemView);
                tvCommonPhrases = itemView.findViewById(R.id.tv_common_phrases);
            }
        }

        public CommonPhrasesAdapter() {}

        public void setDataList(List<String> dataList) {
            this.mDataList = dataList;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public CommonPhrasesAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.common_phrases_item, parent, false);
            CommonPhrasesAdapter.ViewHolder holder = new CommonPhrasesAdapter.ViewHolder(view);
            return holder;
        }

        @Override
        public void onBindViewHolder(@NonNull CommonPhrasesAdapter.ViewHolder holder, int position) {
            String content = mDataList.get(position);
            holder.tvCommonPhrases.setText(content);
            holder.tvCommonPhrases.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    popupWindow.dismiss();
                    if (onClickListener != null) {
                        onClickListener.onClick(content);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (mDataList != null) {
                return mDataList.size();
            } else {
                return 0;
            }
        }
    }

    public void setOnClickListener(OnClickListener listener) {
        this.onClickListener = listener;
    }

    @FunctionalInterface
    public interface OnClickListener {
        void onClick(String content);
    }
}
