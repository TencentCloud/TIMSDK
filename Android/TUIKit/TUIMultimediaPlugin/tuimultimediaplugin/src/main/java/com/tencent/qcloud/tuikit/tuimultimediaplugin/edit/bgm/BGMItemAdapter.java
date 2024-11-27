package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo.ItemPosition;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMType;

public class BGMItemAdapter extends BaseAdapter {

    private final Context mContext;
    private final BGMInfo mBGMInfo;
    private final int mBGMTypeIndex;
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedPosition;
    private final TUIMultimediaData<Boolean> mTuiDataBGMEnable;

    private BGMItemView mLastSelectedItemView;

    public BGMItemAdapter(Context context, BGMInfo bgmInfo, int bgmTypeIndex,
            TUIMultimediaData<ItemPosition> tuiDataSelectedPosition, TUIMultimediaData<Boolean> tuiDataBGMEnable) {
        mContext = context;
        mBGMInfo = bgmInfo;
        mBGMTypeIndex = bgmTypeIndex;
        mTuiDataSelectedPosition = tuiDataSelectedPosition;
        mTuiDataSelectedPosition.observe(position -> mLastSelectedItemView = null);

        mTuiDataBGMEnable = tuiDataBGMEnable;
        mTuiDataBGMEnable.observe(enable -> {
            if (mLastSelectedItemView != null) {
                mLastSelectedItemView.setEnabled(enable);
            }
        });
    }

    @Override
    public int getCount() {
        BGMType bgmType = mBGMInfo.getBGMType(mBGMTypeIndex);
        return bgmType != null ? bgmType.getItemSize() : 0;
    }

    @Override
    public Object getItem(int position) {
        BGMType bgmType = mBGMInfo.getBGMType(mBGMTypeIndex);
        return bgmType != null ? bgmType.getBGMItem(position) : null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(mContext)
                    .inflate(R.layout.multimedia_plugin_edit_bgm_item_view_container, parent, false);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        ItemPosition currentPosition = new ItemPosition(mBGMTypeIndex, position);
        BGMItem bgmItem = mBGMInfo.getBGMItem(currentPosition);
        BGMItemView bgmItemView = holder.bgmItemView;
        bgmItemView.bindBGMItem(bgmItem);

        boolean isSelected = currentPosition.equals(mTuiDataSelectedPosition.get());
        bgmItemView.setSelected(isSelected);
        if (isSelected) {
            bgmItemView.setEnabled(mTuiDataBGMEnable.get());
            if (mLastSelectedItemView != null && mLastSelectedItemView != bgmItemView) {
                mLastSelectedItemView.setSelected(false);
            }
            mLastSelectedItemView = bgmItemView;
        }

        convertView.setOnClickListener(v -> {
            if (currentPosition.equals(mTuiDataSelectedPosition.get())) {
                return;
            }

            if (mLastSelectedItemView != null) {
                mLastSelectedItemView.setSelected(false);
            }
            mTuiDataSelectedPosition.set(currentPosition);
            mLastSelectedItemView = bgmItemView;
            bgmItemView.setSelected(true);
            bgmItemView.setEnabled(true);
        });
        return convertView;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        public BGMItemView bgmItemView;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            bgmItemView = new BGMItemView(itemView.getContext());
            ((RelativeLayout) itemView).addView(bgmItemView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT));
        }
    }
}
