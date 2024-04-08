package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.ArrayList;
import java.util.List;

public class EvaluationHolder extends MessageBaseHolder {
    private final String TAG = EvaluationHolder.class.getSimpleName();
    private static final int UNSELECT = -1;
    private View rootView;
    private ViewGroup llStar, llNumber;
    private ImageView ivStar1, ivStar2, ivStar3, ivStar4, ivStar5;
    private TextView tvNumber1, tvNumber2, tvNumber3, tvNumber4, tvNumber5;
    private View vNumberFloatLayer1, vNumberFloatLayer2, vNumberFloatLayer3, vNumberFloatLayer4, vNumberFloatLayer5;
    private View vStarFloatLayer1, vStarFloatLayer2, vStarFloatLayer3, vStarFloatLayer4, vStarFloatLayer5;
    private List<ImageView> ivStarList = new ArrayList<>();
    private List<TextView> tvNumberList = new ArrayList<>();
    private List<View> numberFloatLayerList = new ArrayList<>();
    private List<View> starFloatLayerList = new ArrayList<>();
    private TextView tvInviteToEvaluation;
    private TextView tvEvaluationTail;
    private TextView tvSubmitEvaluation;
    private View vSubmitEvaluationFloatLayer;
    private int selectedIndex = -1;

    public EvaluationHolder(View itemView) {
        super(itemView);
        rootView = itemView;
        tvInviteToEvaluation = itemView.findViewById(R.id.tv_invite_to_evaluation);
        tvEvaluationTail = itemView.findViewById(R.id.tv_evaluation_tail);
        tvSubmitEvaluation = itemView.findViewById(R.id.tv_submit_evaluation);
        vSubmitEvaluationFloatLayer = itemView.findViewById(R.id.tv_submit_evaluation_float_layer);
        llStar = itemView.findViewById(R.id.ll_star);
        llNumber = itemView.findViewById(R.id.ll_number);

        ivStar1 = itemView.findViewById(R.id.iv_star1);
        ivStar2 = itemView.findViewById(R.id.iv_star2);
        ivStar3 = itemView.findViewById(R.id.iv_star3);
        ivStar4 = itemView.findViewById(R.id.iv_star4);
        ivStar5 = itemView.findViewById(R.id.iv_star5);
        ivStarList.add(ivStar1);
        ivStarList.add(ivStar2);
        ivStarList.add(ivStar3);
        ivStarList.add(ivStar4);
        ivStarList.add(ivStar5);

        tvNumber1 = itemView.findViewById(R.id.tv_number1);
        tvNumber2 = itemView.findViewById(R.id.tv_number2);
        tvNumber3 = itemView.findViewById(R.id.tv_number3);
        tvNumber4 = itemView.findViewById(R.id.tv_number4);
        tvNumber5 = itemView.findViewById(R.id.tv_number5);
        tvNumberList.add(tvNumber1);
        tvNumberList.add(tvNumber2);
        tvNumberList.add(tvNumber3);
        tvNumberList.add(tvNumber4);
        tvNumberList.add(tvNumber5);

        vNumberFloatLayer1 = itemView.findViewById(R.id.v_number1_float_layer);
        vNumberFloatLayer2 = itemView.findViewById(R.id.v_number2_float_layer);
        vNumberFloatLayer3 = itemView.findViewById(R.id.v_number3_float_layer);
        vNumberFloatLayer4 = itemView.findViewById(R.id.v_number4_float_layer);
        vNumberFloatLayer5 = itemView.findViewById(R.id.v_number5_float_layer);
        numberFloatLayerList.add(vNumberFloatLayer1);
        numberFloatLayerList.add(vNumberFloatLayer2);
        numberFloatLayerList.add(vNumberFloatLayer3);
        numberFloatLayerList.add(vNumberFloatLayer4);
        numberFloatLayerList.add(vNumberFloatLayer5);

        vStarFloatLayer1 = itemView.findViewById(R.id.v_star1_float_layer);
        vStarFloatLayer2 = itemView.findViewById(R.id.v_star2_float_layer);
        vStarFloatLayer3 = itemView.findViewById(R.id.v_star3_float_layer);
        vStarFloatLayer4 = itemView.findViewById(R.id.v_star4_float_layer);
        vStarFloatLayer5 = itemView.findViewById(R.id.v_star5_float_layer);
        starFloatLayerList.add(vStarFloatLayer1);
        starFloatLayerList.add(vStarFloatLayer2);
        starFloatLayerList.add(vStarFloatLayer3);
        starFloatLayerList.add(vStarFloatLayer4);
        starFloatLayerList.add(vStarFloatLayer5);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_evaluation;
    }

    @Override
    public void layoutViews(TUIMessageBean msg, int position) {
        EvaluationMessageBean evaluationMessageBean = (EvaluationMessageBean) msg;
        TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
        presenter.setMessage(evaluationMessageBean);
        EvaluationBean evaluationBean = evaluationMessageBean.getEvaluationBean();
        if (evaluationBean == null) {
            return;
        }

        EvaluationBean.Menu selectedMenu = evaluationBean.getSelectedMenu();
        int expiredTime = evaluationBean.getExpireTime();
        tvInviteToEvaluation.setText(evaluationBean.getHead());
        if (!TextUtils.isEmpty(evaluationBean.getTail())) {
            tvEvaluationTail.setText(evaluationBean.getTail());
        }

        if (selectedMenu == null) {
            
            tvEvaluationTail.setVisibility(View.GONE);
        } else {
            
            tvEvaluationTail.setVisibility(View.VISIBLE);
        }

        if (evaluationBean.getType() == EvaluationBean.EVALUATION_TYPE_STAR) {
            llStar.setVisibility(View.VISIBLE);
            llNumber.setVisibility(View.GONE);
        } else {
            llStar.setVisibility(View.GONE);
            llNumber.setVisibility(View.VISIBLE);
        }

        tvSubmitEvaluation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (selectedIndex == UNSELECT) {
                    return;
                }

                EvaluationBean.Menu submitMenu = evaluationBean.getMenuList().get(selectedIndex);
                presenter.sendEvaluationMessage(submitMenu, evaluationBean.getSessionID());
            }
        });

        if (selectedMenu == null && V2TIMManager.getInstance().getServerTime() < expiredTime && selectedIndex != UNSELECT) {
            
            vSubmitEvaluationFloatLayer.setVisibility(View.GONE);
            tvSubmitEvaluation.setClickable(true);
        } else {
            
            vSubmitEvaluationFloatLayer.setVisibility(View.VISIBLE);
            tvSubmitEvaluation.setClickable(false);
        }

        if (selectedMenu == null && V2TIMManager.getInstance().getServerTime() < expiredTime) {
            
            if (evaluationBean.getType() == EvaluationBean.EVALUATION_TYPE_STAR) {
                for (int i = 0; i < ivStarList.size(); i++) {
                    ivStarList.get(i).setBackgroundResource(R.drawable.evaluation_star_default);
                    starFloatLayerList.get(i).setVisibility(View.GONE);
                    int finalI = i;
                    ivStarList.get(i).setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            selectedIndex = finalI;
                            
                            vSubmitEvaluationFloatLayer.setVisibility(View.GONE);
                            tvSubmitEvaluation.setClickable(true);
                            for (int j = 0; j < ivStarList.size(); j++) {
                                if (j <= finalI) {
                                    ivStarList.get(j).setBackgroundResource(R.drawable.evaluation_star_active);
                                } else {
                                    ivStarList.get(j).setBackgroundResource(R.drawable.evaluation_star_default);
                                }
                            }
                        }
                    });
                }
            } else {
                for (int i = 0; i < tvNumberList.size(); i++) {
                    int finalI = i;
                    tvNumberList.get(i).setBackgroundResource(TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_bg));
                    tvNumberList.get(i).setTextColor(
                        rootView.getResources().getColor(TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_color)));
                    numberFloatLayerList.get(i).setVisibility(View.GONE);
                    tvNumberList.get(i).setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            selectedIndex = finalI;
                            
                            vSubmitEvaluationFloatLayer.setVisibility(View.GONE);
                            tvSubmitEvaluation.setClickable(true);
                            for (int j = 0; j < tvNumberList.size(); j++) {
                                if (j <= finalI) {
                                    tvNumberList.get(j).setBackgroundResource(R.drawable.evaluation_number_active_bg_light);
                                    tvNumberList.get(j).setTextColor(rootView.getResources().getColor(R.color.evaluation_number_active_color));
                                } else {
                                    tvNumberList.get(j).setBackgroundResource(
                                        TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_bg));
                                    tvNumberList.get(j).setTextColor(rootView.getResources().getColor(
                                        TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_color)));
                                }
                            }
                        }
                    });
                }
            }
        } else {
            
            List<EvaluationBean.Menu> menuList = evaluationBean.getMenuList();
            if (menuList == null || menuList.isEmpty() || menuList.size() > 5) {
                return;
            }

            for (int i = 0; i < menuList.size(); i++) {
                ivStarList.get(i).setOnClickListener(null);
                tvNumberList.get(i).setOnClickListener(null);
                int selectedMenuID = 0;
                if (selectedMenu != null) {
                    selectedMenuID = Integer.valueOf(selectedMenu.getId());
                }

                if (Integer.valueOf(menuList.get(i).getId()) <= selectedMenuID) {
                    if (evaluationBean.getType() == EvaluationBean.EVALUATION_TYPE_STAR) {
                        ivStarList.get(i).setBackgroundResource(R.drawable.evaluation_star_active);
                        starFloatLayerList.get(i).setVisibility(View.VISIBLE);
                    } else {
                        tvNumberList.get(i).setBackgroundResource(TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_active_bg));
                        tvNumberList.get(i).setTextColor(rootView.getResources().getColor(R.color.evaluation_number_active_color));
                        numberFloatLayerList.get(i).setVisibility(View.VISIBLE);
                    }
                } else {
                    if (evaluationBean.getType() == EvaluationBean.EVALUATION_TYPE_STAR) {
                        ivStarList.get(i).setBackgroundResource(R.drawable.evaluation_star_default);
                        starFloatLayerList.get(i).setVisibility(View.VISIBLE);
                    } else {
                        tvNumberList.get(i).setBackgroundResource(TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_bg));
                        tvNumberList.get(i).setTextColor(
                            rootView.getResources().getColor(TUIThemeManager.getAttrResId(rootView.getContext(), R.attr.evaluation_number_default_color)));
                        numberFloatLayerList.get(i).setVisibility(View.VISIBLE);
                    }
                }
            }
        }
    }
}
