import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_service.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import '../../../../i18n/i18n_utils.dart';
import 'dart:io' show Platform;
import '../../../config.dart';


class BaiduMapService extends TIMMapService{

  String appKey = IMDemoConfig.baiduMapIOSAppKey;

  /// 使用百度地图提供的定位能力，需要先安装flutter_bmflocation包。
  /// 安装好包后，去除这些代码的注释，根据百度地图官方的flutter即可定位文档，配置好环境，即可使用。
  /// 需要解除注释的方法：moveToCurrentLocationActionByMapLocation/ initAndroidOptions/ initIOSOptions/ initBaiduLocationPermission
  @override
  void moveToCurrentLocationActionWithSearchPOIByMapSDK({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
    void Function(TIMReverseGeoCodeSearchResult, bool)?
    onGetReverseGeoCodeSearchResult,
  }) async {
    // await initBaiduLocationPermission();
    // Map iosMap = initIOSOptions().getMap();
    // Map androidMap = initAndroidOptions().getMap();
    // final LocationFlutterPlugin _myLocPlugin = LocationFlutterPlugin();
    //
    // //根据定位数据挪地图及加载周边POI列表
    // void dealWithLocationResult(BaiduLocation result) {
    //   if (result.latitude != null && result.longitude != null) {
    //     TIMCoordinate coordinate =
    //     TIMCoordinate(result.latitude!, result.longitude!);
    //     moveMapCenter(coordinate);
    //     if(onGetReverseGeoCodeSearchResult != null){
    //       searchPOIByCoordinate(
    //           coordinate: coordinate,
    //           onGetReverseGeoCodeSearchResult: onGetReverseGeoCodeSearchResult);
    //     }
    //   } else {
    //     Utils.toast(imt("获取当前位置失败"));
    //   }
    // }
    //
    // // 设置获取到定位后的回调
    // if (Platform.isIOS) {
    //   _myLocPlugin.singleLocationCallback(callback: (BaiduLocation result) {
    //     dealWithLocationResult(result);
    //   });
    // } else if (Platform.isAndroid) {
    //   _myLocPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
    //     dealWithLocationResult(result);
    //     _myLocPlugin.stopLocation();
    //   });
    // }
    //
    // // 启动定位
    // await _myLocPlugin.prepareLoc(androidMap, iosMap);
    // if (Platform.isIOS) {
    //   _myLocPlugin
    //       .singleLocation({'isReGeocode': true, 'isNetworkState': true});
    // } else if (Platform.isAndroid) {
    //   _myLocPlugin.startLocation();
    // }
  }

  // static BaiduLocationAndroidOption initAndroidOptions() {
  //   BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
  //       coorType: 'bd09ll',
  //       locationMode: BMFLocationMode.hightAccuracy,
  //       isNeedAddress: true,
  //       isNeedAltitude: true,
  //       isNeedLocationPoiList: true,
  //       isNeedNewVersionRgc: true,
  //       isNeedLocationDescribe: true,
  //       openGps: true,
  //       locationPurpose: BMFLocationPurpose.sport,
  //       coordType: BMFLocationCoordType.bd09ll);
  //   return options;
  // }
  //
  // static BaiduLocationIOSOption initIOSOptions() {
  //   BaiduLocationIOSOption options = BaiduLocationIOSOption(
  //       coordType: BMFLocationCoordType.bd09ll,
  //       BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
  //       desiredAccuracy: BMFDesiredAccuracy.best);
  //   return options;
  // }
  //
  // initBaiduLocationPermission() async {
  //   LocationFlutterPlugin myLocPlugin = LocationFlutterPlugin();
  //   // 动态申请定位权限
  //   await LocationUtils.requestLocationPermission();
  //   // 设置是否隐私政策
  //   myLocPlugin.setAgreePrivacy(true);
  //   BMFMapSDK.setAgreePrivacy(true);
  //   if (Platform.isIOS) {
  //     // 设置ios端ak, android端ak可以直接在清单文件中配置
  //     myLocPlugin.authAK(appKey);
  //   }
  // }

  @override
  void poiCitySearch({
    required void Function(List<TIMPoiInfo>?, bool)
    onGetPoiCitySearchResult,
    required String keyword,
    required String city,
  }) async {
    BMFPoiCitySearchOption citySearchOption = BMFPoiCitySearchOption(
      city: city,
      keyword: keyword,
      scope: BMFPoiSearchScopeType.DETAIL_INFORMATION,
      isCityLimit: false,
    );

    // 检索对象
    BMFPoiCitySearch citySearch = BMFPoiCitySearch();

    // 检索回调
    citySearch.onGetPoiCitySearchResult(
        callback: (result, errorCode) {
          List<TIMPoiInfo> tmpPoiInfoList = [];
          result.poiInfoList?.forEach((v) {
            tmpPoiInfoList.add(TIMPoiInfo.fromMap(v.toMap()));
          });
          onGetPoiCitySearchResult(
              tmpPoiInfoList,
              errorCode != BMFSearchErrorCode.NO_ERROR
          );
        }
    );

    // 发起检索
    bool result = await citySearch.poiCitySearch(citySearchOption);

    if (result) {
      print(imt("发起检索成功"));
    } else {
      print(imt("发起检索失败"));
    }
  }

  @override
  void searchPOIByCoordinate(
      {required TIMCoordinate coordinate,
        required void Function(TIMReverseGeoCodeSearchResult, bool)
        onGetReverseGeoCodeSearchResult}) async {
    BMFReverseGeoCodeSearchOption option = BMFReverseGeoCodeSearchOption(
      location: BMFCoordinate.fromMap(coordinate.toMap()),
    );

    // 检索对象
    BMFReverseGeoCodeSearch reverseGeoCodeSearch = BMFReverseGeoCodeSearch();

    // 注册检索回调
    reverseGeoCodeSearch.onGetReverseGeoCodeSearchResult(
        callback: (result, errorCode){
          print("failed reason ${errorCode} ${errorCode.name} ${errorCode.toString()}");
          return onGetReverseGeoCodeSearchResult(
              TIMReverseGeoCodeSearchResult.fromMap(result.toMap()),
              errorCode != BMFSearchErrorCode.NO_ERROR
          );
        });

    // 发起检索
    bool result = await reverseGeoCodeSearch.reverseGeoCodeSearch(BMFReverseGeoCodeSearchOption.fromMap(option.toMap()));

    if (result) {
      print(imt("发起检索成功"));
    } else {
      print(imt("发起检索失败"));
    }
  }
  
}