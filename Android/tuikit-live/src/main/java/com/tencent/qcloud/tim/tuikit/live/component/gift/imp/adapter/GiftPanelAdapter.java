package com.tencent.qcloud.tim.tuikit.live.component.gift.imp.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.GiftInfo;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.RecyclerViewController;
import com.tencent.qcloud.tim.tuikit.live.utils.GlideEngine;

import java.util.List;

public class GiftPanelAdapter extends RecyclerView.Adapter<GiftPanelAdapter.ViewHolder> {
    private Context                mContext;
    private RecyclerView           mRecyclerView;
    private RecyclerViewController mRecyclerViewController;
    private int                    mPageIndex;
    private List<GiftInfo>         mSelectGiftInfoList;
    private List<GiftInfo>         mGiftInfoList;
    private OnItemClickListener    mOnItemClickListener;

    public GiftPanelAdapter(RecyclerView recyclerView, int pageIndex, List<GiftInfo> list,
                            Context context, List<GiftInfo> selectGiftInfoList) {
        super();
        mRecyclerView = recyclerView;
        mGiftInfoList = list;
        mContext = context;
        mPageIndex = pageIndex;
        mSelectGiftInfoList = selectGiftInfoList;
        recyclerViewClickListener(list, mContext);
    }

    private void recyclerViewClickListener(final List<GiftInfo> list, Context mContext) {
        mRecyclerViewController = new RecyclerViewController(mContext, mRecyclerView);
        mRecyclerViewController.setOnItemClickListener(new RecyclerViewController.OnItemClickListener() {
            @Override
            public void onItemClick(int position, View view) {
                final GiftInfo giftModel = list.get(position);
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(view, giftModel, position, mPageIndex);
                }
                clearSelectState();
                giftModel.isSelected = true;
                mSelectGiftInfoList.add(giftModel);
                notifyDataSetChanged();
            }
        });
    }

    private void clearSelectState() {
        for (GiftInfo giftInfo : mSelectGiftInfoList) {
            giftInfo.isSelected = false;
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.live_recycle_item_gift_panel, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, final int position) {
        final GiftInfo giftInfo = mGiftInfoList.get(position);
        GlideEngine.loadImage(holder.mImageGift, giftInfo.giftPicUrl);
        holder.mTextGiftName.setText(giftInfo.title);
        holder.mTextGiftPrice.setText(String.format(mContext.getString(R.string.live_gift_game_currency), giftInfo.price));
        if (giftInfo.isSelected) {
            holder.mLayoutRootView.setBackgroundResource(R.drawable.live_gift_shape_normal);
            holder.mTextGiftName.setVisibility(View.GONE);
//            holder.mTextSendBtn.setVisibility(View.VISIBLE);
        } else {
            holder.mLayoutRootView.setBackground(null);
            holder.mTextGiftName.setVisibility(View.VISIBLE);
//            holder.mTextSendBtn.setVisibility(View.GONE);
        }
    }

    @Override
    public int getItemCount() {
        return mGiftInfoList.size();
    }

    public void clearSelection(int pageIndex) {
        if (mPageIndex != pageIndex) {
            notifyDataSetChanged();
        }
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        LinearLayout mLayoutRootView;
        ImageView    mImageGift;
        TextView     mTextGiftName;
        TextView     mTextGiftPrice;
//        TextView     mTextSendBtn;

        public ViewHolder(View view) {
            super(view);
            mLayoutRootView = (LinearLayout) view.findViewById(R.id.ll_gift_root);
            mImageGift      = (ImageView)    view.findViewById(R.id.iv_gift_icon);
            mTextGiftName   = (TextView)     view.findViewById(R.id.tv_gift_name);
            mTextGiftPrice  = (TextView)     view.findViewById(R.id.tv_gift_price);
//            mTextSendBtn    = (TextView)     view.findViewById(R.id.tv_send);
        }
    }

    public interface OnItemClickListener {
        void onItemClick(View view, GiftInfo giftInfo, int position, int pageIndex);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mOnItemClickListener = listener;
    }
}
