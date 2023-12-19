package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuichatbotplugin.R;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotConstants;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.presenter.TUIChatBotPresenter;
import java.util.ArrayList;
import java.util.List;

public class BranchListAdapter extends RecyclerView.Adapter {
    private final int ITEM_SHOW_COUNT = 4;
    private int lastItemPosition = 0;
    private TUIChatBotPresenter presenter;
    private List<BranchBean.Item> branchItemTotalList = new ArrayList<>();
    private List<BranchBean.Item> branchItemList = new ArrayList<>();

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View rootView = inflater.inflate(R.layout.chat_bot_branch_item_layout, parent, false);
        BranchItemHolder holder = new BranchItemHolder(rootView);
        holder.setAdapter(this);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        BranchBean.Item branchItem = branchItemList.get(position);
        BranchItemHolder branchItemHolder = (BranchItemHolder) holder;
        branchItemHolder.layoutViews(branchItem, position);
    }

    @Override
    public int getItemCount() {
        return branchItemList.size();
    }

    public void setPresenter(TUIChatBotPresenter presenter) {
        this.presenter = presenter;
    }

    public TUIChatBotPresenter getPresenter() {
        return this.presenter;
    }

    public void setBranchItemList(List<BranchBean.Item> itemList) {
        BranchMessageBean messageBean = presenter.getMessageBean();

        if (TextUtils.equals(messageBean.getBranchBean().getSubType(), TUIChatBotConstants.CHAT_BOT_SUBTYPE_CLARIFY_MSG)) {
            branchItemList = itemList;
        } else {
            branchItemTotalList.clear();
            branchItemList.clear();

            branchItemTotalList.addAll(itemList);
            if (branchItemTotalList.size() <= 4) {
                branchItemList.addAll(branchItemTotalList);
            } else {
                for (int i = 0; i < branchItemTotalList.size(); i++) {
                    branchItemList.add(branchItemTotalList.get(i));
                    if (branchItemList.size() == ITEM_SHOW_COUNT) {
                        lastItemPosition = i;
                        break;
                    }
                }
            }
        }

        notifyDataSetChanged();
    }

    public void refreshData() {
        if (branchItemTotalList.size() <= 4) {
            return;
        }

        branchItemList.clear();
        int remainCount = branchItemTotalList.size() - lastItemPosition - 1;
        if (remainCount == 0) {
            for (int i = 0; i < branchItemTotalList.size(); i++) {
                branchItemList.add(branchItemTotalList.get(i));
                if (branchItemList.size() == ITEM_SHOW_COUNT) {
                    lastItemPosition = i;
                    break;
                }
            }
        } else if (remainCount <= 4) {
            branchItemList.addAll(branchItemTotalList.subList(lastItemPosition + 1, branchItemTotalList.size()));
            lastItemPosition = branchItemTotalList.size() - 1;
        } else {
            for (int i = lastItemPosition + 1; i < branchItemTotalList.size(); i++) {
                branchItemList.add(branchItemTotalList.get(i));
                if (branchItemList.size() == ITEM_SHOW_COUNT) {
                    lastItemPosition = i;
                    break;
                }
            }
        }

        notifyDataSetChanged();
    }
}
