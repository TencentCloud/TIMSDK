package com.tencent.cloud.tuikit.roomkit.view.main.exitroom;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_EXIT_ROOM_VIEW;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SHOW_OWNER_EXIT_ROOM_PANEL;

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
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

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
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_EXIT_ROOM_VIEW, null);
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
        UserModel userModel = ConferenceController.sharedInstance(mContext).getConferenceState().userModel;
        boolean isOnlyOneUserInRoom = ConferenceController.sharedInstance().getConferenceState().getTotalUserCount() == 1;
        boolean isOwner = TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.getRole());

        TextView leaveRoomTipsTv = findViewById(R.id.tv_leave_tips);
        leaveRoomTipsTv.setText(
                (isOwner && !isOnlyOneUserInRoom) ? mContext.getString(R.string.tuiroomkit_leave_room_tips) :
                        mContext.getString(R.string.tuiroomkit_confirm_leave_tip));
        Button exitRoomBtn = findViewById(R.id.btn_leave_room);
        Button destroyRoomBtn = findViewById(R.id.btn_finish_room);
        destroyRoomBtn.setVisibility(isOwner ? View.VISIBLE : View.GONE);

        exitRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isOwner) {
                    handleOwnerExitRoom();
                } else {
                    ConferenceController.sharedInstance().exitRoom();
                }
                dismiss();
            }
        });
        destroyRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ConferenceController.sharedInstance().destroyRoom(null);
                dismiss();
            }
        });
    }

    private void handleOwnerExitRoom() {
        ConferenceController manager = ConferenceController.sharedInstance();
        int userCount = ConferenceController.sharedInstance().getConferenceState().getTotalUserCount();
        if (userCount == 1) {
            manager.exitRoom();
            return;
        }
        UserEntity nextOwner = filterRoomOwner();
        if (nextOwner == null) {
            ConferenceEventCenter.getInstance().notifyUIEvent(SHOW_OWNER_EXIT_ROOM_PANEL, null);
            return;
        }
        manager.changeUserRole(nextOwner.getUserId(), TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "changeUserRole onSuccess");
                manager.exitRoom();
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "changeUserRole onError error=" + error + " message=" + message);
            }
        });
    }

    private UserEntity filterRoomOwner() {
        List<UserEntity> list = ConferenceController.sharedInstance().getConferenceState().allUserList;
        String localUserId = ConferenceController.sharedInstance().getConferenceState().userModel.userId;
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
