import { camera, cameraPicker } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common as commonKit } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
export class VideoRecorder {

  
  static async recordVideo(context: common.UIAbilityContext): Promise<string> {
    try {
      
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        context as commonKit.Context,
        [cameraPicker.PickerMediaType.VIDEO],
        pickerProfile
      );

      

      
      if (pickerResult && pickerResult.resultUri && pickerResult.resultUri.length > 0) {
        const videoPath = pickerResult.resultUri;
        
        return videoPath;
      } else {
        
        return '';
      }
    } catch (error) {
      const err = error as BusinessError;
      
      return '';
    }
  }
} 