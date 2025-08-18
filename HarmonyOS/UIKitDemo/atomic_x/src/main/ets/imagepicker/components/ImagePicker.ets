import { BusinessError } from '@kit.BasicServicesKit';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
export interface MediaSelectResult {
  path: string;
  type: 'image' | 'video';
}
export class ImagePicker {

  
  static async selectImage(): Promise<MediaSelectResult> {
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      
      const PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
      
      if (PhotoSelectResult && PhotoSelectResult.photoUris && PhotoSelectResult.photoUris.length > 0) {
        const imagePath = PhotoSelectResult.photoUris[0];
        const extension = imagePath.split(".").pop()?.toLowerCase();
        
        
        
        if (extension === 'jpg' || extension === 'png' || extension === 'gif' || extension === 'jpeg') {
          const result: MediaSelectResult = { path: imagePath, type: 'image' };
          return result;
        } else if (extension === 'mp4' || extension === 'avi' || extension === 'mov') {
          const result: MediaSelectResult = { path: imagePath, type: 'video' };
          return result;
        } else {
          console.warn(`[ImagePicker] 未知文件类型: ${extension}`);
          const result: MediaSelectResult = { path: imagePath, type: 'image' }; 
          return result;
        }
      } else {
        
        const result: MediaSelectResult = { path: '', type: 'image' };
        return result;
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[ImagePicker] PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      const result: MediaSelectResult = { path: '', type: 'image' };
      return result;
    }
  }
} 