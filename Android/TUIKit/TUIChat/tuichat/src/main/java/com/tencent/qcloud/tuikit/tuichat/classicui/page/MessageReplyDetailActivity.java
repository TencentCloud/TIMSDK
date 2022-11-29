package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import static com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView.DATA_CHANGE_TYPE_UPDATE;

import android.os.Bundle;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply.ReplyDetailsView;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IReplyMessageHandler;
import com.tencent.qcloud.tuikit.tuichat.presenter.ReplyPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MessageReplyDetailActivity extends BaseLightActivity implements InputView.MessageHandler, IReplyMessageHandler {
    // 取一个足够大的偏移保证能一次性滚动到最底部
    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;

    private TitleBarLayout titleBarLayout;
    private MessageRecyclerView messageRecyclerView;
    private MessageAdapter messageAdapter;
    private ReplyDetailsView repliesList;
    private InputView inputView;
    private ReplyPresenter presenter;
    private TUIMessageBean message;
    private ChatInfo chatInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_message_reply_detail);

        message = (TUIMessageBean) getIntent().getSerializableExtra(TUIChatConstants.MESSAGE_BEAN);
        chatInfo = (ChatInfo) getIntent().getSerializableExtra(TUIChatConstants.CHAT_INFO);
        presenter = new ReplyPresenter();
        presenter.setMessageId(message.getId());
        presenter.setChatInfo(chatInfo);
        presenter.setChatEventListener();
        presenter.setReplyHandler(this);
        titleBarLayout = findViewById(R.id.reply_title);
        titleBarLayout.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        titleBarLayout.setTitle(getString(R.string.chat_reply_detail), ITitleBarLayout.Position.MIDDLE);

        inputView = findViewById(R.id.reply_input_layout);
        inputView.disableMoreInput(true);
        inputView.disableAudioInput(true);
        inputView.disableShowCustomFace(true);
        inputView.setMessageHandler(this);

        repliesList = findViewById(R.id.replies_detail);

        messageRecyclerView = findViewById(R.id.message_view);
        messageRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        messageRecyclerView.setPresenter(presenter.getChatPresenter());
        messageRecyclerView.setItemAnimator(null);
        setOnEmptyAreaClickListener();
        initData();
    }

    private void initData() {
        if (message != null) {
            MessageRepliesBean repliesBean = message.getMessageRepliesBean();
            if (repliesBean != null) {
                presenter.findReplyMessages(repliesBean);
            }

            messageAdapter = new MessageAdapter();
            messageAdapter.setReplyDetailMode(true);
            messageAdapter.setPresenter(presenter.getChatPresenter());
            messageRecyclerView.setAdapter(messageAdapter);
            presenter.getReactUserBean(message, new IUIKitCallback<Void>() {
                @Override
                public void onSuccess(Void data) {
                    initMessageDetail();
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    initMessageDetail();
                }
            });
        }
    }

    private void initMessageDetail() {
        List<TUIMessageBean> messageBeanList = new ArrayList<>();
        messageBeanList.add(message);
        messageAdapter.onDataSourceChanged(messageBeanList);
        messageAdapter.onViewNeedRefresh(DATA_CHANGE_TYPE_UPDATE, message);
    }

    @Override
    public void sendMessage(TUIMessageBean replyContentMsg) {
        ReplyPreviewBean replyPreviewBean = ChatMessageBuilder.buildReplyPreviewBean(message);
        TUIMessageBean replyMessageBean = ChatMessageBuilder.buildReplyMessage(replyContentMsg.getExtra(), replyPreviewBean);
        presenter.sendReplyMessage(replyMessageBean, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                scrollToEnd();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("send reply failed code=" + errCode + " msg=" + errMsg);
            }
        });
    }

    @Override
    public void updateData(TUIMessageBean messageBean) {
        message = messageBean;
        initData();
    }

    @Override
    public void onRepliesMessageFound(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap) {
        if (repliesList != null) {
            repliesList.setData(messageBeanMap);
        }
    }


    @Override
    public void scrollToEnd() {
        if (repliesList.getAdapter() != null) {
            RecyclerView.LayoutManager layoutManager = repliesList.getLayoutManager();
            int itemCount = repliesList.getAdapter().getItemCount();
            if (layoutManager instanceof LinearLayoutManager && itemCount > 0) {
                ((LinearLayoutManager) layoutManager).scrollToPositionWithOffset(itemCount - 1, SCROLL_TO_END_OFFSET);
            }
        }
    }

    private void setOnEmptyAreaClickListener() {
        GestureDetector.OnGestureListener gestureListener = new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                inputView.onEmptyClick();
                return true;
            }
        };

        GestureDetector gestureDetector = new GestureDetector(this, gestureListener);
        repliesList.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                gestureDetector.onTouchEvent(event);
                return false;
            }
        });
    }

}