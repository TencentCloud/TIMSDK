package com.tencent.cloud.tuikit.roomkit.view.create;

import android.content.Context;
import android.view.View;
import android.widget.Button;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;

public class RoomTypeSelectView extends BottomSheetDialog implements View.OnClickListener {
    private boolean    mIsSeatEnabled;
    private Button     mButtonConfirm;
    private Button     mButtonCancel;
    private RadioGroup mGroupRoomType;

    private SeatEnableCallback mSeatEnableCallback;

    public interface SeatEnableCallback {
        void onSeatEnableChanged(boolean enable);
    }

    public RoomTypeSelectView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_room_type_select);
        initView();
    }

    public void setSeatEnableCallback(SeatEnableCallback callback) {
        mSeatEnableCallback = callback;
    }

    private void initView() {
        mButtonCancel = findViewById(R.id.btn_cancel);
        mButtonConfirm = findViewById(R.id.btn_confirm);
        mGroupRoomType = findViewById(R.id.rg_room_type);

        mButtonCancel.setOnClickListener(this);
        mButtonConfirm.setOnClickListener(this);

        mGroupRoomType.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                mIsSeatEnabled = checkedId == R.id.rb_raise_hand;
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_cancel) {
            dismiss();
        } else if (v.getId() == R.id.btn_confirm) {
            if (mSeatEnableCallback != null) {
                mSeatEnableCallback.onSeatEnableChanged(mIsSeatEnabled);
            }
            dismiss();
        }
    }
}
