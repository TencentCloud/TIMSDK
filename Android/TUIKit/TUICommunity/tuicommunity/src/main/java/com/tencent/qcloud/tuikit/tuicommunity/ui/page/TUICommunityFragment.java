package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityFragment;
import com.tencent.qcloud.tuikit.tuicommunity.ui.widget.AddCommunityView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.widget.CommunityDetailView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.widget.CommunityGroupList;
import com.tencent.qcloud.tuikit.tuicommunity.ui.widget.CommunitySelfView;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import java.util.List;

public class TUICommunityFragment extends Fragment implements ICommunityFragment {
    private View baseView;
    private ViewPager2 communityContentViewPager;
    private CommunityFragmentAdapter communityFragmentAdapter;
    private ShadeImageView selfFace;
    private ShadeImageView selfFaceSelectBorder;
    private ShadeImageView addGroup;
    private ShadeImageView addGroupSelectBorder;

    private View connectFailed;
    private View connecting;
    private ImageView homeView;
    private CommunityGroupList groupIconList;
    private CommunityPresenter presenter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.community_main_fragment_layout, container, false);
        initView();
        initData();
        return baseView;
    }

    private void initView() {
        communityContentViewPager = baseView.findViewById(R.id.community_content_view_pager);
        // forbidden smooth scroll
        communityContentViewPager.setUserInputEnabled(false);

        communityFragmentAdapter = new CommunityFragmentAdapter();
        communityContentViewPager.setAdapter(communityFragmentAdapter);
        selfFace = baseView.findViewById(R.id.self_face);
        selfFaceSelectBorder = baseView.findViewById(R.id.self_face_select_border);
        addGroup = baseView.findViewById(R.id.add_community);
        addGroupSelectBorder = baseView.findViewById(R.id.add_community_select_border);
        selfFace.setRadius(ScreenUtil.dip2px(24));
        selfFaceSelectBorder.setRadius(ScreenUtil.dip2px(24));
        selfFace.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchCommunity(0);
            }
        });
        addGroup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchCommunity(communityFragmentAdapter.getItemCount() - 1);
            }
        });
        groupIconList = baseView.findViewById(R.id.community_group_list);
        communityContentViewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                clearSelected();
                if (position == 0) {
                    selfFaceSelectBorder.setVisibility(View.VISIBLE);
                } else if (position == communityFragmentAdapter.getItemCount() - 1) {
                    addGroupSelectBorder.setVisibility(View.VISIBLE);
                } else {
                    groupIconList.setSelectedPosition(position - 1);
                }
            }
        });

        connectFailed = baseView.findViewById(R.id.network_connect_failed);
        connecting = baseView.findViewById(R.id.network_connecting);
        homeView = baseView.findViewById(R.id.home_view);
        if (TUIConfig.getTUIHostType() != TUIConfig.TUI_HOST_TYPE_RTCUBE) {
            homeView.setVisibility(View.GONE);
        } else {
            homeView.setVisibility(View.VISIBLE);
            homeView.setBackgroundResource(R.drawable.title_bar_left_icon);
            int iconwidth = ScreenUtil.dip2px(TUIConstants.TIMAppKit.BACK_RTCUBE_HOME_ICON_WIDTH);
            int iconHeight = ScreenUtil.dip2px(TUIConstants.TIMAppKit.BACK_RTCUBE_HOME_ICON_HEIGHT);
            ViewGroup.LayoutParams iconParams = homeView.getLayoutParams();
            iconParams.width = iconwidth;
            iconParams.height = iconHeight;
            homeView.setLayoutParams(iconParams);
            homeView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_KEY, TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_IM);
                    TUICore.startActivity("TRTCMainActivity", bundle);
                    getActivity().finish();
                }
            });
        }
    }

    @Override
    public void onSelfFaceChanged(String newFaceUrl) {
        GlideEngine.loadUserIcon(selfFace, newFaceUrl);
    }

    private void clearSelected() {
        selfFaceSelectBorder.setVisibility(View.GONE);
        addGroupSelectBorder.setVisibility(View.GONE);
        groupIconList.clearSelected();
    }

    private void initData() {
        presenter = new CommunityPresenter();
        groupIconList.setPresenter(presenter);
        presenter.setCommunityFragment(this);
        presenter.setCommunityEventListener();
        groupIconList.setOnCommunityClickListener(new OnCommunityClickListener() {
            @Override
            public void onClick(CommunityBean communityBean) {
                int index = communityFragmentAdapter.getIndexInAdapter(communityBean);
                if (index != -1) {
                    switchCommunity(index);
                } else {
                    ToastUtil.toastShortMessage("can't find community");
                }
            }
        });
        presenter.loadJoinedCommunityList();
        presenter.getSelfFaceUrl(new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                GlideEngine.loadUserIcon(selfFace, data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("can't load self face icon");
            }
        });
    }

    private void switchCommunity(int index) {
        communityContentViewPager.setCurrentItem(index, false);
    }

    @Override
    public void onJoinedCommunityChanged(List<CommunityBean> communityBeanList) {
        communityFragmentAdapter.setData(communityBeanList);
    }

    @Override
    public void onItemRangeChanged(int index, int count) {
        communityFragmentAdapter.notifyItemRangeChanged(index + 1, count);
    }

    @Override
    public void onItemInserted(int index) {
        communityFragmentAdapter.notifyItemInserted(index + 1);
    }

    @Override
    public void onItemChanged(int index) {
        communityFragmentAdapter.notifyItemChanged(index + 1);
    }

    @Override
    public void onItemRemoved(int index) {
        int currentItem = communityContentViewPager.getCurrentItem();
        if (currentItem == index + 1) {
            communityContentViewPager.setCurrentItem(index);
        }
        communityFragmentAdapter.notifyItemRemoved(index + 1);
    }

    @Override
    public void onNetworkStateChanged(int state) {
        if (state == CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECTED) {
            connectFailed.setVisibility(View.GONE);
            connecting.setVisibility(View.GONE);
        } else if (state == CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECT_FAILED) {
            connecting.setVisibility(View.GONE);
            connectFailed.setVisibility(View.VISIBLE);
        } else if (state == CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECTING) {
            connecting.setVisibility(View.VISIBLE);
            connectFailed.setVisibility(View.GONE);
        }
    }

    @Override
    public void onCommunitySelected(CommunityBean communityBean) {
        int index = communityFragmentAdapter.getIndexInAdapter(communityBean);
        if (index != -1) {
            switchCommunity(index);
        }
    }

    public static class CommunityFragmentAdapter extends RecyclerView.Adapter<CommunityFragmentAdapter.FragmentContentViewHolder> {
        private static final int SELF_PAGE_TYPE = 1;
        private static final int ADD_PAGE_TYPE = 2;
        private static final int COMMUNITY_PAGE_TYPE = 3;

        private List<CommunityBean> data;

        public void setData(List<CommunityBean> data) {
            this.data = data;
        }

        @NonNull
        @Override
        public FragmentContentViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view;
            if (viewType == SELF_PAGE_TYPE) {
                view = new CommunitySelfView(parent.getContext());
            } else if (viewType == ADD_PAGE_TYPE) {
                view = new AddCommunityView(parent.getContext());
            } else {
                view = new CommunityDetailView(parent.getContext());
            }
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            view.setLayoutParams(layoutParams);
            return new FragmentContentViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull FragmentContentViewHolder holder, int position) {
            if (holder.itemView instanceof CommunityDetailView) {
                //                ((CommunityDetailView) holder.itemView).hideTopicList();
                CommunityBean communityBean = data.get(position - 1);
                ((CommunityDetailView) holder.itemView).setCommunityBean(communityBean);
            }
        }

        @Override
        public int getItemViewType(int position) {
            if (position == 0) {
                return SELF_PAGE_TYPE;
            } else if (position == getItemCount() - 1) {
                return ADD_PAGE_TYPE;
            } else {
                return COMMUNITY_PAGE_TYPE;
            }
        }

        @Override
        public int getItemCount() {
            if (data == null || data.isEmpty()) {
                return 2;
            }
            return data.size() + 2;
        }

        public int getIndexInAdapter(CommunityBean communityBean) {
            if (data == null || data.isEmpty()) {
                return -1;
            }
            return data.indexOf(communityBean) + 1;
        }

        static class FragmentContentViewHolder extends RecyclerView.ViewHolder {
            public FragmentContentViewHolder(@NonNull View itemView) {
                super(itemView);
            }
        }
    }

    public abstract static class OnCommunityClickListener {
        public void onClick(CommunityBean communityBean) {}
    }
}