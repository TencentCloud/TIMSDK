package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.app.Activity;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServicePluginService;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.component.CommonPhrasesPopupCard;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUICustomerServiceConfig;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUICustomerServiceProductInfo;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUIInputViewFloatLayerData;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class InputViewFloatLayerProxy {
    private RecyclerView rvFloatLayer;
    private ChatInfo chatInfo;
    public InputViewFloatLayerProxy(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
        initDataList();
    }

    private void initDataList() {
        List<TUIInputViewFloatLayerData> dataList = new ArrayList<>();
        TUIInputViewFloatLayerData productInfoData = new TUIInputViewFloatLayerData();
        productInfoData.setContent(TUICustomerServicePluginService.getAppContext().getString(R.string.send_product_info));
        productInfoData.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
                TUICustomerServiceProductInfo productInfo = TUICustomerServiceConfig.getInstance().getProductInfo();
                presenter.sendProductMessage(chatInfo.getId(), productInfo);
            }
        });
        dataList.add(productInfoData);

        TUIInputViewFloatLayerData commonPhrasesData = new TUIInputViewFloatLayerData();
        commonPhrasesData.setContent(TUICustomerServicePluginService.getAppContext().getString(R.string.common_phrases));
        commonPhrasesData.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                showCommonPhrasesView();
            }
        });
        dataList.add(commonPhrasesData);

        TUICustomerServiceConfig.getInstance().setInputViewFloatLayerDataList(dataList);
    }

    public void showFloatLayerContent(ViewGroup viewGroup) {
        if (chatInfo == null) {
            return;
        }

        viewGroup.setVisibility(View.VISIBLE);
        LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.input_view_float_layer_content_view, viewGroup);
        rvFloatLayer = viewGroup.findViewById(R.id.rv_float_layer);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(viewGroup.getContext());
        linearLayoutManager.setOrientation(RecyclerView.HORIZONTAL);
        rvFloatLayer.setLayoutManager(linearLayoutManager);

        List<TUIInputViewFloatLayerData> dataList = TUICustomerServiceConfig.getInstance().getInputViewFloatLayerDataList();
        FloatLayerAdapter floatLayerAdapter = new FloatLayerAdapter(dataList);
        rvFloatLayer.setAdapter(floatLayerAdapter);
        floatLayerAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                TUIInputViewFloatLayerData data = dataList.get(position);
                data.getOnItemClickListener().onItemClick(view, position);
            }
        });
    }

    private void showCommonPhrasesView() {
        CommonPhrasesPopupCard commonPhrasesPopupCard = new CommonPhrasesPopupCard((Activity) rvFloatLayer.getContext());
        String[] commonPhrasesArray = TUICustomerServicePluginService.getAppContext().getResources().getStringArray(R.array.common_phrases_list);
        List<String> dataList = Arrays.asList(commonPhrasesArray);
        commonPhrasesPopupCard.setDataList(dataList);
        commonPhrasesPopupCard.setOnClickListener(new CommonPhrasesPopupCard.OnClickListener() {
            @Override
            public void onClick(String content) {
                TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
                presenter.sendTextMessage(chatInfo.getId(), content);
            }
        });

        commonPhrasesPopupCard.show(rvFloatLayer, Gravity.BOTTOM);
    }

    public class FloatLayerAdapter extends RecyclerView.Adapter<FloatLayerAdapter.ViewHolder> {
        private List<TUIInputViewFloatLayerData> mDataList;
        private OnItemClickListener onItemClickListener;

        public class ViewHolder extends RecyclerView.ViewHolder {
            TextView tvFloatLayer;

            public ViewHolder(View itemView) {
                super(itemView);
                tvFloatLayer = itemView.findViewById(R.id.tv_float_layer);
            }
        }

        public FloatLayerAdapter(List<TUIInputViewFloatLayerData> dataList) {
            this.mDataList = dataList;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.float_layer_item, parent, false);
            ViewHolder holder = new ViewHolder(view);
            return holder;
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            TUIInputViewFloatLayerData data = mDataList.get(position);
            holder.tvFloatLayer.setText(data.getContent());
            holder.tvFloatLayer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onItemClick(view, holder.getBindingAdapterPosition());
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (mDataList != null) {
                return mDataList.size();
            } else {
                return 0;
            }
        }

        public void setOnItemClickListener(OnItemClickListener listener) {
            this.onItemClickListener = listener;
        }
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }
}
