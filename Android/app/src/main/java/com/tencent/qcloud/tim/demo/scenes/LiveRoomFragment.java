package com.tencent.qcloud.tim.demo.scenes;

import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.tencent.liteav.login.ProfileManager;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.adapter.RoomListAdapter;
import com.tencent.qcloud.tim.demo.scenes.net.RoomManager;
import com.tencent.qcloud.tim.demo.utils.ClickUtils;

import java.util.ArrayList;
import java.util.List;

public class LiveRoomFragment extends BaseScenesFragment implements View.OnClickListener, SwipeRefreshLayout.OnRefreshListener {

    private static final String TAG = "LiveRoomFragment";

    private View mRootView;

    private RecyclerView mRecyclerView;
    private SwipeRefreshLayout mSwipeRefreshLayout;

    private RoomListAdapter mRoomListAdapter;
    private List<RoomListAdapter.ScenesRoomInfo> mRoomInfoList = new ArrayList<>();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (mRootView == null) {
            mRootView = inflater.inflate(R.layout.live_fragment_live_room, container, false);
            initView();
        }
        getScenesRoomInfos();
        return mRootView;
    }

    @Override
    public void onRefresh() {
        getScenesRoomInfos();
    }

    @Override
    public void onClick(View v) {
        if (ClickUtils.isFastClick(v.getId())) {
            return;
        }
        switch (v.getId()) {
            case R.id.live_scenes_live_create_room:
                createRoom();
                break;
        }
    }

    private void initView() {
        mSwipeRefreshLayout = mRootView.findViewById(R.id.live_scenes_live_room_swipe_refresh_layout_list);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRootView.findViewById(R.id.live_scenes_live_create_room).setOnClickListener(this);
        mRecyclerView = mRootView.findViewById(R.id.live_scenes_live_room_rv_room_list);

        mRoomListAdapter = new RoomListAdapter(getContext(), mRoomInfoList, new RoomListAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position, RoomListAdapter.ScenesRoomInfo roomInfo) {
                String selfUserId = ProfileManager.getInstance().getUserModel().userId;
                if (roomInfo.anchorId.equals(selfUserId)) {
                    createRoom();
                } else {
                    enterRoom(roomInfo);
                }
            }
        });
        mRecyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        mRecyclerView.setAdapter(mRoomListAdapter);
        mRecyclerView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int space = getResources().getDimensionPixelOffset(R.dimen.page_margin);
                outRect.top = space;
                int childLayoutPosition = parent.getChildLayoutPosition(view);
                if (childLayoutPosition % 2 == 0) {
                    outRect.left = space;
                    outRect.right = space / 2;
                } else {
                    outRect.left = space / 2;
                    outRect.right = space;
                }
            }
        });
        mRoomListAdapter.notifyDataSetChanged();
    }

    private void getScenesRoomInfos() {
        RoomManager.getInstance().getScenesRoomInfos(getContext(), RoomManager.TYPE_LIVE_ROOM, new RoomManager.GetScenesRoomInfosCallback() {
            @Override
            public void onSuccess(List<RoomListAdapter.ScenesRoomInfo> scenesRoomInfos) {
                mRoomInfoList.clear();
                mRoomInfoList.addAll(scenesRoomInfos);
                mSwipeRefreshLayout.setRefreshing(false);
                refreshView();
            }

            @Override
            public void onFailed(int code, String msg) {
                Log.e(TAG, "onFailed: code -> " + code + ", msg -> " + msg);
                Toast.makeText(getActivity(), getString(R.string.online_fail) + msg, Toast.LENGTH_SHORT).show();
                mSwipeRefreshLayout.setRefreshing(false);
                refreshView();
            }
        });
    }

    private void refreshView() {
        mRoomListAdapter.notifyDataSetChanged();
    }

    private void createRoom() {
        LiveRoomAnchorActivity.start(getContext(), "");
    }

    private void enterRoom(RoomListAdapter.ScenesRoomInfo info) {
        Intent intent = new Intent(getActivity(), LiveRoomAudienceActivity.class);
        intent.putExtra(RoomManager.ROOM_TITLE, info.roomName);
        intent.putExtra(RoomManager.GROUP_ID, Integer.valueOf(info.roomId));
        intent.putExtra(RoomManager.USE_CDN_PLAY, false);
        intent.putExtra(RoomManager.ANCHOR_ID, info.anchorId);
        intent.putExtra(RoomManager.PUSHER_NAME, info.anchorName);
        intent.putExtra(RoomManager.COVER_PIC, info.coverUrl);
        intent.putExtra(RoomManager.PUSHER_AVATAR, info.coverUrl);
        startActivity(intent);
    }
}
