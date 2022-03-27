const fs = require("fs");
const path = require("path");
const readline = require("readline").createInterface({
  input: process.stdin,
  output: process.stdout,
});
const singleREP = /'([^']*[^\x00-\xff]{0,200}[^']*)'/g;
const doubleREP = /"([^"]*[^\x00-\xff]{0,200}[^"]*)"/g;

const fileList = [];

const readPath = (currentDirPath, isMaybeFile) => {
  if (isMaybeFile) {
    let stat = fs.statSync(currentDirPath);
    if (stat.isFile()) {
      fileList.push(currentDirPath);
      return;
    }
  }

  fs.readdirSync(currentDirPath).forEach(function (name) {
    let filePath = path.join(currentDirPath, name);
    let stat = fs.statSync(filePath);
    if (stat.isFile()) {
      fileList.push(filePath);
    } else if (stat.isDirectory()) {
      readPath(filePath, false);
    }
  });
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

const hashKey = (value, onError) => {
  const key =
    "k_" + ("0000" + hashStr(value.replace(/\s+/g, "")).toString(36)).slice(-7);
  return key;
};

const getTranslationMap = (jsonStr) => {
  const translation = JSON.parse(jsonStr);
  return new Map(Object.entries(translation));
};

const replaceFile = (filePath, translationMap) => {
  const getReplaceValue = (origin, quotation) => {
    const val = origin.split(quotation == 1 ? "'" : '"')[1];
    const translatedValue = translationMap.get(hashKey(val));
    const ifReplace = (val && translatedValue);
    if (ifReplace) {
      return `"${translatedValue}"`;
    } else {
      return origin;
    }
  };

  try {
    data = fs.readFileSync(filePath, "utf8");
    const newData = data
      .replace(doubleREP, (val) => getReplaceValue(val, 2))
      .replace(singleREP, (val) => getReplaceValue(val, 1));
    if (newData != data) {
      fs.writeFile(filePath, newData, (err) => {
        if (err) {
          console.error(err);
          return;
        }
      });
    }
  } catch (err) {
    console.error(err);
    return;
  }
};

readline.question(`待替换文件/文件夹路径：`, (path) => {
  readPath(path, true);
  readline.question(`翻译JSON路径：`, (filePath) => {
    fs.readFile(filePath, "utf8", (err, data) => {
      if (err) {
        console.error(err);
      }
      const translationMap = getTranslationMap(data);
      fileList.forEach(item => replaceFile(item, translationMap));
      console.log("替换完成");
    });
  });
});
