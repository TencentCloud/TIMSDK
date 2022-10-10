
using System;

public struct ReqInfo
{
    /// <summary>
    /// -1=non oauthKey
    /// -2=oauthKey not marching
    /// -4=未扫码
    /// -5=已扫码
    ///  0=登录成功
    /// </summary>
    public int code;
    /// <summary>
    /// 登录用户的uid
    /// </summary>
    public long dedeUserID;
    /// <summary>
    /// 用户md5key
    /// </summary>
    public string dedeUserIDCkMd5;
    /// <summary>
    /// accesskey 或 浏览器中的cookie
    /// </summary>
    public string sessData;
    /// <summary>
    /// 登录cookie
    /// </summary>
    public string biliJct;
    /// <summary>
    /// 登录用户属性 bili guest
    /// </summary>
    public string channel;

    public ReqInfo(int _code, long _dedeUserID, string _dedeUserIDCkMd5, string _sessData, string _biliJct, string _channel)
    {
        code = _code;
        dedeUserID = _dedeUserID;
        dedeUserIDCkMd5 = _dedeUserIDCkMd5;
        sessData = _sessData;
        biliJct = _biliJct;
        channel = _channel;
    }
}

/// <summary>
/// 服务返回信息
/// </summary>
public struct ResInfo
{
    public int error;
    public string result;
    public UInt32 pid;
    public string token;
    public string usersig;
    public long sdkappid;

    public string TcpAddr;
    public string WsAddr;
    public string ModuleType;
    public string NodeID;
    public string InstanceID;


    public ResInfo(int _error, string _result, UInt32 _pid, string _token, string _usersig, long _sdkappid, string tcpAddr, string wsAddr, string moduleType, string nodeID, string instanceID)
    {
        error = _error;
        result = _result;
        pid = _pid;
        token = _token;
        usersig = _usersig;
        sdkappid = _sdkappid;

        TcpAddr = tcpAddr;
        WsAddr = wsAddr;
        ModuleType = moduleType;
        NodeID = nodeID;
        InstanceID = instanceID;
    }
}


/// <summary>
/// 请求身份码
/// </summary>
public struct ReqCode
{
    public long app_id;
}

/// <summary>
/// 身份码返回
/// </summary>
public struct ResCode
{
    public string code;
    public string message;
    public CodeData data;
    public ResCode(string _code, string _message, CodeData _data)
    {
        code = _code;
        message = _message;
        data = _data;
    }
}

public struct CodeData
{
    public string code;
    public CodeData(string _code)
    {
        code = _code;
    }
}


public struct LoginInfo
{
    public string channel;
    public long uid;
    public string csrf;

    public LoginInfo(string _channel, long _uid, string _csrf)
    {
        channel = _channel;
        uid = _uid;
        csrf = _csrf;
    }
}
public class MyImConfig
{
    public long SdkAppId;
    public string UserId;
    public string UserSig;
    public string GroupId;

    public MyImConfig(long sdkAppID, string userPid, string userSig, string groupId)
    {
        SdkAppId = sdkAppID;
        UserId = userPid;
        UserSig = userSig;
        GroupId = groupId;
    }
}