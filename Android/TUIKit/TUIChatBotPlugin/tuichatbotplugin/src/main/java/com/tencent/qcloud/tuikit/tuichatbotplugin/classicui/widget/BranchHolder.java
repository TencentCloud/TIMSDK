package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.os.Build;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.R;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotConstants;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.presenter.TUIChatBotPresenter;

public class BranchHolder extends MessageContentHolder {
    private LinearLayout llWelcomeContent;
    private LinearLayout llRefresh;
    private TextView tvWelcomeContent;
    private TextView tvClarifyMessage;
    private ImageView ivRefresh;
    private BranchListLayout listLayout;

    public BranchHolder(View itemView) {
        super(itemView);
        llWelcomeContent = itemView.findViewById(R.id.ll_title_welcome_content);
        tvWelcomeContent = itemView.findViewById(R.id.tv_welcome_content);
        llRefresh = itemView.findViewById(R.id.ll_refresh);
        tvClarifyMessage = itemView.findViewById(R.id.tv_title_clarify_message);
        listLayout = itemView.findViewById(R.id.branch_question_item_list);
        ivRefresh = itemView.findViewById(R.id.iv_refresh);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            llWelcomeContent.getBackground().setAutoMirrored(true);
            ivRefresh.getBackground().setAutoMirrored(true);
        }
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_bot_message_adapter_branch;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        int paddingHorizontal = 0;
        int paddingVertical = 0;
        msgArea.setPaddingRelative(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);

        BranchMessageBean branchMessageBean = (BranchMessageBean) msg;
        TUIChatBotPresenter presenter = new TUIChatBotPresenter();
        presenter.setBranchMessage(branchMessageBean);
        BranchBean branchBean = branchMessageBean.getBranchBean();
        if (branchBean != null) {
            if (TextUtils.equals(branchBean.getSubType(), TUIChatBotConstants.CHAT_BOT_SUBTYPE_WELCOME_MSG)) {
                tvClarifyMessage.setVisibility(View.GONE);
                tvWelcomeContent.setText(branchBean.getTitle());
                llWelcomeContent.setVisibility(View.VISIBLE);
                llRefresh.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        listLayout.refreshData();
                    }
                });
            } else {
                llWelcomeContent.setVisibility(View.GONE);
                tvClarifyMessage.setText(branchBean.getTitle());
                tvClarifyMessage.setVisibility(View.VISIBLE);
            }

            listLayout.setPresenter(presenter);
            listLayout.setBranchItemList(branchBean.getItemList());
        }
    }
}
