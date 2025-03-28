package com.tencent.cloud.tuikit.roomkit.view.main.roominfo;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MEETING_INFO;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;

import java.util.Locale;

import com.trtc.tuikit.common.livedata.Observer;

public class RoomInfoDialog extends BaseBottomDialog {
    private       TextView          mTextName;
    private       TextView          mTextMaster;
    private       TextView          mTextRoomId;
    private       TextView          mTextRoomType;
    private       TextView          mTextRoomLink;
    private       TextView          mTextRoomPassword;
    private       LinearLayout      mButtonCopyRoomId;
    private       LinearLayout      mButtonCopyRoomLink;
    private       LinearLayout      mButtonCopyRoomPassword;
    private       RelativeLayout    mRootCopyRoomLink;
    private       RelativeLayout    mRoomPasswordLayout;
    private       ImageButton       mButtonQRCode;
    private       Button            mButtonCopyInvitationLink;
    private       RoomInfoViewModel mViewModel;
    private final Observer<String>  mRoomNameObserver  = this::updateRoomNameView;
    private final Observer<String>  mOwnerNameObserver = this::updateOwnerNameView;

    public RoomInfoDialog(@NonNull Context context) {
        super(context);
        mViewModel = new RoomInfoViewModel(getContext(), this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_MEETING_INFO, null);
        mViewModel.destroy();
        ConferenceController.sharedInstance().getRoomState().roomName.removeObserver(mRoomNameObserver);
        ConferenceController.sharedInstance().getRoomState().ownerName.removeObserver(mOwnerNameObserver);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_meeting_info;
    }

    @Override
    protected void initView() {
        mTextName = findViewById(R.id.tv_info_name);
        mTextMaster = findViewById(R.id.tv_master);
        mTextRoomId = findViewById(R.id.tv_room_id);
        mTextRoomType = findViewById(R.id.tv_type);
        mRootCopyRoomLink = findViewById(R.id.tuiroomkit_root_room_link_layout);
        mTextRoomLink = findViewById(R.id.tv_room_link);
        mTextRoomPassword = findViewById(R.id.tv_room_password_content);
        mRoomPasswordLayout = findViewById(R.id.tuiroomkit_rl_room_password);
        mButtonCopyRoomId = findViewById(R.id.btn_copy_room_id);
        mButtonCopyRoomLink = findViewById(R.id.btn_copy_room_link);
        mButtonCopyRoomPassword = findViewById(R.id.btn_copy_room_password);
        mButtonCopyInvitationLink = findViewById(R.id.btn_copy_invitation_link_button);
        mButtonQRCode = findViewById(R.id.btn_qr_code);
        ConferenceController.sharedInstance().getRoomState().roomName.observe(mRoomNameObserver);
        ConferenceController.sharedInstance().getRoomState().ownerName.observe(mOwnerNameObserver);

        TUIRoomDefine.RoomInfo roomInfo = ConferenceController.sharedInstance().getConferenceState().roomInfo;
        mViewModel.setMasterName();
        initRoomPasswordView();
        mTextRoomType.setText(mViewModel.getRoomType());
        mTextRoomId.setText(roomInfo.roomId);
        mTextRoomLink.setText(mViewModel.getRoomURL());
        mRootCopyRoomLink.setVisibility(mViewModel.needShowRoomLink() ? View.VISIBLE : View.GONE);

        mButtonCopyRoomId.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.copyContentToClipboard(mTextRoomId.getText().toString(),
                        getContext().getString(R.string.tuiroomkit_copy_room_id_success));
            }
        });

        mButtonQRCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.showQRCodeView();
                dismiss();
            }
        });

        mButtonCopyRoomLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtils.copyToClipboard(mTextRoomLink.getText().toString(), getContext().getString(R.string.tuiroomkit_copy_room_line_success));
            }
        });

        mButtonCopyRoomPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtils.copyToClipboard(mTextRoomPassword.getText().toString(), getContext().getString(R.string.tuiroomkit_copy_room_password_success));
            }
        });

        mButtonCopyInvitationLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtils.copyToClipboard(getInviteLinkInfo(), getContext().getString(R.string.tuiroomkit_copy_room_invitation_link_success));
            }
        });
    }

    private String getInviteLinkInfo() {
        String selfName = ConferenceController.sharedInstance().getUserState().selfInfo.get().userName;
        if (TextUtils.isEmpty(mTextRoomPassword.getText().toString())) {
            return String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_without_password),
                    selfName, mTextName.getText().toString(), mTextRoomId.getText().toString());
        }
        return String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_with_password),
                selfName, mTextName.getText().toString(), mTextRoomId.getText().toString(), mTextRoomPassword.getText().toString());
    }

    public void setMasterName(String name) {
        mTextMaster.setText(name);
    }

    public void initRoomPasswordView() {
        String password = ConferenceController.sharedInstance(getContext()).getConferenceState().roomInfo.password;
        boolean isEnablePassword = (!TextUtils.isEmpty(password));
        mRoomPasswordLayout.setVisibility(isEnablePassword ? View.VISIBLE : View.GONE);
        mTextRoomPassword.setText(isEnablePassword ? password : "");
    }

    private void updateRoomNameView(String name) {
        mTextName.setText(name);
    }

    private void updateOwnerNameView(String name) {
        mTextMaster.setText(name);
    }
}
