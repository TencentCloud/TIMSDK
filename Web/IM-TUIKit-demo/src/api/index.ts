import axios from 'axios';
import qs from 'qs';
const baseURL = '';

const instance = axios.create({
  baseURL: `${baseURL}`,
  headers: { 'content-type': 'application/x-www-form-urlencoded' },
});

export function AxiosApi(data: any, url:string, method: string) {
  const options:any = {
    method: method || 'POST',
    url,
  };
  if (options.method === 'GET') {
    options.params = data;
  } else {
    options.data = qs.stringify(data);
  }
  return instance(options);
}
