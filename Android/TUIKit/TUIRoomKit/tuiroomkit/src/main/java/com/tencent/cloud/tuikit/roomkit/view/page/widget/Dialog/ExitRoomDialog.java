package com.tencent.cloud.tuikit.roomkit.view.page.widget.dialog;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.OWNER_EXIT_ROOM_ACTION;

import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
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
    private static final String TAG = "ExitRoomDialog";

    private Context mContext;

    public ExitRoomDialog(@NonNull Context context) {
        super(context);
        mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_dialog_exit_room);
        initWindow();
        initView();
    }

    private void initWindow() {
        Window window = getWindow();
        if (window == null) {
            return;
        }
        window.findViewById(com.google.android.material.R.id.design_bottom_sheet)
                .setBackgroundResource(R.drawable.tuiroomkit_bg_bottom_dialog_black_portrait);
        window.setBackgroundDrawableResource(android.R.color.transparent);
        window.setWindowAnimations(R.style.TUIRoomBottomDialogVerticalAnim);

        WindowManager.LayoutParams params = window.getAttributes();
        params.width = WindowManager.LayoutParams.MATCH_PARENT;
        params.height = getContext().getResources().getDisplayMetrics().heightPixels;
        params.gravity = Gravity.BOTTOM;
        params.flags =
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;
        window.setAttributes(params);

        View bottomSheetView = findViewById(com.google.android.material.R.id.design_bottom_sheet);
        ViewGroup.LayoutParams viewParams = bottomSheetView.getLayoutParams();
        viewParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        bottomSheetView.setLayoutParams(viewParams);

        BottomSheetBehavior<View> behavior = BottomSheetBehavior.from(bottomSheetView);
        behavior.setSkipCollapsed(true);
        behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        behavior.setPeekHeight(getContext().getResources().getDisplayMetrics().heightPixels);
    }

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
