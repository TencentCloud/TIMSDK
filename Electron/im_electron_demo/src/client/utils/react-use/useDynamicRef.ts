import React from 'react';

const map = new Map<string, React.RefObject<unknown>>();

const setRef = <T>(key: string) : React.RefObject<T> => {
    const ref = React.createRef<T>();
    map.set(key, ref);
    return ref;
};

const getRef = <T>(key: string) : React.RefObject<T> | undefined  => {
    return map.get(key) as React.RefObject<T>;
};

const clearRef = () => {
    map.clear();
}

 const useDynamicRef = <T>() : [(key: string) =>  React.RefObject<T>, (key: string) =>  React.RefObject<T>, () => void] => [setRef, getRef, clearRef];
 
 export default useDynamicRef