package com.tencent.cloud.tuikit.roomkit.view.settingitem;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;

import java.util.List;

public class SingleRadioButtonDialog extends BottomSheetDialog {
    private Context    mContext;
    private TextView   mTitle;
    private RadioGroup mRadioGroup;

    private int              mSelectPosition;
    private List<String>     mDataArray;
    private OnSelectListener mListener;


    public SingleRadioButtonDialog(Context context, List<String> dataArray) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        mContext = context;
        mDataArray = dataArray;
        setContentView(R.layout.tuiroomkit_dialog_single_radio_button);
        initView();
    }

    private void initView() {
        mRadioGroup = findViewById(R.id.radio_group);
        mTitle = findViewById(R.id.tv_title);
        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        if (mDataArray != null) {
            for (int i = 0; i < mDataArray.size(); i++) {
                RadioButton radioButton = createRadioButton(mDataArray.get(i));
                radioButton.setId(i);
                if (i == mSelectPosition) {
                    radioButton.setChecked(true);
                }
                mRadioGroup.addView(radioButton);
            }
        }
        mRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                RadioButton radioButton = findViewById(checkedId);
                String selectText = radioButton.getText().toString();
                mSelectPosition = checkedId;
                if (mListener != null) {
                    mListener.onSelect(checkedId, selectText);
                }
                dismiss();
            }
        });
    }

    public void setTitle(String text) {
        mTitle.setText(text);
    }

    private RadioButton createRadioButton(String text) {
        RadioButton radioButton = new RadioButton(mContext);
        int paddingHorizon = mContext.getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_padding_horizon);
        int paddingVertical = mContext.getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_padding_vertical);
        radioButton.setPadding(paddingHorizon,
                paddingVertical,
                paddingHorizon,
                paddingVertical);
        radioButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        radioButton.setTextColor(mContext.getResources().getColor(R.color.tuiroomkit_color_text_light_grey));
        radioButton.setText(text);
        radioButton.setButtonDrawable(null);
        setStyle(radioButton);
        return radioButton;
    }

    private void setStyle(RadioButton rb) {
        ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        Drawable drawable = mContext.getResources()
                .getDrawable(R.drawable.tuiroomkit_bg_rb_icon_selector);
        //定义底部标签图片大小和位置
        int rightBound = mContext.getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_bounds_horizon);
        int bottomBound = mContext.getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_radio_button_bounds_vertical);
        drawable.setBounds(0, 0, rightBound, bottomBound);
        //设置图片在文字的哪个方向
        rb.setCompoundDrawables(null, null, drawable, null);
        rb.setLayoutParams(layoutParams);
    }

    public void setSelection(final int position) {
        mSelectPosition = position;
        if (null == mRadioGroup) {
            return;
        }
        for (int i = 0; i < mRadioGroup.getChildCount(); i++) {
            if (mRadioGroup.getChildAt(i) instanceof RadioButton) {
                final int id = mRadioGroup.getChildAt(i).getId();
                if (id == position) {
                    ((RadioButton) mRadioGroup.getChildAt(i)).setChecked(true);
                }
            }
        }
    }

    public int getSelectedItemPosition() {
        return mSelectPosition;
    }

    public void setSelectListener(OnSelectListener listener) {
        mListener = listener;
    }

    public interface OnSelectListener {
        void onSelect(int position, String text);
    }
}
