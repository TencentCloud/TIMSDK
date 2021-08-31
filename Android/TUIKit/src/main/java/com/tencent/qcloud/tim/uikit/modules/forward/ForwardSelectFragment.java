package com.tencent.qcloud.tim.uikit.modules.forward;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseFragment;
import com.tencent.qcloud.tim.uikit.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.forward.base.ConversationBean;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import static com.tencent.qcloud.tim.uikit.utils.TUIKitConstants.FORWARD_CREATE_GROUP_CODE;
import static com.tencent.qcloud.tim.uikit.utils.TUIKitConstants.FORWARD_SELECT_MEMBERS_CODE;

public class ForwardSelectFragment extends BaseFragment {

    private View mBaseView;
    private TitleBarLayout mTitleBarLayout;
    private ForwardSelectLayout mForwardLayout;

    private RecyclerView mForwardSelectlistView;
    private ForwardConversationSelectorAdapter mAdapter;
    private List<ConversationInfo> mDataSource = new ArrayList<>();
    private List<ConversationInfo> mContactDataSource = new ArrayList<>();
    private List<List<Object>> mSelectConversationIcons = new ArrayList<>();
    private RelativeLayout mForwardSelectlistViewLayout;
    private TextView mSureView;

    private static final String TAG = ForwardSelectFragment.class.getSimpleName();
    public static final String FORWARD_CREATE_NEW_CHAT = "forward_create_new_chat";

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.forward_fragment, container, false);
        return mBaseView;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        // 从布局文件中获取会话列表面板
        mForwardLayout = view.findViewById(R.id.forward_conversation_layout);

        // 会话列表面板的默认UI和交互初始化
        mForwardLayout.initDefault();

        customizeConversation();
        mForwardLayout.getConversationList().setOnItemClickListener(new ConversationListLayout.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position, ConversationInfo conversationInfo) {
                //此处为demo的实现逻辑，更根据会话类型跳转到相关界面，开发者可根据自己的应用场景灵活实现
                if (position == 1){
                    return;
                } else if (position == 0){
                    //跳转到通讯录或者创建群聊界面
                    if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))){
                        //通讯录
                        Intent intent = new Intent(getContext(), ForwardSelectGroupActivity.class);
                        //intent.putExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, (Serializable) mContactDataSource);
                        intent.putExtra(TUIKitConstants.GroupType.TYPE, TUIKitConstants.GroupType.PUBLIC);
                        intent.putExtra(FORWARD_CREATE_NEW_CHAT, 0);
                        startActivityForResult(intent, TUIKitConstants.FORWARD_SELECT_MEMBERS_CODE);
                    }else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){
                        //创建群聊界面
                        Intent intent = new Intent(getContext(), ForwardSelectGroupActivity.class);
                        intent.putExtra(TUIKitConstants.GroupType.TYPE, TUIKitConstants.GroupType.PUBLIC);
                        intent.putExtra(FORWARD_CREATE_NEW_CHAT, 1);
                        startActivityForResult(intent, FORWARD_CREATE_GROUP_CODE);
                    }else{
                        TUIKitLog.d(TAG,"Titlebar exception");
                    }
                } else {
                    //转发
                    if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))) {//会话多选
                        mDataSource = mForwardLayout.getConversationList().getAdapter().getSelectConversations();
                        checkRepeat();
                        RefreshSelectConversations();
                    } else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){//点击会话转发
                        ForwardMessages(conversationInfo);
                    } else {
                        ForwardMessages(conversationInfo);
                    }
                }
            }
        });
        mForwardLayout.getConversationList().setOnItemLongClickListener(new ConversationListLayout.OnItemLongClickListener() {
            @Override
            public void OnItemLongClick(View view, int position, ConversationInfo conversationInfo) {

            }
        });

        mForwardSelectlistViewLayout = view.findViewById(R.id.forward_select_list_layout);
        mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
        mForwardSelectlistView = view.findViewById(R.id.forward_select_list);
        mForwardSelectlistView.setLayoutManager(new CustomLinearLayoutManager(getContext(), CustomLinearLayoutManager.HORIZONTAL, false));
        mAdapter = new ForwardConversationSelectorAdapter(this.getContext());
        mForwardSelectlistView.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(new ForwardConversationSelectorAdapter.OnItemClickListener() {
            @Override
            public void onClick(View view, int position) {
                boolean needFresh = false;
                if (mDataSource != null && mDataSource.size() != 0){
                    if(position < mDataSource.size()) {
                        mDataSource.remove(position);
                        mForwardLayout.getConversationList().getAdapter().setSelectConversations(mDataSource);
                        needFresh = true;
                    }
                }

                if(!needFresh) {
                    if (mContactDataSource != null && mContactDataSource.size() != 0) {
                        if (position - mDataSource.size() < mContactDataSource.size()) {
                            mContactDataSource.remove(position - mDataSource.size());
                            needFresh = true;
                        }
                    }
                }

                if (needFresh) {
                    RefreshSelectConversations();
                }
            }
        });
        mSureView = view.findViewById(R.id.btn_msg_ok);
        mSureView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getActivity() != null) {
                    ArrayList<ConversationBean> conversationBeans = new ArrayList<ConversationBean>();
                    if (mDataSource != null && mDataSource.size() != 0){
                        for (int i=0;i<mDataSource.size();i++){
                            ConversationBean conversationBean = new ConversationBean(mDataSource.get(i).getId(), mDataSource.get(i).isGroup() ? 1 : 0, mDataSource.get(i).getTitle());
                            conversationBeans.add(conversationBean);
                        }
                    }

                    if (mContactDataSource != null && mContactDataSource.size() != 0){
                        for (int i=0;i<mContactDataSource.size();i++){
                            ConversationBean conversationBean = new ConversationBean(mContactDataSource.get(i).getId(), mContactDataSource.get(i).isGroup() ? 1 : 0, mContactDataSource.get(i).getTitle());
                            conversationBeans.add(conversationBean);
                        }
                    }

                    Intent intent = new Intent();
                    intent.putParcelableArrayListExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationBeans);
                    getActivity().setResult(TUIKitConstants.FORWARD_SELECT_ACTIVTY_CODE, intent);

                    getActivity().finish();
                }
            }
        });

        RefreshSelectConversations();
        initTitleAction();
    }

    private List<ConversationInfo> noRepeatIDMergeConversation(List<ConversationInfo> data1, List<ConversationInfo> data2){
        if ((data1 == null && data2 == null ) || (data1.size() == 0 && data2.size() ==0) ){
            return null;
        }
        if (data1 == null || data1.size() == 0){
            return data2;
        }
        if (data2 == null || data2.size() == 0){
            return data1;
        }

        List<String> dataString1 = new ArrayList<>();
        List<String> dataString2 = new ArrayList<>();
        for (int i=0;i<data1.size();i++){
            dataString1.add(data1.get(i).getId());
        }
        for (int i=0;i<data2.size();i++){
            dataString2.add(data2.get(i).getId());
        }

        Set<String> set = new HashSet<>(dataString1);
        set.addAll(dataString2);
        List<String> list = new ArrayList<>(set);

        List<ConversationInfo> result = new ArrayList<>();
        for (int i=0;i<list.size();i++){
            String id = list.get(i);
            boolean findit = false;

            for (int j=0;j<data1.size();j++){
                if (id.equals(data1.get(j).getId())){
                    result.add(data1.get(j));
                    findit = true;
                    break;
                }
            }

            if (findit)continue;

            for (int j=0;j<data2.size();j++){
                if (id.equals(data2.get(j).getId())){
                    result.add(data2.get(j));
                    break;
                }
            }
        }

        return result;
    }

    private void RefreshSelectConversations(){
        mSelectConversationIcons.clear();

        mDataSource = mForwardLayout.getConversationList().getAdapter().getSelectConversations();
        //mDataSource = noRepeatIDMergeConversation(mDataSource, mContactDataSource);

        if (mDataSource != null && mDataSource.size() != 0){
            for (int i=0;i<mDataSource.size();i++){
                mSelectConversationIcons.add(mDataSource.get(i).getIconUrlList());
            }
        }
        if (mContactDataSource != null && mContactDataSource.size() != 0){
            for (int i=0;i<mContactDataSource.size();i++){
                mSelectConversationIcons.add(mContactDataSource.get(i).getIconUrlList());
            }
        }

        mAdapter.setDataSource(mSelectConversationIcons);

        if (mSelectConversationIcons == null || mSelectConversationIcons.size() == 0){
            mSureView.setText(getString(R.string.sure));
            mSureView.setVisibility(View.GONE);
            mForwardSelectlistViewLayout.setVisibility(View.GONE);
        } else {
            mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
            mSureView.setVisibility(View.VISIBLE);
            mSureView.setText(getString(R.string.sure) + "(" + mSelectConversationIcons.size() + ")");
        }
    }

    private void ForwardMessages(final ConversationInfo conversationInfo){
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        builder.setTitle("");
        builder.setMessage(getString(R.string.forward_alert_title));
        //点击对话框以外的区域是否让对话框消失
        builder.setCancelable(true);
        //设置正面按钮
        builder.setPositiveButton(getString(R.string.sure), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (getActivity() != null) {
                    ArrayList<ConversationBean> conversationBeans = new ArrayList<ConversationBean>();
                    ConversationBean conversationBean = new ConversationBean(conversationInfo.getId(), conversationInfo.isGroup() ? 1 : 0, conversationInfo.getTitle());
                    conversationBeans.add(conversationBean);
                    Intent intent = new Intent();
                    intent.putParcelableArrayListExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationBeans);
                    getActivity().setResult(TUIKitConstants.FORWARD_SELECT_ACTIVTY_CODE, intent);

                    getActivity().finish();
                }
                dialog.dismiss();
            }
        });
        //设置反面按钮
        builder.setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    private void customizeConversation(){
        mTitleBarLayout = mForwardLayout.getTitleBar();
        mTitleBarLayout.setTitle("", TitleBarLayout.POSITION.MIDDLE);
        mTitleBarLayout.getLeftGroup().setVisibility(View.VISIBLE);
        mTitleBarLayout.getRightGroup().setVisibility(View.VISIBLE);
        mTitleBarLayout.setTitle(getString(R.string.titlebar_close), TitleBarLayout.POSITION.LEFT);
        mTitleBarLayout.setTitle(getString(R.string.titlebar_mutiselect), TitleBarLayout.POSITION.RIGHT);
        mTitleBarLayout.getLeftIcon().setVisibility(View.GONE);
        mTitleBarLayout.getRightIcon().setVisibility(View.GONE);

        ForwardSelectListLayout listLayout = (ForwardSelectListLayout) mForwardLayout.getConversationList();
        listLayout.getAdapter().setAtInfoTextShow(false);
        listLayout.getAdapter().setTimelineTextShow(false);
        listLayout.getAdapter().setMessageTextShow(false);
        listLayout.getAdapter().setUnreadTextShow(false);

        listLayout.getAdapter().setForwardFragment(true);
    }

    private void initTitleAction() {
        mForwardLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //点击取消/关闭
                if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))){
                    mTitleBarLayout.getRightGroup().setVisibility(View.VISIBLE);
                    mTitleBarLayout.setTitle(getString(R.string.titlebar_close), TitleBarLayout.POSITION.LEFT);
                    mTitleBarLayout.setTitle(getString(R.string.titlebar_mutiselect), TitleBarLayout.POSITION.RIGHT);

                    //取消多选状态
                    ForwardSelectListLayout listLayout = (ForwardSelectListLayout) mForwardLayout.getConversationList();
                    listLayout.getAdapter().setShowMutiSelectCheckBox(false);
                    listLayout.getAdapter().notifyDataSetChanged();

                    //取消选中会话显示
                    mForwardSelectlistViewLayout.setVisibility(View.GONE);
                    mAdapter.setDataSource(null);
                    mSelectConversationIcons.clear();
                }else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){
                    getActivity().finish();
                }else{
                    TUIKitLog.d(TAG,"Titlebar exception");
                }
            }
        });

        mForwardLayout.getTitleBar().setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //点击多选
                mTitleBarLayout.getRightGroup().setVisibility(View.GONE);
                mTitleBarLayout.setTitle(getString(R.string.titlebar_cancle), TitleBarLayout.POSITION.LEFT);

                //打开多选状态
                ForwardSelectListLayout listLayout = (ForwardSelectListLayout) mForwardLayout.getConversationList();
                listLayout.getAdapter().setShowMutiSelectCheckBox(true);
                listLayout.getAdapter().notifyDataSetChanged();
            }
        });
    }

    private List<String> ParseForwardBundle(String selectMsgsIds){
        if (selectMsgsIds == null || selectMsgsIds.isEmpty()){
            return null;
        }

        String[] msgs = selectMsgsIds.split(",");
        List<String> ids = new ArrayList<>();
        for (int i = 0; i < msgs.length; i++) {
            ids.add(msgs[i]);
        }

        return ids;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == FORWARD_CREATE_GROUP_CODE && resultCode == FORWARD_CREATE_GROUP_CODE) {
            if (getActivity() != null) {
                getActivity().setResult(TUIKitConstants.FORWARD_SELECT_ACTIVTY_CODE, data);
                getActivity().finish();
            }
        } else if (requestCode == FORWARD_SELECT_MEMBERS_CODE && resultCode == FORWARD_SELECT_MEMBERS_CODE){
            ArrayList<ConversationInfo> conversationBeans = (ArrayList<ConversationInfo>) data.getSerializableExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY);
            if (conversationBeans == null || conversationBeans.isEmpty()){
                mContactDataSource.clear();
                RefreshSelectConversations();
                return;
            }

            mContactDataSource.clear();
            for (int i=0;i<conversationBeans.size();i++){
                mContactDataSource.add(conversationBeans.get(i));
            }
            checkRepeat();

            RefreshSelectConversations();
        }
    }

    private void checkRepeat() {
        Iterator<ConversationInfo> iterator = mContactDataSource.iterator();
        while (iterator.hasNext()) {
            ConversationInfo conversationInfo = iterator.next();
            if (mDataSource != null && mDataSource.size() != 0) {
                for (int i = 0; i < mDataSource.size(); i++) {
                    if (conversationInfo.getId().equals(mDataSource.get(i).getId())) {
                        iterator.remove();//使用迭代器的删除方法删除
                        break;
                    }
                }
            }
        }
    }
    @Override
    public void onResume() {
        super.onResume();

    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
