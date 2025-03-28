package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.Locale;
import java.util.Map;

public class ScheduleInviteMemberView extends BottomSheetDialog implements View.OnClickListener {
    public static final String KEY_INVITE_ROOM_ID   = "roomId";
    public static final String KEY_INVITE_ROOM_TYPE = "roomType";
    public static final String KEY_INVITE_ROOM_NAME = "roomName";
    public static final String KEY_INVITE_ROOM_TIME = "roomTime";

    private Context          mContext;
    private TextView         mTvRoomName;
    private TextView         mTvRoomType;
    private TextView         mTvRoomTime;
    private TextView         mTvRoomId;
    private TextView         mTvTitle;
    private TextView         mTvPasswordTitle;
    private TextView         mTvPassword;
    private ConstraintLayout mLayoutCopyPassword;
    private ConstraintLayout mLayoutCopyRoomId;
    private Button           mCopyInviteLinkButton;

    public ScheduleInviteMemberView(@NonNull Context context, Map<String, Object> roomInfo) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_schedule_success);
        mContext = context;
        initView(roomInfo);
    }

    private void initView(Map<String, Object> roomInfo) {
        mTvTitle = findViewById(R.id.tv_schedule_success_text);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTvRoomType = findViewById(R.id.tv_room_type);
        mTvRoomTime = findViewById(R.id.tv_room_time);
        mTvRoomId = findViewById(R.id.tv_room_id);
        mTvPasswordTitle = findViewById(R.id.tv_room_password_title);
        mTvPassword = findViewById(R.id.tv_room_password);
        mLayoutCopyPassword = findViewById(R.id.cl_room_password_copy);
        mLayoutCopyRoomId = findViewById(R.id.cl_room_id_copy);
        mCopyInviteLinkButton = findViewById(R.id.btn_copy_invitation_link_button);

        mTvRoomId.setText((String) roomInfo.get(KEY_INVITE_ROOM_ID));
        mTvRoomName.setText((String) roomInfo.get(KEY_INVITE_ROOM_NAME));
        mTvRoomType.setText((String) roomInfo.get(KEY_INVITE_ROOM_TYPE));
        mTvRoomTime.setText((String) roomInfo.get(KEY_INVITE_ROOM_TIME));

        initRoomEncrypt(mTvRoomId.getText().toString());

        mLayoutCopyRoomId.setOnClickListener(this);
        mCopyInviteLinkButton.setOnClickListener(this);
        mLayoutCopyPassword.setOnClickListener(this);
    }

    private void initRoomEncrypt(String roomId) {
        ScheduleController.sharedInstance().fetchRoomInfo(roomId, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                updateRoomPassword(roomInfo.password);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                updateRoomPassword("");
            }
        });
    }

    private void updateRoomPassword(String password) {
        boolean isEnablePassword = (!TextUtils.isEmpty(password));
        mTvPasswordTitle.setVisibility(isEnablePassword ? View.VISIBLE : View.GONE);
        mTvPassword.setVisibility(isEnablePassword ? View.VISIBLE : View.GONE);
        mLayoutCopyPassword.setVisibility(isEnablePassword ? View.VISIBLE : View.GONE);
        mTvPassword.setText(isEnablePassword ? password : "");
    }

    public void setTitleText(String titleText) {
        mTvTitle.setText(titleText);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.cl_room_id_copy) {
            CommonUtils.copyToClipboard(mTvRoomId.getText().toString(), mContext.getString(R.string.tuiroomkit_copy_room_id_success));
        } else if (view.getId() == R.id.cl_room_password_copy) {
            CommonUtils.copyToClipboard(mTvPassword.getText().toString(), mContext.getString(R.string.tuiroomkit_copy_room_password_success));
        } else if (view.getId() == R.id.btn_copy_invitation_link_button) {
            String inviteLinkContent = "";
            if (TextUtils.isEmpty(mTvPassword.getText().toString())) {
                inviteLinkContent = String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_out_room),
                        TUILogin.getNickName(), mTvRoomName.getText().toString(), mTvRoomTime.getText().toString(), mTvRoomId.getText().toString());
            } else {
                inviteLinkContent = String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_out_room_with_password),
                        TUILogin.getNickName(), mTvRoomName.getText().toString(), mTvRoomTime.getText().toString(), mTvRoomId.getText().toString(), mTvPassword.getText().toString());
            }
            CommonUtils.copyToClipboard(inviteLinkContent, mContext.getString(R.string.tuiroomkit_copy_room_invitation_link_success));
        }
    }

}
