package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.IFloatChatDisplayView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.TUIFloatChatRecyclerView;
import com.tencent.liteav.base.Log;
import com.trtc.tuikit.common.livedata.Observer;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatIMService;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatPresenter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IFloatChatMessage;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IFloatChatPresenter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.store.FloatChatStore;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.adapter.FloatChatMsgListAdapter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.adapter.TUIFloatChatDisplayAdapter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;

import java.util.ArrayList;

@SuppressLint("ViewConstructor")
public class TUIFloatChatDisplayView extends FrameLayout implements IFloatChatDisplayView {
    private static final String TAG                            = "TUIBarrageDisplayView";
    private static final int    CLICK_ACTION_MAX_MOVE_DISTANCE = 10;

    private TextView                 mTextNotice;
    private TUIFloatChatRecyclerView mRecyclerMsg;
    private FloatChatMsgListAdapter  mAdapter;
    private ArrayList<TUIFloatChat>  mMsgList;
    private int                      mBarrageCount = 0;

    private final IFloatChatPresenter    mPresenter;
    private final Observer<TUIFloatChat> mBarrageObserver = this::insertBarrages;
    private       View.OnClickListener   mClickListener;
    private       float                  mTouchDownPointX;
    private       float                  mTouchDownPointY;
    private       boolean                mIsClickAction;

    public TUIFloatChatDisplayView(Context context, String roomId) {
        this(context, new FloatChatIMService(roomId));
    }

    private TUIFloatChatDisplayView(Context context, IFloatChatMessage service) {
        super(context);
        mPresenter = new FloatChatPresenter(context, service);
        mPresenter.initDisplayView(this);
        initView(context);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        FloatChatStore.sharedInstance().mSendBarrage.set(null);
        addObserver();
    }

    private void addObserver() {
        FloatChatStore.sharedInstance().mSendBarrage.observe(mBarrageObserver);
    }

    private void removeObserver() {
        FloatChatStore.sharedInstance().mSendBarrage.removeObserver(mBarrageObserver);
    }

    private void initView(Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_float_chat_view_display, this);
        mTextNotice = findViewById(R.id.tv_notice);
        mRecyclerMsg = findViewById(R.id.rv_msg);
        mMsgList = new ArrayList<>();
        if (FloatChatStore.sharedInstance().mRecordedMessage != null) {
            for (TUIFloatChat barrage : FloatChatStore.sharedInstance().mRecordedMessage) {
                mMsgList.add(barrage);
            }
        }
        mAdapter = new FloatChatMsgListAdapter(context, mMsgList, null);
        mRecyclerMsg.setLayoutManager(new LinearLayoutManager(context));
        mRecyclerMsg.setAdapter(mAdapter);
        mRecyclerMsg.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                mRecyclerMsg.onTouchEvent(motionEvent);
                return recognizeClickEventFromTouch(motionEvent);
            }
        });
    }

    public void setViewClickListener(OnClickListener clickListener) {
        mClickListener = clickListener;
    }

    private void setNotice(String username, String notice) {
        username = TextUtils.isEmpty(username) ? "" : username;
        notice = TextUtils.isEmpty(notice) ? "" : notice;
        String result = username + notice;
        SpannableStringBuilder builder = new SpannableStringBuilder(result);
        ForegroundColorSpan redSpan = new ForegroundColorSpan(Color.BLUE);
        builder.setSpan(redSpan, 0, username.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextNotice.setText(builder);
        mTextNotice.setBackgroundResource(R.drawable.tuiroomkit_float_chat_bg_msg_item);
    }

    public void setAdapter(TUIFloatChatDisplayAdapter adapter) {
        mAdapter.setCustomAdapter(adapter);
    }

    public void destroyPresenter() {
        mPresenter.destroyPresenter();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeObserver();
        FloatChatStore.sharedInstance().mSendBarrage.set(null);
    }

    @SuppressLint("NotifyDataSetChanged")
    @Override
    public void insertBarrages(TUIFloatChat... barrages) {
        if (barrages == null) {
            return;
        }
        for (TUIFloatChat barrage : barrages) {
            if (barrage == null) {
                Log.e(TAG, " insertBarrage barrages is empty");
                continue;
            }
            String message = barrage.content;
            Log.i(TAG, " insertBarrage message = " + message);
            mMsgList.add(barrage);
            FloatChatStore.sharedInstance().mRecordedMessage.add(barrage);
            mBarrageCount++;
        }
        mAdapter.notifyDataSetChanged();
        mRecyclerMsg.smoothScrollToPosition(mAdapter.getItemCount());
    }

    public int getBarrageCount() {
        return mBarrageCount;
    }

    private boolean recognizeClickEventFromTouch(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mTouchDownPointX = event.getX();
                mTouchDownPointY = event.getY();
                mIsClickAction = true;
                break;

            case MotionEvent.ACTION_MOVE:
                float xDistance = Math.abs(event.getX() - mTouchDownPointX);
                float yDistance = Math.abs(event.getY() - mTouchDownPointY);
                if (xDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE || yDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE) {
                    mIsClickAction = false;
                }
                break;

            case MotionEvent.ACTION_UP:
                if (mIsClickAction && mClickListener != null) {
                    mClickListener.onClick(this);
                }
                break;

            default:
                break;
        }

        return true;
    }
}
