package com.tencent.liteav.demo.beauty.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.liteav.demo.beauty.model.ItemInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;
import com.tencent.liteav.demo.beauty.utils.ResourceUtils;
import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.ArrayList;
import java.util.List;

public class ItemAdapter extends BaseAdapter {

    private Context             mContext;
    private TabInfo             mTabInfo;
    private List<ItemInfo>      mItemInfoList;
    private OnItemClickListener mItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ItemInfo itemInfo, int position);
    }

    // 当前选中
    private int mSelectPos;

    public ItemAdapter(Context context) {
        mContext = context;
    }

    public void setData(TabInfo tabInfo) {
        setData(tabInfo, 0);
    }

    public void setData(TabInfo tabInfo, int defaultIndex) {
        mTabInfo = tabInfo;
        mSelectPos = defaultIndex;
        if (mItemInfoList == null) {
            mItemInfoList = new ArrayList<>();
        }
        mItemInfoList.clear();
        mItemInfoList.addAll(tabInfo.getTabItemList());
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return mTabInfo.getTabItemList().size();
    }

    @Override
    public ItemInfo getItem(int position) {
        return mItemInfoList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return mItemInfoList.get(position).getItemId();
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(mContext).inflate(R.layout.beauty_view_item, parent, false);
            holder = new ViewHolder(convertView);
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) holder.icon.getLayoutParams();
            int width, height;
            if (mTabInfo.getTabItemIconWidth() == LinearLayout.LayoutParams.MATCH_PARENT) {
                width = LinearLayout.LayoutParams.MATCH_PARENT;
            } else if(mTabInfo.getTabItemIconWidth() == LinearLayout.LayoutParams.WRAP_CONTENT) {
                width = LinearLayout.LayoutParams.WRAP_CONTENT;
            } else {
                width = BeautyUtils.dip2px(mContext, mTabInfo.getTabItemIconWidth());
            }
            if (mTabInfo.getTabItemIconHeight() == LinearLayout.LayoutParams.MATCH_PARENT) {
                height = LinearLayout.LayoutParams.MATCH_PARENT;
            } else if (mTabInfo.getTabItemIconHeight() == LinearLayout.LayoutParams.WRAP_CONTENT) {
                height = LinearLayout.LayoutParams.WRAP_CONTENT;
            } else {
                height = BeautyUtils.dip2px(mContext, mTabInfo.getTabItemIconHeight());
            }
            layoutParams.width = width;
            layoutParams.height = height;
            holder.icon.setLayoutParams(layoutParams);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        final ItemInfo itemInfo = getItem(position);
        BeautyUtils.setTextViewText(holder.title, ResourceUtils.getString(itemInfo.getItemName()));
        BeautyUtils.setTextViewSize(holder.title, mTabInfo.getTabItemNameSize());
        if (mSelectPos == position) {
            BeautyUtils.setTextViewColor(holder.title, mTabInfo.getTabItemNameColorSelect());
            BeautyUtils.setImageResource(holder.icon, itemInfo.getItemIconSelect());
        } else {
            BeautyUtils.setTextViewColor(holder.title, mTabInfo.getTabItemNameColorNormal());
            BeautyUtils.setImageResource(holder.icon, itemInfo.getItemIconNormal());
        }
        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mItemClickListener != null) {
                    mItemClickListener.onItemClick(itemInfo, position);
                    if (mSelectPos != position) {
                        mSelectPos = position;
                        notifyDataSetChanged();
                    }
                }
            }
        });
        return convertView;
    }

    public void setOnItemClickListener(OnItemClickListener itemClickListener) {
        mItemClickListener = itemClickListener;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private ImageView icon;
        private TextView title;

        public ViewHolder(View itemView) {
            super(itemView);
            icon = (ImageView) itemView.findViewById(R.id.beauty_iv_icon);
            title = (TextView) itemView.findViewById(R.id.beauty_tv_title);
        }
    }
}
