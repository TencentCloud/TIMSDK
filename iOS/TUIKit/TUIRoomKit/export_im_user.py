#!/usr/bin/env python3
# coding: utf-8
import urllib
import requests
import random
import json


def post_request(url, data=None, headers=None):
    try:
        response = requests.post(url, data=data, headers=headers)
        response.raise_for_status()
        return response.text
    except requests.exceptions.HTTPError as errh:
        print("HTTP Error:", errh)
    except requests.exceptions.ConnectionError as errc:
        print("Error Connecting:", errc)
    except requests.exceptions.Timeout as errt:
        print("Timeout Error:", errt)
    except requests.exceptions.RequestException as err:
        print("Something went wrong", err)


url = 'https://console.tim.qq.com/'
sdk_app_id = '1400704311'
# 下面两个参数找aby要，切记不可随意扩散
identifier = ''
usersig = ''

random = f"{random.randint(0, 4294967295)}"
contenttype = 'json'

# action define
account_check = 'v4/im_open_login_svc/account_check'
multiaccount_import = 'v4/im_open_login_svc/multiaccount_import'
portrait_set = 'v4/profile/portrait_set'
friend_add = 'v4/sns/friend_add'

# common parameters
parameters = {
    'sdkappid': sdk_app_id,
    'identifier': identifier,
    'usersig': usersig,
    'random': random,
    'contenttype': contenttype,
}
encoded_params = urllib.parse.urlencode(parameters)

body = {
    "CheckItem":
    [
        {
            "UserID": "abyyxwang"
        },
        {
            "UserID": "UserID_2"
        }
    ]
}


def check_user():
    request_url = f"{url}{account_check}?{encoded_params}"
    print("\n")
    print(post_request(request_url, data=json.dumps(body)))


def import_user(user_data):
    request_url = f"{url}{multiaccount_import}?{encoded_params}"
    print("\n")
    print(post_request(request_url, data=json.dumps(user_data)))


def user_profile_set(user_profile_data):
    request_url = f"{url}{portrait_set}?{encoded_params}"
    print("\n")
    print(post_request(request_url, data=json.dumps(user_profile_data)))


def user_add_friend(body):
    request_url = f"{url}{friend_add}?{encoded_params}"
    print("\n")
    print(post_request(request_url, data=json.dumps(body)))


# # 打开文件并读取内容
with open('output.json', 'r', encoding='utf-8') as file:
    data = file.read()
# 将读取的内容解析为 JSON 格式
json_data = json.loads(data)

# 1、导入用户
# # 打印解析后的 JSON 数据
# # print(json_data)
# print(import_user(json_data))

# 2、设置用户资料为随意添加好友
# for user in json_data['AccountList']:
#     user_profile_data = {
#         "From_Account": user['UserID'],
#         "ProfileItem": [
#             {
#                 "Tag": "Tag_Profile_IM_AllowType",
#                 "Value": "AllowType_Type_AllowAny"
#             }
#         ]
#     }
#     user_profile_set(user_profile_data)

# 3、给json列表里的用户互相添加好友
# for user in json_data['AccountList']:
#     array = []
#     for user_2 in json_data['AccountList']:
#         if user['UserID'] != user_2['UserID']:
#             array.append({
#                 "To_Account": user_2['UserID'],
#                 "AddSource": "AddSource_Type_Admin"
#             })

#     body = {
#         "From_Account": user['UserID'],
#         "AddFriendItem": array
#     }
#     user_add_friend(body)
