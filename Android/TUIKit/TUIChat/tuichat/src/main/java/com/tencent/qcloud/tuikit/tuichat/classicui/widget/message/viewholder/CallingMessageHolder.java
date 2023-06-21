package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;

public class CallingMessageHolder extends TextMessageHolder {
    private TextView msgBodyText;
    private ImageView mLeftView;
    private ImageView mRightView;
    private LinearLayout mCallingLayout;

    public CallingMessageHolder(View itemView) {
        super(itemView);
        msgBodyText = itemView.findViewById(R.id.msg_body_tv);
        mLeftView = itemView.findViewById(R.id.left_icon);
        mRightView = itemView.findViewById(R.id.right_icon);
        mCallingLayout = itemView.findViewById(R.id.calling_layout);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_calling;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        super.layoutVariableViews(msg, position);

        if (!(msg instanceof CallingMessageBean)) {
            return;
        }
        CallingMessageBean callingMessageBean = (CallingMessageBean) msg;
        if (msg.isSelf()) {
            mLeftView.setVisibility(View.GONE);
            mRightView.setVisibility(View.VISIBLE);
            if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                mRightView.setImageResource(R.drawable.ic_audio_call);
            } else if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                mRightView.setImageResource(R.drawable.ic_self_video_call);
            }
            unreadAudioText.setVisibility(View.GONE);
        } else {
            mRightView.setVisibility(View.GONE);
            mLeftView.setVisibility(View.VISIBLE);
            if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                mLeftView.setImageResource(R.drawable.ic_audio_call);
            } else if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                mLeftView.setImageResource(R.drawable.ic_other_video_call);
            }
            unreadAudioText.setVisibility(callingMessageBean.isShowUnreadPoint() ? View.VISIBLE : View.GONE);
        }

        if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL
            || callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
            msgArea.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (selectableTextHelper != null) {
                        selectableTextHelper.selectAll();
                    }
                    return true;
                }
            });

            msgArea.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onRecallClick(v, position, msg);
                    }
                }
            });

            if (isForwardMode || isReplyDetailMode) {
                return;
            }
            setSelectableTextHelper(msg, msgBodyText, position, false);
        }
    }
}
