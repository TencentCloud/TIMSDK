package com.tencent.cloud.tuikit.roomkit.view.main.floatchat;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.service.IFindNameCardService;

public class FloatChatView extends FrameLayout {
    private Context                 mContext;
    private TUIFloatChatButton      mBarrageButton;
    private TUIFloatChatDisplayView mBarrageDisplay;
    private FrameLayout             mLayoutBarrageButtonContainer;
    private FrameLayout             mLayoutBarrageDisplayContainer;

    public FloatChatView(Context context, String roomId) {
        super(context);
        mContext = context;
        mBarrageButton = new TUIFloatChatButton(mContext, roomId);
        mBarrageDisplay = new TUIFloatChatDisplayView(mContext, roomId);
        initView();
    }

    private void initView() {
        removeAllViews();
        addView(LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_float_chat, this, false));
        mLayoutBarrageButtonContainer = findViewById(R.id.tuiroomkit_barrage_button_container);
        mLayoutBarrageDisplayContainer = findViewById(R.id.tuiroomkit_barrage_display_view_container);
        mLayoutBarrageDisplayContainer.addView(mBarrageDisplay);
        mLayoutBarrageButtonContainer.addView(mBarrageButton);
    }

    public void isShow(boolean enable) {
        mBarrageButton.setVisibility(enable ? View.VISIBLE : View.INVISIBLE);
        mBarrageDisplay.setVisibility(enable ? View.VISIBLE : View.INVISIBLE);
    }

    public void setFindUserNameCardService(IFindNameCardService service) {
        mBarrageDisplay.setFindNameCardService(service);
    }

    public void destroy() {
        mBarrageDisplay.destroyPresenter();
    }
}
