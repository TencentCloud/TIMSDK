package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.view.View;
import android.widget.Button;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;

public class SetConferenceTypeView extends BottomSheetDialog implements View.OnClickListener {
    private Button mButtonCancel;
    private Button mButtonFreeToSpeak;
    private Button mButtonRaiseHand;

    private SeatEnableCallback mSeatEnableCallback;

    public interface SeatEnableCallback {
        void onSeatEnableChanged(boolean enable);
    }

    public void setSeatEnableCallback(SeatEnableCallback callback) {
        mSeatEnableCallback = callback;
    }

    public SetConferenceTypeView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_conference_type_select);
        initView();
    }

    private void initView() {
        mButtonCancel = findViewById(R.id.btn_cancel_select);
        mButtonFreeToSpeak = findViewById(R.id.btn_free_speech);
        mButtonRaiseHand = findViewById(R.id.btn_raise_hand);
        mButtonCancel.setOnClickListener(this);
        mButtonFreeToSpeak.setOnClickListener(this);
        mButtonRaiseHand.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_cancel_select) {
            dismiss();
        } else if (v.getId() == R.id.btn_free_speech) {
            setConferenceType(false);
        } else if (v.getId() == R.id.btn_raise_hand) {
            setConferenceType(true);
        }
    }

    private void setConferenceType(boolean isSeatEnabled) {
        if (mSeatEnableCallback != null) {
            mSeatEnableCallback.onSeatEnableChanged(isSeatEnabled);
        }
        dismiss();
    }
}
