package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaScrollViewAdapter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyType;

public class BeautyItemAdapter extends TUIMultimediaScrollViewAdapter {

    private final Context mContext;
    private final BeautyInfo mBeautyInfo;
    private final int mTypeIndex;
    private ViewHolder mLastSelectedView;

    public BeautyItemAdapter(Context context, BeautyInfo beautyInfo, int typeIndex) {
        mContext = context;
        mBeautyInfo = beautyInfo;
        mTypeIndex = typeIndex;
    }

    @Override
    public int getCount() {
        BeautyType beautyType = mBeautyInfo.getBeautyType(mTypeIndex);
        return beautyType != null ? beautyType.getItemSize() : 0;
    }

    @Override
    public BeautyItem getItem(int position) {
        BeautyType beautyType = mBeautyInfo.getBeautyType(mTypeIndex);
        return beautyType != null ? beautyType.getItem(position) : null;
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
                    .inflate(getViewResourceId(), parent, false);
            holder = new ViewHolder(convertView, mContext);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        BeautyType beautyType = mBeautyInfo.getBeautyType(mTypeIndex);
        BeautyItem beautyItem = beautyType != null ? beautyType.getItem(position) : null;
        if (beautyItem != null) {
            holder.title.setText(beautyItem.getName());
            TUIMultimediaResourceUtils.setImageResource(holder.icon, beautyItem.getIconResName());
        }

        holder.setSelected(mSelectPosition == position && mSelectPosition != 0);
        if (mSelectPosition == position) {
            mLastSelectedView = holder;
        }

        convertView.setOnClickListener(v -> {
            if (mSelectPosition != position) {
                mSelectPosition = position;
                holder.setSelected(mSelectPosition != 0);
                mBeautyInfo.setSelectedItemIndex(mTypeIndex, position);
                if (mLastSelectedView != null) {
                    mLastSelectedView.setSelected(false);
                }
                mLastSelectedView = holder;
            }
        });
        return convertView;
    }

    private int getViewResourceId() {
        String typeName = mBeautyInfo.getBeautyType(mTypeIndex).getName();
        if (typeName.equals(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_setting_panel_filter))) {
            return R.layout.multimedia_plugin_record_beauty_filter_item_view;
        } else {
            return R.layout.multimedia_plugin_record_beauty_item_view;
        }
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        private final View root;
        private Context context;
        private final ImageView icon;
        private final TextView title;
        private final ImageView background;

        public ViewHolder(View itemView, Context context) {
            super(itemView);
            this.context = context;
            root = itemView;
            icon = itemView.findViewById(R.id.beauty_iv_icon);
            title = itemView.findViewById(R.id.beauty_tv_title);
            background = itemView.findViewById(R.id.select_background);
        }

        public void setSelected(boolean selected) {
            if (selected) {
                background.setBackground(
                        TUIMultimediaResourceUtils.getDrawable(context, R.drawable.multimedia_plugin_beauty_backgroud_selected,
                                TUIMultimediaIConfig.getInstance().getThemeColor()));
            } else {
                background.setBackground(null);
            }
        }
    }
}
