#!/bin/bash
echo "开始编译腾讯云即时通信IM Unity SDK文档"

set -e

rm -rf Docfx/src/*


cp -rf ./Assets/TencentIMSDK/Callback/Callback.cs ./Docfx/src/
cp -rf ./Assets/TencentIMSDK/Types/Types.cs ./Docfx/src/
cp -rf ./Assets/TencentIMSDK/Enums/Enums.cs ./Docfx/src/
cp -rf ./Assets/TencentIMSDK/TencentIMSDK.cs ./Docfx/src/

echo "开始编译文档"


cd Docfx

rm -rf obj/*

/usr/local/bin/docfx 

cd ../

echo "编译完成"

rm -rf Docfx/src/*

# 把文档放在build下去一起发布
cp -rf Docfx/_site build

# 运行文档
/usr/local/bin/docfx Docfx/docfx.json --serve