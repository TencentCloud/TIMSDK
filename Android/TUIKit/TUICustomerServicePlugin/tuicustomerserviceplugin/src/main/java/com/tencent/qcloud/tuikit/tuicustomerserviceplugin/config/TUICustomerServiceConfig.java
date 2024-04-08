package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;

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
    private List<String> customerServiceAccounts = new ArrayList<>();

    public List<TUIInputViewFloatLayerData> getInputViewFloatLayerDataList() {
        return inputViewFloatLayerDataList;
    }

    private TUICustomerServiceConfig() {
        customerServiceAccounts.add(TUICustomerServiceConstants.DEFAULT_CUSTOMER_SERVICE_ACCOUNT);
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
            defaultProductInfo.setName("Handwoven leather handbag 2023 new women's mini simple and elegant high-end and classy");
            defaultProductInfo.setDescription("$788");
            defaultProductInfo.setPictureUrl("https://qcloudimg.tencent-cloud.cn/raw/a811f634eab5023f973c9b224bc07a51.png");
            defaultProductInfo.setJumpUrl("https://cloud.tencent.com/document/product/269");
            return defaultProductInfo;
        }
    }

    public List<String> getCustomerServiceAccounts() {
        return customerServiceAccounts;
    }

    public void setCustomerServiceAccounts(List<String> customerServiceAccounts) {
        if (customerServiceAccounts == null) {
            return;
        }

        this.customerServiceAccounts = customerServiceAccounts;
    }

    public boolean isOnlineShopping(String userID) {
        if (TextUtils.isEmpty(userID)) {
            return false;
        }

        return userID.contains("#online_shopping_mall");
    }
}
