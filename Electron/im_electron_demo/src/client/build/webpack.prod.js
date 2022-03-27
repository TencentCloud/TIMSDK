const { merge } = require('webpack-merge');
const baseConfig = require('./webpack.base');
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");

module.exports = merge(baseConfig, {
    mode: 'production',
    cache: {
        type: 'filesystem',
        buildDependencies: {
          config: [__filename]
        }
    },
    // devtool: 'hidden-source-map',
    optimization: {
        minimize: true,
        minimizer: [
            new CssMinimizerPlugin(),
            new TerserPlugin()
        ]
    }
})