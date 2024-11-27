package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaScrollViewAdapter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;

public class SubtitleColorItemAdapter extends TUIMultimediaScrollViewAdapter {

    private static final int[] COLOR_ARRAY = {Color.WHITE, Color.BLACK, Color.RED, Color.GREEN, Color.BLUE, Color.CYAN,
            Color.DKGRAY, Color.GRAY, Color.LTGRAY, Color.MAGENTA, Color.YELLOW};
    private static final int CIRCLE_SHAPE_SIZE_DP = 18;
    private static final int SELECT_CIRCLE_SHAPE_SIZE_DP = 25;

    private final Context mContext;
    private final TUIMultimediaData<Integer> mTuiDataSelectColor;

    public SubtitleColorItemAdapter(Context context, TUIMultimediaData<Integer> tuiDataSelectColor) {
        mContext = context;
        mTuiDataSelectColor = tuiDataSelectColor;
        mSelectPosition = getColorIndex(tuiDataSelectColor.get());
    }

    public static int getColorIndex(int color) {
        for (int i = 0; i < COLOR_ARRAY.length; i++) {
            if (COLOR_ARRAY[i] == color) {
                return i;
            }
        }
        return 0;
    }

    @Override
    public void setSelectPosition(int position) {
        if (mSelectPosition != position) {
            mSelectPosition = position;
            if (mTuiDataSelectColor.get() != COLOR_ARRAY[mSelectPosition]) {
                mTuiDataSelectColor.set(COLOR_ARRAY[mSelectPosition]);
            }
            notifyDataSetChanged();
        }
    }

    @Override
    public int getCount() {
        return COLOR_ARRAY.length;
    }

    @Override
    public Object getItem(int position) {
        return COLOR_ARRAY[position];
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
                    .inflate(R.layout.multimedia_plugin_edit_subtitle_color_item, parent, false);
            holder = new ViewHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.innerCircleShape.setImageResource(R.drawable.multimedia_plugin_subtitle_color_selector_circle_shape);
        GradientDrawable circleShape = (GradientDrawable) holder.innerCircleShape.getDrawable();
        circleShape.setColor(COLOR_ARRAY[position]);

        int innerCircleShapeSize = (mSelectPosition == position ? SELECT_CIRCLE_SHAPE_SIZE_DP : CIRCLE_SHAPE_SIZE_DP);
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) holder.innerCircleShape
                .getLayoutParams();
        layoutParams.width = TUIMultimediaResourceUtils.dip2px(mContext, innerCircleShapeSize);
        layoutParams.height = TUIMultimediaResourceUtils.dip2px(mContext, innerCircleShapeSize);
        holder.innerCircleShape.setLayoutParams(layoutParams);

        layoutParams = (RelativeLayout.LayoutParams) holder.outerCircleShape.getLayoutParams();
        layoutParams.width = TUIMultimediaResourceUtils.dip2px(mContext, innerCircleShapeSize + 4);
        layoutParams.height = TUIMultimediaResourceUtils.dip2px(mContext, innerCircleShapeSize + 4);
        holder.outerCircleShape.setLayoutParams(layoutParams);

        convertView.setOnClickListener(v -> {
            if (mSelectPosition != position) {
                mSelectPosition = position;
                mTuiDataSelectColor.set(COLOR_ARRAY[mSelectPosition]);
                notifyDataSetChanged();
            }
        });
        return convertView;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        private final ImageView outerCircleShape;
        private final ImageView innerCircleShape;

        public ViewHolder(View itemView) {
            super(itemView);
            outerCircleShape = itemView.findViewById(R.id.outer_color_shape);
            innerCircleShape = itemView.findViewById(R.id.inner_color_shape);
        }
    }
}
