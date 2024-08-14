package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BotBranchBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BotBranchMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.ArrayList;
import java.util.List;

public class BotBranchListAdapter extends RecyclerView.Adapter {
    private final int ITEM_SHOW_COUNT = 4;
    private int lastItemPosition = 0;
    private TUICustomerServicePresenter presenter;
    private List<BotBranchBean.Item> botBranchItemTotalList = new ArrayList<>();
    private List<BotBranchBean.Item> botBranchItemList = new ArrayList<>();

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View rootView = inflater.inflate(R.layout.bot_branch_item_layout, parent, false);
        BotBranchItemHolder holder = new BotBranchItemHolder(rootView);
        holder.setAdapter(this);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        BotBranchBean.Item branchItem = botBranchItemList.get(position);
        BotBranchItemHolder branchItemHolder = (BotBranchItemHolder) holder;
        branchItemHolder.layoutViews(branchItem, position);
    }

    @Override
    public int getItemCount() {
        return botBranchItemList.size();
    }

    public void setPresenter(TUICustomerServicePresenter presenter) {
        this.presenter = presenter;
    }

    public TUICustomerServicePresenter getPresenter() {
        return this.presenter;
    }

    public void setBotBranchItemList(List<BotBranchBean.Item> itemList) {
        BotBranchMessageBean botBranchMessageBean = (BotBranchMessageBean) presenter.getMessageBean();

        if (TextUtils.equals(botBranchMessageBean.getBotBranchBean().getSubType(), TUICustomerServiceConstants.BOT_SUBTYPE_CLARIFY_MSG)) {
            botBranchItemList = itemList;
        } else {
            botBranchItemTotalList.clear();
            botBranchItemList.clear();

            botBranchItemTotalList.addAll(itemList);
            if (botBranchItemTotalList.size() <= 4) {
                botBranchItemList.addAll(botBranchItemTotalList);
            } else {
                for (int i = 0; i < botBranchItemTotalList.size(); i++) {
                    botBranchItemList.add(botBranchItemTotalList.get(i));
                    if (botBranchItemList.size() == ITEM_SHOW_COUNT) {
                        lastItemPosition = i;
                        break;
                    }
                }
            }
        }

        notifyDataSetChanged();
    }

    public void refreshData() {
        if (botBranchItemTotalList.size() <= 4) {
            return;
        }

        botBranchItemList.clear();
        int remainCount = botBranchItemTotalList.size() - lastItemPosition - 1;
        if (remainCount == 0) {
            for (int i = 0; i < botBranchItemTotalList.size(); i++) {
                botBranchItemList.add(botBranchItemTotalList.get(i));
                if (botBranchItemList.size() == ITEM_SHOW_COUNT) {
                    lastItemPosition = i;
                    break;
                }
            }
        } else if (remainCount <= 4) {
            botBranchItemList.addAll(botBranchItemTotalList.subList(lastItemPosition + 1, botBranchItemTotalList.size()));
            lastItemPosition = botBranchItemTotalList.size() - 1;
        } else {
            for (int i = lastItemPosition + 1; i < botBranchItemTotalList.size(); i++) {
                botBranchItemList.add(botBranchItemTotalList.get(i));
                if (botBranchItemList.size() == ITEM_SHOW_COUNT) {
                    lastItemPosition = i;
                    break;
                }
            }
        }

        notifyDataSetChanged();
    }
}
