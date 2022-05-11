const title:any = {
  zh_cn: '腾讯云即时通信 Web-IM',
  en: 'Instant Messaging  Web-IM',
};
export function switchTitle(locale:string) {
  return document.title = title[locale];
}
