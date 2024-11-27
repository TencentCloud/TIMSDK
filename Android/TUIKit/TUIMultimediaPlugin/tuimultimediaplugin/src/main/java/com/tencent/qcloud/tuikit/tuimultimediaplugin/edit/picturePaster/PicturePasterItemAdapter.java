package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo.ItemPosition;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterType;


public class PicturePasterItemAdapter extends BaseAdapter {

    private final Context mContext;
    private final PicturePasterInfo mPasterInfo;
    private final int mPasterTypeIndex;
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedItem;

    public PicturePasterItemAdapter(Context context, PicturePasterInfo pasterInfo, int pasterTypeIndex,
            TUIMultimediaData<ItemPosition> tuiDataSelectedItem) {
        mContext = context;
        mPasterInfo = pasterInfo;
        mPasterTypeIndex = pasterTypeIndex;
        mTuiDataSelectedItem = tuiDataSelectedItem;
    }

    @Override
    public int getCount() {
        PicturePasterType typeInfo = mPasterInfo.getPasterType(mPasterTypeIndex);
        if (typeInfo != null) {
            return typeInfo.getItemSize();
        }
        return 0;
    }

    @Override
    public Object getItem(int position) {
        return null;
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
                    .inflate(R.layout.multimedia_plugin_edit_picture_paster_item_view, parent, false);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (position >= 0) {
            PicturePasterItem pasterItem = mPasterInfo.getPasterItem(new ItemPosition(mPasterTypeIndex, position));
            Bitmap bitmap = pasterItem != null ? pasterItem.getPasterIcon() : null;
            if (bitmap != null && !bitmap.isRecycled()) {
                holder.icon.setImageBitmap(bitmap);
            }
        }

        convertView.setOnClickListener(v -> mTuiDataSelectedItem.set(new ItemPosition(mPasterTypeIndex, position)));
        return convertView;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        private final ImageView icon;

        public ViewHolder(View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.paster_iv_icon);
        }
    }
}
