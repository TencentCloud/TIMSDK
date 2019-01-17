package com.tencent.qcloud.uikit.business.contact.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.contact.IContactDataProvider;
import com.tencent.qcloud.uikit.api.contact.IContactPanel;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.presenter.ContactPresenter;
import com.tencent.qcloud.uikit.business.contact.view.adapter.ContactPopMenuAction;
import com.tencent.qcloud.uikit.business.contact.view.adapter.ContactPopMenuAdapter;
import com.tencent.qcloud.uikit.business.contact.view.event.ContactPanelEvent;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.common.ProxyFactory;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;

import java.util.ArrayList;
import java.util.List;


/**
 * Created by valexhuang on 2018/8/2.
 */


public class ContactMainPanel extends LinearLayout implements IContactPanel {
    private List<ContactInfoBean> mDatas = new ArrayList<>();
    private ContactPresenter mPresenter;
    private PageTitleBar mTitleBar;
    private ContactList mContactList;
    private AlertDialog mPopDialog;
    private ContactPopMenuAdapter mMenuAdapter;
    private View mPopView;
    private ListView mPopMenuList;
    private AdapterView.OnItemClickListener mMenuItemClickListener;

    public ContactMainPanel(Context context) {
        super(context);
        init();
    }

    public ContactMainPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ContactMainPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.contact_main_panel, this);
        mTitleBar = findViewById(R.id.contact_panel_title_bar);
        mContactList = findViewById(R.id.contact_panel_list);
        mTitleBar.setTitle(getResources().getString(R.string.contacts), PageTitleBar.POSITION.CENTER);
        mTitleBar.getLeftGroup().setVisibility(View.GONE);
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                showPopMenu();
            }
        });
        mPresenter = new ContactPresenter(this);
    }


    /**
     * 组织数据源
     *
     * @param data
     * @return
     */
    private void initDatas(final String[] data) {
        //延迟两秒 模拟加载数据中....
        // postDelayed(new Runnable() {
        //   @Override
        //     public void run() {
        mDatas = new ArrayList<>();
        //微信的头部 也是可以右侧IndexBar导航索引的，
        // 但是它不需要被ItemDecoration设一个标题titile
        mDatas.add((ContactInfoBean) new ContactInfoBean("新的朋友").setTop(true).setBaseIndexTag(ContactInfoBean.INDEX_STRING_TOP));
        mDatas.add((ContactInfoBean) new ContactInfoBean("群聊").setTop(true).setBaseIndexTag(ContactInfoBean.INDEX_STRING_TOP));
        mDatas.add((ContactInfoBean) new ContactInfoBean("标签").setTop(true).setBaseIndexTag(ContactInfoBean.INDEX_STRING_TOP));
        mDatas.add((ContactInfoBean) new ContactInfoBean("公众号").setTop(true).setBaseIndexTag(ContactInfoBean.INDEX_STRING_TOP));
        for (int i = 0; i < data.length; i++) {
            ContactInfoBean cityBean = new ContactInfoBean();
            cityBean.setIdentifier(data[i]);//设置城市名称
            mDatas.add(cityBean);
        }
        mContactList.setDatas(mDatas);

    }


    private void showPopMenu() {
        if (mPopDialog == null) {
            mMenuAdapter = new ContactPopMenuAdapter();
            List<ContactPopMenuAction> menuActions = new ArrayList<ContactPopMenuAction>();
            ContactPopMenuAction action = new ContactPopMenuAction();
            action.setActionName("添加好友");
            menuActions.add(action);
            action = new ContactPopMenuAction();
            action.setActionName("发起群聊");
            menuActions.add(action);
            mMenuAdapter.setDataSource(menuActions);
            mPopView = inflate(getContext(), R.layout.contact_pop_menu, null);
            mPopMenuList = mPopView.findViewById(R.id.contact_pop_list);
            mPopMenuList.setAdapter(mMenuAdapter);
            mPopMenuList.setOnItemClickListener(mMenuItemClickListener);
            mPopDialog = PopWindowUtil.buildCustomDialog((Activity) getContext());
            //mPopDialog.setView(mPopView, 0, 0, 0, 0);
            mPopDialog.show();
            WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
            lp.width = 300;
            lp.height = RelativeLayout.LayoutParams.WRAP_CONTENT;
            lp.y = getResources().getDimensionPixelSize(R.dimen.page_title_height);
            mPopDialog.getWindow().setAttributes(lp);
            mPopDialog.getWindow().setGravity(Gravity.TOP | Gravity.RIGHT);
            mPopDialog.getWindow().setBackgroundDrawable(null);
            mPopDialog.setContentView(mPopView);
        } else {
            mPopDialog.show();
        }

    }


    @Override
    public PageTitleBar getTitleBar() {
        return null;
    }

    @Override
    public void setContactPanelEvent(ContactPanelEvent event) {

    }

    @Override
    public void addPopActions(List<PopMenuAction> actions) {

    }

    @Override
    public void setDataProvider(IContactDataProvider provider) {
        //mAdapter.setDataProvider(provider.getDataSource());
    }

    @Override
    public IContactDataProvider setProxyDataProvider(IContactDataProvider provider) {
        IContactDataProvider proxyProvider = ProxyFactory.createContactProviderProxy(provider, mContactList.getAdapter());
        mContactList.getAdapter().setDataSource(proxyProvider.getDataSource());
        return proxyProvider;
    }


    @Override
    public void refreshData() {

    }

    @Override
    public void initDefault() {
        initDatas(getResources().getStringArray(R.array.provinces));
    }


}
