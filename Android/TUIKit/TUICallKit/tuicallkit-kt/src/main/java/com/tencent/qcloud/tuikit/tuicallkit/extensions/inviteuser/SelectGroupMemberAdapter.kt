package com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser.SelectGroupMemberAdapter.GroupMemberViewHolder
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader.loadImage

class SelectGroupMemberAdapter : RecyclerView.Adapter<GroupMemberViewHolder>() {
    private var mContext: Context? = null
    private var mGroupMemberList: List<GroupMemberInfo> = ArrayList()
    fun setDataSource(userList: List<GroupMemberInfo>) {
        mGroupMemberList = userList
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): GroupMemberViewHolder {
        mContext = parent.context
        val view = LayoutInflater.from(mContext).inflate(R.layout.tuicallkit_list_item_group_user, parent, false)
        return GroupMemberViewHolder(view)
    }

    override fun onBindViewHolder(holder: GroupMemberViewHolder, position: Int) {
        val userInfo = mGroupMemberList[position]
        holder.itemView.setOnClickListener { v: View? ->
            holder.mCheckBox.isChecked = !holder.mCheckBox.isChecked
            userInfo.isSelected = holder.mCheckBox.isChecked
        }
        holder.layoutView(userInfo)
    }

    override fun getItemCount(): Int {
        return mGroupMemberList.size
    }

    inner class GroupMemberViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        public val mImageAvatar: ImageView
        public val mTextName: TextView
        public val mTextHint: TextView
        public val mCheckBox: CheckBox
        fun layoutView(userInfo: GroupMemberInfo?) {
            if (userInfo == null || TextUtils.isEmpty(userInfo.userId)) {
                return
            }
            itemView.isEnabled = !userInfo.isSelected
            mCheckBox.isEnabled = !userInfo.isSelected
            mCheckBox.isChecked = userInfo.isSelected
            mCheckBox.isSelected = userInfo.isSelected
            mTextName.text = if (TextUtils.isEmpty(userInfo.userName)) userInfo.userId else userInfo.userName
            mTextHint.visibility =
                if (userInfo.userId == TUILogin.getLoginUser()) View.VISIBLE else View.GONE
            loadImage(mContext, mImageAvatar, userInfo.avatar, R.drawable.tuicallkit_ic_avatar)
        }

        init {
            mCheckBox = itemView.findViewById(R.id.group_user_check_box)
            mImageAvatar = itemView.findViewById(R.id.group_user_avatar)
            mTextName = itemView.findViewById(R.id.group_user_name)
            mTextHint = itemView.findViewById(R.id.group_user_hint)
        }
    }
}