package com.tencent.qcloud.tim.uikit.modules.chat.layout.message;

import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IBaseViewHolder;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatProvider;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageCustomHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageEmptyHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageHeaderHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class MessageListAdapter extends RecyclerView.Adapter {

    public static final int MSG_TYPE_HEADER_VIEW = -99;
    private static final String TAG = MessageListAdapter.class.getSimpleName();
    private boolean mLoading = true;
    private MessageLayout mRecycleView;
    private List<MessageInfo> mDataSource = new ArrayList<>();
    private MessageLayout.OnItemLongClickListener mOnItemLongClickListener;

    //消息转发
    private HashMap<String, Boolean> mSelectedPositions = new HashMap<String, Boolean>();
    private boolean isShowMutiSelectCheckBox = false;

    private int mHighShowPosition;

    //获得选中条目的结果，msgid
    public ArrayList<MessageInfo> getSelectedItem() {
        if (mSelectedPositions == null || mSelectedPositions.size() == 0) {
            return null;
        }
        ArrayList<MessageInfo> selectList = new ArrayList<>();
        for (int i = 0; i < getItemCount()-1; i++) {
            if (isItemChecked(mDataSource.get(i).getId())) {
                selectList.add(mDataSource.get(i));
            }
        }

        return selectList;
    }

    public boolean getShowMutiSelectCheckBox(){
        return isShowMutiSelectCheckBox;
    }

    public void setShowMutiSelectCheckBox(boolean show){
        isShowMutiSelectCheckBox = show;

        if(!isShowMutiSelectCheckBox && mSelectedPositions != null){
            mSelectedPositions.clear();
        }
    }

    //设置给定位置条目的选择状态
    public void setItemChecked(String msgID, boolean isChecked) {
        if (mSelectedPositions == null) {
            return;
        }

        mSelectedPositions.put(msgID, isChecked);
    }

    //根据位置判断条目是否选中
    private boolean isItemChecked(String id) {
        if (mSelectedPositions.size() <= 0) {
            return false;
        }

        if (mSelectedPositions.containsKey(id)) {
            return mSelectedPositions.get(id);
        } else {
            return false;
        }
    }

    public MessageLayout.OnItemLongClickListener getOnItemClickListener() {
        return this.mOnItemLongClickListener;
    }

    public void setOnItemClickListener(MessageLayout.OnItemLongClickListener listener) {
        this.mOnItemLongClickListener = listener;
    }

    public void setHighShowPosition(int mHighShowPosition) {
        this.mHighShowPosition = mHighShowPosition;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder holder = MessageEmptyHolder.Factory.getInstance(parent, this, viewType);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull final RecyclerView.ViewHolder holder, final int position) {
        final MessageInfo msg = getItem(position);
        if (holder instanceof MessageBaseHolder) {
            final MessageBaseHolder baseHolder = (MessageBaseHolder) holder;
            baseHolder.setOnItemClickListener(mOnItemLongClickListener);
            String msgId = "";
            if (msg != null) {
                msgId = msg.getId();
            }

            switch (getItemViewType(position)) {
                case MSG_TYPE_HEADER_VIEW:
                    ((MessageHeaderHolder) baseHolder).setLoadingStatus(mLoading);
                    break;
                case MessageInfo.MSG_TYPE_TEXT:
                case MessageInfo.MSG_TYPE_IMAGE:
                case MessageInfo.MSG_TYPE_VIDEO:
                case MessageInfo.MSG_TYPE_CUSTOM_FACE:
                case MessageInfo.MSG_TYPE_AUDIO:
                case MessageInfo.MSG_TYPE_FILE:
                case MessageInfo.MSG_TYPE_MERGE: {
                    if (position == mHighShowPosition) {
                    /*ValueAnimator animator = ValueAnimator.ofInt(TUIKit.getAppContext().getResources().getColor(R.color.chat_background_color),TUIKit.getAppContext().getResources().getColor(R.color.green));
                    animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                        @Override
                        public void onAnimationUpdate(ValueAnimator animation) {
                            int curValue = (int)animation.getAnimatedValue();
                            ((MessageEmptyHolder) baseHolder).mContentLayout.setBackgroundColor(curValue);
                        }
                    });
                    animator.setRepeatMode(ValueAnimator.REVERSE);
                    animator.setRepeatCount(ValueAnimator.INFINITE);
                    animator.setDuration(3000);
                    animator.start();*/

                        final Handler mHandlerData = new Handler();
                        Runnable runnable = new Runnable() {
                            @Override
                            public void run() {
                                ((MessageEmptyHolder) baseHolder).mContentLayout.setBackgroundColor(TUIKit.getAppContext().getResources().getColor(R.color.line));
                                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                                    @Override
                                    public void run() {
                                        ((MessageEmptyHolder) baseHolder).mContentLayout.setBackgroundColor(TUIKit.getAppContext().getResources().getColor(R.color.chat_background_color));
                                    }
                                }, 600);
                            }
                        };

                        mHandlerData.postDelayed(runnable, 200);
                    }
                }
                break;
                default:
                    break;
            }
            baseHolder.layoutViews(msg, position);
            setCheckBoxStatus(position, msgId, baseHolder);
        }
        // 对于自定义消息，需要在正常布局之后，交给外部调用者重新加载渲染
        if (holder instanceof IBaseViewHolder) {
            if (holder instanceof MessageCustomHolder) {
                ((MessageCustomHolder) holder).setShowMutiSelect(isShowMutiSelectCheckBox);
            }
            bindCustomHolder(position, msg, (IBaseViewHolder) holder);
        }
    }

    private void bindCustomHolder(int position, MessageInfo msg, IBaseViewHolder customHolder) {
        for(TUIChatControllerListener chatListener : TUIKitListenerManager.getInstance().getTUIChatListeners()) {
            if (chatListener.bindCommonViewHolder(customHolder, msg, position)) {
                return;
            }
        }
    }

    // 设置多选框的选中状态和点击事件
    private void setCheckBoxStatus(final int position, final String msgId, MessageBaseHolder baseHolder) {
        if (!(baseHolder instanceof MessageEmptyHolder) || ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox == null) {
            return;
        }
        if (!isShowMutiSelectCheckBox) {
            ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setVisibility(View.GONE);
        } else {
            ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setVisibility(View.VISIBLE);

            //设置条目状态
            ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setChecked(isItemChecked(msgId));
            //checkBox的监听
            ((MessageEmptyHolder) baseHolder).mMutiSelectCheckBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (isItemChecked(msgId)) {
                        setItemChecked(msgId, false);
                    } else {
                        setItemChecked(msgId, true);
                    }
                }
            });

            //条目view的监听
            baseHolder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (isItemChecked(msgId)) {
                        setItemChecked(msgId, false);
                    } else {
                        setItemChecked(msgId, true);
                    }
                    notifyItemChanged(position);
                }
            });
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
                    notifyItemRangeInserted(mDataSource.size() + 1, value);
                    notifyDataSetChanged();
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_UPDATE) {
                    notifyItemChanged(value + 1);
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
                    notifyItemRemoved(value + 1);
                    notifyDataSetChanged();
                } else if (type == MessageLayout.DATA_CHANGE_SCROLL_TO_POSITION) {
                    notifyDataSetChanged();
                    mRecycleView.scrollToPositon(value);
                    mRecycleView.setHighShowPosition(value);
                } else if (type == MessageLayout.DATA_CHANGE_TYPE_NEW_MESSAGE) {
                    notifyItemRangeInserted(mDataSource.size() + 1, value);
                    notifyDataSetChanged();
                    mRecycleView.onMsgAddBack();
                }
            }
        }, 100);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size() + 1;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return MSG_TYPE_HEADER_VIEW;
        }
        MessageInfo msg = getItem(position);
        return msg.getMsgType();
    }

    public void setDataSource(IChatProvider provider) {
        if (provider == null) {
            mDataSource.clear();
        } else {
            mDataSource = provider.getDataSource();
            provider.setAdapter(this);
        }
        notifyDataSourceChanged(MessageLayout.DATA_CHANGE_TYPE_REFRESH, getItemCount());

        mSelectedPositions.clear();
    }

    public int getLastMessagePosition(V2TIMMessage lastlastMessage) {
        int positon = 0;
        if (mDataSource == null || mDataSource.isEmpty()) {
            return positon;
        }

        for (int i =0; i < mDataSource.size(); i++) {
            if (mDataSource.get(i).getTimMessage().getMsgID() == lastlastMessage.getMsgID()) {
                positon = i;
            }
        }
        return positon + 1;
    }

    public MessageInfo getItem(int position) {
        if (position == 0 || mDataSource.size() == 0) {
            return null;
        }
        MessageInfo info = mDataSource.get(position - 1);
        return info;
    }
}