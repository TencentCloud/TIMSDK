package com.tencent.liteav.demo.beauty.model;

import java.util.List;

/**
 * 美颜面板 tab 相关属性
 * 成员变量名和 assets/default_beauty_data.json 的 key 相对应，便于 json 解析
 */
public class TabInfo {

    private long tab_id;                            // long, tab id，tab 唯一标识

    private int tab_type;                           // int, tab类型
    private int tab_item_name_size;                 // int, item文字大小
    private int tab_item_icon_width;                // int, item icon 宽度
    private int tab_item_icon_height;               // int, item icon 高度
    private int tab_item_level_hint_size;           // int, 进度条提示文字大小
    private int tab_item_level_value_size;          // int, 进度条值文字大小

    private String tab_name;                        // string, tab 名称
    private String tab_item_name_color_normal;      // string, item 文件常规颜色
    private String tab_item_name_color_select;      // string, item 文件选中颜色
    private String tab_item_level_hint_color;       // string, 进度条提示文字颜色
    private String tab_item_level_value_color;      // string, 进度条值文字颜色
    private String tab_item_level_progress_drawable;// string, 进度条背景颜色
    private String tab_item_level_progress_thumb;   // string, 进度条 bar 颜色

    private List<ItemInfo> tab_item_list;

    public long getTabId() {
        return tab_id;
    }

    public int getTabType() {
        return tab_type;
    }

    public String getTabName() {
        return tab_name;
    }

    public int getTabItemNameSize() {
        return tab_item_name_size;
    }

    public String getTabItemNameColorNormal() {
        return tab_item_name_color_normal;
    }

    public String getTabItemNameColorSelect() {
        return tab_item_name_color_select;
    }

    public int getTabItemIconWidth() {
        return tab_item_icon_width;
    }

    public int getTabItemIconHeight() {
        return tab_item_icon_height;
    }

    public String getTabItemLevelHintColor() {
        return tab_item_level_hint_color;
    }

    public int getTabItemLevelHintSize() {
        return tab_item_level_hint_size;
    }

    public String getTabItemLevelValueColor() {
        return tab_item_level_value_color;
    }

    public int getTabItemLevelValueSize() {
        return tab_item_level_value_size;
    }

    public String getTabItemLevelProgressDrawable() {
        return tab_item_level_progress_drawable;
    }

    public String getTabItemLevelProgressThumb() {
        return tab_item_level_progress_thumb;
    }

    public List<ItemInfo> getTabItemList() {
        return tab_item_list;
    }

    @Override
    public String toString() {
        return "TabInfo{" +
                "tab_id=" + tab_id +
                ", tab_name='" + tab_name + '\'' +
                ", tab_item_name_size=" + tab_item_name_size +
                ", tab_item_name_color_normal='" + tab_item_name_color_normal + '\'' +
                ", tab_item_name_color_select='" + tab_item_name_color_select + '\'' +
                ", tab_item_icon_width=" + tab_item_icon_width +
                ", tab_item_icon_height=" + tab_item_icon_height +
                ", tab_item_level_hint_color='" + tab_item_level_hint_color + '\'' +
                ", tab_item_level_hint_size=" + tab_item_level_hint_size +
                ", tab_item_level_value_color='" + tab_item_level_value_color + '\'' +
                ", tab_item_level_value_size=" + tab_item_level_value_size +
                ", tab_item_level_progress_drawable='" + tab_item_level_progress_drawable + '\'' +
                ", tab_item_level_progress_thumb='" + tab_item_level_progress_thumb + '\'' +
                ", tab_item_list=" + tab_item_list +
                '}';
    }
}
