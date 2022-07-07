import logger from './logger'; // -----------------检测类型工具函数-----------------

/**
 * 检测input类型是否为Map
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->map / false->not a map
 */

export const isMap = function (input) {
  return getType(input) === 'map';
};
/**
 * 检测input类型是否为Set
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->set / false->not a set
 */

export const isSet = function (input) {
  return getType(input) === 'set';
};
/**
 * 检测input类型是否为File
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->file / false->not a file
 */

export const isFile = function (input) {
  return getType(input) === 'file';
};
/**
 * 检测input类型是否为number
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->number / false->not a number
 */

export const isNumber = function (input) {
  return input !== null && (typeof input === 'number' && !isNaN(input - 0) || typeof input === 'object' && input.constructor === Number);
};
/**
 * 检测input类型是否为string
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->string / false->not a string
 */

export const isString = function (input) {
  return typeof input === 'string';
};
export const isObject = function (input) {
  // null is object, hence the extra check
  return input !== null && typeof input === 'object';
};
/**
 * Checks to see if a value is an object and only an object
 * plain object: 没有标准定义，一般认为通过 {} 或者 new Object() 或者 Object.create(null) 方式创建的对象是纯粹对象
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->an object and only an object
 */

export const isPlainObject = function (input) {
  // 注意不能使用以下方式判断，因为IE9/IE10下，对象的__proto__是undefined
  // return isObject(input) && input.__proto__ === Object.prototype;
  if (typeof input !== 'object' || input === null) {
    return false;
  }

  const proto = Object.getPrototypeOf(input);

  if (proto === null) {
    // edge case Object.create(null)
    return true;
  }

  let baseProto = proto;

  while (Object.getPrototypeOf(baseProto) !== null) {
    baseProto = Object.getPrototypeOf(baseProto);
  } // 2. 原型链第一个和最后一个比较


  return proto === baseProto;
};
/**
 * 检测input类型是否为数组
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->array / false->not an array
 */

export const isArray = function (input) {
  if (typeof Array.isArray === 'function') {
    return Array.isArray(input);
  }

  return getType(input) === 'array';
};
/**
 * Checks to see if a value is undefined
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input value is undefined
 */

export const isUndefined = function (input) {
  return typeof input === 'undefined';
};
const isNativeClassRegex = /^class\s/;
/**
 * Is ES6+ class
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input is ES6+ class
 */

export const isNativeClass = function (input) {
  return typeof input === 'function' && isNativeClassRegex.test(input.toString());
};
/**
 * 检测input类型是否为数组或者object
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input is an array or an object
 */

export const isArrayOrObject = function (input) {
  return isArray(input) || isObject(input);
};
/**
 * 检测input类型是否为function
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input is a function
 */

export const isFunction = function (input) {
  return typeof input === 'function';
};
export const isBoolean = function (input) {
  return typeof input === 'boolean';
};
/**
 * 检测input是否为Error的实例
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input is an instance of Error
 */

export const isInstanceOfError = function (input) {
  return input instanceof Error;
};
/**
 * Get the object type string
 * @param {*} input 任意类型的输入
 * @returns {String} the object type string
 */

export const getType = function (input) {
  return Object.prototype.toString.call(input).match(/^\[object (.*)\]$/)[1].toLowerCase();
};
/**
 * ### 用于 request 参数 key 名称的合法性验证。
 * > 不合法的 key 有:
 *  - 非 string 类型的 key ；
 *  - 非字母和数字开头的 key ；
 * @param {string} key - 参数 key
 * @returns {boolean}
 *  - true : 合法；
 *  - false: 非法；
 */

export const isValidRequestKey = function (key) {
  // 非 string 类型的 key
  if (typeof key !== 'string') {
    return false;
  }

  const firstCharactor = key[0]; // 非字母和数字开头的 key

  if (/[^a-zA-Z0-9]/.test(firstCharactor)) {
    return false;
  }

  return true;
}; // -----------------获取时间工具函数，计算耗时用-----------------

let baseTime = 0;

if (!Date.now) {
  Date.now = function now() {
    return new Date().getTime();
  };
}

export const TimeUtil = {
  now() {
    if (baseTime === 0) {
      baseTime = Date.now() - 1;
    }

    const diff = Date.now() - baseTime;

    if (diff > 0xffffffff) {
      baseTime += 0xffffffff;
      return Date.now() - baseTime;
    }

    return diff;
  },

  utc() {
    return Math.round(Date.now() / 1000);
  }

}; // -----------------深度合并工具函数-----------------

/**
 * 深度 merge 两个对象。merge source to target.
 * @param {Object|Object[]} target 目标对象
 * @param {Object|Object[]} source 来源对象
 * @param {String[]} [keysIgnore] 要忽略的 keys。命中的 key 会在merge时被忽略
 * @param {*[]} [valuesIgnore] 要忽略的 values。命中的 value 会在merge时被忽略
 * @returns {Number} merge的次数（只有key相同value不同的时候才会merge），如果target和source既不是数组也不是object，则返回0
 */

export const deepMerge = function (target, source, keysIgnore, valuesIgnore) {
  // 1. 非 Array 或 Object 类型则直接 return
  if (!(isArrayOrObject(target) && isArrayOrObject(source))) {
    return 0;
  }

  let mergedCount = 0;
  const keys = Object.keys(source);
  let tmpKey;

  for (let i = 0, len = keys.length; i < len; i++) {
    tmpKey = keys[i];

    if (isUndefined(source[tmpKey]) || keysIgnore && keysIgnore.includes(tmpKey)) {
      continue;
    }

    if (isArrayOrObject(target[tmpKey]) && isArrayOrObject(source[tmpKey])) {
      // 递归merge
      mergedCount += deepMerge(target[tmpKey], source[tmpKey], keysIgnore, valuesIgnore);
    } else {
      if (valuesIgnore && valuesIgnore.includes(source[tmpKey])) {
        continue;
      }

      if (target[tmpKey] !== source[tmpKey]) {
        target[tmpKey] = source[tmpKey];
        mergedCount += 1;
      }
    }
  }

  return mergedCount;
}; // 简单的深拷贝实现

export const deepCopy = function (input) {
  const keys = Object.keys(input);
  const ret = {};
  let key;

  for (let i = 0, {
    length
  } = keys; i < length; i++) {
    key = keys[i];

    if (isArrayOrObject(input[key])) {
      ret[key] = deepCopy(input[key]);
    } else {
      ret[key] = input[key];
    }
  }

  return ret;
}; // -----------------其它-----------------

/**
 * 序列化Error实例，只序列化Error实例的message和code属性（如果有的话）
 * @param {Error} error Error实例
 * @returns {String} 序列化后的内容
 */

export const stringifyError = function (error) {
  return JSON.stringify(error, ['message', 'code']);
};
/**
 * 返回一个 ISO（ISO 8601 Extended Format）格式的字符串，如"2019-11-15T18:45:06.000+0800"，用于记录sso上报时的时间
 * @returns {String}
 */

export const date2ISOString = function () {
  const date = new Date(); // YYYY-MM-DDTHH:mm:ss.sssZ。时区总是UTC（协调世界时），加一个后缀“Z”标识。

  const tempISOString = date.toISOString(); // 返回协调世界时（UTC）相对于当前时区的时间差值，单位为分钟。
  // 如果本地时区晚于协调世界时，则该差值为正值，如果早于协调世界时则为负值

  const timezoneOffset = date.getTimezoneOffset();
  const currentTimeZoneInHour = timezoneOffset / 60;
  let replaceString = '';

  if (currentTimeZoneInHour < 0) {
    // 东区
    if (currentTimeZoneInHour > -10) {
      replaceString = `+0${Math.abs(currentTimeZoneInHour * 100)}`;
    } else {
      replaceString = `+${Math.abs(currentTimeZoneInHour * 100)}`;
    }
  } else {
    // 西区
    if (currentTimeZoneInHour >= 10) {
      replaceString = `-${currentTimeZoneInHour * 100}`;
    } else {
      replaceString = `-0${currentTimeZoneInHour * 100}`;
    }
  } // 不需要 encodeURIComponent 把 + 转成 %2B，kibana能识别


  return tempISOString.replace('Z', replaceString);
};
/**
 * 把map的内容转成字符串，
 * @param {Map} input 字典
 * @returns {String} 字典的内容
 */

export const map2String = function (input) {
  if (!isMap(input)) {
    return 'not a map!!!';
  }

  let result = '';

  for (const [k, v] of input.entries()) {
    if (!isMap(v)) {
      result += `[k=${k} v=${v}] `;
    } else {
      return `[k=${k} -> ${map2String(v)}`;
    }
  }

  return result;
};
/**
 * 获取字符串占用的字节数
 * @param {String} string - 字符串
 * @returns {Number} 字符串的长度
 */

export const stringSize = function (string) {
  if (string.length === 0) {
    return 0;
  }

  let i = 0;
  let char = '';
  let len = 0;
  let sizeStep = 1;

  const charSet = function () {
    if (typeof document !== 'undefined' && typeof document.characterSet !== 'undefined') {
      return document.characterSet;
    }

    return 'UTF-8';
  }();

  while (typeof string[i] !== 'undefined') {
    char = string[i++];

    if (char.charCodeAt[i] <= 255) {
      sizeStep = 1;
    } else {
      sizeStep = charSet === 'UTF-8' >= 0 ? 3 : 2;
    }

    len += sizeStep;
  }

  return len;
};
/**
 *  用于生成随机整数
 * @param {Number} level - 整数的级别 例如： 99, 999 , 9999 等
 * @returns {Number} 随机数字
 */

export const randomInt = function (level) {
  const lv = level || 99999999;
  return Math.round(Math.random() * lv);
};
const CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const CHARS_LENGTH = CHARS.length;
/**
 * 获取[0,9],[a-z],[A,Z]拼成的随机字符串，长度32
 * @returns {String} 长度为32的随机字符串
 */

export const randomString = function () {
  let result = '';

  for (let i = 32; i > 0; --i) {
    result += CHARS[Math.floor(Math.random() * CHARS_LENGTH)];
  }

  return result;
}; // 判断传入的枚举值是否有效

export const isValidType = function (obj, type) {
  for (const k in obj) {
    if (obj[k] === type) {
      return true;
    }
  }

  return false;
};
const AIIList = {};
export const autoincrementIndex = function (key) {
  if (!key) {
    logger.error('autoincrementIndex(string: key) need key parameter');
    return false;
  }

  if (typeof AIIList[key] === 'undefined') {
    const dateInstance = new Date();
    let hoursString = `3${dateInstance.getHours()}`.slice(-2); // 小时数，用3占位，因为一天中不会出现30小时

    let minuteString = `0${dateInstance.getMinutes()}`.slice(-2);
    let secondString = `0${dateInstance.getSeconds()}`.slice(-2);
    AIIList[key] = parseInt([hoursString, minuteString, secondString, '0001'].join(''));
    hoursString = null;
    minuteString = null;
    secondString = null;
    logger.warn(`utils.autoincrementIndex() create new sequence : ${key} = ${AIIList[key]}`);
  }

  return AIIList[key]++;
}; // 统一用HTTPS

export const uniformHTTPS = function (url) {
  if (url.indexOf('http://') === -1 || url.indexOf('https://') === -1) {
    return `https://${url}`;
  }

  return url.replace(/https|http/, 'https');
};
/**
 * 使用转JSON方式克隆一个对象
 * @param {Object} data 要克隆的对象
 * @returns {Object} 克隆后的对象
 */

export const cloneBaseOnJSON = function (data) {
  try {
    return JSON.parse(JSON.stringify(data));
  } catch (error) {
    logger.error('cloneBaseOnJSON Error: ', error);
    return data;
  }
};
/**
 * 深度克隆
 * @param {Object} data 要克隆的对象
 * @returns {Object} 克隆后的对象
 */

export const clone = function (data) {
  if (Object.getOwnPropertyNames(data).length === 0) {
    return Object.create(null);
  }

  const newObject = Array.isArray(data) ? [] : Object.create(null);
  let type = ''; // eslint-disable-next-line guard-for-in

  for (const key in data) {
    // null 是一个特殊的对象，优先处理掉
    if (data[key] === null) {
      newObject[key] = null;
      continue;
    } // undefined 也优先处理掉


    if (data[key] === undefined) {
      newObject[key] = undefined;
      continue;
    }

    type = typeof data[key];

    if (['string', 'number', 'function', 'boolean'].indexOf(type) >= 0) {
      newObject[key] = data[key];
      continue;
    } // 只剩对象，递归


    newObject[key] = clone(data[key]);
  }

  return newObject;
};
/**
 * 更新自定义字段，如资料自定义字段，群组自定义字段，群成员自定义字段
 * @param {Object[]} target 待更新的自定义字段数组 [{key,value}, {key,value}, ...]
 * @param {Object[]} source 最新的自定义字段数组 [{key,value}, {key,value}, ...]
 */

export function updateCustomField(target, source) {
  if (!isArray(target) || !isArray(source)) {
    logger.warn('updateCustomField target 或 source 不是数组，忽略此次更新。');
    return;
  }

  source.forEach(({
    key,
    value
  }) => {
    const customField = target.find(item => item.key === key);

    if (customField) {
      customField.value = value;
    } else {
      target.push({
        key,
        value
      });
    }
  });
}
/**
 * 类似 lodash.mapKeys 功能，并具备过滤 keys 的功能
 * @export
 * @param {*} obj
 * @param {*} iteratee
 */

export function filterMapKeys(obj, iteratee) {
  const newObj = Object.create(null);
  Object.keys(obj).forEach(key => {
    const nextKey = iteratee(obj[key], key); // 回调返回 false 则过滤 key

    if (nextKey) {
      newObj[nextKey] = obj[key];
    }
  });
  return newObj;
} // -----------------类lodash.mapKeys函数-----------------

export function mapKeys(obj, iteratee) {
  const newObj = {};
  Object.keys(obj).forEach(key => {
    newObj[iteratee(obj[key], key)] = obj[key];
  });
  return newObj;
} // -----------------类lodash.mapValues函数-----------------

export function mapValues(obj, iteratee) {
  const newObj = {};
  Object.keys(obj).forEach(key => {
    newObj[key] = iteratee(obj[key], key);
  });
  return newObj;
}