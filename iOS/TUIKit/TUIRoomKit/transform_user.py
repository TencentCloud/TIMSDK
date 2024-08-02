#!/usr/bin/env python3
# coding: utf-8
import json

input_str = "abyyxwang(王勇旭);adamsfliu(刘峰);chaooliang(梁超);chardzhang(张旭);chengyuzhao(赵澄宇);colleenyu(俞珂静);dennyfeng(冯立军);gorkinzheng(郑光键);harvychen(陈华);hiliu(刘珂);jackyixue(薛毅);janejntang(唐佳宁);jasperdai(戴一乐);jeremiawang(王宇轩);jiahaoliang(梁嘉豪);joewwwang(王嘉炜);krabyu(于西巍);lanqiiliu(刘齐);maggiehwang(王会琪);masonqiao(乔龙);mileszzhang(张晨曦);noahcheng(程广阔);petertwang(王朋涛);prenenerli(李磊);qiaoyang(杨桥);randewang(王宇);rexchang(常青);rulongzhang(张如龙);summerccao(曹鹏程);tatemin(闵禹强);v_qhhzhang(张齐会);wesleylei(雷日);xanderzhao(赵兵);xinlxinli(黎鑫);yuanfazheng(郑元发);zackshi(史晓龙);petertwang(王朋涛);aidenlli(李乐);dannyyun(贠丹妮);nuyoahma(马权)"

account_list = input_str.split(';')
account_data = []

for account in account_list:
    user_id, user_nick = account.split('(')
    account_data.append({
        "UserID": user_id,
        "Nick": user_nick.replace(")", ""),
        "FaceUrl": "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"
    })

output_json = {
    "AccountList": account_data
}

json_output = json.dumps(output_json, ensure_ascii=False)
print(json_output)
with open('output.json', 'w', encoding='utf-8') as file:
    json.dump(output_json, file, ensure_ascii=False, indent=4)
