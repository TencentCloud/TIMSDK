package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.widget.NestedScrollView;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IReplyMessageHandler;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIForwardChatMinimalistActivity;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply.ReplyDetailsView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.presenter.ReplyPresenter;
import java.util.Locale;
import java.util.Map;

public class ChatReplyDialogFragment extends DialogFragment implements IReplyMessageHandler {
    // 取一个足够大的偏移保证能一次性滚动到最底部
    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = 999999;
    private static final int SCROLL_TO_END_DELAY = 500;

    private BottomSheetDialog dialog;

    private TUIMessageBean originMessage;

    private View cancelBtn;
    private TextView title;
    private FrameLayout messageContent;
    private NestedScrollView scrollView;

    private ReplyDetailsView repliesList;
    private ReplyPresenter presenter;

    private ChatInfo chatInfo;

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        dialog = new BottomSheetDialog(getContext(), R.style.ChatPopActivityStyle);
        dialog.setCanceledOnTouchOutside(true);
        BottomSheetBehavior<FrameLayout> bottomSheetBehavior = dialog.getBehavior();
        bottomSheetBehavior.setFitToContents(false);
        bottomSheetBehavior.setHalfExpandedRatio(0.45f);
        bottomSheetBehavior.setSkipCollapsed(true);
        bottomSheetBehavior.setExpandedOffset(ScreenUtil.dip2px(36));
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (originMessage == null) {
            return super.onCreateView(inflater, container, savedInstanceState);
        }
        View view = inflater.inflate(R.layout.chat_reply_dialog_layout, container);
        cancelBtn = view.findViewById(R.id.cancel_btn);
        title = view.findViewById(R.id.title);
        scrollView = view.findViewById(R.id.scroll_view);
        messageContent = view.findViewById(R.id.message_content);
        repliesList = view.findViewById(R.id.replies_list);
        messageContent.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                messageContent.requestLayout();
            }
        });

        initData();
        return view;
    }

    public void setOriginMessage(TUIMessageBean originMessage) {
        this.originMessage = originMessage;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    private void initData() {
        if (originMessage != null) {
            showMessage();

            presenter = new ReplyPresenter();
            presenter.setMessageBean(originMessage);
            presenter.setChatInfo(chatInfo);
            presenter.setChatEventListener();
            presenter.setReplyHandler(this);

            MessageRepliesBean repliesBean = originMessage.getMessageRepliesBean();
            if (repliesBean != null) {
                presenter.findReplyMessages(repliesBean);
                title.setText(String.format(
                    Locale.US, getResources().getString(com.tencent.qcloud.tuikit.timcommon.R.string.chat_reply_num), repliesBean.getRepliesSize()));
            }

            cancelBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    dismiss();
                }
            });
        }
    }

    private void showMessage() {
        messageContent.removeAllViews();
        int type = MinimalistUIService.getInstance().getViewType(originMessage.getClass());
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(messageContent, null, type);
        if (holder instanceof MessageBaseHolder) {
            ((MessageContentHolder) holder).isMessageDetailMode = true;
            ((MessageContentHolder) holder).setBottomContent(originMessage);
            ((MessageContentHolder) holder).setOnItemClickListener(new OnItemClickListener() {
                @Override
                public void onMessageClick(View view, TUIMessageBean messageBean) {
                    if (messageBean instanceof MergeMessageBean) {
                        Intent intent = new Intent(view.getContext(), TUIForwardChatMinimalistActivity.class);
                        intent.putExtra(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, messageBean);
                        startActivity(intent);
                    }
                }
            });
            ((MessageBaseHolder) holder).layoutViews(originMessage, 0);
        }
        messageContent.addView(holder.itemView);
    }

    @Override
    public void updateData(TUIMessageBean messageBean) {
        if (messageBean == null) {
            return;
        }
        this.originMessage = messageBean;
        if (!isAdded()) {
            return;
        }
        showMessage();
        MessageRepliesBean repliesBean = messageBean.getMessageRepliesBean();
        if (repliesBean != null) {
            presenter.findReplyMessages(repliesBean);
        }
    }

    @Override
    public void onRepliesMessageFound(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap) {
        if (repliesList != null) {
            repliesList.setData(messageBeanMap);
            scrollToEnd();
        }
    }

    public void scrollToEnd() {
        scrollView.postDelayed(() -> scrollView.smoothScrollBy(0, SCROLL_TO_END_OFFSET), SCROLL_TO_END_DELAY);
    }
}
