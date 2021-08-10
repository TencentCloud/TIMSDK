import Foundation

//  Json工具类

public class JsonUtil {

    /**
     *  字典转模型
     */
    public static func toModel<T>(_ type: T.Type, value: Any?) -> T? where T: Decodable {
        guard let value = value else {
            return nil
        }
        return toModel(type, value: value)
    }

    /**
     *  字典转模型
     */
    public static func toModel<T>(_ type: T.Type, value: Any) -> T? where T: Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: value) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return try? decoder.decode(type, from: data)
    }

    /**
     * 将json字符串转换为字典
     */
    public static func getDictionaryFromJSONString(jsonString: String) -> [String: Any] {

        let jsonData: Data = jsonString.data(using: .utf8)!

        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return (dict as! NSDictionary) as! [String: Any]
        }
        return NSDictionary() as! [String: Any]
    }


    /**
     * JSON字符串转换成字典，兼容数组
     */
    public static func getDictionaryOrArrayFromObject(_ object: Any) -> Any {
		if object is Array<Any> {
			var ret: Array<Any> = []
			for i in object as! Array<Any> {
				let item = toJson(i)
				ret.append(getDictionaryFromJSONString(jsonString: item as! String))
			}
			return ret
		}
		
        if object is AnyObject {
            let json = toJson(object)
			let ret = getDictionaryFromJSONString(jsonString: json as! String);
			return ret
        }
		
		return object
    }

    /**
     * 将对象转换为JSON字符串(数组/对象)
     */
    public static func toJson(_ object: Any) -> Any {
        // 解析数组
        if let array = object as? [Any] {
            let isStringArray = object is [String];
            var result = "[";
            for item in array {
                let data = isStringArray ? "\"\(toJsonByObj(item))\"" : toJsonByObj(item);
                result += "\(data),";
            }
            // 删除末尾逗号
            if result.hasSuffix(",") {
                result = String(result.dropLast());
            }
            return result + "]";
        }

        // 解析单个对象
        return toJsonByObj(object);
    }

    /**
     * 将对象转换为JSON字符串(单个对象)
     */
    private static func toJsonByObj(_ object: Any) -> Any {

        if object is String {
            return "\(object)";
        }

        if object is Int32 || object is Int || object is UInt32 || object is UInt64 || object is Bool || object is Double || object is time_t || object is Date || object is Data || object is Dictionary<AnyHashable, Any> {
            return vHandler(object);
        }

        var result = "{";
        // 反射当前类及父类反射对象
        let morror = Mirror.init(reflecting: object)
        let superMorror = morror.superclassMirror
        // 键值对字典
        var dict: Dictionary<String?, Any> = [:];

        // 遍历父类和子类属性集合，添加到键值对字典
        if superMorror != nil {
            for (name, value) in (superMorror?.children)! {
                dict[name!] = value;
            }
        }

        for (name, value) in morror.children {
            dict[name!] = value;
        }

        // 组装json对象
        for (name, value) in dict {
            // 解码值，根据不同类型设置不同封装，nil不进行封装
            if let n = name {
                let v = unwrap(value);
                // 未解码成功的值，则是nil
                if !("\(type(of: v))".hasPrefix("Optional")) {
                    result += kv(n, v);
                    result += ",";
                }
            }
        }

        // 删除末尾逗号
        if result.hasSuffix(",") {
            result = String(result.dropLast());
        }

        return result + "}";
    }

    /**
     * 解码值，optional 将会被自动解码
     */
    private static func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return first.value
    }

    /**
     * 根据K和V拼装键值对
     */
    private static func kv(_ k: Any, _ v: Any) -> String {
        return "\"\(k)\":\(vHandler(v))";
    }

    /**
     *  值处理，根据不同类型的值，返回不同的结果
     */
    private static func vHandler(_ v: Any) -> Any {
        // 根据类型赋值不同的值
        // 如果是字符串，将会进行转移 " to \"
        // 如果是Data，将会解析为字符串并且进行转移
        if v is String {
            return "\"\(stringReplace(source: "\(v)"))\"";
        } else if v is Int32 || v is Int || v is UInt32 || v is UInt64 || v is Bool || v is Double || v is time_t {
            return v;
        } else if v is Date {
            return Int((v as! Date).timeIntervalSince1970);
        } else if v is Data {
            return "\"\(stringReplace(source: String(data: v as! Data, encoding: String.Encoding.utf8)!))\"";
        } else if v is Dictionary<AnyHashable, Any> {
            var result = "{";
            // 解析键值对
            for (key, value) in v as! Dictionary<AnyHashable, Any> {
                result += "\(kv(key, value)),";
            }
            // 删除末尾逗号
            if result.hasSuffix(",") {
                result = String(result.dropLast());
            }
            return result + "}";
        } else if v is NSObject {
            return toJson(v);
        } else {
            return "\"\(v)\"";
        }
    }

    /**
     *  字符串替换
     */
    private static func stringReplace(source: String) -> String {
        var result = source;

        // 内容替换
        result = result.replacingOccurrences(of: "\\", with: "\\\\");
        result = result.replacingOccurrences(of: "\"", with: "\\\"");
        result = result.replacingOccurrences(of: "/", with: "\\/");
        result = result.replacingOccurrences(of: "\\\\b", with: "\\b");
        result = result.replacingOccurrences(of: "\\\\f", with: "\\f");
        result = result.replacingOccurrences(of: "\n", with: "\\n");
        result = result.replacingOccurrences(of: "\r", with: "\\r");
        result = result.replacingOccurrences(of: "\t", with: "\\t");
        result = result.replacingOccurrences(of: "\0", with: "");

        return result;
    }
}
