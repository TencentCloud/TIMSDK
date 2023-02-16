import TimRender from "im_electron_sdk/dist/renderer";
import { message } from "tea-component";

let timRenderInstance: TimRender;

const getInstance = ():TimRender => {
    if(!timRenderInstance) {
        const renderInstance = new TimRender();
        const proxedInstance = new Proxy(renderInstance, {
            get: (obj, prop) => {
                return async (...args) => {
                    const [params] = args
                    const res = await obj[prop](...args);
                    if (res && res.data && res.data.code != undefined && res.data.code !== 0 )  {
                        const {data: {code, desc} } = res;
                        console.error("接口出错:", prop, code, desc,res, JSON.stringify(args[0]));
                        
                        if(!params.hide_tips){
                            message.error({content: ` ${String(prop)} 接口出错：${desc}`});
                        }
                        return res
                    } 
                    return  res
                }
            }
        });
        timRenderInstance = proxedInstance;
    }
    return timRenderInstance;
}

export default getInstance();
 