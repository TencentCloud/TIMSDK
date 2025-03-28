package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.content.Context;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.cloud.tuikit.roomkit.R;

public class SwitchSettingItem extends BaseSettingItem {
    private Listener       mListener;
    private ItemViewHolder mItemViewHolder;

    public SwitchSettingItem(Context context,
                             @NonNull ItemText itemText,
                             Listener listener) {
        super(context, itemText);
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.tuiroomkit_item_setting_switch, null)
        );
        mListener = listener;
    }

    public SwitchSettingItem setCheck(final boolean isCheck) {
        mItemViewHolder.mItemSwitch.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSwitch.setChecked(isCheck);
            }
        });
        return this;
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.mRootView;
        }
        return null;
    }

    public void hideBottomLine() {
        mItemViewHolder.mBottomLine.setVisibility(View.GONE);
    }

    public interface Listener {
        void onSwitchChecked(boolean isChecked);
    }

    public class ItemViewHolder {
        public  View         mRootView;
        private View         mBottomLine;
        private TextView     mTitle;
        private SwitchCompat mItemSwitch;

        public ItemViewHolder(@NonNull final View itemView) {
            mRootView = itemView;
            mTitle = itemView.findViewById(R.id.title);
            mTitle.setText(mItemText.title);
            mBottomLine = itemView.findViewById(R.id.bottom_line);
            mItemSwitch = itemView.findViewById(R.id.switch_item);
            mItemSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (mListener != null) {
                        mListener.onSwitchChecked(isChecked);
                    }
                }
            });
        }
    }
}
