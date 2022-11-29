package com.tencent.qcloud.tuikit.tuisearch.classicui.view;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.bean.SearchDataBean;
import com.tencent.qcloud.tuikit.tuisearch.interfaces.ISearchMoreMsgAdapter;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SearchMoreMsgAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> implements ISearchMoreMsgAdapter {
    private static final int SEARCH_MESSAGE_HEADER_TYPE = -1100;

    private Context context;

    private String text;

    private int mViewType = -1;

    //data list
    private List<SearchDataBean> mDataList;

    private int mTotalCount = 0;

    private SearchDataBean searchDataBean;

    private View.OnClickListener onConversationClickListener;

    private boolean isConversationVisible = true;

    public void setSearchDataBean(SearchDataBean searchDataBean) {
        this.searchDataBean = searchDataBean;
    }

    public void setOnConversationClickListener(View.OnClickListener onConversationClickListener) {
        this.onConversationClickListener = onConversationClickListener;
    }

    public void setText(String text) {
        this.text = text;
    }

    public SearchMoreMsgAdapter(Context context) {
        this.context = context;
    }

    public int getTotalCount() {
        return mTotalCount;
    }

    @Override
    public void onTotalCountChanged(int mTotalCount) {
        this.mTotalCount = mTotalCount;
    }

    @Override
    public void onDataSourceChanged(List<SearchDataBean> dataSource) {
        if (dataSource == null) {
            if (mDataList != null) {
                mDataList.clear();
                mDataList = null;
            }
        } else {
            mDataList = dataSource;
        }

        notifyDataSetChanged();
    }

    public List<SearchDataBean> getDataSource() {
        return mDataList;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == SEARCH_MESSAGE_HEADER_TYPE) {
            return new SearchMessageHeaderHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.search_header, parent, false));
        }
        return new MessageViewHolder(LayoutInflater.from(context).inflate(R.layout.item_contact_search, parent, false));
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        if (holder instanceof SearchMessageHeaderHolder) {
            bindSearchHeaderHolder((SearchMessageHeaderHolder) holder);
            return;
        }
        MessageViewHolder contactViewHolder = (MessageViewHolder) holder;
        if (contactViewHolder != null && mDataList != null && mDataList.size() > 0 && position <= mDataList.size()) {
            SearchDataBean dataBean = mDataList.get(position - 1);
            String title = dataBean.getTitle();
            String subTitle = dataBean.getSubTitle();
            String subTitleLabel = dataBean.getSubTitleLabel();
            String path = dataBean.getIconPath();

            contactViewHolder.mSubTvLabelText.setText(subTitleLabel);
            if (!TextUtils.isEmpty(path)) {
                GlideEngine.loadImage(contactViewHolder.mUserIconView, path);
            } else {
                int avatarIconResID;
                if (searchDataBean.isGroup()) {
                    avatarIconResID = TUIUtil.getDefaultGroupIconResIDByGroupType(context, searchDataBean.getGroupType());
                } else {
                    avatarIconResID = TUIThemeManager.getAttrResId(contactViewHolder.mUserIconView.getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_user_icon);
                }
                contactViewHolder.mUserIconView.setImageResource(avatarIconResID);
            }
            if (text != null) {
                SpannableString string = matcherSearchText(Color.rgb(0, 0, 255), title, text);
                contactViewHolder.mTvText.setText(string);

                SpannableString subString = matcherSearchText(Color.rgb(0, 0, 255), subTitle, text);
                contactViewHolder.mSubTvText.setText(subString);
            } else {
                contactViewHolder.mTvText.setText(title);
                contactViewHolder.mSubTvText.setText(subTitle);
            }
            contactViewHolder.mLlItem.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onItemClickListener.onClick(view, position - 1);
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        if (mDataList == null) {
            return 1;
        }
        return mDataList.size() + 1;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return SEARCH_MESSAGE_HEADER_TYPE;
        }
        return mViewType;
    }

    public interface onItemClickListener {
        void onClick(View view, int pos);
    }

    private SearchMoreMsgAdapter.onItemClickListener onItemClickListener;

    public void setOnItemClickListener(SearchMoreMsgAdapter.onItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    private void bindSearchHeaderHolder(SearchMessageHeaderHolder holder) {
        if (searchDataBean == null) {
            return;
        }
        if (isConversationVisible) {
            holder.conversationLayout.setVisibility(View.VISIBLE);
        } else {
            holder.conversationLayout.setVisibility(View.GONE);
        }
        holder.conversationLayout.setOnClickListener(onConversationClickListener);
        int avatarDefaultIconResID;
        if (searchDataBean.isGroup()) {
            avatarDefaultIconResID = TUIUtil.getDefaultGroupIconResIDByGroupType(context, searchDataBean.getGroupType());
        } else {
            avatarDefaultIconResID = TUIThemeManager.getAttrResId(holder.itemView.getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_user_icon);
        }
        if (!TextUtils.isEmpty(searchDataBean.getIconPath())) {
            GlideEngine.loadImageSetDefault(holder.conversationIcon, searchDataBean.getIconPath(), avatarDefaultIconResID);
        } else {
            holder.conversationIcon.setImageResource(avatarDefaultIconResID);
        }
        holder.conversationTitle.setText(searchDataBean.getTitle());
    }

    public void setConversationVisible(boolean isVisible) {
        isConversationVisible = isVisible;
        notifyItemChanged(0);
    }

    static class MessageViewHolder extends RecyclerView.ViewHolder {
        private LinearLayout mLlItem;
        private ImageView mUserIconView;
        private TextView mTvText;
        private TextView mSubTvText;
        private TextView mSubTvLabelText;

        public MessageViewHolder(View itemView) {
            super(itemView);
            mLlItem = (LinearLayout) itemView.findViewById(R.id.ll_item);
            mUserIconView = (ImageView) itemView.findViewById(R.id.ivAvatar);
            mTvText = (TextView) itemView.findViewById(R.id.conversation_title);
            mSubTvText = (TextView) itemView.findViewById(R.id.conversation_sub_title);
            mSubTvLabelText = (TextView) itemView.findViewById(R.id.conversation_sub_title_label);
        }
    }

    static class SearchMessageHeaderHolder extends RecyclerView.ViewHolder {
        private RelativeLayout conversationLayout;
        private ImageView conversationIcon;
        private TextView conversationTitle;
        public SearchMessageHeaderHolder(@NonNull View itemView) {
            super(itemView);
            conversationLayout = (RelativeLayout) itemView.findViewById(R.id.conversation_layout);
            conversationIcon = (ImageView) itemView.findViewById(R.id.icon_conversation);
            conversationTitle = (TextView) itemView.findViewById(R.id.conversation_title);
        }
    }

    private SpannableString matcherSearchText(int color, String text, String keyword) {
        if (text == null || TextUtils.isEmpty(text)) {
            return SpannableString.valueOf("");
        }
        SpannableString spannableString = new SpannableString(text);
        Pattern pattern = Pattern.compile(Pattern.quote(keyword), Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(spannableString);
        while (matcher.find()) {
            int start = matcher.start();
            int end = matcher.end();
            spannableString.setSpan(new ForegroundColorSpan(color), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        return spannableString;
    }
}
