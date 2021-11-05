import Vue from 'vue';
import App from './App';

// 全局mixins，用于实现setData等功能';
import Mixin from './polyfill/mixins';
Vue.mixin(Mixin);

Vue.config.productionTip = false;

App.mpType = 'app';

const app = new Vue({
    ...App
});
app.$mount();
