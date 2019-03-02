import Vue from 'vue';
import App from './App.vue';
import router from './router';

import 'codemirror/theme/base16-dark.css';
import 'codemirror/lib/codemirror.css';
import '@/style/main.scss';

Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
}).$mount('#app');
