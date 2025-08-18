import picker from '@ohos.file.picker';
export class FilePicker {
  
  static async selectFile(): Promise<string[]> {
    try {
      
      const documentPicker = new picker.DocumentViewPicker();

      
      const documentSelectOptions: picker.DocumentSelectOptions = {
        maxSelectNumber: 1,
      };

      
      const documentSelectResult = await documentPicker.select(documentSelectOptions);

      if (documentSelectResult && documentSelectResult.length > 0) {
        
        return documentSelectResult;
      } else {
        
        return [];
      }
    } catch (error) {
      
      return [];
    }
  }
} 