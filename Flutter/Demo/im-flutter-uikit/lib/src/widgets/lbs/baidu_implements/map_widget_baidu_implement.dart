// ignore_for_file: overridden_fields, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_class.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_widget.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import '../../../../i18n/i18n_utils.dart';

class BaiduMap extends TIMMapWidget {
  @override
  final Function? onMapLoadDone;
  @override
  final Function(
          TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason)?
      onMapMoveEnd;

  const BaiduMap({Key? key, this.onMapLoadDone, this.onMapMoveEnd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BaiduMapState();
}

class BaiduMapState extends TIMMapState<BaiduMap> {
  late BMFMapController timMapController;
  Widget mapWidget = Container();

  /// 创建完成回调
  void onMapCreated(BMFMapController controller) {
    timMapController = controller;

    /// 地图加载回调
    timMapController.setMapDidLoadCallback(callback: () {
      print(imt('mapDidLoad-地图加载完成'));
    });

    /// 设置移动结束回调
    timMapController.setMapRegionDidChangeWithReasonCallback(
      callback: (status, reason) => onMapMoveEnd(
          status.targetGeoPt != null
              ? TIMCoordinate.fromMap(status.targetGeoPt!.toMap())
              : null,
          TIMRegionChangeReason.values[reason.index]),
    );

    if (widget.onMapLoadDone != null) {
      widget.onMapLoadDone!();
    }
  }

  /// 地图移动结束
  @override
  void onMapMoveEnd(
      TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason) {
    if (widget.onMapMoveEnd != null) {
      widget.onMapMoveEnd!(targetGeoPt, regionChangeReason);
    }
  }

  /// 移动地图视角
  @override
  void moveMapCenter(TIMCoordinate pt) {
    timMapController.setCenterCoordinate(
        BMFCoordinate.fromMap(pt.toMap()), true,
        animateDurationMs: 1000);
  }

  @override
  void forbiddenMapFromInteract() {
    timMapController.updateMapOptions(BMFMapOptions(
      scrollEnabled: false,
      zoomEnabled: false,
      overlookEnabled: false,
      rotateEnabled: false,
      gesturesEnabled: false,
      showZoomControl: false,
      showMapScaleBar: false,
      changeCenterWithDoubleTouchPointEnabled: false,
    ));
  }

  @override
  void addMarkOnMap(TIMCoordinate pt, String title) {
    BMFMarker marker = BMFMarker.icon(
        position: BMFCoordinate.fromMap(pt.toMap()),
        title: title,
        identifier: 'flutter_marker',
        icon: 'assets/pin_red.png');

    timMapController.addMarker(marker);
  }

  /// 设置地图参数
  BMFMapOptions initMapOptions() {
    BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(39.917215, 116.380341),
      zoomLevel: 18,
    );
    return mapOptions;
  }

  @override
  Widget build(BuildContext context) {
    return BMFMapWidget(
      onBMFMapCreated: onMapCreated,
      mapOptions: initMapOptions(),
    );
  }
}
