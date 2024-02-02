package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.core.widget.NestedScrollView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.tuichat.R;

public class FaceViewHolder extends RecyclerView.ViewHolder {
    public static final int TYPE = 2;
    protected RecyclerView recentUseList;
    protected TextView recentUseText;
    protected FaceGroup faceGroup;
    protected RecyclerView faceRecyclerView;
    protected GridLayoutManager faceLayoutManager;
    protected FaceListAdapter faceListAdapter;
    protected TextView faceGroupNameTv;
    protected NestedScrollView nestedScrollView;
    protected TextView sendButton;
    protected ImageView deleteButton;
    protected View controlButtonArea;
    protected FaceView.OnItemClickListener onItemClickListener;

    public FaceViewHolder(@NonNull View itemView) {
        super(itemView);
        faceRecyclerView = itemView.findViewById(R.id.face_group_list);
        faceGroupNameTv = itemView.findViewById(R.id.face_group_name);
        recentUseList = itemView.findViewById(R.id.face_recent_use_list);
        recentUseText = itemView.findViewById(R.id.recent_use_text);
        controlButtonArea = itemView.findViewById(R.id.control_button_area);
        controlButtonArea.setVisibility(View.GONE);
        deleteButton = itemView.findViewById(R.id.delete_button);
        deleteButton.getDrawable().setAutoMirrored(true);
        sendButton = itemView.findViewById(R.id.send_button);
        nestedScrollView = itemView.findViewById(R.id.face_scroll_view);
        nestedScrollView.setScrollbarFadingEnabled(false);
    }

    public void setOnEmojiClickListener(FaceView.OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    public void showFaceList(FaceGroup faceGroup) {
        this.faceGroup = faceGroup;
        layoutFaces();
    }

    public void layoutFaces() {
        recentUseText.setVisibility(View.GONE);
        recentUseList.setVisibility(View.GONE);
        controlButtonArea.setVisibility(View.GONE);
        faceLayoutManager = new GridLayoutManager(TIMCommonService.getAppContext(), faceGroup.getPageColumnCount());
        faceRecyclerView.setLayoutManager(faceLayoutManager);
        faceListAdapter = new FaceListAdapter();
        faceListAdapter.setOnEmojiClickListener(onItemClickListener);
        faceListAdapter.setFaceList(faceGroup.getFaces());
        int topSpace = itemView.getContext().getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_top_space);
        int leftSpace = itemView.getContext().getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_left_space);
        if (faceRecyclerView.getItemDecorationCount() == 0) {
            faceRecyclerView.addItemDecoration(new FaceView.GridDecoration(faceGroup.getPageColumnCount(), leftSpace, topSpace), 0);
        }
        faceRecyclerView.setAdapter(faceListAdapter);
        faceGroupNameTv.setText(faceGroup.getGroupName());
        faceGroupNameTv.setVisibility(View.GONE);
    }
}
