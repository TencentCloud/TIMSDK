package com.tencent.qcloud.tuikit.tuicallkit.view.component.inviteuser

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.trtc.tuikit.common.imageloader.ImageLoader

class SelectGroupMemberAdapter : RecyclerView.Adapter<SelectGroupMemberAdapter.GroupMemberViewHolder>() {
    private lateinit var context: Context
    private var groupMemberList: List<GroupMemberInfo> = ArrayList()

    fun setDataSource(userList: List<GroupMemberInfo>) {
        groupMemberList = userList
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): GroupMemberViewHolder {
        context = parent.context
        val view = LayoutInflater.from(context).inflate(R.layout.tuicallkit_list_item_group_user, parent, false)
        return GroupMemberViewHolder(view)
    }

    override fun onBindViewHolder(holder: GroupMemberViewHolder, position: Int) {
        val userInfo = groupMemberList[position]
        holder.itemView.setOnClickListener {
            holder.checkBox.isChecked = !holder.checkBox.isChecked
            userInfo.isSelected = holder.checkBox.isChecked
        }
        holder.layoutView(userInfo)
    }

    override fun getItemCount(): Int {
        return groupMemberList.size
    }

    inner class GroupMemberViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val imageAvatar: ImageView
        private val textName: TextView
        private val textHint: TextView
        val checkBox: CheckBox

        init {
            checkBox = itemView.findViewById(R.id.group_user_check_box)
            imageAvatar = itemView.findViewById(R.id.group_user_avatar)
            textName = itemView.findViewById(R.id.group_user_name)
            textHint = itemView.findViewById(R.id.group_user_hint)
        }

        fun layoutView(userInfo: GroupMemberInfo?) {
            if (userInfo == null || userInfo.userId.isNullOrEmpty()) {
                return
            }
            itemView.isEnabled = !userInfo.isSelected
            checkBox.isEnabled = !userInfo.isSelected
            checkBox.isChecked = userInfo.isSelected
            checkBox.isSelected = userInfo.isSelected
            textName.text = if (userInfo.userName.isNullOrEmpty()) userInfo.userId else userInfo.userName
            textHint.visibility = if (userInfo.userId == TUILogin.getLoginUser()) View.VISIBLE else View.GONE
            ImageLoader.load(context, imageAvatar, userInfo.avatar, R.drawable.tuicallkit_ic_avatar)
        }
    }
}