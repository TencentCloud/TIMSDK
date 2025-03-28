package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.IFloatChatDisplayView;
import com.tencent.liteav.base.Log;

public class FloatChatPresenter implements IFloatChatPresenter, IFloatChatMessage.BarrageMessageDelegate {
    private static final String TAG = "BarragePresenter";

    protected final Context               mContext;
    private         IFloatChatDisplayView mDisplayView;
    private final   IFloatChatMessage     mFloatChatService;

    public FloatChatPresenter(Context context, IFloatChatMessage service) {
        mContext = context;
        mFloatChatService = service;
        mFloatChatService.setDelegate(this);
    }

    @Override
    public void initDisplayView(IFloatChatDisplayView view) {
        mDisplayView = view;
    }

    @Override
    public void destroyPresenter() {
        mDisplayView = null;
        mFloatChatService.setDelegate(null);
    }

    @Override
    public void sendBarrage(final TUIFloatChat barrage, final IFloatChatMessage.BarrageSendCallBack callback) {
        mFloatChatService.sendBarrage(barrage, new IFloatChatMessage.BarrageSendCallBack() {

            @Override
            public void onSuccess(TUIFloatChat barrage) {
                callback.onSuccess(barrage);
            }

            @Override
            public void onFailed(int code, String msg) {
                callback.onFailed(code, msg);
                Log.i(TAG, " sendBarrage failed errorCode = " + code + " , errorMsg = " + msg);
            }
        });
    }

    @Override
    public void onReceivedBarrage(TUIFloatChat barrage) {
        receiveBarrage(barrage);
    }

    @Override
    public void receiveBarrage(TUIFloatChat barrage) {
        if (barrage == null || barrage.content == null) {
            Log.i(TAG, " receiveBarrage barrage is empty");
            return;
        }
        if (mDisplayView != null) {
            mDisplayView.insertBarrages(barrage);
        }
    }
}
