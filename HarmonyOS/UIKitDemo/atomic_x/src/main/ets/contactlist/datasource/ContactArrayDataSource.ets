import { ContactInfo, CommonDataSource } from 'chatengine';
export default class ContactArrayDataSource extends CommonDataSource<ContactInfo> {
  constructor(data: ContactInfo[] = []) {
    super();
    if (data.length > 0) {
      this.setData(data);
    }
  }

  
  getData(index: number): ContactInfo {
    const contact = super.getData(index);
    if (contact === null) {
      
      const emptyContact = new ContactInfo();
      emptyContact.ID = '';
      return emptyContact;
    }
    return contact;
  }

  
  updateData(newData: ContactInfo[]): void {
    this.setData(newData);
  }

  
  getRawData(): ContactInfo[] {
    const result: ContactInfo[] = [];
    for (let i = 0; i < this.totalCount(); i++) {
      const contact = super.getData(i);
      if (contact !== null) {
        result.push(contact);
      }
    }
    return result;
  }
}