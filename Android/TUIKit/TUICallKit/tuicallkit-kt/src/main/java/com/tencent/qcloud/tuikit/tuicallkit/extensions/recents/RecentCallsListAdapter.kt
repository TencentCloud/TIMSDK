package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces.ICallRecordItemListener

class RecentCallsListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    private lateinit var context: Context
    private val dataSource: MutableList<CallRecords> = ArrayList()
    private var itemListener: ICallRecordItemListener? = null
    private val selectedPositions = HashMap<String, Boolean>()
    var isMultiSelectMode = false
        private set

    fun setOnCallRecordItemListener(listener: ICallRecordItemListener?) {
        itemListener = listener
    }

    fun onDataSourceChanged(dataSource: List<CallRecords>?) {
        dataSource?.let {
            this.dataSource.clear()
            this.dataSource.addAll(it)
            notifyDataSetChanged()
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        context = parent.context.applicationContext
        val inflater = LayoutInflater.from(parent.context)
        return if (viewType == ITEM_TYPE_HEADER) {
            val view =
                inflater.inflate(R.layout.tuicallkit_item_head_view, parent, false)
            HeaderViewHolder(view)
        } else {
            val view = inflater.inflate(
                R.layout.tuicallkit_layout_call_list_item,
                parent,
                false
            )
            RecentCallsItemHolder(view)
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is RecentCallsItemHolder) {
            val viewHolder = holder
            viewHolder.layoutView.setOnClickListener { v: View? ->
                val curPos = viewHolder.bindingAdapterPosition
                itemListener?.onItemClick(viewHolder.itemView, getItemViewType(curPos), getItem(curPos))
            }
            viewHolder.imageDetails.setOnClickListener { view: View? ->
                itemListener?.onDetailViewClick(view, getItem(viewHolder.bindingAdapterPosition))
            }

            if (!viewHolder.layoutDelete.hasOnClickListeners()) {
                viewHolder.layoutDelete.setOnClickListener { view: View? ->
                    val curPos = viewHolder.bindingAdapterPosition
                    val record = getItem(curPos)
                    if (record == null || TextUtils.isEmpty(record.callId)) {
                        return@setOnClickListener
                    }
                    setItemChecked(record.callId, true)
                    itemListener?.onItemDeleteClick(view, getItemViewType(curPos), record)
                }
            }
            viewHolder.layoutViews(context, getItem(position), position)
            setCheckBoxStatus(viewHolder)
        }
    }

    override fun onViewRecycled(holder: RecyclerView.ViewHolder) {
        if (holder is RecentCallsItemHolder) {
            holder.callIconView.clear()
        }
    }

    private fun getItem(position: Int): CallRecords? {
        if (dataSource.isNullOrEmpty()) {
            return null
        }
        val dataPosition = position - HEADER_COUNT
        return if (dataPosition < dataSource.size && dataPosition >= 0) {
            dataSource[dataPosition]
        } else null
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getItemCount(): Int {
        return if (dataSource == null) {
            HEADER_COUNT
        } else dataSource.size + HEADER_COUNT
    }

    override fun getItemViewType(position: Int): Int {
        return if (position == 0) {
            ITEM_TYPE_HEADER
        } else ITEM_TYPE_NORMAL
    }

    private fun setCheckBoxStatus(holder: RecentCallsItemHolder?) {
        if (holder?.checkBoxSelectCall == null) {
            return
        }
        if (!isMultiSelectMode) {
            holder.checkBoxSelectCall.visibility = View.GONE
            holder.itemView.setOnClickListener(null)
        } else {
            holder.checkBoxSelectCall.visibility = View.VISIBLE
        }
    }

    private fun getIndexInAdapter(records: CallRecords): Int {
        var position = -1
        if (dataSource.size > 0) {
            val indexInData = dataSource.indexOf(records)
            if (indexInData != -1) {
                position = indexInData + HEADER_COUNT
            }
        }
        return position
    }

    fun setShowMultiSelectCheckBox(show: Boolean) {
        isMultiSelectMode = show
        for (records in dataSource) {
            if (records == null || TextUtils.isEmpty(records.callId)) {
                continue
            }
            setItemChecked(records.callId, show)
            val currentPosition = getIndexInAdapter(records)
            if (currentPosition != -1) {
                notifyItemChanged(currentPosition)
            }
        }
    }

    private fun setItemChecked(callId: String, isChecked: Boolean) {
        selectedPositions[callId] = isChecked
    }

    val selectedItem: List<CallRecords>?
        get() {
            if (selectedPositions.size == 0) {
                return null
            }
            val selectList: MutableList<CallRecords> = ArrayList()
            for (i in 0 until itemCount) {
                val records = getItem(i)
                if (records != null && isItemChecked(records.callId)) {
                    selectList.add(records)
                }
            }
            return selectList
        }

    private fun isItemChecked(id: String): Boolean {
        if (selectedPositions.size <= 0) {
            return false
        }
        return if (selectedPositions.containsKey(id)) {
            selectedPositions[id] ?: false
        } else {
            false
        }
    }

    internal class HeaderViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)
    companion object {
        private const val ITEM_TYPE_HEADER = 101
        private const val ITEM_TYPE_NORMAL = -98
        private const val HEADER_COUNT = 1
    }
}