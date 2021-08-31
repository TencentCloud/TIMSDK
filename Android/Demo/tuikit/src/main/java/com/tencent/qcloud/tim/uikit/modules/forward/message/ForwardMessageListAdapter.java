package com.tencent.qcloud.tim.uikit.modules.forward.message;

import android.util.SparseBooleanArray;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.base.IBaseViewHolder;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageEmptyHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;

import java.util.ArrayList;
import java.util.List;


public class ForwardMessageListAdapter extends MessageListAdapter {

    public static final int MSG_TYPE_HEADER_VIEW = -99;
    private static final String TAG = ForwardMessageListAdapter.class.getSimpleName();
    private boolean mLoading = true;
    private MessageLayout mRecycleView;
    private List<V2TIMMessage> mDataSource = new ArrayList<>();
    private MessageLayout.OnItemLongClickListener mOnItemLongClickListener;

    //消息转发
    private SparseBooleanArray mSelectedPositions = new SparseBooleanArray();
    private boolean isShowMutiSelectCheckBox = false;


    public void setShowMutiSelectCheckBox(boolean show){
        isShowMutiSelectCheckBox = show;

        if(!isShowMutiSelectCheckBox && mSelectedPositions != null){
            mSelectedPositions.clear();
        }
    }

    //设置给定位置条目的选择状态
    public void setItemChecked(int position, boolean isChecked) {
        mSelectedPositions.put(position, isChecked);
    }

    //根据位置判断条目是否选中
    private boolean isItemChecked(int position) {
        return mSelectedPositions.get(position);
    }

    public MessageLayout.OnItemLongClickListener getOnItemClickListener() {
        return this.mOnItemLongClickListener;
    }

    public void setOnItemClickListener(MessageLayout.OnItemLongClickListener listener) {
        this.mOnItemLongClickListener = listener;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder holder = ForwardMessageBaseHolder.ForwardFactory.getInstance(parent, this, viewType);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull final RecyclerView.ViewHolder holder, final int position) {
       /* V2TIMMessage msg = getItem(position);

        MessageInfo messageinfo = null;
        List<MessageInfo> list = MessageInfoUtil.TIMMessage2MessageInfo(msg);
        if (list != null && list.size() > 0) {
            messageinfo = list.get(list.size() - 1);
        }*/

        final MessageInfo msgInfo = getItem(position);
        if (holder instanceof MessageBaseHolder) {
            MessageBaseHolder baseHolder = (MessageBaseHolder) holder;
            baseHolder.setOnItemClickListener(mOnItemLongClickListener);

            switch (getItemViewType(position)) {
                case MessageInfo.MSG_TYPE_TEXT:
                case MessageInfo.MSG_TYPE_IMAGE:
                case MessageInfo.MSG_TYPE_VIDEO:
                case MessageInfo.MSG_TYPE_CUSTOM_FACE:
                case MessageInfo.MSG_TYPE_AUDIO:
                case MessageInfo.MSG_TYPE_FILE:
                case MessageInfo.MSG_TYPE_MERGE:
                    if (!isShowMutiSelectCheckBox) {
                        ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setVisibility(View.GONE);
                    } else {
                        ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setVisibility(View.VISIBLE);

                        //设置条目状态
                        ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setChecked(isItemChecked(position));
                        //checkBox的监听
                        ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (isItemChecked(position)) {
                                    setItemChecked(position, false);
                                } else {
                                    setItemChecked(position, true);
                                }
                            }
                        });

                        //条目view的监听
                        baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (isItemChecked(position)) {
                                    setItemChecked(position, false);
                                } else {
                                    setItemChecked(position, true);
                                }
                                notifyItemChanged(position);
                            }
                        });
                    }
                    break;
                default:
                    break;
            }
            baseHolder.layoutViews(msgInfo, position);
        }
        // 对于自定义消息，需要在正常布局之后，交给外部调用者重新加载渲染
        if (holder instanceof IBaseViewHolder) {
            bindCustomHolder(position, msgInfo, (IBaseViewHolder) holder);
        }
    }

    private void bindCustomHolder(int position, MessageInfo msg, IBaseViewHolder baseViewHolder) {
        for (TUIChatControllerListener chatListener : TUIKitListenerManager.getInstance().getTUIChatListeners()) {
            if (chatListener.bindCommonViewHolder(baseViewHolder, msg, position)) {
                return;
            }
        }
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mRecycleView = (MessageLayout) recyclerView;
        mRecycleView.setItemViewCacheSize(5);
    }

    public void showLoading() {
        if (mLoading) {
            return;
        }
        mLoading = true;
        notifyItemChanged(0);
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof MessageContentHolder) {
            ((MessageContentHolder) holder).msgContentFrame.setBackground(null);
        }
    }

    public void notifyDataSourceChanged(final int type, final int value) {
        BackgroundTasks.getInstance().postDelayed(new Runnable() {
            @Override
            public void run() {
                mLoading = false;
                if (type == MessageLayout.DATA_CHANGE_TYPE_REFRESH) {
                    notifyDataSetChanged();
                    mRecycleView.scrollToEnd();
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_ADD_BACK) {
                    notifyItemRangeInserted(mDataSource.size(), value);
                    notifyDataSetChanged();
                    mRecycleView.scrollToEnd();
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_UPDATE) {
                    notifyItemChanged(value);
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_LOAD || type == MessageLayout.DATA_CHANGE_TYPE_ADD_FRONT) {
                    //加载条目为数0，只更新动画
                    if (value == 0) {
                        notifyItemChanged(0);
                    } else {
                        //加载过程中有可能之前第一条与新加载的最后一条的时间间隔不超过5分钟，时间条目需去掉，所以这里的刷新要多一个条目
                        if (getItemCount() > value) {
                            notifyItemRangeInserted(0, value);
                        } else {
                            notifyItemRangeInserted(0, value);
                        }
                    }
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_DELETE) {
                    notifyItemRemoved(value);
                    notifyDataSetChanged();
                    mRecycleView.scrollToEnd();
                }
            }
        }, 100);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size();
    }

    @Override
    public int getItemViewType(int position) {
        MessageInfo msg = getItem(position);
        return msg.getMsgType();
    }

    public void setDataSource(List<V2TIMMessage> v2TIMMessages) {
        if (v2TIMMessages == null) {
            mDataSource.clear();
        } else {
            mDataSource = v2TIMMessages;
        }
        notifyDataSourceChanged(MessageLayout.DATA_CHANGE_TYPE_REFRESH, getItemCount());

        mSelectedPositions.clear();
    }

    public V2TIMMessage getMsgItem(int position){
        if (mDataSource == null){
            return null;
        }

        return mDataSource.get(position);
    }

    public MessageInfo getItem(int position) {
        if (mDataSource == null) {
            return null;
        }
        MessageInfo messageInfo = MessageInfoUtil.TIMMessage2MessageInfo(mDataSource.get(position));
        messageInfo.setSelf(false);
        return messageInfo;
    }
}