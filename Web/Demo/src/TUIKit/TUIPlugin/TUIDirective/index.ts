const directiveList:any = [{
  name: 'TUILongPress',
  callback: (el:Element, binding:any) => {
    // Define variable
    let pressTimer:any = null;
    let isActive = true;

    // Define funtion handlers
    // Create timeout ( run function after 1s )
    const start = (e:any) => {
      if (pressTimer === null) {
        pressTimer = setTimeout(() => {
          if (isActive) {
            binding.value(el);
            isActive = false;
          }
        }, 1000);
      }
    };

    // Cancel Timeout
    const cancel = (e: any) => {
      // Check if timer has a value or not
      if (pressTimer !== null) {
        clearTimeout(pressTimer);
        pressTimer = null;
        isActive = true;
      }
    };

    // Add Event listeners
    el.addEventListener('mousedown', start);
    el.addEventListener('touchstart', start);
    // Cancel timeouts if this events happen
    el.addEventListener('click', cancel);
    el.addEventListener('mouseout', cancel);
    el.addEventListener('touchend', cancel);
    el.addEventListener('touchcancel', cancel);
  },
}];

const directive = (app: any) => {
  directiveList.map((item:any)=> {
    app.directive(item.name, {
      mounted: item.callback,
    });
  });
};

export default  directive;
