package com.tencent.qcloud.tuikit.tuicommunity.component;

import android.content.Context;
import android.os.Build;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.IPopupCard;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.IPopupView;

import java.util.List;

public class SelectListPopupView extends FrameLayout implements IPopupView {
    private View contentView;
    private int maxHeightPx;
    private TextView title;
    private TextView cancelButton;
    private RecyclerView selectList;
    private LinearLayoutManager layoutManager;

    private List<String> data;
    private SelectAdapter adapter;
    private OnSelectListener onSelectListener;
    private String selected;
    private IPopupCard popupCard;
    public SelectListPopupView(Context context) {
        super(context);
        init(context, null);
    }

    public SelectListPopupView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public SelectListPopupView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public SelectListPopupView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attributeSet) {
        contentView = LayoutInflater.from(context).inflate(R.layout.community_select_list_popup_layout, this);
        title = contentView.findViewById(R.id.title);
        cancelButton = contentView.findViewById(R.id.cancel_button);
        selectList = contentView.findViewById(R.id.select_list);
        layoutManager = new LinearLayoutManager(getContext());
        selectList.setLayoutManager(layoutManager);
        adapter = new SelectAdapter();
        selectList.setAdapter(adapter);

        cancelButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (popupCard != null) {
                    popupCard.dismiss();
                }
            }
        });
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int measuredHeight = MeasureSpec.getSize(heightMeasureSpec);
        if(maxHeightPx > 0 && maxHeightPx < measuredHeight) {
            heightMeasureSpec = MeasureSpec.makeMeasureSpec(maxHeightPx, MeasureSpec.AT_MOST);
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    public void setTitle(int stringResID) {
        title.setText(stringResID);
    }

    public void setTitle(String titleString) {
        title.setText(titleString);
    }

    public void setMaxHeightPx(int maxHeightPx) {
        this.maxHeightPx = maxHeightPx;
    }

    public void setData(List<String> data) {
        this.data = data;
        adapter.notifyDataSetChanged();
    }

    public void setSelected(String selected) {
        this.selected = selected;
    }

    public void setOnSelectListener(OnSelectListener onSelectListener) {
        this.onSelectListener = onSelectListener;
    }

    class SelectAdapter extends RecyclerView.Adapter<SelectAdapter.SelectViewHolder> {

        @NonNull
        @Override
        public SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_select_list_popup_item_layout, parent, false);
            return new SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull SelectViewHolder holder, int position) {
            String itemName = data.get(position);
            holder.textView.setText(itemName);
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    selected = itemName;
                    notifyDataSetChanged();
                    if (onSelectListener != null) {
                        onSelectListener.onSelected(itemName);
                    }
                    if (popupCard != null) {
                        popupCard.dismiss();
                    }
                }
            });
            if (TextUtils.equals(itemName, selected)) {
                holder.itemView.setBackgroundColor(getResources().getColor(R.color.community_list_selected_color));
            } else {
                holder.itemView.setBackgroundColor(getResources().getColor(R.color.community_list_normal_color));
            }
        }

        @Override
        public int getItemCount() {
            if (data == null || data.isEmpty()) {
                return 0;
            }
            return data.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder {
            private final TextView textView;
            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                textView = itemView.findViewById(R.id.item_text);
            }
        }
    }

    @Override
    public void setPopupCard(IPopupCard popupCard) {
        this.popupCard = popupCard;
    }

    public interface OnSelectListener {
        void onSelected(String data);
    }
}
