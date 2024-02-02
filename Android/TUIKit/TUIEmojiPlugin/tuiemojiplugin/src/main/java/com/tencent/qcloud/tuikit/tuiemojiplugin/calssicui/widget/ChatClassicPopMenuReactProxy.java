package com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.EmojiIndicatorView;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import com.tencent.qcloud.tuikit.tuiemojiplugin.R;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.OnEmojiClickedListener;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionBeanCache;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.TUIEmojiPresenter;
import com.tencent.qcloud.tuikit.tuiemojiplugin.util.TUIEmojiLog;
import java.util.ArrayList;
import java.util.List;

public class ChatClassicPopMenuReactProxy {
    private static final String TAG = ChatClassicPopMenuReactProxy.class.getSimpleName();
    // emoji column num
    private static final int EMOJI_COLUMN_NUM = 8;
    private static final int EMOJI_ROW_NUM = 3;
    private static final int RECENT_EMOJI_NUM = 6;

    private RecyclerView facePageRecyclerView;
    private LinearLayout facePageLinearLayout;
    private EmojiIndicatorView facePageIndicator;
    private RecyclerView recentFaceView;
    private View divideLine;
    private FacePageAdapter facePageAdapter;

    private final List<Emoji> emojiList = new ArrayList<>();
    private final List<String> recentEmojiList = new ArrayList<>();
    private OnEmojiClickedListener onEmojiClickedListener;
    private boolean isShowMoreFace = false;
    private int oldFacePageIndex = 0;
    private Context context;
    private TUIEmojiPresenter presenter;
    private ChatPopMenu chatPopMenu;

    public ChatClassicPopMenuReactProxy() {
        presenter = new TUIEmojiPresenter();
    }

    public void setChatPopMenu(ChatPopMenu chatPopMenu) {
        this.chatPopMenu = chatPopMenu;
    }

    public void fill() {
        FrameLayout frameLayout = chatPopMenu.getReactFrameLayout();
        context = frameLayout.getContext();

        View reactionArea = LayoutInflater.from(frameLayout.getContext()).inflate(R.layout.tuiemoji_classic_chat_popup_react_area, null);
        frameLayout.addView(reactionArea);
        initEmojiList();

        divideLine = reactionArea.findViewById(R.id.divide_line);
        // recent faces

        recentFaceView = reactionArea.findViewById(R.id.recent_faces);
        recentFaceView.setItemAnimator(null);
        LinearLayoutManager recentLayoutManager = new LinearLayoutManager(context, RecyclerView.HORIZONTAL, false);
        int recentSpacing = reactionArea.getResources().getDimensionPixelOffset(R.dimen.tuiemoji_chat_pop_menu_recent_face_space);
        recentFaceView.addItemDecoration(new GridDecoration(null, RECENT_EMOJI_NUM + 1, recentSpacing, 0));
        recentFaceView.setLayoutManager(recentLayoutManager);
        RecentFaceAdapter recentFaceAdapter = new RecentFaceAdapter();
        recentFaceView.setAdapter(recentFaceAdapter);
        // grid faces
        facePageLinearLayout = reactionArea.findViewById(R.id.face_grid_ll);
        facePageRecyclerView = reactionArea.findViewById(R.id.face_grid);
        facePageIndicator = reactionArea.findViewById(R.id.face_indicator);
        facePageLinearLayout.setVisibility(View.GONE);
        LinearLayoutManager faceLayoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false);
        PagerSnapHelper snapHelper = new PagerSnapHelper();
        snapHelper.attachToRecyclerView(facePageRecyclerView);
        facePageRecyclerView.setLayoutManager(faceLayoutManager);
        facePageAdapter = new FacePageAdapter();
        facePageRecyclerView.setAdapter(facePageAdapter);
        setFacePageIndicator(faceLayoutManager);
        if (!chatPopMenu.isShowFaces()) {
            recentFaceView.setVisibility(View.GONE);
            divideLine.setVisibility(View.GONE);
        } else {
            recentFaceView.setVisibility(View.VISIBLE);
            if (chatPopMenu.hasMenuAction()) {
                divideLine.setVisibility(View.VISIBLE);
                chatPopMenu.setActionListVisibility(View.VISIBLE);
            } else {
                divideLine.setVisibility(View.GONE);
                chatPopMenu.setActionListVisibility(View.GONE);
            }
        }
        onEmojiClickedListener = new OnEmojiClickedListener() {
            @Override
            public void onEmojiClicked(Emoji emoji) {
                MessageReactionBean messageReactionBean = MessageReactionBeanCache.getMessageReactionBean(chatPopMenu.getMessageBean().getId());
                if (messageReactionBean != null) {
                    ReactionBean reactionBean = messageReactionBean.getReactionBean(emoji.getFaceKey());
                    if (reactionBean == null) {
                        addMessageReaction(chatPopMenu.getMessageBean(), emoji.getFaceKey());
                    } else {
                        if (reactionBean.isByMySelf()) {
                            removeMessageReaction(chatPopMenu.getMessageBean(), emoji.getFaceKey());
                        } else {
                            addMessageReaction(chatPopMenu.getMessageBean(), emoji.getFaceKey());
                        }
                    }
                }
                updateRecentEmoji(emoji);
                chatPopMenu.hide();
            }
        };
    }

    private void addMessageReaction(TUIMessageBean messageBean, String reactionID) {
        presenter.addMessageReaction(messageBean, reactionID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUIEmojiLog.i(TAG, "addMessageReaction success " + messageBean.getId() + " " + reactionID);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIEmojiLog.e(TAG, "addMessageReaction failed code " + errorCode + ",message " + errorMessage);
                ToastUtil.toastLongMessage(
                    context.getString(R.string.tuiemoji_add_reaction_failed_tip) + " " + ErrorMessageConverter.convertIMError(errorCode, errorMessage));
            }
        });
    }

    private void removeMessageReaction(TUIMessageBean messageBean, String reactionID) {
        presenter.removeMessageReaction(messageBean, reactionID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUIEmojiLog.i(TAG, "removeMessageReaction success " + messageBean.getId() + " " + reactionID);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIEmojiLog.e(TAG, "addMessageReaction failed code " + errorCode + ",message " + errorMessage);
                ToastUtil.toastLongMessage(
                    context.getString(R.string.tuiemoji_remove_reaction_failed_tip) + " " + ErrorMessageConverter.convertIMError(errorCode, errorMessage));
            }
        });
    }

    private void setFacePageIndicator(LinearLayoutManager faceLayoutManager) {
        facePageIndicator.init(facePageAdapter.getItemCount());
        facePageRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                int currentFacePageIndex;
                if (dx >= 0) {
                    currentFacePageIndex = faceLayoutManager.findLastVisibleItemPosition();
                } else {
                    currentFacePageIndex = faceLayoutManager.findFirstVisibleItemPosition();
                }
                // the page is not be selected
                if (currentFacePageIndex == RecyclerView.NO_POSITION || oldFacePageIndex == currentFacePageIndex) {
                    return;
                }
                facePageIndicator.playBy(oldFacePageIndex, currentFacePageIndex);
                oldFacePageIndex = currentFacePageIndex;
            }
        });
    }

    private void initEmojiList() {
        emojiList.addAll(FaceManager.getEmojiList());
        initDefaultEmoji();
    }

    private void initDefaultEmoji() {
        List<String> emojis = (List<String>) RecentEmojiManager.getCollection();
        if (emojis == null) {
            List<Emoji> subList = emojiList.subList(0, RECENT_EMOJI_NUM);
            List<String> emojiKeys = new ArrayList<>();
            for (Emoji emoji : subList) {
                emojiKeys.add(emoji.getFaceKey());
            }
            emojis = new ArrayList<>(emojiKeys);
            RecentEmojiManager.putCollection(emojis);
        }
        recentEmojiList.addAll(emojis);
    }

    private void updateRecentEmoji(Emoji emoji) {
        recentEmojiList.remove(emoji.getFaceKey());
        recentEmojiList.add(0, emoji.getFaceKey());
        RecentEmojiManager.updateRecentUseEmoji(emoji.getFaceKey());
    }

    class RecentFaceAdapter extends RecyclerView.Adapter<RecentFaceAdapter.RecentFaceViewHolder> {
        @NonNull
        @Override
        public RecentFaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.tuiemoji_chat_menu_recent_face_item_layout, parent, false);
            return new RecentFaceViewHolder(faceView);
        }

        @Override
        public void onBindViewHolder(@NonNull RecentFaceViewHolder holder, int position) {
            Emoji emoji;
            if (position == RECENT_EMOJI_NUM) {
                emoji = new Emoji();
                Bitmap bitMap;
                if (!isShowMoreFace) {
                    bitMap = BitmapFactory.decodeResource(context.getResources(), R.drawable.tuiemoji_classic_chat_menu_face_show_more);
                } else {
                    bitMap = BitmapFactory.decodeResource(context.getResources(), R.drawable.tuiemoji_classic_chat_menu_face_hide_more);
                }
                emoji.setIcon(bitMap);
            } else {
                emoji = getEmoji(recentEmojiList.get(position));
            }
            if (emoji == null) {
                return;
            }
            holder.faceIv.setImageBitmap(emoji.getIcon());
            if (onEmojiClickedListener != null) {
                holder.faceIv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (position == RECENT_EMOJI_NUM) {
                            isShowMoreFace = !isShowMoreFace;
                            refreshLayout();
                            notifyItemChanged(position);
                        } else {
                            onEmojiClickedListener.onEmojiClicked(emoji);
                            chatPopMenu.hide();
                        }
                    }
                });
            }
        }

        private Emoji getEmoji(String emojiKey) {
            for (Emoji emoji : emojiList) {
                if (TextUtils.equals(emoji.getFaceKey(), emojiKey)) {
                    return emoji;
                }
            }
            return null;
        }

        @Override
        public int getItemCount() {
            return RECENT_EMOJI_NUM + 1;
        }

        class RecentFaceViewHolder extends RecyclerView.ViewHolder {
            ImageView faceIv;

            public RecentFaceViewHolder(@NonNull View itemView) {
                super(itemView);
                faceIv = itemView.findViewById(R.id.face_iv);
            }
        }
    }

    class FacePageAdapter extends RecyclerView.Adapter<FacePageAdapter.FacePageViewHolder> {
        @NonNull
        @Override
        public FacePageAdapter.FacePageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            RecyclerView faceGridView = new RecyclerView(parent.getContext());
            faceGridView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            faceGridView.setLayoutManager(new GridLayoutManager(parent.getContext(), EMOJI_COLUMN_NUM));
            int faceVerticalSpacing = ScreenUtil.dip2px(16.32f);
            int faceHorizontalSpacing = ScreenUtil.dip2px(9.12f);
            faceGridView.addItemDecoration(new FaceGridDecoration(EMOJI_COLUMN_NUM, faceHorizontalSpacing, faceVerticalSpacing));
            return new FacePageViewHolder(faceGridView);
        }

        @Override
        public void onBindViewHolder(@NonNull FacePageAdapter.FacePageViewHolder holder, int position) {
            FaceGridAdapter faceGridAdapter = new FaceGridAdapter();
            holder.recyclerView.setAdapter(faceGridAdapter);
            int startIndex = position * EMOJI_ROW_NUM * EMOJI_COLUMN_NUM;
            int endIndex = (position + 1) * EMOJI_COLUMN_NUM * EMOJI_ROW_NUM;
            if (endIndex > emojiList.size()) {
                endIndex = emojiList.size();
            }
            List<Emoji> data = emojiList.subList(startIndex, endIndex);
            faceGridAdapter.setData(data);
        }

        @Override
        public int getItemCount() {
            return (int) Math.ceil(emojiList.size() * 1.0f / (EMOJI_COLUMN_NUM * EMOJI_ROW_NUM));
        }

        class FacePageViewHolder extends RecyclerView.ViewHolder {
            public RecyclerView recyclerView;

            public FacePageViewHolder(@NonNull View itemView) {
                super(itemView);
                recyclerView = (RecyclerView) itemView;
            }
        }
    }

    private void refreshLayout() {
        if (isShowMoreFace) {
            facePageLinearLayout.setVisibility(View.VISIBLE);
            chatPopMenu.setActionListVisibility(View.GONE);
            divideLine.setVisibility(View.VISIBLE);
        } else {
            facePageLinearLayout.setVisibility(View.GONE);
            if (chatPopMenu.hasMenuAction()) {
                divideLine.setVisibility(View.VISIBLE);
                chatPopMenu.setActionListVisibility(View.VISIBLE);
            } else {
                divideLine.setVisibility(View.GONE);
                chatPopMenu.setActionListVisibility(View.GONE);
            }
        }
        chatPopMenu.showAtLocation();
    }

    class FaceGridAdapter extends RecyclerView.Adapter<FaceViewHolder> {
        private List<Emoji> data;

        public void setData(List<Emoji> data) {
            this.data = data;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public FaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.tuiemoji_classic_chat_menu_face_item_layout, parent, false);
            return new FaceViewHolder(faceView);
        }

        @Override
        public void onBindViewHolder(@NonNull FaceViewHolder holder, int position) {
            Emoji emoji = data.get(position);
            holder.faceIv.setBackground(new BitmapDrawable(holder.itemView.getResources(), emoji.getIcon()));
            if (onEmojiClickedListener != null) {
                holder.faceIv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onEmojiClickedListener.onEmojiClicked(emoji);
                        updateRecentEmoji(emoji);
                        chatPopMenu.hide();
                    }
                });
            }
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }
    }

    static class FaceViewHolder extends RecyclerView.ViewHolder {
        ImageView faceIv;

        public FaceViewHolder(@NonNull View itemView) {
            super(itemView);
            faceIv = itemView.findViewById(R.id.face_iv);
        }
    }

    static class FaceGridDecoration extends RecyclerView.ItemDecoration {
        private final int columnNum;
        private final int leftRightSpace; // horizontal spacing
        private final int topBottomSpace; // vertical spacing

        public FaceGridDecoration(int columnNum, int leftRightSpace, int topBottomSpace) {
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            int left = column * leftRightSpace / columnNum;
            int right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            if (LayoutUtil.isRTL()) {
                outRect.left = right;
                outRect.right = left;
            } else {
                outRect.left = left;
                outRect.right = right;
            }

            // grid has multi rows, add top spacing
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }
    }

    static class GridDecoration extends RecyclerView.ItemDecoration {
        private final int columnNum;
        private final int leftRightSpace;
        private final int topBottomSpace;
        private final Drawable divider;

        public GridDecoration(Drawable divider, int columnNum, int leftRightSpace, int topBottomSpace) {
            this.divider = divider;
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            int left = column * leftRightSpace / columnNum;
            int right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            if (LayoutUtil.isRTL()) {
                outRect.left = right;
                outRect.right = left;
            } else {
                outRect.left = left;
                outRect.right = right;
            }

            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }

        @Override
        public void onDraw(@NonNull Canvas canvas, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            if (divider == null) {
                return;
            }
            canvas.save();
            final int childCount = parent.getChildCount();
            int rowNum = (int) Math.ceil(childCount * 1.0f / columnNum);
            final int divideLine = rowNum - 1;
            for (int i = 0; i < divideLine; i++) {
                View startChild = parent.getChildAt(i * columnNum);
                View endChild = parent.getChildAt((i + 1) * columnNum - 1);
                final int bottom = startChild.getBottom();
                final int top = bottom - divider.getIntrinsicHeight();
                divider.setBounds(startChild.getLeft(), top + topBottomSpace / 2, endChild.getRight(), bottom + topBottomSpace / 2);
                divider.draw(canvas);
            }
            canvas.restore();
        }
    }
}
