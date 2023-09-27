package com.tencent.cloud.tuikit.roomkit.view.component;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.OWNER_EXIT_ROOM_ACTION;

import android.content.Context;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;

public class ExitRoomDialog extends BaseBottomDialog {
    private static final String TAG = "ExitRoomDialog";

    private Context mContext;

    public ExitRoomDialog(@NonNull Context context) {
        super(context);
        mContext = context;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_exit_room;
    }

    @Override
    protected void initView() {
        UserModel userModel = RoomEngineManager.sharedInstance(mContext).getRoomStore().userModel;
        boolean isOnlyOneUserInRoom = RoomEngineManager.sharedInstance().getRoomStore().getTotalUserCount() == 1;
        boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.role);

        TextView leaveRoomTipsTv = findViewById(R.id.tv_leave_tips);
        leaveRoomTipsTv.setText(
                (isOwner && !isOnlyOneUserInRoom) ? mContext.getString(R.string.tuiroomkit_leave_room_tips) :
                        mContext.getString(R.string.tuiroomkit_confirm_leave_tip));
        Button exitRoomBtn = findViewById(R.id.btn_leave_room);
        exitRoomBtn.setVisibility(isOwner && isOnlyOneUserInRoom ? View.GONE : View.VISIBLE);
        Button destroyRoomBtn = findViewById(R.id.btn_finish_room);
        destroyRoomBtn.setVisibility(isOwner ? View.VISIBLE : View.GONE);

        exitRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isOwner) {
                    RoomEventCenter.getInstance().notifyUIEvent(OWNER_EXIT_ROOM_ACTION, null);
                } else {
                    RoomEngineManager.sharedInstance().exitRoom(null);
                }
                dismiss();
            }
        });
        destroyRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                RoomEngineManager.sharedInstance().destroyRoom(null);
                dismiss();
            }
        });
    }
}
