let tim = null;

function TIMConvCreate(){
    tim.getConversationManager().TIMConvCreate({
        convId:"C2C_3708",
        convType:1,
        
        userData:"user_data:TIMConvCreate"
    }).then(data=>{
        console.log('TIMConvCreate res',data)
    })
}
function TIMConvGetConvList(){
    tim.getConversationManager().TIMConvGetConvList(
        {
            
            userData:"user_data:TIMConvGetConvList"
        }
    ).then(data=>{
        console.log('TIMConvGetConvList res',data)
    })
}
function setCallback(){
    tim.getConversationManager().TIMSetConvEventCallback({
        callback:(...args)=>{
            console.log("*****:",args)
        },
        user_data:"TIMSetConvEventCallback"
    })
}
const testConversation = data => {
    tim = data;
    // TIMConvCreate();
    // TIMConvGetConvList();
    // setCallback()
}
module.exports = {
    testConversation
}