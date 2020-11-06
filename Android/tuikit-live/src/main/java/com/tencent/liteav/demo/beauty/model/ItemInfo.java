package com.tencent.liteav.demo.beauty.model;

/**
 * 美颜面板 item 相关属性
 * 成员变量名和 assets/default_beauty_data.json 的 key 相对应，便于 json 解析
 */
public class ItemInfo {

    private long item_id;               // long, item id，item 唯一标识

    private int item_type;              // int, item 类型，item 的功能
    private int item_level;             // int, 特效级别，-1代表无特效级别，即不显示SeekBar

    private String item_name;           // string, item 名称
    private String item_material_url;   // string, 素材 url
    private String item_material_path;  // string, 素材本地路径
    private String item_icon_normal;    // drawable, item 常规 icon
    private String item_icon_select;    // drawable, item 选中 icon

    public long getItemId() {
        return item_id;
    }

    public int getItemType() {
        return item_type;
    }

    public String getItemName() {
        return item_name;
    }

    public String getItemIconNormal() {
        return item_icon_normal;
    }

    public String getItemIconSelect() {
        return item_icon_select;
    }

    public void setItemLevel(int item_level) {
        this.item_level = item_level;
    }

    public int getItemLevel() {
        return item_level;
    }

    public String getItemMaterialUrl() {
        return item_material_url;
    }

    public String getItemMaterialPath() {
        return item_material_path;
    }

    public void setItemMaterialPath(String item_material_path) {
        this.item_material_path = item_material_path;
    }

    public void setItemName(String itemName) {
        this.item_name = itemName;
    }

    @Override
    public String toString() {
        return "ItemInfo{" +
                "item_id=" + item_id +
                ", item_type=" + item_type +
                ", item_name='" + item_name + '\'' +
                ", item_material_url='" + item_material_url + '\'' +
                ", item_level=" + item_level +
                ", item_icon_normal='" + item_icon_normal + '\'' +
                ", item_icon_select='" + item_icon_select + '\'' +
                ", item_material_path='" + item_material_path + '\'' +
                '}';
    }
}
