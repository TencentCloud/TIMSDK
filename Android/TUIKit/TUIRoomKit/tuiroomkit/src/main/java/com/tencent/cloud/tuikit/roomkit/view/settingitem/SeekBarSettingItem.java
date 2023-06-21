package com.tencent.cloud.tuikit.roomkit.view.settingitem;

import android.content.Context;
import android.view.View;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;


public class SeekBarSettingItem extends BaseSettingItem {
    private Listener       mListener;
    private ItemViewHolder mItemViewHolder;

    public SeekBarSettingItem(Context context,
                              @NonNull ItemText itemText,
                              Listener listener) {
        super(context, itemText);
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.tuiroomkit_item_setting_seekbar, null)
        );
        mListener = listener;
    }

    public int getMax() {
        return mItemViewHolder.mItemSb.getMax();
    }

    public SeekBarSettingItem setMax(final int max) {
        mItemViewHolder.mItemSb.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSb.setMax(max);
            }
        });
        return this;
    }

    public SeekBarSettingItem setProgress(final int progress) {
        mItemViewHolder.mItemSb.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSb.setProgress(progress);
            }
        });
        return this;
    }

    public SeekBarSettingItem setTips(final String tips) {
        mItemViewHolder.mTipsTv.setText(tips);
        return this;
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.mRootView;
        }
        return null;
    }

    public interface Listener {
        void onSeekBarChange(int progress, boolean fromUser);
    }

    public class ItemViewHolder {
        public View     mRootView;
        public TextView mTitle;
        public SeekBar  mItemSb;
        public TextView mTipsTv;

        public ItemViewHolder(@NonNull final View itemView) {
            mRootView = itemView;
            mTitle = itemView.findViewById(R.id.title);
            mItemSb = itemView.findViewById(R.id.sb_item);
            mTipsTv = itemView.findViewById(R.id.tv_tips);
            if (mItemText == null) {
                return;
            }
            mTitle.setText(mItemText.title);
            mItemSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    if (mListener != null) {
                        mListener.onSeekBarChange(progress, fromUser);
                    }
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });
        }
    }
}
