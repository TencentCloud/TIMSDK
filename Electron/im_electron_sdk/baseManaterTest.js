
let tim = null;
function TIMGetServerTime(){
    console.log('TIMGetServerTime res',tim.getTimbaseManager().TIMGetServerTime());
}
function TIMGetLoginUserID(){

    tim.getTimbaseManager().TIMGetLoginUserID({userData:'user_data:TIMGetLoginUserID'}).then(data=>{
        console.log("TIMGetLoginUserID res",data)
    })
}
function TIMLogout(){
    tim.getTimbaseManager().TIMLogout({
        userData:"user_data:TIMLogout"
    }).then(data=>{
        console.log('TIMLogout res',data)
    })
}
function  TIMGetLoginStatus(){
    console.log('TIMGetLoginStatus res:',tim.getTimbaseManager().TIMGetLoginStatus())
}
const testBaseManager = data => {
    tim = data;
    TIMGetServerTime();
    TIMGetLoginUserID();
    TIMGetLoginStatus();
}
module.exports = {
    testBaseManager
}