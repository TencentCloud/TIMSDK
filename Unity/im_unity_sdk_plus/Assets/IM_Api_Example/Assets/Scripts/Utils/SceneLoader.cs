using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : MonoBehaviour
{
  public void LoadScene(string sceneName)
  {
    SceneManager.LoadScene(sceneName);
  }
  public void PreviousScene()
  {
    int previousLevel = PlayerPrefs.GetInt("previousLevel");
    Application.LoadLevel(previousLevel);
  }
  public void JumpToEventListener()
  {
    SceneManager.LoadScene("EventListener");
  }
}
