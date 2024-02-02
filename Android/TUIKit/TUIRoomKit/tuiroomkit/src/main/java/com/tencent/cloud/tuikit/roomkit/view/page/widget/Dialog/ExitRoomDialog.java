package com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.SHOW_OWNER_EXIT_ROOM_PANEL;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
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
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

import java.util.List;

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

    @Override
    public void dismiss() {
        super.dismiss();
        RoomEventCenter.getInstance().notifyUIEvent(DISMISS_EXIT_ROOM_VIEW, null);
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
        boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.getRole());

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
                    handleOwnerExitRoom();
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

    private void handleOwnerExitRoom() {
        UserEntity nextOwner = filterRoomOwner();
        if (nextOwner == null) {
            RoomEventCenter.getInstance().notifyUIEvent(SHOW_OWNER_EXIT_ROOM_PANEL, null);
            return;
        }
        RoomEngineManager manager = RoomEngineManager.sharedInstance();
        manager.changeUserRole(nextOwner.getUserId(), TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "changeUserRole onSuccess");
                manager.exitRoom(null);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "changeUserRole onError error=" + error + " message=" + message);
            }
        });
    }

    private UserEntity filterRoomOwner() {
        List<UserEntity> list = RoomEngineManager.sharedInstance().getRoomStore().allUserList;
        String localUserId = RoomEngineManager.sharedInstance().getRoomStore().userModel.userId;
        int count = 0;
        UserEntity nextOwner = null;
        for (UserEntity user : list) {
            if (TextUtils.equals(user.getUserId(), localUserId)
                    || user.getVideoStreamType() == TUIRoomDefine.VideoStreamType.SCREEN_STREAM) {
                continue;
            }
            count++;
            if (count > 1) {
                break;
            }
            nextOwner = user;
        }
        if (count > 1) {
            return null;
        }
        return nextOwner;
    }
}
