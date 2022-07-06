/**
 * 如果你想删除本文件，请先确认它使用的范围，感谢合作~
 *
 * author: 375890534@qq.com
 */
export default {
    methods: {
        //转义符换成普通字符
        escape2Html(str) {
            if (!str) return str;
            var arrEntities = {
                'lt': '<',
                'gt': '>',
                'nbsp': ' ',
                'amp': '&',
                'quot': '"'
            };
            return str.replace(/&(lt|gt|nbsp|amp|quot);/ig, function(all, t) {
                return arrEntities[t];
            });
        },
        //普通字符转换成转义符
        html2Escape(sHtml) {
            if (!sHtml) return sHtml;
            return sHtml.replace(/[<>&"]/g, function(c) {
                return {
                    '<': '&lt;',
                    '>': '&gt;',
                    '&': '&amp;',
                    '"': '&quot;'
                } [c];
            });
        },
        //setData polyfill 勿删!!!   (用于转换后的uniapp的项目能直接使用this.setData()函数)
        setData: function(obj, callback) {
            let that = this;
            const handleData = (tepData, tepKey, afterKey) => {
                var tepData2 = tepData;
                tepKey = tepKey.split('.');
                tepKey.forEach(item => {
                    if (tepData[item] === null || tepData[item] === undefined) {
                        let reg = /^[0-9]+$/;
                        tepData[item] = reg.test(afterKey) ? [] : {};
                        tepData2 = tepData[item];
                    } else {
                        tepData2 = tepData[item];
                    }
                });
                return tepData2;
            };
            const isFn = function(value) {
                return typeof value == 'function' || false;
            };
            Object.keys(obj).forEach(function(key) {
                let val = obj[key];
                key = key.replace(/\]/g, '').replace(/\[/g, '.');
                let front, after;
                let index_after = key.lastIndexOf('.');
                if (index_after != -1) {
                    after = key.slice(index_after + 1);
                    front = handleData(that, key.slice(0, index_after), after);
                } else {
                    after = key;
                    front = that;
                }
                if (front.$data && front.$data[after] === undefined) {
                    Object.defineProperty(front, after, {
                        get() {
                            return front.$data[after];
                        },
                        set(newValue) {
                            front.$data[after] = newValue;
                            that.hasOwnProperty("$forceUpdate") && that.$forceUpdate();
                        },
                        enumerable: true,
                        configurable: true
                    });
                    front[after] = val;
                } else {
                    that.$set(front, after, val);
                }
            });
            // this.$forceUpdate();
            isFn(callback) && this.$nextTick(callback);
        }
    }
}
