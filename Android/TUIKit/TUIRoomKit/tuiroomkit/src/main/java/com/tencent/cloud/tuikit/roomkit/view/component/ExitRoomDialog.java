package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

public class ExitRoomDialog extends BottomSheetDialog {
    private static final String TAG = "ExitRoomDialog";

    public ExitRoomDialog(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_dialog_exit_room);

        UserModel userModel = RoomEngineManager.sharedInstance(context).getRoomStore().userModel;
        final boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.role);
        if (isOwner) {
            RoomEngineManager.sharedInstance(context).getRoomEngine()
                    .getUserList(0, new TUIRoomDefine.GetUserListCallback() {
                        @Override
                        public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                            initView(context, true, userListResult.userInfoList.size() == 1);
                        }

                        @Override
                        public void onError(TUICommonDefine.Error error, String s) {
                            Log.e(TAG, "get user list onError error=" + error + " s=" + s);
                            initView(context, true, false);
                        }
                    });
        } else {
            initView(context, false, false);
        }
    }

    private void initView(Context context, boolean isOwner, boolean isOnlyOneUserInRoom) {
        TextView leaveRoomTipsTv = findViewById(R.id.tv_leave_tips);
        leaveRoomTipsTv.setText(
                (isOwner && !isOnlyOneUserInRoom) ? context.getString(R.string.tuiroomkit_leave_room_tips) :
                        context.getString(R.string.tuiroomkit_confirm_leave_tip));
        Button leaveRoomBtn = findViewById(R.id.btn_leave_room);
        leaveRoomBtn.setVisibility(isOwner && isOnlyOneUserInRoom ? View.GONE : View.VISIBLE);
        Button finishRoomBtn = findViewById(R.id.btn_finish_room);
        finishRoomBtn.setVisibility(isOwner ? View.VISIBLE : View.GONE);

        leaveRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String event = isOwner ? RoomEventCenter.RoomKitUIEvent.LEAVE_MEETING :
                        RoomEventCenter.RoomKitUIEvent.EXIT_MEETING;
                RoomEventCenter.getInstance().notifyUIEvent(event, null);
                dismiss();
            }
        });
        finishRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, null);
                dismiss();
            }
        });
        Button cancelBtn = findViewById(R.id.btn_cancel);
        cancelBtn.setOnClickListener(new View.OnClickListener() {
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
