using UnityEngine ;
using EasyUI.Helpers ;

/* -------------------------------
   Created by : Hamza Herbou
   hamza95herbou@gmail.com
---------------------------------- */

namespace EasyUI.Toast {

   public enum ToastColor {
      Black,
      Red,
      Purple,
      Magenta,
      Blue,
      Green,
      Yellow,
      Orange
   }

   public enum ToastPosition {
      TopLeft,
      TopCenter,
      TopRight,
      MiddleLeft,
      MiddleCenter,
      MiddleRight,
      BottomLeft,
      BottomCenter,
      BottomRight
   }

   public static class Toast {
      public static bool isLoaded = false ;

      private static ToastUI toastUI ;

      private static void Prepare () {
         if (!isLoaded) {
            GameObject instance = MonoBehaviour.Instantiate (Resources.Load<GameObject> ("ToastUI")) ;
            instance.name = "[ TOAST UI ]" ;
            toastUI = instance.GetComponent <ToastUI> () ;
            isLoaded = true ;
         }
      }



      public static void Show (string text) {
         Prepare () ;
         toastUI.Init (text, 2F, ToastColor.Black, ToastPosition.BottomCenter) ;
      }


      public static void Show (string text, float duration) {
         Prepare () ;
         toastUI.Init (text, duration, ToastColor.Black, ToastPosition.BottomCenter) ;
      }

      public static void Show (string text, float duration, ToastPosition position) {
         Prepare () ;
         toastUI.Init (text, duration, ToastColor.Black, position) ;
      }


      public static void Show (string text, ToastColor color) {
         Prepare () ;
         toastUI.Init (text, 2F, color, ToastPosition.BottomCenter) ;
      }

      public static void Show (string text, ToastColor color, ToastPosition position) {
         Prepare () ;
         toastUI.Init (text, 2F, color, position) ;
      }


      public static void Show (string text, Color color) {
         Prepare () ;
         toastUI.Init (text, 2F, color, ToastPosition.BottomCenter) ;
      }

      public static void Show (string text, Color color, ToastPosition position) {
         Prepare () ;
         toastUI.Init (text, 2F, color, position) ;
      }


      public static void Show (string text, float duration, ToastColor color) {
         Prepare () ;
         toastUI.Init (text, duration, color, ToastPosition.BottomCenter) ;
      }

      public static void Show (string text, float duration, ToastColor color, ToastPosition position) {
         Prepare () ;
         toastUI.Init (text, duration, color, position) ;
      }


      public static void Show (string text, float duration, Color color) {
         Prepare () ;
         toastUI.Init (text, duration, color, ToastPosition.BottomCenter) ;
      }

      public static void Show (string text, float duration, Color color, ToastPosition position) {
         Prepare () ;
         toastUI.Init (text, duration, color, position) ;
      }



      public static void Dismiss () {
         toastUI.Dismiss () ; 
      }

   }

}
