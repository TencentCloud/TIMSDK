package com.tencent.qcloud.tim.uikit.modules.search.model;

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
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.modules.search.SearchFuntionUtils;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SearchMoreMsgAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>{
    private Context context;
    /**
     * 需要改变颜色的text
     */
    private String text;

    private int mViewType = -1;

    //data list
    private List<V2TIMMessage> mDataList;

    private int mTotalCount = 0;

    /**
     * 在MainActivity中设置text
     */
    public void setText(String text) {
        this.text = text;
    }

    public SearchMoreMsgAdapter(Context context) {
        this.context = context;
    }

    public int getTotalCount() {
        return mTotalCount;
    }

    public void setTotalCount(int mTotalCount) {
        this.mTotalCount = mTotalCount;
    }

    public void setDataSource(List<V2TIMMessage> provider) {
        if (provider == null) {
            if (mDataList != null) {
                mDataList.clear();
                mDataList = null;
            }
        } else {
            mDataList = provider;
        }

        notifyDataSetChanged();
    }

    public List<V2TIMMessage> getDataSource() {
        return mDataList;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        SearchMoreMsgAdapter.MessageViewHolder holder = new SearchMoreMsgAdapter.MessageViewHolder(LayoutInflater.from(context).inflate(R.layout.item_contact_search, parent, false));
        return holder;
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        SearchMoreMsgAdapter.MessageViewHolder contactViewHolder = (SearchMoreMsgAdapter.MessageViewHolder) holder;
        if (contactViewHolder != null && mDataList != null && mDataList.size() > 0 && position < mDataList.size()) {
            V2TIMMessage v2TIMMessage = mDataList.get(position);
            String title = "";
            if (!TextUtils.isEmpty(v2TIMMessage.getFriendRemark())) {
                title = v2TIMMessage.getFriendRemark();
            } else if (!TextUtils.isEmpty(v2TIMMessage.getNameCard())) {
                title = v2TIMMessage.getNameCard();
            } else if (!TextUtils.isEmpty(v2TIMMessage.getNickName())) {
                title = v2TIMMessage.getNickName();
            } else {
                title = v2TIMMessage.getUserID()== null ? v2TIMMessage.getGroupID() : v2TIMMessage.getUserID();
            }
            String subTitle = SearchFuntionUtils.getMessageText(v2TIMMessage);
            String path = v2TIMMessage.getFaceUrl();

            if (!TextUtils.isEmpty(path)) {
                GlideEngine.loadImage(contactViewHolder.mUserIconView, path, null);
            } else {
                contactViewHolder.mUserIconView.setImageResource(R.drawable.default_user_icon);
            }
            if (text != null) {
                //设置span
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
                    onItemClickListener.onClick(view, position);
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        if (mDataList == null) {
            return 0;
        }
        return mDataList.size();
    }

    @Override
    public int getItemViewType(int position) {
        return mViewType;
    }
    /**
     * Recyclerview的点击监听接口
     */
    public interface onItemClickListener {
        void onClick(View view, int pos);
    }

    private SearchMoreMsgAdapter.onItemClickListener onItemClickListener;

    public void setOnItemClickListener(SearchMoreMsgAdapter.onItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    class MessageViewHolder extends RecyclerView.ViewHolder {
        private LinearLayout mLlItem;
        private ImageView mUserIconView;
        private TextView mTvText;
        private TextView mSubTvText;

        public MessageViewHolder(View itemView) {
            super(itemView);
            mLlItem = (LinearLayout) itemView.findViewById(R.id.ll_item);
            mUserIconView = (ImageView) itemView.findViewById(R.id.ivAvatar);
            mTvText = (TextView) itemView.findViewById(R.id.conversation_title);
            mSubTvText = (TextView) itemView.findViewById(R.id.conversation_sub_title);
        }
    }

    /**
     * 正则匹配 返回值是一个SpannableString 即经过变色处理的数据
     */
    private SpannableString matcherSearchText(int color, String text, String keyword) {
        if (text == null || TextUtils.isEmpty(text)) {
            return SpannableString.valueOf("");
        }
        SpannableString spannableString = new SpannableString(text);
        //条件 keyword
        Pattern pattern = Pattern.compile(Pattern.quote(keyword), Pattern.CASE_INSENSITIVE);
        //匹配
        Matcher matcher = pattern.matcher(spannableString);
        while (matcher.find()) {
            int start = matcher.start();
            int end = matcher.end();
            //ForegroundColorSpan 需要new 不然也只能是部分变色
            spannableString.setSpan(new ForegroundColorSpan(color), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        //返回变色处理的结果
        return spannableString;
    }
}
