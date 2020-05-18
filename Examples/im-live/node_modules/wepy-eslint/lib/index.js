'use strict';

exports.__esModule = true;

exports.default = function (esConfig, filepath) {
    if (!esConfig.formatter) {
        esConfig.formatter = formatter;
    }
    esConfig.output = esConfig.output === undefined ? true : esConfig.output;
    var engine = new _eslint2.default.CLIEngine(esConfig);
    var report = engine.executeOnFiles([filepath]);
    var formatter = engine.getFormatter();
    var rst = formatter(report.results);
    if (rst && esConfig.output) {
        console.log(rst);
    }
    return rst;
};

var _eslint = require('eslint');

var _eslint2 = _interopRequireDefault(_eslint);

var _eslintFriendlyFormatter = require('eslint-friendly-formatter');

var _eslintFriendlyFormatter2 = _interopRequireDefault(_eslintFriendlyFormatter);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;