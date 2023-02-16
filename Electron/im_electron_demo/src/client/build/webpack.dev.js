const { merge } = require('webpack-merge');
const baseConfig = require('./webpack.base');

module.exports = merge(baseConfig, {
    mode: 'development',
    devtool: 'eval-cheap-module-source-map',
    cache: {
        type: 'memory'
    },
    devServer: {
        port: 3000,
        hot: true,
        compress: true
    }
})