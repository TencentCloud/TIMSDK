package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.graphics.Color;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CallingMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public class CallingMessageHolder extends TextMessageHolder {

    public CallingMessageHolder(View itemView) {
        super(itemView);
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        super.layoutVariableViews(msg, position);

        if (!(msg instanceof CallingMessageBean)) {
            return;
        }
        CallingMessageBean callingMessageBean = (CallingMessageBean) msg;
        SpannableStringBuilder stringBuilder = new SpannableStringBuilder(timeInLineTextLayout.getTextView().getText());
        int resID = R.drawable.ic_audio_call;
        if (msg.isSelf()) {
            if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                resID = R.drawable.ic_audio_call;
            } else if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                resID = R.drawable.ic_self_video_call;
            }
            appendIcon(false, stringBuilder, resID);
            timeInLineTextLayout.setText(stringBuilder);
        } else {
            if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL) {
                resID = R.drawable.ic_audio_call;
            } else if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
                resID = R.drawable.ic_other_video_call;
            }
            appendIcon(true, stringBuilder, resID);
            timeInLineTextLayout.setText(stringBuilder);
        }

        if (callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_AUDIO_CALL ||
                callingMessageBean.getCallType() == CallingMessageBean.ACTION_ID_VIDEO_CALL) {
            timeInLineTextLayout.getTextView().setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onRecallClick(view, position, msg);
                    }
                }
            });
            timeInLineTextLayout.getTextView().setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, position, callingMessageBean);
                    }
                    return true;
                }
            });
        } else {
            timeInLineTextLayout.getTextView().setOnLongClickListener(null);
            timeInLineTextLayout.getTextView().setOnClickListener(null);
        }
    }

    private void appendIcon(boolean isStart, SpannableStringBuilder stringBuilder, int resID) {
        ImageSpan imageSpan;
        if (isStart) {
            imageSpan = new ImageSpan(itemView.getContext(), resID);
            stringBuilder.insert(0, "iconA");
            stringBuilder.setSpan(new ForegroundColorSpan(Color.TRANSPARENT), "icon".length(), "iconA".length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            stringBuilder.setSpan(imageSpan, 0, "icon".length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else {
            imageSpan = new ImageSpan(itemView.getContext(), resID);
            stringBuilder.append("Aicon");
            stringBuilder.setSpan(new ForegroundColorSpan(Color.TRANSPARENT), stringBuilder.length() - "Aicon".length(), stringBuilder.length() - "icon".length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            stringBuilder.setSpan(imageSpan, stringBuilder.length() - "icon".length(), stringBuilder.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
    }

}
