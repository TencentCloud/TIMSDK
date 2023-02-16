import React, { useEffect, useState, useRef } from 'react';

interface iStyle {
  position: any,
  left: number,
  top: number
}

const PublicRightClick = ({ children }) => {
  const [show, setShow] = useState<boolean>(false);
  const [style, setStyle] = useState<iStyle>({
    position: 'fixed', left: 300, top: 200
  });
  const showRef = useRef<any>();
  const rightClickRef = useRef<any>();
  
  const handleContextMenu = (event) => {
    console.log(event);
    event.preventDefault();
    const { target: { className } } = event;
    if(!className.includes('right-menu-item')) return;
    setShow(true);
    let { clientX, clientY } = event;
    const screenW: number = window.innerWidth;
    const screenH: number = window.innerHeight;
    const rightClickRefW: number = rightClickRef?.current?.offsetWidth;
    const rightClickRefH: number = rightClickRef?.current?.offsetHeight;

    const right = (screenW - clientX) > rightClickRefW;
    const top = (screenH - clientY) > rightClickRefH;
    clientX = right ?  clientX + 6 : clientX - rightClickRefW - 6;
    clientY = top ? clientY + 6 : clientY - rightClickRefH - 6;
    setStyle({
      ...style,
      left: clientX,
      top: clientY
    });
  };
  
  const handleClick = (event: any) => {
    if(!showRef.current) return;
    if (event.target.parentNode !== rightClickRef.current){
      setShow(false)
    }
  };

  const setShowFalse = () => {
    // eslint-disable-next-line no-useless-return
    if(!showRef.current) return;
    setShow(false)
  };
  
  useEffect(() => {
    document.addEventListener('contextmenu', handleContextMenu);
    document.addEventListener('click', handleClick, true);
    document.addEventListener('scroll', setShowFalse, true);
    return () => {
      document.removeEventListener('contextmenu', handleContextMenu);
      document.removeEventListener('click', handleClick,true);
      document.removeEventListener('scroll', setShowFalse, true);
    }
  }, []);
  
  useEffect(() => {
    showRef.current = show;
  }, [show]);
 
  // 渲染右键
  const renderContentMenu = () => (
    <div ref={rightClickRef} className="right-menu" style={style} >
      {children}
    </div>
  );
  // 总渲染
  return show ? renderContentMenu() : null;
};

export default React.memo(PublicRightClick);