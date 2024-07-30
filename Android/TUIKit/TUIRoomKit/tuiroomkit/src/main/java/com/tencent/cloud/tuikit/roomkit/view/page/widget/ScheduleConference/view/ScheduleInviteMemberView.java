package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.view;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;

public class ScheduleInviteMemberView extends BottomSheetDialog implements View.OnClickListener {
    private static final String           LABEL = "Label";
    private              TextView         mTvRoomId;
    private              TextView         mTvRoomLink;
    private              TextView         mTvTitle;
    private              Context          mContext;
    private              ConstraintLayout mLayoutCopyRoomId;
    private              ConstraintLayout mLayoutCopyRoomLink;

    public ScheduleInviteMemberView(@NonNull Context context, String roomId, String roomLink) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_schedule_success);
        mContext = context;
        initView(roomId, roomLink);
    }

    private void initView(String roomId, String roomLink) {
        mTvTitle = findViewById(R.id.tv_schedule_success_text);
        mTvRoomId = findViewById(R.id.tv_room_id);
        mTvRoomLink = findViewById(R.id.tv_room_link);
        mLayoutCopyRoomId = findViewById(R.id.cl_room_id_copy);
        mLayoutCopyRoomId.setOnClickListener(this);
        mLayoutCopyRoomLink = findViewById(R.id.cl_room_link_copy);
        mLayoutCopyRoomLink.setOnClickListener(this);
        mTvRoomId.setText(roomId);
        mTvRoomLink.setText(roomLink);
    }

    public void setTitleText(String titleText) {
        mTvTitle.setText(titleText);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.cl_room_id_copy) {
            copyRoomIdToClipboard();
        } else if (view.getId() == R.id.cl_room_link_copy) {
            copyRoomLinkToClipboard();
        }
    }

    private void copyRoomIdToClipboard() {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText(LABEL, mTvRoomId.getText());
        cm.setPrimaryClip(mClipData);
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_copy_room_id_success));
    }

    private void copyRoomLinkToClipboard() {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText(LABEL, mTvRoomLink.getText());
        cm.setPrimaryClip(mClipData);
        RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_copy_room_line_success));
    }

}
