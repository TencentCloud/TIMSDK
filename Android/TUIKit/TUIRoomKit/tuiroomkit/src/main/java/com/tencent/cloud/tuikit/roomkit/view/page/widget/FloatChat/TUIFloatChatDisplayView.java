package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatIMService;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.FloatChatPresenter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IFindNameCardService;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IFloatChatMessage;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.service.IFloatChatPresenter;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.store.FloatChatStore;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.IFloatChatDisplayView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.MessageBarrageView;
import com.trtc.tuikit.common.livedata.Observer;

@SuppressLint("ViewConstructor")
public class TUIFloatChatDisplayView extends FrameLayout implements IFloatChatDisplayView {
    private static final String TAG = "TUIBarrageDisplayView";

    private MessageBarrageView   mViewMessageBarrage;
    private IFindNameCardService mFindNameCardService;

    private final IFloatChatPresenter    mPresenter;
    private final Observer<TUIFloatChat> mBarrageObserver = this::insertBarrages;

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
        mViewMessageBarrage = findViewById(R.id.tuiroomkit_view_message_barrage);
    }

    public void setFindNameCardService(IFindNameCardService service) {
        mFindNameCardService = service;
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
            String userNameCard = getUserNameCard(barrage);
            if (!TextUtils.isEmpty(userNameCard)) {
                barrage.user.userName = userNameCard;
            }
            mViewMessageBarrage.addMessage(barrage);
        }
    }

    private String getUserNameCard(TUIFloatChat barrage) {
        if (mFindNameCardService == null || barrage == null || TextUtils.isEmpty(barrage.user.userId)) {
            return "";
        }
        return mFindNameCardService.findUserNameCard(barrage.user.userId);
    }
}
