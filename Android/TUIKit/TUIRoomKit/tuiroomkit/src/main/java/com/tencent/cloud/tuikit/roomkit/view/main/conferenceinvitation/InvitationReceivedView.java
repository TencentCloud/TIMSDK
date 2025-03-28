package com.tencent.cloud.tuikit.roomkit.view.main.conferenceinvitation;

import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DESTROY_INVITATION_RECEIVED_ACTIVITY;

import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainActivity;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

import de.hdodenhof.circleimageview.CircleImageView;

public class InvitationReceivedView extends RelativeLayout {

    private Context mContext;

    private ImageView         mImgBackground;
    private CircleImageView   mImgInviterAvatar;
    private TextView          mTextInvitation;
    private TextView          mTextConferenceName;
    private TextView          mTextOwnerName;
    private TextView          mTextMemberCount;
    private SlideToAcceptView mViewSlideToAccept;
    private Button            mBtnReject;
    private String            mInviteRoomId;

    private Observer<Boolean> mIsNeedToDestroy = this::destroy;

    public InvitationReceivedView(Context context) {
        this(context, null);
    }

    public InvitationReceivedView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public InvitationReceivedView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        mContext = context;
        View.inflate(context, R.layout.tuiroomkit_view_conference_invitaion_received, this);
        mImgBackground = findViewById(R.id.img_background);
        mImgInviterAvatar = findViewById(R.id.img_inviter_avatar);
        mTextInvitation = findViewById(R.id.tv_invitation);
        mTextConferenceName = findViewById(R.id.tv_conference_name);
        mTextOwnerName = findViewById(R.id.tv_conference_owner);
        mTextMemberCount = findViewById(R.id.tv_conference_member_count);
        mViewSlideToAccept = findViewById(R.id.view_accept_invitation);
        mBtnReject = findViewById(R.id.btn_reject_invitation);

        mViewSlideToAccept.setListener(new SlideToAcceptView.AcceptListener() {
            @Override
            public void onAccept() {
                ConferenceController.sharedInstance().getInvitationController().accept(mInviteRoomId, null);
                ConferenceDefine.JoinConferenceParams params = new ConferenceDefine.JoinConferenceParams(mInviteRoomId);
                Intent intent = new Intent(mContext, ConferenceMainActivity.class);
                intent.putExtra(KEY_JOIN_CONFERENCE_PARAMS, params);
                mContext.startActivity(intent);
                ConferenceController.sharedInstance().getViewState().isInvitationPending.set(false);
            }
        });

        mBtnReject.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ConferenceController.sharedInstance().getInvitationController().reject(mInviteRoomId, TUIConferenceInvitationManager.RejectedReason.REJECT_TO_ENTER, null);
                ConferenceController.sharedInstance().getViewState().isInvitationPending.set(false);
            }
        });
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ViewState viewState = ConferenceController.sharedInstance().getViewState();
        viewState.isInvitationPending.set(true);
        viewState.isInvitationPending.observe(mIsNeedToDestroy);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getViewState().isInvitationPending.removeObserver(mIsNeedToDestroy);
    }

    public void setData(String roomId, String avatarUrl, String inviterName, String conferenceName, String ownerName, int memberCount) {
        mInviteRoomId = roomId;
        updateBackground(avatarUrl);
        updateInviterAvatar(avatarUrl);
        updateInviterName(inviterName);
        updateConferenceName(conferenceName);
        updateOwnerName(ownerName);
        updateMemberCount(memberCount);
    }

    private void updateBackground(String avatarUrl) {
        ImageLoader.loadImage(mContext, mImgBackground, avatarUrl,
                R.drawable.tuiroomkit_ic_avatar);
    }

    private void updateInviterAvatar(String avatarUrl) {
        ImageLoader.loadImage(mContext, mImgInviterAvatar, avatarUrl,
                R.drawable.tuiroomkit_ic_avatar);
    }

    private void updateInviterName(String name) {
        mTextInvitation.setText(String.format(mContext.getString(R.string.tuiroomkit_invite_yout_to_join_conference), name));
    }

    private void updateConferenceName(String name) {
        mTextConferenceName.setText(name);
    }

    private void updateOwnerName(String name) {
        mTextOwnerName.setText(name);
    }

    private void updateMemberCount(int count) {
        mTextMemberCount.setText(String.valueOf(count));
    }

    private void destroy(boolean isPending) {
        if (isPending) {
            return;
        }
        ConferenceEventCenter.getInstance().notifyUIEvent(DESTROY_INVITATION_RECEIVED_ACTIVITY, null);
    }
}
