const directiveList:any = [{
  name: 'TUILongPress',
  callback: (el:Element, binding:any, vNode:any) => {
    // 确保提供的表达式是函数
    if (typeof binding.value !== 'function') {
      // 获取组件名称
      const compName = vNode.context.name;
      // 将警告传递给控制台
      let warn = `[longpress:] provided expression '${binding.expression}' is not afunction, but has to be `;
      if (compName) {
        warn += `Found in component '${compName}' `;
      }
      console.warn(warn);
    }
    // 定义变量
    let pressTimer:any = null;
    // 定义函数处理程序
    // 创建计时器（ 1秒后执行函数 ）
    const start = (e:any) => {
      if (e.type === 'click' && e.button !== 0) {
        return;
      }
      if (pressTimer === null) {
        pressTimer = setTimeout(() => {
          // 执行函数
          handler(e);
        }, 1000);
      }
    };
    // 取消计时器
    const cancel = (e:any) => {
      // 检查计时器是否有值
      if (pressTimer !== null) {
        clearTimeout(pressTimer);
        pressTimer = null;
      }
    };
    // 运行函数
    const handler = (e:any) => {
      // 执行传递给指令的方法
      binding.value(e);
    };
    // 添加事件监听器
    el.addEventListener('mousedown', start, false);
    el.addEventListener('touchstart', start, false);
    // 取消计时器
    el.addEventListener('click', cancel);
    el.addEventListener('mouseout', cancel);
    el.addEventListener('touchend', cancel);
    el.addEventListener('touchcancel', cancel);
  },
}];

const directive = (app: any) => {
  directiveList.map((item:any) => {
    app.directive(item.name, {
      beforeMount: item.callback,
    });
  });
};

export default  directive;
