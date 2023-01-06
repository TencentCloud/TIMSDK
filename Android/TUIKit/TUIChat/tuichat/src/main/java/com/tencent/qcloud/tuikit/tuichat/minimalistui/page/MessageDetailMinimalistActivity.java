package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.presenter.MessageReceiptPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ReplyPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.List;

public class MessageDetailMinimalistActivity extends BaseMinimalistLightActivity {

    private static final String TAG = MessageDetailMinimalistActivity.class.getSimpleName();

    private MessageReceiptPresenter presenter;
    private ReplyPresenter replyPresenter;

    private View readStatusArea;
    private View readTitle;
    private View unreadtitle;
    private FrameLayout messageArea;
    private RecyclerView readList;
    private RecyclerView unreadList;

    private TUIMessageBean messageBean;
    private ChatInfo chatInfo;

    private MemberAdapter readAdapter;
    private MemberAdapter unreadAdapter;

    private final List<GroupMemberInfo> readMemberList = new ArrayList<>();
    private final List<GroupMemberInfo> unreadMemberList = new ArrayList<>();
    private long readNextSeq;
    private long unreadNextSeq;
    private boolean readFinished = false;
    private boolean unreadFinished = false;

    private boolean readLoading = false;
    private boolean unreadLoading = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TUIChatLog.i(TAG, "onCreate " + this);
        setContentView(R.layout.chat_minimalist_message_detail_layout);

        initView();
        initData();
    }

    private void initView() {
        messageArea = findViewById(R.id.message_area);
        readStatusArea = findViewById(R.id.read_status_area);
        readList = findViewById(R.id.read_list);
        unreadList = findViewById(R.id.unread_list);
        unreadtitle = findViewById(R.id.unread_title);
        readTitle = findViewById(R.id.read_title);

        View backBtn = findViewById(R.id.back_btn_area);
        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
    }

    private void initData() {
        Intent intent = getIntent();
        messageBean = (TUIMessageBean) intent.getSerializableExtra(TUIChatConstants.MESSAGE_BEAN);
        chatInfo = (ChatInfo) intent.getSerializableExtra(TUIChatConstants.CHAT_INFO);
        presenter = new MessageReceiptPresenter();
        presenter.setChatInfo(chatInfo);
        presenter.setMessageReplyBean(messageBean, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                setMessageAndReceiptDetail();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                setMessageAndReceiptDetail();
            }
        });
    }

    private void setMessageAndReceiptDetail() {
        setMsgAbstract();

        if (!messageBean.isSelf()) {
            readStatusArea.setVisibility(View.GONE);
            return;
        }

        readAdapter = new MemberAdapter();
        unreadAdapter = new MemberAdapter();
        readList.setLayoutManager(new CustomLinearLayoutManager(this));
        unreadList.setLayoutManager(new CustomLinearLayoutManager(this));
        readList.setAdapter(readAdapter);
        unreadList.setAdapter(unreadAdapter);

        if (!messageBean.isGroup()) {
            setUserReadStatus(messageBean);
            return;
        }

        presenter.getGroupMessageReadReceipt(messageBean, new IUIKitCallback<List<MessageReceiptInfo>>() {
            @Override
            public void onSuccess(List<MessageReceiptInfo> data) {
                MessageReceiptInfo info = data.get(0);
                if (info.getReadCount() <= 0) {
                    readTitle.setVisibility(View.GONE);
                }
                if (info.getUnreadCount() <= 0) {
                    unreadtitle.setVisibility(View.GONE);
                }
            }

            @Override
            public void onError(int errCode, String errMsg, List<MessageReceiptInfo> data) {
                super.onError(errCode, errMsg, data);
            }
        });

        readList.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int state) {
                if (state == RecyclerView.SCROLL_STATE_IDLE) {
                    if (isLastItemVisibleCompleted(readList) && !readFinished) {
                        loadGroupMessageReadMembers(readNextSeq);
                    }
                }
            }
        });

        unreadList.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int state) {
                if (state == RecyclerView.SCROLL_STATE_IDLE) {
                    if (isLastItemVisibleCompleted(unreadList) && !unreadFinished) {
                        loadGroupMessageUnreadMembers(unreadNextSeq);
                    }
                }
            }
        });

        loadGroupMessageReadMembers(0);
        loadGroupMessageUnreadMembers(0);
    }

    private void setUserReadStatus(TUIMessageBean messageBean) {
        String userId = messageBean.getUserId();
        GroupMemberInfo groupMemberInfo = new GroupMemberInfo();
        groupMemberInfo.setAccount(userId);
        groupMemberInfo.setFriendRemark(chatInfo.getChatName());
        groupMemberInfo.setIconUrl(chatInfo.getFaceUrl());
        if (messageBean.isPeerRead()) {
            unreadtitle.setVisibility(View.GONE);
            readMemberList.add(groupMemberInfo);
            readAdapter.setData(readMemberList);
            readAdapter.notifyDataSetChanged();
        } else {
            readTitle.setVisibility(View.GONE);
            unreadMemberList.add(groupMemberInfo);
            unreadAdapter.setData(unreadMemberList);
            unreadAdapter.notifyDataSetChanged();
        }
    }

    private void setMsgAbstract() {
        int type = MinimalistUIService.getInstance().getViewType(messageBean.getClass());
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(messageArea, null, type);
        if (holder instanceof MessageContentHolder) {
            ((MessageContentHolder) holder).layoutViews(messageBean, 0);
            ((MessageContentHolder) holder).setTranslationContent(messageBean, 0);
        }
        messageArea.addView(holder.itemView);
    }

    private void loadGroupMessageReadMembers(long seq) {
        if (readLoading) {
            return;
        }
        readLoading = true;
        presenter.getGroupMessageReadMembers(messageBean, true, seq, new IUIKitCallback<GroupMessageReadMembersInfo>() {
            @Override
            public void onSuccess(GroupMessageReadMembersInfo data) {
                readNextSeq = data.getNextSeq();
                readFinished = data.isFinished();
                readMemberList.addAll(data.getGroupMemberInfoList());
                readAdapter.setData(readMemberList);
                readAdapter.notifyDataSetChanged();
                readLoading = false;
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                readLoading = false;
                TUIChatLog.e(TAG, "errCode " + errCode + " errMsg " + errMsg);
            }
        });
    }

    private void loadGroupMessageUnreadMembers(long seq) {
        if (unreadLoading) {
            return;
        }
        unreadLoading = true;
        presenter.getGroupMessageReadMembers(messageBean, false, seq, new IUIKitCallback<GroupMessageReadMembersInfo>() {
            @Override
            public void onSuccess(GroupMessageReadMembersInfo data) {
                unreadNextSeq = data.getNextSeq();
                unreadFinished = data.isFinished();
                unreadMemberList.addAll(data.getGroupMemberInfoList());
                unreadAdapter.setData(unreadMemberList);
                unreadAdapter.notifyDataSetChanged();
                unreadLoading = false;
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                unreadLoading = false;
                TUIChatLog.e(TAG, "errCode " + errCode + " errMsg " + errMsg);
            }
        });
    }

    public boolean isLastItemVisibleCompleted(RecyclerView recyclerView) {
        LinearLayoutManager linearLayoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
        if (linearLayoutManager == null) {
            return false;
        }
        int lastPosition = linearLayoutManager.findLastCompletelyVisibleItemPosition();
        int childCount = linearLayoutManager.getChildCount();
        int firstPosition = linearLayoutManager.findFirstVisibleItemPosition();
        if (lastPosition >= firstPosition + childCount - 1) {
            return true;
        }
        return false;
    }

    static class MemberAdapter extends RecyclerView.Adapter<MemberAdapter.MemberViewHolder> {

        private List<GroupMemberInfo> data;

        public void setData(List<GroupMemberInfo> data) {
            this.data = data;
        }

        @NonNull
        @Override
        public MemberViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_minimalist_group_receipt_member_item, parent, false);
            return new MemberViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull MemberViewHolder holder, int position) {
            GroupMemberInfo memberInfo = data.get(position);
            GlideEngine.loadUserIcon(holder.face, memberInfo.getIconUrl());
            holder.name.setText(getDisplayName(memberInfo));
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TUIChat.CHAT_ID, memberInfo.getAccount());
                    TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
                }
            });
        }

        @Override
        public int getItemCount() {
            if (data != null && !data.isEmpty()) {
                return data.size();
            }
            return 0;
        }

        static class MemberViewHolder extends RecyclerView.ViewHolder {
            private final ImageView face;
            private final TextView name;

            public MemberViewHolder(@NonNull View itemView) {
                super(itemView);
                face = itemView.findViewById(R.id.avatar_img);
                name = itemView.findViewById(R.id.name_tv);
            }
        }

        private String getDisplayName(GroupMemberInfo memberInfo) {
            String displayName;
            if (!TextUtils.isEmpty(memberInfo.getNameCard())) {
                displayName = memberInfo.getNameCard();
            } else if (!TextUtils.isEmpty(memberInfo.getFriendRemark())) {
                displayName = memberInfo.getFriendRemark();
            } else if (!TextUtils.isEmpty(memberInfo.getNickName())) {
                displayName = memberInfo.getNickName();
            } else {
                displayName = memberInfo.getAccount();
            }
            return displayName;
        }
    }

}
