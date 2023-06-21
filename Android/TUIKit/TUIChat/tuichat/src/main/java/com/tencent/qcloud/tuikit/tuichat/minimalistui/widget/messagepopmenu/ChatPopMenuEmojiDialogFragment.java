package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu;

import android.app.Dialog;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuikit.timcommon.component.face.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import java.util.List;

public class ChatPopMenuEmojiDialogFragment extends DialogFragment {
    public static final int SPAN_COUNT = 7;

    private BottomSheetDialog dialog;

    private RecyclerView emojiGridList;

    private List<Emoji> emojiList;

    private EmojiClickListener emojiClickListener;

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        dialog = new BottomSheetDialog(getContext(), R.style.ChatPopActivityStyle);
        dialog.setCanceledOnTouchOutside(true);
        BottomSheetBehavior<FrameLayout> bottomSheetBehavior = dialog.getBehavior();
        bottomSheetBehavior.setFitToContents(false);
        bottomSheetBehavior.setHalfExpandedRatio(0.45f);
        bottomSheetBehavior.setSkipCollapsed(true);
        bottomSheetBehavior.setExpandedOffset(ScreenUtil.dip2px(36));
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.chat_popmenu_emoji_dialog_layout, container);
        emojiGridList = view.findViewById(R.id.emoji_grid_list);
        initData();
        return view;
    }

    private void initData() {
        emojiList = FaceManager.getEmojiList();
        emojiGridList.setLayoutManager(new GridLayoutManager(getContext(), SPAN_COUNT));
        emojiGridList.setAdapter(new EmojiAdapter());
        emojiGridList.post(new Runnable() {
            @Override
            public void run() {
                FaceGridDecoration decoration = new FaceGridDecoration(SPAN_COUNT)
                                                    .setTopBottomSpace(ScreenUtil.dip2px(10))
                                                    .setWidth(emojiGridList.getWidth())
                                                    .setItemWidth(emojiGridList.getChildAt(0).getWidth());
                emojiGridList.addItemDecoration(decoration);
            }
        });
    }

    public void setEmojiClickListener(EmojiClickListener emojiClickListener) {
        this.emojiClickListener = emojiClickListener;
    }

    class EmojiAdapter extends RecyclerView.Adapter<EmojiAdapter.EmojiHolder> {
        @NonNull
        @Override
        public EmojiHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_pop_menu_emoji_item_layout, parent, false);
            return new EmojiHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull EmojiHolder holder, int position) {
            Emoji emoji = emojiList.get(position);
            holder.emojiImg.setImageBitmap(emoji.getIcon());
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (emojiClickListener != null) {
                        emojiClickListener.onClick(emoji);
                    }
                    dismiss();
                }
            });
        }

        @Override
        public int getItemCount() {
            if (emojiList == null) {
                return 0;
            } else {
                return emojiList.size();
            }
        }

        class EmojiHolder extends RecyclerView.ViewHolder {
            private final ImageView emojiImg;

            public EmojiHolder(@NonNull View itemView) {
                super(itemView);
                emojiImg = itemView.findViewById(R.id.emoji_img);
            }
        }
    }

    static class FaceGridDecoration extends RecyclerView.ItemDecoration {
        private final int columnNum;
        private int topBottomSpace;
        private int width;
        private int itemWidth;

        public FaceGridDecoration(int columnNum) {
            this.columnNum = columnNum;
        }

        public FaceGridDecoration setTopBottomSpace(int space) {
            this.topBottomSpace = space;
            return this;
        }

        public FaceGridDecoration setWidth(int width) {
            this.width = width;
            return this;
        }

        public FaceGridDecoration setItemWidth(int itemWidth) {
            this.itemWidth = itemWidth;
            return this;
        }

        private int getLeftRightSpace() {
            return (width - (columnNum * itemWidth)) / (columnNum - 1);
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;
            int leftRightSpace = getLeftRightSpace();
            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            outRect.top = topBottomSpace;
            outRect.bottom = topBottomSpace;
        }
    }

    interface EmojiClickListener {
        void onClick(Emoji emoji);
    }
}
