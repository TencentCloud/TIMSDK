const fs = require("fs");
const path = require("path");
const readline = require("readline").createInterface({
  input: process.stdin,
  output: process.stdout,
});

let pathList = [];
const keyMap = new Map();
const keyMapRevert = new Map();
const dirPaths = ["lib/business_logic", "lib/data_services", "lib/ui"];

const singleREP = /'([^']*[^\x00-\xff]{0,200}[^']*)'/g;
const doubleREP = /"([^"]*[^\x00-\xff]{0,200}[^"]*)"/g;
const parameterREP = /(?<=\{{)[^}]*(?=\}})/g;
const dartParameterREP = /(?<=\${)[^}]*(?=\})/g;
const extractDartParaOutREP = /\${[^}]+}/g;

const readPath = (currentDirPath) => {
  fs.readdirSync(currentDirPath).forEach(function (name) {
    var filePath = path.join(currentDirPath, name);
    var stat = fs.statSync(filePath);
    if (stat.isFile()) {
      pathList.push(filePath);
    } else if (stat.isDirectory()) {
      readPath(filePath);
    }
  });
};

const detectChinese = (filePath, resolve, reject) => {
  fs.readFile(filePath, "utf8", (err, data) => {
    const temp = [];
    if (err) {
      console.error(err);
      reject(err);
    }
    const resultSingle = data.match(singleREP);
    if (Array.isArray(resultSingle) && resultSingle.length > 0) {
      temp.push(...resultSingle.map((item) => item.split("'")[1]));
    }
    const resultDouble = data.match(doubleREP);
    if (Array.isArray(resultDouble) && resultDouble.length > 0) {
      temp.push(...resultDouble.map((item) => item.split('"')[1]));
    }
    resolve(temp);
  });
};

const flatArray = (arr) => {
  if (Object.prototype.toString.call(arr) != "[object Array]") {
    return false;
  }
  let res = [];
  arr.map((item) => {
    if (item instanceof Array) {
      res.push(...item);
    } else {
      res.push(item);
    }
  });
  return res;
};

const dealWithResult = (originResult) => {
  const arr = flatArray(originResult).filter((item) => item);
  const noRepeatArr = Array.from(new Set(arr));
  const chineseArr = noRepeatArr.filter((item) => /[\u4e00-\u9fa5]/.test(item));
  const finalArr = chineseArr.filter((item) => !parameterREP.test(item));
  return finalArr;
};

const hashStr = (text) => {
  "use strict";

  let hash = 5381,
    index = text.length;

  while (index) {
    hash = (hash * 33) ^ text.charCodeAt(--index);
  }

  return hash >>> 0;
};

const hashKey = (value, context, onError) => {
  const key =
    "k_" + ("0000" + hashStr(value.replace(/\s+/g, "")).toString(36)).slice(-7);
  const existedValue = keyMap.get(context ? `${key}_${context}` : key);
  if (existedValue && existedValue !== value) {
    onError &&
      onError((filepath) => {
        console.error("");
        console.error(filepath);
        console.error("Same sentence in different forms found:");
        console.error(`    "${existedValue}"`);
        console.error(`    "${value}"`);
      });
  } else {
    keyMap.set(context ? `${key}_${context}` : key, value);
    keyMapRevert.set(value, context ? `${key}_${context}` : key);
  }
  return key;
};

const replace = () => {
  const getReplaceValue = (origin, quotation) => {
    const val = origin.split(quotation == 1 ? "'" : '"')[1];
    const ifReplace = val && keyMapRevert.get(val) && origin.indexOf("imt") === -1;
    if(origin.indexOf("${") === -1 && ifReplace){
      return ifReplace ? `ttBuild.imt("${val}")` : origin;
    }else if(ifReplace){
      const parameter = val.match(dartParameterREP)[0];
      const template = val.replace(extractDartParaOutREP, `{{${parameter}}}`);
      return parameter;
    }else{
      return origin;
    }
  };

  pathList.forEach((path) => {
    if (path.indexOf("i18n") > -1) {
      return;
    }
    let data;
    try {
      data = fs.readFileSync(path, "utf8");
    } catch (err) {
      console.error(err);
      return;
    }
    const newData = data
      .replace(doubleREP, (val) => getReplaceValue(val, 2))
      .replace(singleREP, (val) => getReplaceValue(val, 1));
    if (newData != data) {
      fs.writeFile(path, newData, (err) => {
        if (err) {
          console.error(err);
          return;
        }
      });
    }
  });
};

dirPaths.forEach((item) => readPath(item));
pathList = Array.from(new Set(pathList));

Promise.all(
  pathList.map((item) => {
    return new Promise((resolve, reject) => {
      return detectChinese(item, resolve, reject);
    });
  })
).then((res) => {
  const resultArray = dealWithResult(res);
  const chineseDict = {};
  resultArray.forEach((item) => (chineseDict[hashKey(item)] = item));

  try{
    const data = fs.readFileSync('lib/i18n/i18n_utils.dart', 'utf8').split('\n');
    const lineIndex = data.findIndex(item => item.indexOf("final zhJson =") > -1);
    data[lineIndex] = `  final zhJson = `;
    data[lineIndex + 1] = `    '''${JSON.stringify(chineseDict).replace(/\$/g, "\\$")}''';`;
    // data.splice(lineIndex + 1, 0, `    '''${JSON.stringify(chineseDict).replace(/\$/g, "\\$")}''';`);
    fs.writeFileSync('lib/i18n/i18n_utils.dart', data.join('\n'), 'utf8');
  }catch(err){
    console.log(`替换dart文件失败, ${err}`);
  }

  try{
    // 增补英文JSON
    const enDataFile = fs.readFileSync('lib/i18n/strings.i18n.json');
    const enData = JSON.parse(enDataFile);
    for(const item in chineseDict){
      if(!enData.hasOwnProperty(item)){
        enData[item] = chineseDict[item];
      }
    }
    fs.writeFile(
      "lib/i18n/strings.i18n.json",
      JSON.stringify(enData),
      (err) => {
        if (err) {
          console.error(err);
          return;
        }
      }
    );
  }catch(err){
    console.error(err);
  }

  try{
    // 增补繁体中文JSON
    const hantDataFile = fs.readFileSync('lib/i18n/strings_zh-Hant.i18n.json');
    const hantData = JSON.parse(hantDataFile);

    for(const item in chineseDict){
      if(!hantData.hasOwnProperty(item)){
        hantData[item] = chineseDict[item];
      }
    }
    fs.writeFile(
      "lib/i18n/strings_zh-Hant.i18n.json",
      JSON.stringify(hantData),
      (err) => {
        if (err) {
          console.error(err);
          return;
        }
      }
    );
  }catch(err){
    console.error(err);
  }

  try{
    // 增补简体中文JSON
    const zhDataFile = fs.readFileSync('lib/i18n/strings_zh-Hans.i18n.json');
    const zhData = JSON.parse(zhDataFile);
    for(const item in chineseDict){
      if(!zhData.hasOwnProperty(item)){
        zhData[item] = chineseDict[item];
      }
    }
    fs.writeFile(
      "lib/i18n/strings_zh-Hans.i18n.json",
      JSON.stringify(zhData),
      (err) => {
        if (err) {
          console.error(err);
          return;
        }
      }
    );
  }catch(err){
    console.error(err);
  }

  readline.close();
});