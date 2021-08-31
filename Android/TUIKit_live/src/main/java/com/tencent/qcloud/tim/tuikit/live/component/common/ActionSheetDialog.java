package com.tencent.qcloud.tim.tuikit.live.component.common;

import android.app.Dialog;
import android.content.Context;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;

import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.ArrayList;
import java.util.List;

public class ActionSheetDialog {
    private Context                  mContext;
    private Dialog                   mDialog;
    private TextView                 mTextTitle;
    private TextView                 mTextCancel;
    private LinearLayout             mLayoutContent;
    private ScrollView               mScrollContent;
    private List<SheetItem>          mSheetItemList;
    private Display                  mDisplay;
    private boolean                  mShowTitle;
    private OnSheetItemClickListener mOnSheetItemClickListener;

    public ActionSheetDialog(@NonNull Context context) {
        this.mContext = context;
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        mDisplay = windowManager.getDefaultDisplay();
    }

    @NonNull
    public ActionSheetDialog builder() {
        // 获取Dialog布局
        View view = LayoutInflater.from(mContext).inflate(R.layout.live_layout_action_sheet, null);
        // 设置Dialog最小宽度为屏幕宽度
        view.setMinimumWidth(mDisplay.getWidth());
        // 获取自定义Dialog布局中的控件
        mScrollContent = (ScrollView) view.findViewById(R.id.sLayout_content);
        mLayoutContent = (LinearLayout) view
                .findViewById(R.id.lLayout_content);
        mTextTitle = (TextView) view.findViewById(R.id.txt_title);
        mTextCancel = (TextView) view.findViewById(R.id.txt_cancel);
        mTextCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        // 定义Dialog布局和参数
        mDialog = new Dialog(mContext, R.style.LiveActionSheetDialogStyle);
        mDialog.setContentView(view);
        Window dialogWindow = mDialog.getWindow();
        dialogWindow.setGravity(Gravity.LEFT | Gravity.BOTTOM);
        WindowManager.LayoutParams lp = dialogWindow.getAttributes();
        lp.x = 0;
        lp.y = 0;
        dialogWindow.setAttributes(lp);
        return this;
    }

    @NonNull
    public ActionSheetDialog setTitle(String title) {
        mShowTitle = true;
        mTextTitle.setVisibility(View.VISIBLE);
        mTextTitle.setText(title);
        return this;
    }

    @NonNull
    public ActionSheetDialog setCancelable(boolean cancel) {
        mDialog.setCancelable(cancel);
        return this;
    }

    @NonNull
    public ActionSheetDialog setCanceledOnTouchOutside(boolean cancel) {
        mDialog.setCanceledOnTouchOutside(cancel);
        return this;
    }

    /**
     * @param strItem  条目名称
     * @param color    条目字体颜色，设置null则默认蓝色
     * @return
     */
    @NonNull
    public ActionSheetDialog addSheetItem(String strItem, @ColorInt int color) {
        if (mSheetItemList == null) {
            mSheetItemList = new ArrayList<>();
        }
        mSheetItemList.add(new SheetItem(strItem, color));
        return this;
    }

    /**
     * @param strItems  条目名称数组
     * @param color    条目字体颜色，设置null则默认蓝色
     * @param listener
     * @return
     */
    @NonNull
    public ActionSheetDialog addSheetItems(String[] strItems, @ColorInt int color,
                                          OnSheetItemClickListener listener) {
        mOnSheetItemClickListener = listener;
        if (mSheetItemList == null) {
            mSheetItemList = new ArrayList<>();
        }
        for (String strItem : strItems) {
            mSheetItemList.add(new SheetItem(strItem, color));
        }
        return this;
    }

    /**
     * 设置条目布局
     */
    private void setSheetItems() {
        if (mSheetItemList == null || mSheetItemList.size() <= 0) {
            return;
        }
        int size = mSheetItemList.size();
        float scale = mContext.getResources().getDisplayMetrics().density;
        int height = (int) (45 * scale + 0.5f);
        // 添加条目过多的时候控制高度
        if ((height * size) > (mDisplay.getHeight() / 2)) {
            LayoutParams params = (LayoutParams) mScrollContent.getLayoutParams();
            params.height = mDisplay.getHeight() / 2;
        }
        // 循环添加条目
        for (int i = 1; i <= size; i++) {
            final int index = i;
            final SheetItem sheetItem = mSheetItemList.get(i - 1);
            String strItem = sheetItem.name;
            int color = sheetItem.color;
            TextView textView = new TextView(mContext);
            textView.setText(strItem);
            textView.setTextSize(18);
            textView.setGravity(Gravity.CENTER);

            // 背景图片
            if (size == 1) {
                if (mShowTitle) {
                    textView.setBackgroundResource(R.drawable.live_action_sheet_bottom_selector);
                } else {
                    textView.setBackgroundResource(R.drawable.live_action_sheet_single_selector);
                }
            } else {
                if (mShowTitle) {
                    if (i >= 1 && i < size) {
                        textView.setBackgroundResource(R.drawable.live_action_sheet_middle_selector);
                    } else {
                        textView.setBackgroundResource(R.drawable.live_action_sheet_bottom_selector);
                    }
                } else {
                    if (i == 1) {
                        textView.setBackgroundResource(R.drawable.live_action_sheet_top_selector);
                    } else if (i < size) {
                        textView.setBackgroundResource(R.drawable.live_action_sheet_middle_selector);
                    } else {
                        textView.setBackgroundResource(R.drawable.live_action_sheet_bottom_selector);
                    }
                }
            }

            // 字体颜色
            if (color == 0) {
                textView.setTextColor(mContext.getResources().getColor(R.color.live_action_sheet_blue));
            } else {
                textView.setTextColor(color);
            }

            textView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, height));

            // 点击事件
            textView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mOnSheetItemClickListener != null) {
                        mOnSheetItemClickListener.onClick(index, sheetItem.name);
                    }
                    mDialog.dismiss();
                }
            });

            mLayoutContent.addView(textView);
        }
    }

    public void show() {
        setSheetItems();
        mDialog.show();
    }

    public interface OnSheetItemClickListener {
        void onClick(int which, String text);
    }

    public class SheetItem {
        String name;
        @ColorInt int color;

        public SheetItem(String name, int color) {
            this.name = name;
            this.color = color;
        }
    }
}
