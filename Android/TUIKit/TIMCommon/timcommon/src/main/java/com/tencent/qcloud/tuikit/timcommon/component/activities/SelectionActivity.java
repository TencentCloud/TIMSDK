package com.tencent.qcloud.tuikit.timcommon.component.activities;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputFilter;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import java.util.ArrayList;

public class SelectionActivity extends BaseLightActivity {
    private static OnResultReturnListener sOnResultReturnListener;

    private RecyclerView selectListView;
    private SelectAdapter selectListAdapter;
    private EditText input;
    private int mSelectionType;
    private ArrayList<String> selectList = new ArrayList<>();
    private int selectedItem = -1;
    private OnItemClickListener onItemClickListener;
    private boolean needConfirm = true;
    private boolean returnNow = true;

    public static void startTextSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        bundle.putInt(Selection.TYPE, Selection.TYPE_TEXT);
        startSelection(context, bundle, listener);
    }

    public static void startListSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        bundle.putInt(Selection.TYPE, Selection.TYPE_LIST);
        startSelection(context, bundle, listener);
    }

    private static void startSelection(Context context, Bundle bundle, OnResultReturnListener listener) {
        Intent intent = new Intent(context, SelectionActivity.class);
        intent.putExtra(Selection.CONTENT, bundle);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        sOnResultReturnListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuicore_selection_activity);
        final TitleBarLayout titleBar = findViewById(R.id.edit_title_bar);
        selectListView = findViewById(R.id.select_list);
        selectListAdapter = new SelectAdapter();
        selectListView.setAdapter(selectListAdapter);
        selectListView.setLayoutManager(new CustomLinearLayoutManager(this));
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        dividerItemDecoration.setDrawable(getResources().getDrawable(R.drawable.core_list_divider));
        selectListView.addItemDecoration(dividerItemDecoration);
        onItemClickListener = new OnItemClickListener() {
            @Override
            public void onClick(int position) {
                selectedItem = position;
                selectListAdapter.setSelectedItem(position);
                selectListAdapter.notifyDataSetChanged();
                if (!needConfirm) {
                    echoClick();
                }
            }
        };
        input = findViewById(R.id.edit_content_et);

        Bundle bundle = getIntent().getBundleExtra(Selection.CONTENT);
        switch (bundle.getInt(Selection.TYPE)) {
            case Selection.TYPE_TEXT:
                selectListView.setVisibility(View.GONE);
                String defaultString = bundle.getString(Selection.INIT_CONTENT);
                int limit = bundle.getInt(Selection.LIMIT);
                if (!TextUtils.isEmpty(defaultString)) {
                    input.setText(defaultString);
                    input.setSelection(defaultString.length());
                }
                if (limit > 0) {
                    input.setFilters(new InputFilter[] {new InputFilter.LengthFilter(limit)});
                }
                break;
            case Selection.TYPE_LIST:
                input.setVisibility(View.GONE);
                ArrayList<String> list = bundle.getStringArrayList(Selection.LIST);
                selectedItem = bundle.getInt(Selection.DEFAULT_SELECT_ITEM_INDEX);
                if (list == null || list.size() == 0) {
                    return;
                }
                selectList.clear();
                selectList.addAll(list);
                selectListAdapter.setSelectedItem(selectedItem);
                selectListAdapter.setData(selectList);
                selectListAdapter.notifyDataSetChanged();

                break;
            default:
                finish();
                return;
        }
        mSelectionType = bundle.getInt(Selection.TYPE);

        final String title = bundle.getString(Selection.TITLE);

        needConfirm = bundle.getBoolean(Selection.NEED_CONFIRM, true);
        returnNow = bundle.getBoolean(Selection.RETURN_NOW, true);

        titleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
        titleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        titleBar.getRightIcon().setVisibility(View.GONE);
        if (needConfirm) {
            titleBar.getRightTitle().setText(getResources().getString(com.tencent.qcloud.tuicore.R.string.sure));
            titleBar.setOnRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    echoClick();
                }
            });
        } else {
            titleBar.getRightGroup().setVisibility(View.GONE);
        }
    }

    private void echoClick() {
        switch (mSelectionType) {
            case Selection.TYPE_TEXT:
                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(input.getText().toString());
                }
                break;
            case Selection.TYPE_LIST:
                if (sOnResultReturnListener != null) {
                    sOnResultReturnListener.onReturn(selectedItem);
                }
                break;
            default:
                break;
        }
        if (returnNow) {
            finish();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        sOnResultReturnListener = null;
    }

    class SelectAdapter extends RecyclerView.Adapter<SelectAdapter.SelectViewHolder> {
        int selectedItem = -1;
        ArrayList<String> data = new ArrayList<>();

        public void setData(ArrayList<String> data) {
            this.data.clear();
            this.data.addAll(data);
        }

        public void setSelectedItem(int selectedItem) {
            this.selectedItem = selectedItem;
        }

        @NonNull
        @Override
        public SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(SelectionActivity.this).inflate(R.layout.core_select_item_layout, parent, false);
            return new SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull SelectViewHolder holder, int position) {
            String nameStr = data.get(position);
            holder.name.setText(nameStr);
            if (selectedItem == position) {
                holder.selectedIcon.setVisibility(View.VISIBLE);
            } else {
                holder.selectedIcon.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onClick(position);
                }
            });
        }

        @Override
        public int getItemCount() {
            return data.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder {
            TextView name;
            ImageView selectedIcon;

            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                name = itemView.findViewById(R.id.name);
                selectedIcon = itemView.findViewById(R.id.selected_icon);
            }
        }
    }

    public interface OnResultReturnListener {
        void onReturn(Object res);
    }

    public interface OnItemClickListener {
        void onClick(int position);
    }

    public static class Selection {
        public static final String SELECT_ALL = "select_all";
        public static final String CONTENT = "content";
        public static final String TYPE = "type";
        public static final String TITLE = "title";
        public static final String INIT_CONTENT = "init_content";
        public static final String DEFAULT_SELECT_ITEM_INDEX = "default_select_item_index";
        public static final String LIST = "list";
        public static final String LIMIT = "limit";
        public static final String NEED_CONFIRM = "needConfirm";
        public static final String RETURN_NOW = "returnNow";
        public static final int TYPE_TEXT = 1;
        public static final int TYPE_LIST = 2;
    }
}
