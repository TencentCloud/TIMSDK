package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class GroupTypeSelectMinimalistActivity extends AppCompatActivity {
    private static final String TAG = GroupTypeSelectMinimalistActivity.class.getSimpleName();

    private RecyclerView mRecyclerView;
    private RecyclerView.LayoutManager mLayoutManager;
    private RecyclerView.Adapter mAdapter;
    private TextView cancelButton;
    private TextView confirmButton;
    private List<String> mDatas = new ArrayList<>();
    private TextView groupTypeTextView;
    private String groupType;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_minimalist_group_type_select_layout);

        initData();
        initView();
    }

    private void initView() {
        mLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        mAdapter = new MyAdapter(mDatas);
        cancelButton = findViewById(R.id.cancel_button);
        confirmButton = findViewById(R.id.confirm_button);
        mRecyclerView = (RecyclerView) findViewById(R.id.recycler);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setResult();
            }
        });

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
        groupType = mDatas.get(0);
        Intent intent = getIntent();
        String groupTypeTemp = intent.getStringExtra(TUIContactConstants.Selection.GROUP_TYPE);
        if (!TextUtils.isEmpty(groupTypeTemp)) {
            groupType = groupTypeTemp;
        }
    }

    private void setResult() {
        Intent intent = new Intent();
        intent.putExtra(TUIContactConstants.Selection.TYPE, groupType);
        setResult(0, intent);
        finish();
    }

    public class MyAdapter extends RecyclerView.Adapter<MyAdapter.ViewHolder> {
        private List<String> mDatas;

        public MyAdapter(List<String> datas) {
            this.mDatas = datas;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.contact_minimalist_group_type_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(v);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            String type = this.mDatas.get(position);
            switch (type) {
                case TUIContactConstants.GroupType.TYPE_WORK:
                    holder.textView.setText(getString(R.string.group_work_type));
                    holder.subTextView.setText(getString(R.string.group_work_content));
                    break;
                case TUIContactConstants.GroupType.TYPE_PUBLIC:
                    holder.textView.setText(getString(R.string.group_public_type));
                    holder.subTextView.setText(getString(R.string.group_public_des));
                    break;
                case TUIContactConstants.GroupType.TYPE_MEETING:
                    holder.textView.setText(getString(R.string.group_meeting_type));
                    holder.subTextView.setText(getString(R.string.group_meeting_des));
                    break;
                case TUIContactConstants.GroupType.TYPE_COMMUNITY:
                    holder.textView.setText(getString(R.string.group_commnity_type));
                    holder.subTextView.setText(getString(R.string.group_commnity_des));
                    break;
                default:
                    break;
            }

            if (TextUtils.equals(groupType, type)) {
                holder.showSelected();
            } else {
                holder.hideSelected();
            }

            holder.rootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    groupType = type;
                    notifyDataSetChanged();
                }
            });
        }

        @Override
        public int getItemCount() {
            return this.mDatas == null ? 0 : this.mDatas.size();
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            View rootView;
            TextView textView;
            TextView subTextView;
            View selectedBorder;
            View notSelectedBorder;
            View selectedIcon;

            public ViewHolder(View itemView) {
                super(itemView);
                rootView = itemView;
                selectedIcon = itemView.findViewById(R.id.checked_icon);
                selectedBorder = itemView.findViewById(R.id.selected_border);
                notSelectedBorder = itemView.findViewById(R.id.not_selected_border);
                textView = itemView.findViewById(R.id.group_type_text);
                subTextView = itemView.findViewById(R.id.group_type_content);
            }

            public void showSelected() {
                selectedBorder.setVisibility(View.VISIBLE);
                notSelectedBorder.setVisibility(View.GONE);
                selectedIcon.setVisibility(View.VISIBLE);
            }

            public void hideSelected() {
                selectedBorder.setVisibility(View.GONE);
                notSelectedBorder.setVisibility(View.VISIBLE);
                selectedIcon.setVisibility(View.GONE);
            }
        }
    }
}
