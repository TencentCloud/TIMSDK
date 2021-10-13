package com.tencent.qcloud.tuicore.component.menu;

import android.app.Activity;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuicore.component.action.PopMenuAdapter;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

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

    public Menu(Activity activity, View attach) {
        mActivity = activity;
        mAttachView = attach;
    }

    public void setMenuAction(List<PopMenuAction> menuActions) {
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
        View menuView = LayoutInflater.from(mActivity).inflate(R.layout.pop_menu, null);
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
