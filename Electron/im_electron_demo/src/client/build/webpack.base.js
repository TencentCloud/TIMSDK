const path = require('path');
const os = require('os');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const targetPlatform = (function () {
  let target = os.platform();
  for (let i = 0; i < process.argv.length; i++) {
    if (process.argv[i].includes('--target_platform=')) {
      target = process.argv[i].replace('--target_platform=', '');
      break;
    }
  }
  if (!['win32', 'darwin'].includes) target = os.platform();
  return target;
})();

module.exports = {
    entry: {
        main: path.resolve(__dirname, '../app.tsx'),
        call: path.resolve(__dirname, '../call.tsx')
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
        mainFields: ['main', 'module', 'browser'],
    },
    output: {
        clean: true,
        path: path.resolve(__dirname, '../../../bundle'),
        filename: 'js/[name].[contenthash:8].js',
    },
    target: 'electron-renderer',
    module: {
        rules: [
            {
                test: /\.(jsx|js|ts)$/,
                use: 'babel-loader',
                exclude: /node_modules/
            },
            {
                test: /\.(scss|css)$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    'css-loader',
                    'sass-loader',
                ],
            },
            {
                test: /\.(png|jpg|gif|jpeg|webp|svg|eot|ttf|woff|woff2)$/,
                type: 'asset',
            },
            {
                test: /\.tsx?$/,
                exclude: /(node_modules|\.webpack)/,
                use: {
                    loader: 'ts-loader',
                    options: {
                        transpileOnly: true
                    }
                }
            },
            {
                test: /\.node$/,
                loader: 'native-ext-loader',
                options: process.env?.NODE_ENV?.trim() === 'production' ? {
                    rewritePath: targetPlatform === 'win32' ? './resources' : '../Resources'
                } : undefined
            },
        ]
    },
    plugins: [
        new HtmlWebpackPlugin({
            filename: 'index.html',
            chunks: ['main'],
            template: path.resolve(__dirname, '../public/index.html'),
            inject: 'body',
            scriptLoading: 'blocking',
        }),
        new HtmlWebpackPlugin({
            filename: 'call.html',
            chunks: ['call'],
            template: path.resolve(__dirname, '../public/call.html'),
            inject: 'body',
            scriptLoading: 'blocking',
        }),
        new CleanWebpackPlugin(),
        new MiniCssExtractPlugin({
            filename: 'css/[name].css'
        }),
    ],
    node: {
        global: true,
        __dirname: true,
        __filename: true
    }
}