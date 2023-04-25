package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.view.View;
import android.widget.RatingBar;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CustomEvaluationMessageHolder extends MessageContentHolder {
    private TextView textView;
    private TextView contentView;
    private RatingBar ratingBar;

    public CustomEvaluationMessageHolder(View itemView) {
        super(itemView);
        textView = itemView.findViewById(R.id.test_custom_message_tv);
        contentView = itemView.findViewById(R.id.link_tv);
        ratingBar = itemView.findViewById(R.id.opreview_ratingbar);
    }

    public static final String TAG = CustomEvaluationMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        return R.layout.custom_evaluation_message_layout;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        int score = 0;
        String content = "";
        if (msg instanceof CustomEvaluationMessageBean) {
            score = ((CustomEvaluationMessageBean) msg).getScore();
            content = ((CustomEvaluationMessageBean) msg).getContent();
        }

        textView.setText(TUIChatService.getAppContext().getString(R.string.custom_evaluation_message));
        msgContentFrame.setClickable(true);
        if (score == 0) {
            ratingBar.setVisibility(View.GONE);
        } else {
            ratingBar.setRating(score);
            ratingBar.setNumStars(score);
            ratingBar.setIsIndicator(true);
        }
        TUIChatLog.d(TAG, "score = " + score);
        contentView.setText(content);
    }
}
