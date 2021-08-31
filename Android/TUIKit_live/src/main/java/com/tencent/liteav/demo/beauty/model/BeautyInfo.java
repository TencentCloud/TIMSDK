package com.tencent.liteav.demo.beauty.model;

import java.util.List;

/**
 * 美颜面板相关属性
 * 成员变量名和 assets/default_beauty_data.json 的 key 相对应，便于 json 解析
 */
public class BeautyInfo {

    private int beauty_tab_name_size;           // int, tab文字大小
    private int beauty_tab_name_width;          // int, tab 宽度
    private int beauty_tab_name_height;         // int, tab 高度

    private String beauty_bg;                   // color/drawable, beauty布局的背景色值
    private String beauty_tab_name_color_normal;// color, tab文字常规颜色
    private String beauty_tab_name_color_select;// color, tab文字选中颜色

    private List<TabInfo> beauty_tab_list;

    public String getBeautyBg() {
        return beauty_bg;
    }

    public void setBeautyBg(String beauty_bg) {
        this.beauty_bg = beauty_bg;
    }

    public int getBeautyTabNameWidth() {
        return beauty_tab_name_width;
    }

    public int getBeautyTabNameHeight() {
        return beauty_tab_name_height;
    }

    public String getBeautyTabNameColorNormal() {
        return beauty_tab_name_color_normal;
    }

    public String getBeautyTabNameColorSelect() {
        return beauty_tab_name_color_select;
    }

    public int getBeautyTabNameSize() {
        return beauty_tab_name_size;
    }

    public List<TabInfo> getBeautyTabList() {
        return beauty_tab_list;
    }

    @Override
    public String toString() {
        return "BeautyInfo{" +
                ", beauty_bg='" + beauty_bg + '\'' +
                ", beauty_tab_name_width=" + beauty_tab_name_width +
                ", beauty_tab_name_height=" + beauty_tab_name_height +
                ", beauty_tab_name_color_normal='" + beauty_tab_name_color_normal + '\'' +
                ", beauty_tab_name_color_select='" + beauty_tab_name_color_select + '\'' +
                ", beauty_tab_name_size=" + beauty_tab_name_size +
                ", beauty_tab_list=" + beauty_tab_list +
                '}';
    }
}
