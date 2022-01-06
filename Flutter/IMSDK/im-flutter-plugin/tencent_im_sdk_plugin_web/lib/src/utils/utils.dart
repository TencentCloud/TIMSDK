import 'dart:async';
import 'dart:js_util' as js;
import 'dart:js_util';
import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';

typedef Func1<A, R> = R Function(A a);

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('JSON.parse')
external Object parse(String obj);

// 这可比print好用多了
@JS('console.log')
external void log(Object obj);

@JS('File')
class JSFile {
  external JSFile(params1, params2, [params3]);
}

@JS('Object.keys')
external List<String> _getKeysOfObject(jsObject);

@JS('Array')
class ArrayJS {
  external void push(param);
}

@JS('typeof')
external String typeof(type);

@JS('Promise')
class PromiseJsImpl<T> extends ThenableJsImpl<T> {
  external PromiseJsImpl(Function resolver);
  external static PromiseJsImpl<List> all(List<PromiseJsImpl> values);
  external static PromiseJsImpl reject(error);
  external static PromiseJsImpl resolve(value);
}

@anonymous
@JS()
abstract class ThenableJsImpl<T> {
  external ThenableJsImpl then([Func1 onResolve, Func1 onReject]);
}

Future<T> handleThenable<T>(ThenableJsImpl<T> thenable) =>
    promiseToFuture(thenable);

class CommonUtils {
  static V2TimValueCallback<T> returnSuccess<T>(dynamic data, {desc}) {
    var returnMap = Map<String, dynamic>();
    returnMap['code'] = 0;
    returnMap['desc'] = desc ?? 'ok';
    returnMap['data'] = data;
    return V2TimValueCallback<T>.fromJson(returnMap);
  }

  static V2TimCallback returnSuccessWithDesc(String desc) {
    final value = {'code': 0, 'desc': desc};
    return V2TimCallback.fromJson(value);
  }

  static V2TimCallback returnSuccessForCb(data) {
    final value = {'code': 0, 'desc': "ok", 'data': data};
    return V2TimCallback.fromJson(value);
  }

  // static V2TimValueCallback<T> returnErrorForValueCb<T>(desc) {
  //   final value = {'code': 0, 'desc': desc};
  //   return V2TimValueCallback<T>.fromJson(value);
  // }

  static V2TimValueCallback<T> returnErrorForValueCb<T>(data) {
    final value = {'code': 0, 'desc': data};
    if (data is String) {
      value['code'] = 0;
      value['desc'] = data;
    } else {
      Map<dynamic, dynamic> dataMap = jsToMap(data);
      if (dataMap.containsKey("code")) {
        value['code'] = dataMap['code'] ?? 0;
        value['desc'] = dataMap["message"];
      } else {
        value['desc'] = data.toString();
      }
    }
    return V2TimValueCallback<T>.fromJson(value);
  }

  static V2TimCallback returnError(dynamic data) {
    Map<String, dynamic> returnMap = <String, dynamic>{};
    if (data is String) {
      returnMap['code'] = 0;
      returnMap['desc'] = data;
    } else {
      Map<dynamic, dynamic> dataMap = jsToMap(data);
      log(data);
      if (dataMap.containsKey("code")) {
        returnMap['code'] = dataMap['code'] ?? 0;
        returnMap['desc'] = dataMap["message"];
      } else {
        returnMap['code'] = 0;
        returnMap['desc'] = data.message;
      }
    }

    return V2TimCallback.fromJson(returnMap);
  }

  static void emitEvent(channle, String method, String type, data) {
    Map<String, dynamic> resMap = {};
    resMap["type"] = type;
    resMap["data"] = data;
    channle.invokeMethod(method, resMap);
  }
}

dynamic getArrayItem(array, index) {}

Map<String, dynamic> jsToMap(jsObject) {
  if (jsObject == null) return {};

  Map<String, dynamic> map = Map.fromIterable(_getKeysOfObject(jsObject),
      value: (key) => convertTo(key, jsObject));

  // _getKeysOfObject(jsObject).forEach((element) {
  //   print(map[element] is int);
  //   print(map[element]);
  // });
  return map;
}

convertTo(key, jsObject) {
  return js.getProperty(jsObject, key);
}

/*这个函数目的是防止我们JS库中的ENUM对象获取不到，而使用try catach做的返回默认值的处理,
（别的方法我能想到赋默认值的方法都试了！！我只能想到这个骚操作了），如果有更好的方式非常欢迎
讨论、修改
*/
checkEmptyEnum(getEnumFun, defaultValue) {
  try {
    return getEnumFun();
  } catch (err) {
    return defaultValue;
  }
}

Object mapToJSObj(Map<dynamic, dynamic> a) {
  var object = js.newObject();
  a.forEach((k, v) {
    var key = k;
    var value = v;
    js.setProperty(object, key, value);
  });
  return object;
}

Object mapToJSObjForDeep(Map<dynamic, dynamic> map) {
  Object object = js.newObject();
  map.forEach((k, v) {
    var key = k;
    var value = v;

    if (v is List) {
      value = (v.map((e) => mapToJSObjForDeep(e))).toList();
    }
    if (v is Map) {
      value = mapToJSObjForDeep(v);
    }
    js.setProperty(object, key, value);
  });

  return object;
}

createJSArray(List list) {
  var arr = ArrayJS();
  for (var i = 0; i < list.length; i++) {
    arr.push(list[i]);
  }

  log(arr);
  return arr;
}

class JSResult {
  late int code;
  late dynamic data;

  JSResult({required this.code, this.data});

  JSResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
  }
}

Future<JSResult> wrappedPromiseToFuture(Object jsPromise) async {
  final res = await js.promiseToFuture(jsPromise);
  return JSResult.fromJson(jsToMap(res));
}

// Both of these interfaces exist to call `Object.keys` from Dart.
//
// But you don't use them directly. Just see `jsToMap`.
// @JS('Promise')
// class PromiseJsImpl<T> extends ThenableJsImpl<T> {
//   external PromiseJsImpl(Function resolver);
//   external static PromiseJsImpl<List> all(List<PromiseJsImpl> values);
//   external static PromiseJsImpl reject(error);
//   external static PromiseJsImpl resolve(value);
// }

// @anonymous
// @JS()
// abstract class ThenableJsImpl<T> {
//   external ThenableJsImpl then([Func1 onResolve, Func1 onReject]);
// }

// Future<T> handleThenable<T>(ThenableJsImpl<T> thenable) =>
//     promiseToFuture(thenable);
