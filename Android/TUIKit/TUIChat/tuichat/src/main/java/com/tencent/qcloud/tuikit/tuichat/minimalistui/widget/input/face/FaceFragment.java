package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.face;

import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.RecyclerView.ViewHolder;
import androidx.viewpager2.widget.ViewPager2;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuikit.timcommon.component.face.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.component.face.CustomFace;
import com.tencent.qcloud.tuikit.timcommon.component.face.Emoji;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceGroup;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.EmojiIndicatorView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.BaseInputFragment;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FaceFragment extends BaseInputFragment {
    ViewPager2 faceViewPager;
    RecyclerView faceTabListView;
    FaceTabListAdapter faceTabListAdapter;
    ArrayList<Emoji> recentlyEmojiList;
    private OnEmojiClickListener listener;
    private RecentEmojiManager recentManager;
    private TextView sendButton;

    private boolean showCustomFace = true;

    public void setListener(OnEmojiClickListener listener) {
        this.listener = listener;
    }

    public void setShowCustomFace(boolean showCustomFace) {
        this.showCustomFace = showCustomFace;
    }

    @Override
    public void onAttach(Activity activity) {
        if (activity instanceof OnEmojiClickListener) {
            this.listener = (OnEmojiClickListener) activity;
        }
        recentManager = RecentEmojiManager.getInstance();
        super.onAttach(activity);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        try {
            if (recentManager.getCollection(RecentEmojiManager.PREFERENCE_NAME) != null) {
                recentlyEmojiList = (ArrayList<Emoji>) recentManager.getCollection(RecentEmojiManager.PREFERENCE_NAME);
            } else {
                recentlyEmojiList = new ArrayList<>();
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.minimalist_fragment_face, container, false);
        faceViewPager = view.findViewById(R.id.face_viewPager);
        faceTabListView = view.findViewById(R.id.face_view_group);
        sendButton = view.findViewById(R.id.send_btn);
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (listener != null) {
                    listener.sendEmoji();
                }
            }
        });
        initViews();
        return view;
    }

    private void initViews() {
        faceTabListAdapter = new FaceTabListAdapter();
        List<FaceGroup> faceGroups = new ArrayList<>();
        if (!showCustomFace) {
            faceGroups.add(FaceManager.getFaceGroupList().get(0));
        } else {
            faceGroups.addAll(FaceManager.getFaceGroupList());
        }
        faceTabListAdapter.setFaceGroups(faceGroups);
        faceTabListView.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        faceTabListView.setAdapter(faceTabListAdapter);

        FaceVPAdapter vpAdapter = new FaceVPAdapter();
        vpAdapter.setFaceGroups(faceGroups);
        faceViewPager.setAdapter(vpAdapter);
        faceViewPager.setUserInputEnabled(false);
        faceViewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            int oldPosition = 0;

            @Override
            public void onPageSelected(int position) {
                oldPosition = position;
                faceTabListAdapter.setSelected(position);
            }
        });
        faceViewPager.setCurrentItem(0);
    }

    private int getPagerCount(List<? extends ChatFace> list, int columns, int rows, boolean isShowDelete) {
        int count = list.size();
        int dit = 1;
        if (!isShowDelete) {
            dit = 0;
        }
        return count % (columns * rows - dit) == 0 ? count / (columns * rows - dit) : count / (columns * rows - dit) + 1;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        try {
            recentManager.putCollection(RecentEmojiManager.PREFERENCE_NAME, recentlyEmojiList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    class FaceTabListAdapter extends RecyclerView.Adapter<FaceTabListAdapter.FaceTabListViewHolder> {
        private List<FaceGroup> faceGroups;
        private int selected = 0;

        public void setFaceGroups(List<FaceGroup> faceGroups) {
            this.faceGroups = faceGroups;
        }

        public void setSelected(int selected) {
            this.selected = selected;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public FaceTabListViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.minimalist_face_group_icon, parent, false);
            return new FaceTabListViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull FaceTabListViewHolder holder, int position) {
            FaceGroup faceGroup = faceGroups.get(position);
            Glide.with(holder.itemView)
                .load(faceGroup.getFaceGroupIconUrl())
                .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                .into(holder.faceGroupIcon);
            if (selected == position) {
                holder.selectBorder.setVisibility(View.VISIBLE);
            } else {
                holder.selectBorder.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int index = faceGroups.indexOf(faceGroup);
                    if (index == -1) {
                        return;
                    }
                    faceViewPager.setCurrentItem(index);
                }
            });
        }

        @Override
        public int getItemCount() {
            if (faceGroups == null) {
                return 0;
            }
            return faceGroups.size();
        }

        class FaceTabListViewHolder extends ViewHolder {
            private View selectBorder;
            private ImageView faceGroupIcon;

            public FaceTabListViewHolder(@NonNull View itemView) {
                super(itemView);
                selectBorder = itemView.findViewById(R.id.select_border);
                faceGroupIcon = itemView.findViewById(R.id.face_group_tab_icon);
            }
        }
    }

    public interface OnEmojiClickListener {
        void onEmojiDelete();

        void onEmojiClick(Emoji emoji);

        void onCustomFaceClick(int groupIndex, CustomFace customFace);

        void sendEmoji();
    }

    static class FaceGVAdapter extends BaseAdapter {
        private List<ChatFace> faceList;
        private final Context mContext;

        public FaceGVAdapter(Context mContext) {
            super();
            this.mContext = mContext;
        }

        public void setFaceList(List<ChatFace> faceList) {
            this.faceList = faceList;
        }

        @Override
        public int getCount() {
            if (faceList == null) {
                return 0;
            }
            return faceList.size();
        }

        @Override
        public Object getItem(int position) {
            // TODO Auto-generated method stub
            return faceList.get(position);
        }

        @Override
        public long getItemId(int position) {
            // TODO Auto-generated method stub
            return position;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            ViewHolder holder;
            ChatFace chatFace = faceList.get(position);
            if (convertView == null) {
                holder = new ViewHolder();
                convertView = LayoutInflater.from(mContext).inflate(R.layout.item_face, null);
                holder.iv = convertView.findViewById(R.id.face_image);
                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) holder.iv.getLayoutParams();
                if (chatFace != null && chatFace.getHeight() != 0 && chatFace.getWidth() != 0) {
                    params.width = chatFace.getWidth();
                    params.height = chatFace.getHeight();
                }
                holder.iv.setLayoutParams(params);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }

            if (chatFace != null) {
                FaceManager.loadFace(chatFace, holder.iv);
            }
            return convertView;
        }

        class ViewHolder {
            ImageView iv;
        }
    }

    class FaceVPAdapter extends RecyclerView.Adapter<FaceVPAdapter.FaceVPHolder> {
        private List<FaceGroup> faceGroups;

        public void setFaceGroups(List<FaceGroup> faceGroups) {
            this.faceGroups = faceGroups;
        }

        @NonNull
        @Override
        public FaceVPHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_minimalist_face_view_pager_item, parent, false);
            FaceVPHolder holder = new FaceVPHolder(view);
            holder.faceGridAdapter = new FaceGridAdapter();
            holder.viewPager2.setAdapter(holder.faceGridAdapter);
            return new FaceVPHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull FaceVPHolder holder, int position) {
            FaceGridAdapter adapter = holder.faceGridAdapter;
            FaceGroup faceGroup = faceGroups.get(position);
            holder.setData(faceGroup);
            adapter.notifyDataSetChanged();
        }

        @Override
        public int getItemCount() {
            if (faceGroups == null) {
                return 0;
            }
            return faceGroups.size();
        }

        class FaceVPHolder extends ViewHolder {
            private int oldPosition = 0;
            private ViewPager2 viewPager2;
            private FaceGridAdapter faceGridAdapter;
            private EmojiIndicatorView indicatorView;

            public FaceVPHolder(@NonNull View itemView) {
                super(itemView);
                viewPager2 = itemView.findViewById(R.id.face_group_view_pager2);
                indicatorView = itemView.findViewById(R.id.face_indicator);
                faceGridAdapter = new FaceGridAdapter();
                viewPager2.setAdapter(faceGridAdapter);
                viewPager2.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
                    @Override
                    public void onPageSelected(int position) {
                        indicatorView.playBy(oldPosition, position);
                        oldPosition = position;
                    }
                });
            }

            void setData(FaceGroup faceGroup) {
                faceGridAdapter.setFaceGroup(faceGroup);
                indicatorView.init(
                    getPagerCount(faceGroup.getFaces(), faceGroup.getPageColumnCount(), faceGroup.getPageRowCount(), faceGroup.getGroupID() == 0));
                oldPosition = 0;
                faceGridAdapter.notifyDataSetChanged();
            }
        }

        class FaceGridAdapter extends RecyclerView.Adapter<FaceGridAdapter.FaceGridHolder> {
            private FaceGroup faceGroup;

            public void setFaceGroup(FaceGroup faceGroup) {
                this.faceGroup = faceGroup;
            }

            @NonNull
            @Override
            public FaceGridAdapter.FaceGridHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                GridView gridView = (GridView) LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_face_grid, parent, false);
                gridView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                return new FaceGridHolder(gridView);
            }

            @Override
            public void onBindViewHolder(@NonNull FaceGridAdapter.FaceGridHolder holder, int position) {
                boolean isShowDelete = faceGroup.getGroupID() == 0;
                int dit = 1;
                if (!isShowDelete) {
                    dit = 0;
                }
                int columns = faceGroup.getPageColumnCount();
                int rows = faceGroup.getPageRowCount();

                List<ChatFace> faces = faceGroup.getFaces();
                List<ChatFace> subList = faces.subList(position * (columns * rows - dit), Math.min((columns * rows - dit) * (position + 1), faces.size()));

                if (isShowDelete && subList.size() < (columns * rows - dit)) {
                    for (int i = subList.size(); i < (columns * rows - dit); i++) {
                        subList.add(null);
                    }
                }
                if (isShowDelete) {
                    Emoji deleteEmoji = new Emoji();
                    deleteEmoji.setIcon(BitmapFactory.decodeResource(getResources(), R.drawable.face_delete));
                    subList.add(deleteEmoji);
                }
                FaceGVAdapter adapter = (FaceGVAdapter) holder.faceGrid.getAdapter();
                adapter.setFaceList(subList);
                holder.faceGrid.setNumColumns(faceGroup.getPageColumnCount());
                holder.faceGrid.setAdapter(adapter);
                holder.faceGrid.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                        if (subList.get(position) instanceof CustomFace) {
                            listener.onCustomFaceClick(faceGroup.getGroupID(), (CustomFace) subList.get(position));
                        } else if (subList.get(position) instanceof Emoji) {
                            if (position == columns * rows - 1) {
                                if (listener != null) {
                                    listener.onEmojiDelete();
                                }
                                return;
                            }
                            if (listener != null) {
                                listener.onEmojiClick((Emoji) subList.get(position));
                            }
                        }
                    }
                });
            }

            @Override
            public int getItemCount() {
                if (faceGroup == null) {
                    return 0;
                }
                return getPagerCount(faceGroup.getFaces(), faceGroup.getPageColumnCount(), faceGroup.getPageRowCount(), faceGroup.getGroupID() == 0);
            }

            class FaceGridHolder extends ViewHolder {
                private GridView faceGrid;

                public FaceGridHolder(@NonNull View itemView) {
                    super(itemView);
                    faceGrid = (GridView) itemView;
                    faceGrid.setAdapter(new FaceGVAdapter(itemView.getContext()));
                }
            }
        }
    }
}
