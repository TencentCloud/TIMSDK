package com.tencent.cloud.tuikit.roomkit.view.main.floatchat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.widget.FrameLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model.TUIFloatChat;
import com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.FloatChatSendView;

@SuppressLint("ViewConstructor")
public class TUIFloatChatButton extends FrameLayout {

    private final String            mRoomId;
    private       FloatChatSendView mBarrageSendView;


    public TUIFloatChatButton(Context context, String roomId) {
        super(context);
        this.mRoomId = roomId;
        initView(context);
    }

    private void initView(final Context context) {
        LayoutInflater.from(context).inflate(R.layout.tuiroomkit_float_chat_view_send, this);
        mBarrageSendView = new FloatChatSendView(context, mRoomId);
        setOnClickListener(v -> {
            if (!mBarrageSendView.isShowing()) {
                mBarrageSendView.show();
            }
        });
    }

    public void setOnSendListener(OnSendListener listener) {
        mBarrageSendView.setOnSendListener(listener);
    }

    public interface OnSendListener {
        void willSendBarrage(TUIFloatChat barrage);
    }
}
