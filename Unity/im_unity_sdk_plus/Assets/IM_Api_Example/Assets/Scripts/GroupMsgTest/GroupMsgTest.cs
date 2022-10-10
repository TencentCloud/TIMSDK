using UnityEngine;
using Newtonsoft.Json;
using TMPro;
using UnityEngine.UI;
using Object = System.Object;

public class GroupMsgTest : MonoBehaviour
{
    [SerializeField] private Button btnSendMsg;

    [SerializeField] private TMP_InputField _inputField;
    [SerializeField] private TMP_Text receivedMsgText;

    private void Start()
    {
        StartCheckPlayerPrefs();

        btnSendMsg.onClick.AddListener(OnClikSendGroupMsg);
    }

    private void StartCheckPlayerPrefs()
    {
        var reqInfo = new ReqInfo();

        // 开始查询本地PlayerPrefs
        if (!MyUtils.IsExistLocalInfo())
        {
            // 游客首次登录 Pid=0
            reqInfo = new ReqInfo
            (
                _code: 0,
                _dedeUserID: 0,
                _dedeUserIDCkMd5:"",
                _sessData:"",
                _biliJct:"",
                _channel:"guest"
            );
            return;
        }
        else
        {
            var infoList = MyUtils.GetLoginInfo();
            int.TryParse(infoList[1], out var uid);

            int.TryParse(infoList[3], out var lastPid);
            reqInfo = new ReqInfo
            (
                _code: 0,
                _dedeUserID: lastPid,
                _dedeUserIDCkMd5:"",
                _sessData:"",
                _biliJct:"",
                _channel:"guest"
            );
        }

        PostPIDRequest(reqInfo);
    }

    private void OnClikSendGroupMsg()
    {
        var chatMsg = _inputField.text;

        _inputField.text = " ";
        ImManager.Instance.MsgSendGroupMessage(chatMsg); //广播消息
    }

    private void PostPIDRequest(ReqInfo reqInfo)
    {
        Debug.Log($"Request Pid: channel {reqInfo.channel}, uid: {reqInfo.dedeUserID}, code: {reqInfo.code} csrf: {reqInfo.biliJct}");

        var reqUrl = "http://10.221.42.17:8001";
        var loginInfo = new LoginInfo(reqInfo.channel, reqInfo.dedeUserID, reqInfo.biliJct);

        StartCoroutine(MyUtils.Post(reqUrl, reqInfo, PostPidRequestCallback, loginInfo));
    }

    private void PostPidRequestCallback(LoginInfo loginInfo, string resStr)
    {
        var resInfo = JsonConvert.DeserializeObject<ResInfo>(resStr);

        if (resInfo.result != "success")
        {
            Debug.LogError($"PostPid: {resInfo.result}");

            MyUtils.ClearLoginInfo();
            // GenerateNewQrCode();
            // SwitchStatus(LoginStatus.Login);

            return;
        }

        var imConfig = new MyImConfig(
            resInfo.sdkappid,
            resInfo.pid.ToString(),
            resInfo.usersig,
            "11111");

        Debug.Log(
            $"Login Response : {loginInfo.channel} | UserPid: {imConfig.UserId} WsAddr: {resInfo.TcpAddr} | ModuleType: {resInfo.ModuleType} | NodeID: {resInfo.NodeID} | InstanceID: {resInfo.InstanceID}");


        // 保存/覆盖上次登录信息
        MyUtils.StoreLoginInfo(loginInfo.channel,  loginInfo.uid.ToString(), loginInfo.csrf, resInfo.pid.ToString());

        ImManager.Instance.StartConnectIM(imConfig);
        //
        // GameManager.Instance.clientModel.ConnectResInfo = resInfo;
        //
        // GameManager.Instance.netManager.Connect();
    }

    private void OnReceiveMsgCallback(string recvMsg)
    {
        receivedMsgText.text = recvMsg;
    }
}