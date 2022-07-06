import { createVNode, render, ComponentPublicInstance, VNode } from 'vue';
import MessageConstructor from './index.vue';

const instances:any = [];
let seed = 1;

const appendTo: HTMLElement | null = document.body;

const message = function (options:any) {
  const tempVm: any = instances.find((item:any) => `${item.vm.props?.message ?? ''}`
      === `${(options as any).message ?? ''}`);
  if (tempVm) {
    tempVm.vm.component!.props.repeatNum += 1;
    return {
      close: () => ((
          vm.component!.proxy as ComponentPublicInstance<{
            visible: boolean
          }>
      ).visible = false),
    };
  }
  let verticalOffset = options.offset || 20;
  instances.forEach(({ vm }:any) => {
    verticalOffset += (vm.el?.offsetHeight || 0) + 20;
  });
  verticalOffset += 20;
  const id = `message_${seed += 1}`;
  const userOnClose = options.onClose;
  const props:any = {
    zIndex: 20 + seed,
    offset: verticalOffset,
    id,
    ...options,
    onClose: () => {
      close(id, userOnClose);
    },
  };
  const vm = createVNode(
    MessageConstructor,
    props,
  );
  const container = document.createElement('div');
  vm.props!.onDestroy = () => {
    render(null, container);
  };
  render(vm, container);
  instances.push({ vm });
  appendTo.appendChild(container.firstElementChild!);
  return {
    close: () => ((
        vm.component!.proxy as ComponentPublicInstance<{
          visible: boolean
        }>
    ).visible = false),
  };
};

export function close(id: string, userOnClose?: (vm: VNode) => void): void {
  const idx = instances.findIndex(({ vm }: any) => id === vm.component!.props.id);
  if (idx === -1) return;
  const { vm } = instances[idx];
  if (!vm) return;
  userOnClose?.(vm);
  const removedHeight = vm.el!.offsetHeight;
  instances.splice(idx, 1);
  // adjust other instances vertical offset
  const len = instances.length;
  if (len < 1) return;
  for (let i = idx; i < len; i++) {
    const pos = Number.parseInt(instances[i].vm.el!.style.top, 10) - removedHeight - 16;
    instances[i].vm.component!.props.offset = pos;
  }
}

export default message;
