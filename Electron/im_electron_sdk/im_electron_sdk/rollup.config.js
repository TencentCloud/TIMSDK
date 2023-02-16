const path = require('path');
const typescript = require('rollup-plugin-typescript2')
const { nodeResolve } = require('@rollup/plugin-node-resolve');
const uglify = require('rollup-plugin-uglify').uglify;
const pkg = require('./package.json');
import commonjs from 'rollup-plugin-commonjs'
const extensions = ['.js', '.ts'];

const resolve = function (...args) {
  return path.resolve(__dirname, ...args);
};

function getEnvConfigData(format,isUglify){
  return [
    {
      input: resolve('./src/timMain.ts'),
      output: {
        format: format,
        file: resolve(pkg.main),
        name: 'rem',
      },
      plugins: [
        commonjs(),
        typescript(),
        isUglify ? uglify() : null,
        nodeResolve({
          extensions,
          modulesOnly: true,
        }),
        
      ]
    },
    {
      input: resolve('./src/timRender.ts'),
      output: {
        format: format,
        file: resolve(pkg.browser),
        name: 'rem',
        
      },
      plugins: [
        commonjs(),
        typescript(),
        isUglify ? uglify() : null,
        nodeResolve({
          extensions,
          modulesOnly: true,
        }),
      ],
    },
    {
      input: resolve('./src/tim.ts'),
      output: {
        format: format,
        file: resolve('./dist/tim.js'),
        name: 'rem',
        
      },
      plugins: [
        commonjs(),
        typescript(),
        isUglify ? uglify() : null,
        nodeResolve({
          extensions,
          modulesOnly: true,
        }),
      ]
    }
  ]
}

// 打包任务的个性化配置
const jobs = {
  esm: getEnvConfigData('esm'),
  umd: getEnvConfigData('umd'),
  min: getEnvConfigData('umd',true),
};

// 从环境变量获取打包特征
const mergeConfig = jobs[process.env.FORMAT || 'esm'];

export default mergeConfig