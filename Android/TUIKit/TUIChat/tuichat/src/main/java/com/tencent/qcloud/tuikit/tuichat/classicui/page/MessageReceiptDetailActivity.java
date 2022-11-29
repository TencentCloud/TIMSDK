package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.GroupMessageReadMembersInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.presenter.MessageReceiptPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MessageReceiptDetailActivity extends BaseLightActivity {

    private static final String TAG = MessageReceiptDetailActivity.class.getSimpleName();

    private MessageReceiptPresenter presenter;

    private TitleBarLayout titleBarLayout;

    private View groupDetailArea;
    private TextView msgAbstract;
    private ImageView msgAbstractImg;
    private TextView nameTv;
    private TextView timeTv;
    private TextView readTitleTv;
    private TextView unreadTitleTv;
    private View readTitle;
    private View unreadTitle;
    private View readTitleLine;
    private View unreadTitleLine;
    private RecyclerView readList;
    private RecyclerView unreadList;

    private View c2cDetailArea;
    private ImageView userFace;
    private TextView userName;

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
        setContentView(R.layout.msg_receipt_detail_layout);

        initView();
        initData();
    }

    private void initView() {
        titleBarLayout = findViewById(R.id.receipt_title);
        titleBarLayout.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        titleBarLayout.setTitle(getString(R.string.chat_message_detail), ITitleBarLayout.Position.MIDDLE);
        groupDetailArea = findViewById(R.id.group_read_details);
        c2cDetailArea = findViewById(R.id.user_read_detail);
        userFace = findViewById(R.id.user_face);
        userName = findViewById(R.id.user_name_tv);
        msgAbstract = findViewById(R.id.msg_abstract);
        msgAbstractImg = findViewById(R.id.msg_abstract_iv);
        nameTv = findViewById(R.id.name_tv);
        timeTv = findViewById(R.id.time_tv);
        readTitleTv = findViewById(R.id.read_title_tv);
        unreadTitleTv = findViewById(R.id.unread_title_tv);
        readTitleLine = findViewById(R.id.read_title_line);
        unreadTitleLine = findViewById(R.id.unread_title_line);
        readList = findViewById(R.id.read_list);
        unreadList = findViewById(R.id.unread_list);
        readTitle = findViewById(R.id.read_title);
        unreadTitle = findViewById(R.id.unread_title);

        readTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                readTitleLine.setVisibility(View.VISIBLE);
                readTitleTv.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(MessageReceiptDetailActivity.this, com.tencent.qcloud.tuicore.R.attr.core_primary_color)));
                readList.setVisibility(View.VISIBLE);
                unreadList.setVisibility(View.GONE);
                unreadTitleLine.setVisibility(View.INVISIBLE);
                unreadTitleTv.setTextColor(0xff444444);
            }
        });

        unreadTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                unreadTitleLine.setVisibility(View.VISIBLE);
                unreadTitleTv.setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(MessageReceiptDetailActivity.this, com.tencent.qcloud.tuicore.R.attr.core_primary_color)));
                unreadList.setVisibility(View.VISIBLE);
                readList.setVisibility(View.GONE);
                readTitleLine.setVisibility(View.INVISIBLE);
                readTitleTv.setTextColor(0xff444444);
            }
        });
    }

    private void initData() {
        Intent intent = getIntent();
        messageBean = (TUIMessageBean) intent.getSerializableExtra(TUIChatConstants.MESSAGE_BEAN);
        chatInfo = (ChatInfo) intent.getSerializableExtra(TUIChatConstants.CHAT_INFO);
        presenter = new MessageReceiptPresenter();

        setMsgAbstract();

        String userName = messageBean.getUserDisplayName();
        nameTv.setText(userName);
        long time = messageBean.getMessageTime();
        timeTv.setText(DateTimeUtil.getTimeFormatText(new Date(time * 1000)));

        if (!messageBean.isGroup()) {
            setUserDetail(messageBean);
            return;
        }

        readAdapter = new MemberAdapter();
        unreadAdapter = new MemberAdapter();
        readList.setLayoutManager(new CustomLinearLayoutManager(this));
        unreadList.setLayoutManager(new CustomLinearLayoutManager(this));
        readList.setAdapter(readAdapter);
        unreadList.setAdapter(unreadAdapter);

        presenter.getGroupMessageReadReceipt(messageBean, new IUIKitCallback<List<MessageReceiptInfo>>() {
            @Override
            public void onSuccess(List<MessageReceiptInfo> data) {
                MessageReceiptInfo info = data.get(0);
                readTitleTv.setText(getString(R.string.someone_have_read, info.getReadCount()));
                unreadTitleTv.setText(getString(R.string.someone_unread, info.getUnreadCount()));
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

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

    private void setMsgAbstract() {
        if (messageBean instanceof ImageMessageBean || messageBean instanceof VideoMessageBean) {
            msgAbstractImg.setLayoutParams(getImageParams(msgAbstractImg.getLayoutParams(), messageBean));
            msgAbstractImg.setVisibility(View.VISIBLE);
            if (messageBean instanceof ImageMessageBean) {
                GlideEngine.loadImage(msgAbstractImg, ((ImageMessageBean) messageBean).getDataPath());
            } else if (messageBean instanceof VideoMessageBean) {
                GlideEngine.loadImage(msgAbstractImg, ((VideoMessageBean) messageBean).getDataPath());
            }
            msgAbstract.setText("");
        } else {
            msgAbstractImg.setVisibility(View.GONE);
            if (messageBean instanceof FileMessageBean) {
                msgAbstract.setText(messageBean.getExtra() + ((FileMessageBean) messageBean).getFileName());
            } else {
                FaceManager.handlerEmojiText(msgAbstract, messageBean.getExtra(), false);
            }
        }
    }

    private void setUserDetail(TUIMessageBean messageBean) {
        groupDetailArea.setVisibility(View.GONE);
        c2cDetailArea.setVisibility(View.VISIBLE);
        String userId = messageBean.getUserId();
        if (chatInfo != null) {
            GlideEngine.loadUserIcon(userFace, chatInfo.getFaceUrl());
            userName.setText(chatInfo.getChatName());
        }

        c2cDetailArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, userId);
                TUICore.startActivity("FriendProfileActivity", bundle);
            }
        });
    }

    private ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, final TUIMessageBean msg) {
        int width;
        int height;
        if (msg instanceof ImageMessageBean) {
            width = ((ImageMessageBean) msg).getImgWidth();
            height = ((ImageMessageBean) msg).getImgHeight();
        } else {
            width = ((VideoMessageBean) msg).getImgWidth();
            height = ((VideoMessageBean) msg).getImgHeight();
        }
        if (width == 0 || height == 0) {
            return params;
        }
        int defaultSize = ScreenUtil.dip2px(40.32f);
        if (width > height) {
            params.width = defaultSize;
            params.height = defaultSize * height / width;
        } else {
            params.width = defaultSize * width / height;
            params.height = defaultSize;
        }
        return params;
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
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_receipt_member_item, parent, false);
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
                    TUICore.startActivity("FriendProfileActivity", bundle);
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
