package com.tencent.qcloud.tuikit.tuiconversation.classicui.page;

import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopDialogAdapter;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.util.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;

import java.util.ArrayList;
import java.util.List;

public class TUIConversationFragment extends BaseFragment {
    private View mBaseView;
    private ConversationLayout mConversationLayout;
    private ListView mConversationPopList;
    private PopDialogAdapter mConversationPopAdapter;
    private PopupWindow mConversationPopWindow;
    private String popWindowConversationId;
    private List<PopMenuAction> mConversationPopActions = new ArrayList<>();

    private ConversationPresenter presenter;
    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.conversation_fragment, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        // 从布局文件中获取会话列表面板
        mConversationLayout = mBaseView.findViewById(R.id.conversation_layout);

        presenter = new ConversationPresenter();
        presenter.setConversationListener();
        presenter.setShowType(ConversationPresenter.SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD);
        mConversationLayout.setPresenter(presenter);

        // 会话列表面板的默认UI和交互初始化
        mConversationLayout.initDefault();
        // 通过API设置ConversataonLayout各种属性的样例，开发者可以打开注释，体验效果
//        ConversationLayoutSetting.customizeConversation(mConversationLayout);

        mConversationLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {

            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                //此处为demo的实现逻辑，更根据会话类型跳转到相关界面，开发者可根据自己的应用场景灵活实现
                if (conversationInfo.isMarkFold()) {
                    mConversationLayout.clearUnreadStatusOfFoldItem();
                    startFoldedConversationActivity();
                } else {
                    TUIConversationUtils.startChatActivity(conversationInfo);
                }
            }

            @Override
            public void OnItemLongClick(View view, ConversationInfo conversationInfo) {
                showItemPopMenu(view, conversationInfo);
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {
                if (dataSource == null)return;
                ConversationInfo conversationInfo = dataSource.get(0);
                if (conversationInfo == null)return;

                if (!TextUtils.isEmpty(popWindowConversationId) && popWindowConversationId.equals(conversationInfo.getConversationId())) {
                    if (mConversationPopWindow != null) {
                        mConversationPopWindow.dismiss();
                    }
                }
            }
        });

        restoreConversationItemBackground();
    }

    public void restoreConversationItemBackground() {
        if (mConversationLayout.getConversationList().getAdapter() !=  null &&
                mConversationLayout.getConversationList().getAdapter().isClick()) {
            mConversationLayout.getConversationList().getAdapter().setClick(false);
            mConversationLayout.getConversationList().getAdapter().notifyItemChanged(mConversationLayout.getConversationList().getAdapter().getCurrentPosition());
        }
    }

    private void initPopMenuAction() {
        // 设置长按conversation显示PopAction
        List<PopMenuAction> conversationPopActions = new ArrayList<PopMenuAction>();
        PopMenuAction action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.not_display));
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                ConversationInfo conversationInfo = (ConversationInfo) data;
                if (conversationInfo.isMarkFold()) {
                    mConversationLayout.hideFoldedItem(true);
                } else {
                    mConversationLayout.markConversationHidden(conversationInfo);
                }
            }
        });
        conversationPopActions.add(action);

        mConversationPopActions.clear();
        mConversationPopActions.addAll(conversationPopActions);
    }

    private void addMarkUnreadPopMenuAction(boolean markUnread) {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mConversationLayout.markConversationUnread((ConversationInfo) data, markUnread);
            }
        });
        if (markUnread) {
            action.setActionName(getResources().getString(R.string.mark_unread));
        } else {
            action.setActionName(getResources().getString(R.string.mark_read));
        }
        mConversationPopActions.add(0, action);
    }

    private void addDeletePopMenuAction() {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mConversationLayout.deleteConversation((ConversationInfo) data);
            }
        });
        action.setActionName(getResources().getString(R.string.chat_delete));
        mConversationPopActions.add(action);
    }

    /**
     * 长按会话item弹框
     * @param view 长按 view
     * @param conversationInfo 会话数据对象
     */
    private void showItemPopMenu(View view, final ConversationInfo conversationInfo) {
        initPopMenuAction();

        if (!conversationInfo.isMarkFold()) {
            if (conversationInfo.getUnRead() > 0) {
                addMarkUnreadPopMenuAction(false);
            } else {
                if (conversationInfo.isMarkUnread()) {
                    addMarkUnreadPopMenuAction(false);
                } else {
                    addMarkUnreadPopMenuAction(true);
                }
            }

            addDeletePopMenuAction();
        }

        View itemPop = LayoutInflater.from(getActivity()).inflate(R.layout.conversation_pop_menu_layout, null);
        mConversationPopList = itemPop.findViewById(R.id.pop_menu_list);
        mConversationPopList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = mConversationPopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(position, conversationInfo);
                }
                mConversationPopWindow.dismiss();
                restoreConversationItemBackground();
            }
        });

        for (int i = 0; i < mConversationPopActions.size(); i++) {
            PopMenuAction action = mConversationPopActions.get(i);
            if (conversationInfo.isTop()) {
                if (action.getActionName().equals(getResources().getString(R.string.chat_top))) {
                    action.setActionName(getResources().getString(R.string.quit_chat_top));
                }
            } else {
                if (action.getActionName().equals(getResources().getString(R.string.quit_chat_top))) {
                    action.setActionName(getResources().getString(R.string.chat_top));
                }

            }
        }
        mConversationPopAdapter = new PopDialogAdapter();
        mConversationPopList.setAdapter(mConversationPopAdapter);
        mConversationPopAdapter.setDataSource(mConversationPopActions);
        mConversationPopWindow = new PopupWindow(itemPop, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        mConversationPopWindow.setBackgroundDrawable(new ColorDrawable());
        mConversationPopWindow.setOutsideTouchable(true);
        int width = ConversationUtils.getListUnspecifiedWidth(mConversationPopAdapter, mConversationPopList);
        mConversationPopWindow.setWidth(width);
        popWindowConversationId = conversationInfo.getConversationId();
        mConversationPopWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                restoreConversationItemBackground();
                popWindowConversationId = "";
            }
        });
        int x = view.getWidth() / 2;
        int y = - view.getHeight() / 3;
        int popHeight = ScreenUtil.dip2px(45) * 3;
        if (y + popHeight + view.getY() + view.getHeight() > mConversationLayout.getBottom()) {
            y = y - popHeight;
        }
        mConversationPopWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
    }

    private void startFoldedConversationActivity() {
        Intent intent = new Intent(getActivity(), TUIFoldedConversationActivity.class);
        startActivity(intent);
    }

}
