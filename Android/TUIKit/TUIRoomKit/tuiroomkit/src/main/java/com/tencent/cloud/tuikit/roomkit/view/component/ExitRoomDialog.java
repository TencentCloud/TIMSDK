package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

public class ExitRoomDialog extends BottomSheetDialog {
    private TextView mTextTips;
    private Button   mButtonLeave;
    private Button   mButtonFinish;
    private Button   mButtonCancel;

    public ExitRoomDialog(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_dialog_exit_room);
        mTextTips = findViewById(R.id.tv_leave_tips);
        mButtonLeave = findViewById(R.id.btn_leave_room);
        mButtonFinish = findViewById(R.id.btn_finish_room);
        mButtonCancel = findViewById(R.id.btn_cancel);
        UserModel userModel = RoomEngineManager.sharedInstance(context).getRoomStore().userModel;
        final boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.role);
        if (isOwner) {
            mTextTips.setText(context.getString(R.string.tuiroomkit_leave_room_tips));
            mButtonFinish.setVisibility(View.VISIBLE);
        } else {
            mTextTips.setText(context.getString(R.string.tuiroomkit_confirm_leave_tip));
            mButtonFinish.setVisibility(View.GONE);
        }

        mButtonLeave.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String event = isOwner ? RoomEventCenter.RoomKitUIEvent.LEAVE_MEETING
                        : RoomEventCenter.RoomKitUIEvent.EXIT_MEETING;
                RoomEventCenter.getInstance().notifyUIEvent(event, null);
                dismiss();
            }
        });
        mButtonFinish.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, null);
                dismiss();
            }
        });
        mButtonCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getBehavior().setState(BottomSheetBehavior.STATE_EXPANDED);
        super.onCreate(savedInstanceState);
    }
}
