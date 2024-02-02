package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.graphics.Rect;
import android.view.View;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.core.widget.NestedScrollView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import java.util.ArrayList;
import java.util.List;

public class EmojiViewHolder extends FaceViewHolder {
    public static final int TYPE = 1;
    public static final int SHOW_RECENT_EMOJI_NUM = 8;

    private FaceListAdapter recentListAdapter;
    private GridLayoutManager recentLayoutManager;

    public EmojiViewHolder(@NonNull View itemView) {
        super(itemView);
    }

    @Override
    public void layoutFaces() {
        recentUseText.setVisibility(View.VISIBLE);
        recentUseList.setVisibility(View.VISIBLE);
        faceLayoutManager = new GridLayoutManager(TIMCommonService.getAppContext(), faceGroup.getPageColumnCount());
        faceRecyclerView.setLayoutManager(faceLayoutManager);

        faceRecyclerView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                onScrollEvent();
            }
        });

        faceRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                onScrollEvent();
            }
        });

        nestedScrollView.setOnScrollChangeListener(new NestedScrollView.OnScrollChangeListener() {
            @Override
            public void onScrollChange(NestedScrollView v, int scrollX, int scrollY, int oldScrollX, int oldScrollY) {
                onScrollEvent();
            }
        });

        int paddingBottom = ScreenUtil.dip2px(60);
        faceRecyclerView.setPaddingRelative(0, 0, 0, paddingBottom);
        faceListAdapter = new FaceListAdapter();
        faceListAdapter.setOnEmojiClickListener(onItemClickListener);
        faceListAdapter.setFaceList(faceGroup.getFaces());
        int topSpace = itemView.getContext().getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_top_space);
        int leftSpace = itemView.getContext().getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_left_space);
        if (faceRecyclerView.getItemDecorationCount() == 0) {
            faceRecyclerView.addItemDecoration(new FaceView.GridDecoration(faceGroup.getPageColumnCount(), leftSpace, topSpace), 0);
        }
        faceRecyclerView.setAdapter(faceListAdapter);
        faceGroupNameTv.setText(itemView.getContext().getString(R.string.chat_all_emojis));

        controlButtonArea.setVisibility(View.VISIBLE);
        deleteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onDeleteClicked();
                }
            }
        });
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onSendClicked();
                }
            }
        });

        showRecentUse();
    }

    private void onScrollEvent() {
        int first = faceLayoutManager.findFirstVisibleItemPosition();
        int last = faceLayoutManager.findLastVisibleItemPosition();
        if (controlButtonArea.getVisibility() != View.VISIBLE) {
            return;
        }
        Rect controllAreaRect = new Rect();
        controlButtonArea.getGlobalVisibleRect(controllAreaRect);
        for (int i = last; i >= first; i--) {
            View view = faceLayoutManager.findViewByPosition(i);
            if (view == null) {
                continue;
            }
            ImageView imageView = view.findViewById(R.id.face_image);
            if (imageView == null) {
                continue;
            }
            Rect childRect = new Rect();
            imageView.getGlobalVisibleRect(childRect);
            if (controllAreaRect.contains(childRect) || Rect.intersects(controllAreaRect, childRect)) {
                Rect tempRect = new Rect(controllAreaRect);
                tempRect.intersect(childRect);
                double alpha = (Math.sqrt(tempRect.width()) + Math.sqrt(tempRect.height())) / (Math.sqrt(childRect.height()) + Math.sqrt(childRect.width()));
                imageView.setAlpha(1 - (float) alpha);
            } else {
                imageView.setAlpha(1.0f);
            }
        }
    }

    public void showRecentUse() {
        recentListAdapter = new FaceListAdapter();
        int leftSpace = itemView.getContext().getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_left_space);
        recentLayoutManager = new GridLayoutManager(itemView.getContext(), SHOW_RECENT_EMOJI_NUM);
        recentUseList.setLayoutManager(recentLayoutManager);
        recentListAdapter.setOnEmojiClickListener(onItemClickListener);
        if (recentUseList.getItemDecorationCount() == 0) {
            recentUseList.addItemDecoration(new FaceView.GridDecoration(SHOW_RECENT_EMOJI_NUM, leftSpace, 0));
        }
        recentUseList.setAdapter(recentListAdapter);
        setRecentEmojis();
    }

    private void setRecentEmojis() {
        List<String> emojiKeys = RecentEmojiManager.getCollection();
        if (emojiKeys == null) {
            List<Emoji> emojiList = FaceManager.getEmojiList();
            List<Emoji> subList = emojiList.subList(0, SHOW_RECENT_EMOJI_NUM);
            emojiKeys = new ArrayList<>();
            for (Emoji emoji : subList) {
                emojiKeys.add(emoji.getFaceKey());
            }
            RecentEmojiManager.putCollection(emojiKeys);
            if (emojiKeys.isEmpty()) {
                recentUseText.setVisibility(View.GONE);
                recentUseList.setVisibility(View.GONE);
            }
        }

        List<ChatFace> recentFaces = new ArrayList<>();
        for (String key : emojiKeys) {
            if (recentFaces.size() >= SHOW_RECENT_EMOJI_NUM) {
                break;
            }
            Emoji emoji = FaceManager.getEmojiMap().get(key);
            if (emoji != null) {
                recentFaces.add(emoji);
            }
        }
        recentListAdapter.setFaceList(recentFaces);
    }
}
