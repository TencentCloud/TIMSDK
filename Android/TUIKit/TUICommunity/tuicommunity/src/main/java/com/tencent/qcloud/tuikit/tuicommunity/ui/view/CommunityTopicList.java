package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.UnreadCountTextView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicFoldBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TreeNode;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.TopicPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityTopicList;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CommunityTopicList extends RecyclerView implements ICommunityTopicList {
    private LinearLayoutManager layoutManager;
    private TopicAdapter topicAdapter;
    private TopicPresenter presenter;
    private CommunityDetailView.OnTopicClickListener onTopicClickListener;
    public CommunityTopicList(@NonNull Context context) {
        super(context);
        init();
    }

    public CommunityTopicList(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CommunityTopicList(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        layoutManager = new LinearLayoutManager(getContext());
        topicAdapter = new TopicAdapter();
        setLayoutManager(layoutManager);
        setAdapter(topicAdapter);
    }

    public void setPresenter(TopicPresenter presenter) {
        this.presenter = presenter;
        topicAdapter.setPresenter(presenter);
    }

    public void setOnTopicClickListener(CommunityDetailView.OnTopicClickListener onTopicClickListener) {
        this.onTopicClickListener = onTopicClickListener;
        topicAdapter.setOnTopicClickListener(onTopicClickListener);
    }

    public static class TopicAdapter extends RecyclerView.Adapter{

        private static final int VIEW_TYPE_TITLE = 1;
        private static final int VIEW_TYPE_TOPIC = 2;

        private TopicPresenter presenter;

        private List<TreeNode<ITopicBean>> data;
        private CommunityDetailView.OnTopicClickListener onTopicClickListener;

        public void setData(List<TreeNode<ITopicBean>> data) {
            this.data = data;
        }

        public void setPresenter(TopicPresenter presenter) {
            this.presenter = presenter;
        }

        public void setOnTopicClickListener(CommunityDetailView.OnTopicClickListener onTopicClickListener) {
            this.onTopicClickListener = onTopicClickListener;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            if (viewType == VIEW_TYPE_TITLE) {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_topic_list_title_layout, parent, false);
                return new TopicCategoryViewHolder(view);
            } else {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_topic_list_item_layout, parent, false);
                return new TopicViewHolder(view);
            }
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder viewHolder, int position) {
            if (viewHolder instanceof TopicViewHolder) {
                TopicViewHolder holder = (TopicViewHolder) viewHolder;
                TreeNode<ITopicBean> node = data.get(position);
                TopicBean topicBean = (TopicBean) node.getData();
                if (node.isCollapse()) {
                    holder.itemView.setVisibility(GONE);
                    ViewGroup.LayoutParams layoutParams = holder.itemView.getLayoutParams();
                    layoutParams.height = 0;
                    holder.itemView.setLayoutParams(layoutParams);
                } else {
                    ViewGroup.LayoutParams layoutParams = holder.itemView.getLayoutParams();
                    layoutParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
                    holder.itemView.setLayoutParams(layoutParams);
                    holder.itemView.setVisibility(VISIBLE);
                }

                if (topicBean.getType() == TopicBean.TOPIC_TYPE_TEXT) {
                    GlideEngine.loadImage(holder.topicFace, R.drawable.community_text_topic_icon);
                } else {
                    GlideEngine.loadImageSetDefault(holder.topicFace, topicBean.getFaceUrl(), R.drawable.community_text_topic_icon);
                }
                holder.topicTitle.setText(topicBean.getTopicName());
                holder.lastMsgAbstract.setText(topicBean.getLastMsgAbstract());
                if (topicBean.getUnreadCount() != 0) {
                    holder.topicUnread.setVisibility(VISIBLE);
                    holder.topicUnread.setText(topicBean.getUnreadCount() + "");
                } else {
                    holder.topicUnread.setVisibility(GONE);
                }
                holder.itemView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onTopicClickListener != null) {
                            onTopicClickListener.onClick(topicBean);
                        }
                    }
                });
            } else if (viewHolder instanceof TopicCategoryViewHolder) {
                TopicCategoryViewHolder holder = (TopicCategoryViewHolder) viewHolder;
                TreeNode<ITopicBean> node = data.get(position);
                TopicFoldBean foldBean = (TopicFoldBean) node.getData();
                if (node.isCollapse()) {
                    holder.indicatorImage.setImageResource(R.drawable.community_list_collapse_icon);
                } else {
                    holder.indicatorImage.setImageResource(R.drawable.community_list_expand_icon);
                }
                if (TextUtils.isEmpty(foldBean.getFoldName())) {
                    holder.topicCategory.setText(R.string.community_no_category);
                } else {
                    holder.topicCategory.setText(foldBean.getFoldName());
                }
                holder.itemView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        changeCollapseStatus(node);
                    }
                });
                holder.itemView.setOnLongClickListener(new OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        if (onTopicClickListener != null) {
                            onTopicClickListener.onCategoryLongClick(v, node);
                        }
                        return true;
                    }
                });
            }
        }

        private void changeCollapseStatus(TreeNode<ITopicBean> node) {
            presenter.changeTreeNodeCollapseStatus(node);
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }

        @Override
        public int getItemViewType(int position) {
            ITopicBean topicBean = data.get(position).getData();
            if (topicBean instanceof TopicFoldBean) {
                return VIEW_TYPE_TITLE;
            } else {
                return VIEW_TYPE_TOPIC;
            }
        }

        public static class TopicViewHolder extends RecyclerView.ViewHolder {
            private final UnreadCountTextView topicUnread;
            private final TextView topicTitle;
            private final TextView lastMsgAbstract;
            private final ImageView topicFace;
            public TopicViewHolder(@NonNull View itemView) {
                super(itemView);
                topicFace = itemView.findViewById(R.id.topic_face);
                topicTitle = itemView.findViewById(R.id.topic_title);
                lastMsgAbstract = itemView.findViewById(R.id.topic_last_msg);
                topicUnread = itemView.findViewById(R.id.topic_unread);
            }
        }

        public static class TopicCategoryViewHolder extends RecyclerView.ViewHolder {
            private final ImageView indicatorImage;
            private final TextView topicCategory;
            public TopicCategoryViewHolder(@NonNull View itemView) {
                super(itemView);
                indicatorImage = itemView.findViewById(R.id.indicator_image);
                topicCategory = itemView.findViewById(R.id.topic_category);
            }
        }
    }

    @Override
    public void onTopicListChanged(List<TreeNode<ITopicBean>> newData, List<TreeNode<ITopicBean>> oldData) {
        topicAdapter.setData(newData);
        topicAdapter.notifyDataSetChanged();
        setVisibility(VISIBLE);
    }

}
