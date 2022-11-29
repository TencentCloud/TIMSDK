package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class GroupTypeSelectActivity extends BaseLightActivity implements View.OnClickListener {
    private static final String TAG = GroupTypeSelectActivity.class.getSimpleName();

    private RecyclerView mRecyclerView;
    private RecyclerView.LayoutManager mLayoutManager;
    private RecyclerView.Adapter mAdapter;
    private List<String> mDatas = new ArrayList<>();
    private TitleBarLayout titleBarLayout;
    private TextView groupTypeTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_type_select_layout);

        initData();
        initView();
    }

    private void initView() {
        mLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        mAdapter = new MyAdapter(mDatas);
        mRecyclerView = (RecyclerView) findViewById(R.id.recycler);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);
        titleBarLayout = findViewById(R.id.create_group_bar);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setTitle(getString(R.string.group_type_select_text), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.setOnLeftClickListener(this);
        groupTypeTextView = findViewById(R.id.group_type_text);
        groupTypeTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String url = "";
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    url = TUIContactConstants.IM_PRODUCT_DOC_URL;
                } else {
                    url = TUIContactConstants.IM_PRODUCT_DOC_URL_EN;
                }
                Intent intent = new Intent();
                intent.setAction(Intent.ACTION_VIEW);
                Uri contentUrl = Uri.parse(url);
                intent.setData(contentUrl);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
    }

    private void initData() {
        String[] array = getResources().getStringArray(R.array.group_type);
        mDatas.addAll(Arrays.asList(array));
    }

    @Override
    public void onClick(View view) {
        if (view == titleBarLayout.getLeftGroup()) {
            finish();
        }
    }


    public class MyAdapter extends RecyclerView.Adapter<MyAdapter.ViewHolder>{
        private List<String> mDatas;

        public MyAdapter(List<String> datas) {
            this.mDatas = datas;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_type_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(v);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            String type = this.mDatas.get(position);
            holder.imageView.setImageResource(TUIUtil.getDefaultGroupIconResIDByGroupType(getApplicationContext(), type));
            switch(type) {
                case V2TIMManager.GROUP_TYPE_WORK:
                    holder.textView.setText(getString(R.string.group_work_type));
                    holder.subTextView.setText(getString(R.string.group_work_content));
                    break;
                case V2TIMManager.GROUP_TYPE_PUBLIC:
                    holder.textView.setText(getString(R.string.group_public_type));
                    holder.subTextView.setText(getString(R.string.group_public_des));
                    break;
                case V2TIMManager.GROUP_TYPE_MEETING:
                    holder.textView.setText(getString(R.string.group_meeting_type));
                    holder.subTextView.setText(getString(R.string.group_meeting_des));
                    break;
                case V2TIMManager.GROUP_TYPE_COMMUNITY:
                    holder.textView.setText(getString(R.string.group_commnity_type));
                    holder.subTextView.setText(getString(R.string.group_commnity_des));
                    break;
                default:
                    holder.textView.setText(getString(R.string.group_work_type));
                    holder.subTextView.setText(getString(R.string.group_work_content));
                    break;
            }

            holder.rootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent();
                    intent.putExtra(TUIContactConstants.Selection.TYPE, type);
                    setResult(0, intent);
                    finish();
                }
            });
        }

        @Override
        public int getItemCount() {
            return this.mDatas == null ? 0 : this.mDatas.size();
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            View rootView;
            RelativeLayout itemLayout;
            ImageView imageView;
            TextView textView, subTextView;

            public ViewHolder(View itemView) {
                super(itemView);
                rootView = itemView;
                itemLayout = (RelativeLayout) itemView.findViewById(R.id.item_layout);
                imageView = (ImageView) itemView.findViewById(R.id.group_type_icon);
                textView = (TextView) itemView.findViewById(R.id.group_type_text);
                subTextView = (TextView) itemView.findViewById(R.id.group_type_content);
            }
        }
    }


}
