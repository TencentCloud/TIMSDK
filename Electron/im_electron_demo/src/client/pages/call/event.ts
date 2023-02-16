class Event {
    handlers = null;

    constructor() {
        this.handlers = {}
    }

    on(eventName, cb) {
        const eventCallbackStack = this._getHandler(eventName).callbackStack
        eventCallbackStack.push(cb)
    }

    emit(eventName, ...args) {
        if(this.handlers[eventName]) {
            this.handlers[eventName].callbackStack.forEach(cb => {
                // 修正this指向
                cb.call(cb, ...args)
            })
            // 移除once事件
            if(this.handlers[eventName].isOnce) {
                this.off(eventName)
            }
        }
    }

    off(eventName) {
        this.handlers[eventName] && delete this.handlers[eventName]
    }

    once(eventName, cb) {
        const eventCallbackStack = this._getHandler(eventName, true).callbackStack
        eventCallbackStack.push(cb)
    }

    /**
     * 根据事件名获取事件对象
     * @param eventName
     * @param isOnce  // 是否为once事件
     */
    _getHandler(eventName, isOnce = false){
        if(!this.handlers[eventName]) {
            this.handlers[eventName] = {
                isOnce,
                callbackStack: [],
            }
        }
        return this.handlers[eventName]
    }
}

let eventInstance;

const getEventInstance = () => {
    if(!eventInstance) {
        eventInstance = new Event();
    }

    return eventInstance;
}

export default getEventInstance();