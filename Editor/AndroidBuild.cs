using System.IO;
using System.Xml;
using UnityEditor;
using UnityEditor.Android;
using UnityEngine;
using System.Text.RegularExpressions;
using System;

public class AndroidBuild : IPostGenerateGradleAndroidProject
{
    public int callbackOrder => 1;

    public void OnPostGenerateGradleAndroidProject(string path)
    {
        //////////////////////////////////////////////////////////////
        /// 处理配置文件
        string launcherPath = getOutputPath(path);
        string sourcePath = Path.Combine(Application.dataPath, "Plugins/Android/JsonConfigs");
        string sourceFile = Path.Combine(sourcePath, "timpush-configs.json");

        string targetFile = Path.Combine(launcherPath, "src", "main", "assets", "timpush-configs.json");
        CopyFile(sourceFile, targetFile);

        sourceFile = Path.Combine(sourcePath, "agconnect-services.json");
        targetFile = Path.Combine(launcherPath, "agconnect-services.json");
        CopyFile(sourceFile, targetFile);

        sourceFile = Path.Combine(sourcePath, "mcs-services.json");
        targetFile = Path.Combine(launcherPath, "mcs-services.json");
        CopyFile(sourceFile, targetFile);

        sourceFile = Path.Combine(sourcePath, "google-services.json");
        targetFile = Path.Combine(launcherPath, "google-services.json");
        CopyFile(sourceFile, targetFile);
    }

    private void CopyFile(string sourceFile, string targetFile)
    {
        if (!File.Exists(sourceFile))
        {
            Debug.LogError("file not found: " + sourceFile);
            return;
        }

        string targetDir = Path.GetDirectoryName(targetFile);
        if (!Directory.Exists(targetDir))
        {
            Directory.CreateDirectory(targetDir);
        }

        try
        {
            File.Copy(sourceFile, targetFile, overwrite: true);

            Debug.Log($"Copied file from '{sourceFile}' to '{targetFile}'");
        }
        catch (Exception ex)
        {
            Debug.LogError("Copied failed: " + ex.Message);
        }
    }

    private string getOutputPath(string path)
    {
        if (compareVersion("2019.3", Application.unityVersion))
        {
            return path;
        }

        DirectoryInfo parent = new DirectoryInfo(path).Parent;
        return Path.Combine(parent.FullName, "launcher");
    }

    private bool compareVersion(string version1, string version2)
    {
        string[] version1List = version1.Split('.');
        string[] version2List = version2.Split('.');
        int v1year = Int32.Parse(version1List[0]);
        int v2year = Int32.Parse(version2List[0]);
        if (v1year != v2year)
        {
            return v1year > v2year;
        }

        int v1sub = Int32.Parse(version1List[1]);
        int v2sub = Int32.Parse(version2List[1]);
        return v1sub > v2sub;
    }
}