package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config;

import java.util.ArrayList;
import java.util.List;

public class TUICustomerServiceConfig {
    private static TUICustomerServiceConfig instance;

    public static TUICustomerServiceConfig getInstance() {
        if (instance == null) {
            instance = new TUICustomerServiceConfig();
        }

        return instance;
    }

    private TUICustomerServiceProductInfo productInfo;
    private List<TUIInputViewFloatLayerData> inputViewFloatLayerDataList = new ArrayList<>();

    public List<TUIInputViewFloatLayerData> getInputViewFloatLayerDataList() {
        return inputViewFloatLayerDataList;
    }

    public void setInputViewFloatLayerDataList(List<TUIInputViewFloatLayerData> inputViewFloatLayerDataList) {
        this.inputViewFloatLayerDataList = inputViewFloatLayerDataList;
    }

    public void setProductInfo(TUICustomerServiceProductInfo productInfo) {
        this.productInfo = productInfo;
    }

    public TUICustomerServiceProductInfo getProductInfo() {
        if (this.productInfo != null) {
            return this.productInfo;
        } else {
            TUICustomerServiceProductInfo defaultProductInfo = new TUICustomerServiceProductInfo();
            defaultProductInfo.setName("手工编织皮革提包2023新品女士迷你简约大方高端有档次");
            defaultProductInfo.setDescription("¥788");
            defaultProductInfo.setPictureUrl("https://qcloudimg.tencent-cloud.cn/raw/a811f634eab5023f973c9b224bc07a51.png");
            defaultProductInfo.setJumpUrl("https://cloud.tencent.com/document/product/269");
            return defaultProductInfo;
        }
    }
}
