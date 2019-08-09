package com.tencent.qcloud.tim.demo.menu;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.uikit.component.action.PopActionClickListener;
import com.tencent.qcloud.tim.uikit.component.action.PopMenuAction;
import com.tencent.qcloud.tim.uikit.component.action.PopMenuAdapter;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;

import java.util.ArrayList;
import java.util.List;

public class Menu {

    public static final int MENU_TYPE_CONTACT = 1;
    public static final int MENU_TYPE_CONVERSATION = 2;

    // 更多menu
    private ListView mMenuList;
    private PopMenuAdapter mMenuAdapter;
    private PopupWindow mMenuWindow;
    private List<PopMenuAction> mActions = new ArrayList<>();
    private Activity mActivity;
    private View mAttachView;

    public Menu(Activity activity, View attach, int menuType) {
        mActivity = activity;
        mAttachView = attach;

        initActions(menuType);
    }

    private void initActions(int menuType) {
        PopActionClickListener popActionClickListener = new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                PopMenuAction action = (PopMenuAction) data;
                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.add_friend))) {
                    Intent intent = new Intent(DemoApplication.instance(), AddMoreActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.GroupType.GROUP, false);
                    mActivity.startActivity(intent);
                }
                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.add_group))) {
                    Intent intent = new Intent(DemoApplication.instance(), AddMoreActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.GroupType.GROUP, true);
                    mActivity.startActivity(intent);
                }
                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.start_conversation))) {
                    Intent intent = new Intent(DemoApplication.instance(), StartC2CChatActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    mActivity.startActivity(intent);
                }

                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.create_private_group))) {
                    Intent intent = new Intent(DemoApplication.instance(), StartGroupChatActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.GroupType.TYPE, TUIKitConstants.GroupType.PRIVATE);
                    mActivity.startActivity(intent);
                }
                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.create_group_chat))) {
                    Intent intent = new Intent(DemoApplication.instance(), StartGroupChatActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.GroupType.TYPE, TUIKitConstants.GroupType.PUBLIC);
                    mActivity.startActivity(intent);
                }
                if (TextUtils.equals(action.getActionName(), mActivity.getResources().getString(R.string.create_chat_room))) {
                    Intent intent = new Intent(DemoApplication.instance(), StartGroupChatActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIKitConstants.GroupType.TYPE, TUIKitConstants.GroupType.CHAT_ROOM);
                    mActivity.startActivity(intent);
                }
                mMenuWindow.dismiss();
            }
        };

        // 设置右上角+号显示PopAction
        List<PopMenuAction> menuActions = new ArrayList<PopMenuAction>();

        PopMenuAction action = new PopMenuAction();

        if (menuType == MENU_TYPE_CONVERSATION) {
            action.setActionName(mActivity.getResources().getString(R.string.start_conversation));
            action.setActionClickListener(popActionClickListener);
            action.setIconResId(R.drawable.create_c2c);
            menuActions.add(action);
        }

        if (menuType == MENU_TYPE_CONTACT) {
            action = new PopMenuAction();
            action.setActionName(mActivity.getResources().getString(R.string.add_friend));
            action.setIconResId(R.drawable.group_new_friend);
            action.setActionClickListener(popActionClickListener);
            menuActions.add(action);

            action = new PopMenuAction();
            action.setActionName(mActivity.getResources().getString(R.string.add_group));
            action.setIconResId(R.drawable.ic_contact_join_group);
            action.setActionClickListener(popActionClickListener);
            menuActions.add(action);
        }

        if (menuType == MENU_TYPE_CONTACT) {
            mActions.clear();
            mActions.addAll(menuActions);
            return;
        }

        action = new PopMenuAction();
        action.setActionName(mActivity.getResources().getString(R.string.create_private_group));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(mActivity.getResources().getString(R.string.create_group_chat));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(mActivity.getResources().getString(R.string.create_chat_room));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        mActions.clear();
        mActions.addAll(menuActions);
    }

    public boolean isShowing() {
        if (mMenuWindow == null) {
            return false;
        }
        return mMenuWindow.isShowing();
    }

    public void hide() {
        mMenuWindow.dismiss();
    }

    public void show() {
        if (mActions == null || mActions.size() == 0) {
            return;
        }
        mMenuWindow = new PopupWindow(mActivity);
        mMenuAdapter = new PopMenuAdapter();
        mMenuAdapter.setDataSource(mActions);
        View menuView = LayoutInflater.from(mActivity).inflate(R.layout.conversation_pop_menu, null);
        // 设置布局文件
        mMenuWindow.setContentView(menuView);

        mMenuList = menuView.findViewById(R.id.conversation_pop_list);
        mMenuList.setAdapter(mMenuAdapter);
        mMenuList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = (PopMenuAction) mMenuAdapter.getItem(position);
                if (action != null && action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(position, mActions.get(position));
                }
            }
        });
        mMenuWindow.setWidth(ScreenUtil.getPxByDp(160));
        mMenuWindow.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        mMenuWindow.setBackgroundDrawable(mActivity.getResources().getDrawable(R.drawable.top_pop));
        // 设置pop获取焦点，如果为false点击返回按钮会退出当前Activity，如果pop中有Editor的话，focusable必须要为true
        mMenuWindow.setFocusable(true);
        // 设置pop可点击，为false点击事件无效，默认为true
        mMenuWindow.setTouchable(true);
        // 设置点击pop外侧消失，默认为false；在focusable为true时点击外侧始终消失
        mMenuWindow.setOutsideTouchable(true);
        backgroundAlpha(0.5f);
        // 相对于 + 号正下面，同时可以设置偏移量
        mMenuWindow.showAtLocation(mAttachView, Gravity.RIGHT | Gravity.TOP, ScreenUtil.getPxByDp(15), ScreenUtil.getPxByDp(80));
        // 设置pop关闭监听，用于改变背景透明度
        mMenuWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                backgroundAlpha(1.0f);
            }
        });
    }

    /**
     * 此方法用于改变背景的透明度，从而达到“变暗”的效果
     */
    private void backgroundAlpha(float bgAlpha) {
        WindowManager.LayoutParams lp = mActivity.getWindow().getAttributes();
        // 0.0-1.0
        lp.alpha = bgAlpha;
        mActivity.getWindow().setAttributes(lp);
        // everything behind this window will be dimmed.
        // 此方法用来设置浮动层，防止部分手机变暗无效
        mActivity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
    }
}
