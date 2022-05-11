const objectToString = Object.prototype.toString;
const toTypeString = (value: any) => objectToString.call(value);

export const { isArray } = Array;
export const isMap = (val: any) => toTypeString(val) === '[object Map]';
export const isSet = (val: any) => toTypeString(val) === '[object Set]';
export const isDate = (val: any) => val instanceof Date;
export const isFunction = (val: any) => typeof val === 'function';
export const isString = (val: any) => typeof val === 'string';
export const isSymbol = (val: any) => typeof val === 'symbol';
export const isObject = (val: null) => val !== null && typeof val === 'object';
export const isPromise = (val: any) => isObject(val) && isFunction(val.then) && isFunction(val.catch);
