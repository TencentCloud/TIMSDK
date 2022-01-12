import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageMessage extends StatefulWidget {
  final V2TimMessage message;
  final bool isSelect;
  const ImageMessage({required this.message, required this.isSelect, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageMessageState();
}

class ImageMessageState extends State<ImageMessage>
    with AutomaticKeepAliveClientMixin {
  bool imageIsRender = false;
  @override
  // 覆写`wantKeepAlive`返回`true`
  bool get wantKeepAlive => true;
  /*
  为了解决，重复渲染的跳闪问题
  当现有图片队列只有一个，且上一个图片队列不存在时才进行更新，因为此时是发送了新的图片
  */

  @override
  didUpdateWidget(oldWidget) {
    var oldImgListLength = oldWidget.message.imageElem?.imageList?.length ?? 0;
    var currImgListLength = widget.message.imageElem?.imageList?.length ?? 0;
    if (currImgListLength == 1 && oldImgListLength == 0) {
      setState(() {
        imageIsRender = true;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  getPlatformType() {
    return Platform.isAndroid ? 1 : 2;
  }

  getBigPic() {
    String url = '';
    for (var element in widget.message.imageElem!.imageList!) {
      try {
        url = element!.url!;
      } catch (err) {
        Utils.log("message img url is empty！");
        rethrow;
      }
    }
    return url;
  }

  Widget errorDisplay() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: 1,
        color: Colors.black12,
      )),
      height: 100,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
              size: 16,
            ),
            Text(
              "图片加载失败",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImage(image, {imageElem}) {
    Widget res = Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: image,
      ),
    );

    return res;
  }

  //保存网络图片到本地
  _savenNetworkImage(String imageUrl, {bool isAsset = true}) async {
    var status = await Permission.storage.status;
    var response;
    if (status.isDenied) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("提示"),
              content: const Text("您当前没有开启相册权限"),
              actions: <Widget>[
                TextButton(
                  child: const Text("好呀"),
                  onPressed: () => //打开ios的设置
                      openAppSettings(), //关闭对话框
                ),
                TextButton(
                  child: const Text("取消"),
                  onPressed: () {
                    // ... 执行删除操作
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });

      return;
    }

    // 本地资源的情况下
    if (isAsset) {
      File file = File(imageUrl);
      response = await file.readAsBytes();
    } else {
      var res = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      response = res.data;
    }

    var result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response));

    if (Platform.isIOS) {
      if (result['isSuccess']) {
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
      }
    } else {
      if (result != null) {
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
      }
    }
  }

  //动态申请权限
  Future<bool> requestPermission() async {
    // PermissionStatus photoStatus = await Permission.photos.status;
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[0] != PermissionStatus.granted) {
        Utils.toast('无法存储图片，请先授权！');
        return storageStatus.isDenied;
      }
    }
    return storageStatus.isGranted;
  }

  void openDialog(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PhotoView(
                    tightMode: true,
                    imageProvider: NetworkImage(
                      getBigPic(),
                    ),
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.message.msgID!),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.file_download),
                      label: const Text("保存"),
                      onPressed: () {
                        String? path = widget.message.imageElem?.path;
                        String? imageUrl = path == ""
                            // 第0项一般为原图
                            ? widget.message.imageElem?.imageList![0]?.url
                            : path;
                        bool isAsset = path != "" ? true : false;
                        if (imageUrl == null) {
                          return;
                        }
                        if (Platform.isIOS) {
                          _savenNetworkImage(imageUrl, isAsset: isAsset);
                          return;
                        }
                        requestPermission().then((bool res) {
                          if (res) {
                            _savenNetworkImage(imageUrl, isAsset: isAsset);
                          }
                        });
                      },
                    ),
                  )
                ],
              ));
        },
      );
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.message.isSelf!
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: widget.message.imageElem!.imageList!.map(
        (e) {
          if (e!.type != null) {
            if (e.type == getPlatformType()) {
              // 获取不同平台的图片
              if (e.url != null && !imageIsRender) {
                // 1.获取屏幕高度
                var screenWidth = MediaQuery.of(context).size.width;
                // 2. 根据屏幕宽度大概计算图片消息宽度，1.556为屏幕与元素测出的比例系数
                var elementWidth = screenWidth / 1.5;
                // 3. 算出图片的宽高比例
                var rate = e.width!.toDouble() / e.height!.toDouble();
                // 4、根据宽高比例,减去多选时的高度
                double height = (elementWidth / rate -
                    (widget.isSelect ? 10 : 0).toDouble());
                // 为什么做这个骚操作：避免EXpended组件变化导致的图片明显闪动，误差肯定是存在，只要闪动变化较小用户就很难看出来
                return getImage(
                    GestureDetector(
                      onTap: () {
                        openDialog(context);
                      },
                      child:
                          // Container(
                          // height: height + 10,
                          // decoration: BoxDecoration(
                          //   borderRadius:
                          //       const BorderRadius.all(Radius.circular(20)),
                          //   border: Border.all(
                          //     color: hexToColor("E5E5E5"),
                          //     width: 1,
                          //     style: BorderStyle.solid,
                          //   ),
                          // ),
                          FadeInImage.memoryNetwork(
                        height: height,
                        fadeInCurve: Curves.ease,
                        fit: BoxFit.contain,
                        image: e.url!,
                        placeholder: kTransparentImage,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            errorDisplay(),
                      ),
                    ),
                    imageElem: e);
              } else {
                // 有path
                if (widget.message.imageElem!.path!.isNotEmpty) {
                  return getImage(
                      GestureDetector(
                        onTap: () {
                          openDialog(context);
                        },
                        child: Image.file(
                          File(widget.message.imageElem!.path!),
                        ),
                      ),
                      imageElem: null);
                } else {
                  return errorDisplay();
                }
              }
            } else {
              return Container();
            }
          } else {
            setState(() {
              imageIsRender = true;
            });
            // 有path
            if (widget.message.imageElem!.path!.isNotEmpty) {
              return getImage(
                  Image.file(
                    File(widget.message.imageElem!.path!),
                  ),
                  imageElem: null);
            } else {
              return errorDisplay();
            }
          }
        },
      ).toList(),
    );
  }
}
