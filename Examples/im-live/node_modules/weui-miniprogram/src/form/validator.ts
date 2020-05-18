
import {sprintf} from '../utils/string'

const defaultMessage = {
    required: '%s必填',
    minlength: '长度最少为%s',
    maxlength: '长度最大为%s',
    rangelength: '长度在%s和%s之间',
    bytelength: '最多只能输入%s个字',
    min: '值最小为%s',
    max: '值最大为%s',
    range: '值的范围为%s和%s之间',
    mobile: '请输入正确的手机号',
    email: '请输入正确的电子邮件',
    url: '请输入正确的URL地址',
    equalTo: '值和字段%s不相等',
}
export default {
    required: (r, val, param, models) => {
        if (r.required === false) return
        if (!val) return sprintf(r.message || defaultMessage.required, r.name)
    },
    minlength: (r, val) => {
        const minlen = r.minlength
        val = val || ''
        if (val.length < minlen) return sprintf(r.message || defaultMessage.minlength, minlen)
    },
    maxlength: (r, val) => {
        const maxlen = r.maxlength
        val = val || ''
        if (val.length > maxlen) return sprintf(r.message || defaultMessage.maxlength, maxlen)
    },
    rangelength: (r, val) => {
        const range = r.range
        val = val || ''
        if (val.length > range[1] || val.length < range[0]) return sprintf(r.message || defaultMessage.rangelength, range[0], range[1])
    },
    min: (r, val) => {
        const min = r.min
        if (val < min) return sprintf(r.message || defaultMessage.min, min)
    },
    max: (r, val) => {
        const max = r.max
        if (val > max) return sprintf(r.message || defaultMessage.max, max)
    },
    range: (r, val) => {
        const range = r.range
        if (val < range[0] || val > range[1]) return sprintf(r.message || defaultMessage.range, range[0], range[1])
    },
    mobile: (r, val) => {
        if (r.mobile === false) return
        val = val || ''
        if (val.length !== 11) return sprintf(r.message || defaultMessage.mobile)
    },
    email: function( r, value ) {
        if (r.email === false) return
        // contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
        if (!/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value)) {
            return sprintf(r.message || defaultMessage.email)
        }
    },

    // http://docs.jquery.com/Plugins/Validation/Methods/url
    url: function( r, value ) {
        if (r.url === false) return
        // contributed by Scott Gonzalez: http://projects.scottsplayground.com/iri/
        if (!/^(https?|s?ftp|weixin):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value)) {
            return r.message || defaultMessage.url
        }
    },
    equalTo: function(r, value, param, models) {
        const equalTo = r.equalTo
        if (value !== models[equalTo]) return sprintf(r.message || defaultMessage.equalTo, r.name)
    },
    bytelength: function(r, value, param, models) {
        param = r.param
        const len = value.replace(/[^\x00-\xff]/g, '**').length;
        if (len > param) return sprintf(r.message || defaultMessage.bytelength, param)
    }
}