#if UNITY_IPHONE && UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;

using UnityEditor;
using UnityEditor.Callbacks;
using System.Xml;


using UnityEngine;
using UnityEditor.Build.Reporting;
using System.Diagnostics;
using System.Threading;



using UnityEditor.iOS.Xcode.Extensions;
using UnityEditor.iOS.Xcode;

public class SDKBuildIOS : Editor
{

    [PostProcessBuild(999)]
    public static void OnPostprocessBuild(BuildTarget buildTarget, string path)
    {
        UnityEngine.Debug.Log("Start change TencentIMSDK Setting " + path);

        var pathBase = path;

        string projPath = PBXProject.GetPBXProjectPath(path);

        PBXProject proj = new PBXProject();

        proj.ReadFromFile(projPath);

        var frameTarget = proj.GetUnityFrameworkTargetGuid();

        proj.AddHeadersBuildPhase(frameTarget);

        AddProjectSetting(proj, buildTarget, path);

        proj.WriteToFile(projPath);

        UnityEngine.Debug.Log("End change TencentIMSDK Setting");
    }





    static void AddFileToEmbedFrameworks(PBXProject proj, string targetGuid, string framework)
    {
        string fileGuid = proj.AddFile(framework, framework, UnityEditor.iOS.Xcode.PBXSourceTree.Sdk);

        PBXProjectExtensions.AddFileToEmbedFrameworks(proj, targetGuid, fileGuid);


    }


    static void AddProjectSetting(PBXProject proj,BuildTarget buildTarget, string path)
    {
        string targetGuid = proj.GetUnityMainTargetGuid();

        proj.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");

        proj.SetBuildProperty(proj.ProjectGuid(), "ENABLE_BITCODE", "NO");

        string tencentIMSDKFrameworkPath = path + "/Frameworks/com.tencent.imsdk.unity/Assets/TencentIMSDK/Plugins/iOS/ImSDK.xcframework/ios-arm64_armv7/ImSDK.framework";

        UnityEngine.Debug.Log("AddFileToEmbedFrameworks add tencentIMSDKFrameworkPath at " + tencentIMSDKFrameworkPath );

        AddFileToEmbedFrameworks(proj, targetGuid, tencentIMSDKFrameworkPath);

    }



}
#endif