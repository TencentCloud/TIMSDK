using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;
using EasyUI.Toast;
using System.Collections;
using System.Text;
using System.Collections.Generic;
using System.IO;
public class SendSoundMessage : MonoBehaviour
{
  string[] Labels = new string[] { "SoundMessageLabel", "SelectFriendLabel", "SelectGroupLabel", "SelectPriorityLabel", "IsOnlineLabel", "IsUnreadLabel" };
  public Text Header;
  public Button PickFileButton;
  public Text PathText;

  public Dropdown SelectedFriend;
  public Dropdown SelectedGroup;
  public Dropdown SelectedPriority;
  public Toggle IsOnline;
  public Toggle IsUnread;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  private List<string> FriendList;
  private string path;
  private bool micConnected = false;//麦克风是否连接
  private int minFreq, maxFreq;//最小和最大频率
  public AudioClip RecordedClip;//录音
  private string fileName;//保存的文件名
  private bool isRecording = false;
  private byte[] data;

  void Start()
  {
    Application.RequestUserAuthorization(UserAuthorization.Microphone);
    if (Microphone.devices.Length <= 0)
    {
      Debug.LogError("缺少麦克风设备！");
    }
    else
    {
      Debug.Log("设备名称为：" + Microphone.devices[0].ToString() + "请点击Start开始录音！");
      micConnected = true;
      Microphone.GetDeviceCaps(null, out minFreq, out maxFreq);
      if (minFreq == 0 && maxFreq == 0)
      {
        maxFreq = 44100;
      }
    }
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetJoinedGroupListSDK();
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    PickFileButton = GameObject.Find("PickFileButton").GetComponent<Button>();
    PickFileButton.onClick.AddListener(OnPickFile);
    PathText = GameObject.Find("Path").GetComponent<Text>();
    SelectedFriend = GameObject.Find("Friend").GetComponent<Dropdown>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedPriority = GameObject.Find("Priority").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMMsgPriority)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedPriority.options.Add(option);
    }
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    SelectedFriend.onValueChanged.AddListener(delegate
    {
      FriendDropdownValueChanged(SelectedFriend);
    });
    IsOnline = GameObject.Find("Online").GetComponent<Toggle>();
    IsUnread = GameObject.Find("Unread").GetComponent<Toggle>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(SendSoundMessageSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }


  /// <summary>
  /// 开始录音
  /// </summary>
  void Begin()
  {
    if (micConnected)
    {
      if (!Microphone.IsRecording(null))
      {
        RecordedClip = Microphone.Start(null, false, 60, maxFreq);
        isRecording = true;
        PathText.text = "";
        path = "";
        PickFileButton.GetComponentInChildren<Text>().text = Utils.t("SoundFinMessageLabel");
      }
    }
    else
    {
      Debug.LogError("缺少麦克风设备！");
    }
  }
  /// <summary>
  /// 停止录音
  /// </summary>
  void Stop(bool shouldSave = true)
  {
    Microphone.End(null);
    if (!shouldSave) return;
    data = GetRealAudio(ref RecordedClip);
    isRecording = false;
    PickFileButton.GetComponentInChildren<Text>().text = Utils.t("SoundMessageLabel");
    Save();
  }

  /// <summary>
  /// 保存录音
  /// </summary>
  public void Save()
  {
    fileName = "sound_" + DateTime.Now.ToString("ffff");
    if (!fileName.ToLower().EndsWith(".wav"))
    {//如果不是“.wav”格式的，加上后缀
      fileName += ".wav";
    }
    path = Path.Combine(Application.persistentDataPath, fileName);//录音保存路径
    PathText.text = path;
    using (FileStream fs = CreateEmpty(path))
    {
      fs.Write(data, 0, data.Length);
      WriteHeader(fs, RecordedClip); //wav文件头
    }
  }


  /// <summary>
  /// 创建wav格式文件头
  /// </summary>
  /// <param name="filepath"></param>
  /// <returns></returns>
  private FileStream CreateEmpty(string filepath)
  {
    FileStream fileStream = new FileStream(filepath, FileMode.Create);
    byte emptyByte = new byte();

    for (int i = 0; i < 44; i++) //为wav文件头留出空间
    {
      fileStream.WriteByte(emptyByte);
    }

    return fileStream;
  }


  /// <summary>
  /// 获取真正大小的录音
  /// </summary>
  /// <param name="recordedClip"></param>
  /// <returns></returns>
  public static byte[] GetRealAudio(ref AudioClip recordedClip)
  {
    int position = Microphone.GetPosition(null);
    if (position <= 0 || position > recordedClip.samples)
    {
      position = recordedClip.samples;
    }
    float[] soundata = new float[position * recordedClip.channels];
    recordedClip.GetData(soundata, 0);
    recordedClip = AudioClip.Create(recordedClip.name, position,
    recordedClip.channels, recordedClip.frequency, false);
    recordedClip.SetData(soundata, 0);
    int rescaleFactor = 32767;
    byte[] outData = new byte[soundata.Length * 2];
    for (int i = 0; i < soundata.Length; i++)
    {
      short temshort = (short)(soundata[i] * rescaleFactor);
      byte[] temdata = BitConverter.GetBytes(temshort);
      outData[i * 2] = temdata[0];
      outData[i * 2 + 1] = temdata[1];
    }
    Debug.Log("position=" + position + "  outData.leng=" + outData.Length);
    return outData;
  }
  /// <summary>
  /// 写文件头
  /// </summary>
  /// <param name="stream"></param>
  /// <param name="clip"></param>
  public static void WriteHeader(FileStream stream, AudioClip clip)
  {
    int hz = clip.frequency;
    int channels = clip.channels;
    int samples = clip.samples;

    stream.Seek(0, SeekOrigin.Begin);

    Byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
    stream.Write(riff, 0, 4);

    Byte[] chunkSize = BitConverter.GetBytes(stream.Length - 8);
    stream.Write(chunkSize, 0, 4);

    Byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
    stream.Write(wave, 0, 4);

    Byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
    stream.Write(fmt, 0, 4);

    Byte[] subChunk1 = BitConverter.GetBytes(16);
    stream.Write(subChunk1, 0, 4);

    UInt16 one = 1;

    Byte[] audioFormat = BitConverter.GetBytes(one);
    stream.Write(audioFormat, 0, 2);

    Byte[] numChannels = BitConverter.GetBytes(channels);
    stream.Write(numChannels, 0, 2);

    Byte[] sampleRate = BitConverter.GetBytes(hz);
    stream.Write(sampleRate, 0, 4);

    Byte[] byteRate = BitConverter.GetBytes(hz * channels * 2);
    stream.Write(byteRate, 0, 4);

    UInt16 blockAlign = (ushort)(channels * 2);
    stream.Write(BitConverter.GetBytes(blockAlign), 0, 2);

    UInt16 bps = 16;
    Byte[] bitsPerSample = BitConverter.GetBytes(bps);
    stream.Write(bitsPerSample, 0, 2);

    Byte[] datastring = System.Text.Encoding.UTF8.GetBytes("data");
    stream.Write(datastring, 0, 4);

    Byte[] subChunk2 = BitConverter.GetBytes(samples * channels * 2);
    stream.Write(subChunk2, 0, 4);
  }
  public void OnPickFile()
  {
    if (!Application.HasUserAuthorization(UserAuthorization.Microphone)) return;
    if (isRecording)
    {
      Stop();
    }
    else
    {
      Begin();
    }
  }

  void GroupDropdownValueChanged(Dropdown change)
  {
    if (change.value > 0)
    {
      SelectedFriend.value = 0;
    }
  }

  void FriendDropdownValueChanged(Dropdown change)
  {
    if (change.value > 0)
    {
      SelectedGroup.value = 0;
    }
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      GroupList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      Dropdown.OptionData option = new Dropdown.OptionData();
      GroupList.Add("");
      option.text = "";
      SelectedGroup.options.Add(option);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        GroupList.Add(item.group_base_info_group_id);
        option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void GetFriendList(params object[] parameters)
  {
    try
    {
      FriendList = new List<string>();
      SelectedFriend.ClearOptions();
      string text = (string)parameters[1];
      List<FriendProfile> List = Utils.FromJson<List<FriendProfile>>(text);
      Dropdown.OptionData option = new Dropdown.OptionData();
      FriendList.Add("");
      option.text = "";
      SelectedFriend.options.Add(option);
      foreach (FriendProfile item in List)
      {
        print(item.friend_profile_identifier);
        FriendList.Add(item.friend_profile_identifier);
        option = new Dropdown.OptionData();
        option.text = item.friend_profile_identifier;
        SelectedFriend.options.Add(option);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getFriendListFailed"));
    }
  }

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void FriendshipGetFriendProfileListSDK()
  {
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(Utils.addAsyncStringDataToScreen(GetFriendList));
    print($"FriendshipGetFriendProfileListSDK {res}");
  }

  void SendSoundMessageSDK()
  {
    var message = new Message
    {
      message_cloud_custom_str = "unity local sound data",
      message_elem_array = new List<Elem>{new Elem
      {
        elem_type = TIMElemType.kTIMElem_Sound,
        sound_elem_file_path = path
      }},
      message_need_read_receipt = false,
      message_priority = (TIMMsgPriority)SelectedPriority.value,
      message_is_excluded_from_unread_count = IsUnread.isOn,
      message_is_online_msg = IsOnline.isOn
    };
    StringBuilder messageId = new StringBuilder(128);
    if (SelectedGroup.value > 0)
    {
      print(GroupList[SelectedGroup.value]);
      message.message_conv_id = GroupList[SelectedGroup.value];
      message.message_conv_type = TIMConvType.kTIMConv_Group;
      TIMResult res = TencentIMSDK.MsgSendMessage(GroupList[SelectedGroup.value], TIMConvType.kTIMConv_Group, message, messageId, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
    else if (SelectedFriend.value > 0)
    {
      print(FriendList[SelectedFriend.value]);
      message.message_conv_id = FriendList[SelectedFriend.value];
      message.message_conv_type = TIMConvType.kTIMConv_C2C;
      TIMResult res = TencentIMSDK.MsgSendMessage(FriendList[SelectedFriend.value], TIMConvType.kTIMConv_C2C, message, messageId, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
    print(IsOnline.isOn);
    print(IsUnread.isOn);
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
  }

  void CopyText()
  {
    Utils.Copy(Result.text);
  }
  void OnApplicationQuit()
  {
    Stop(false);
    TencentIMSDK.Uninit();
  }
}