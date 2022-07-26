import axios from 'axios';
import qs from 'qs';
const baseURL = 'https://demos.trtc.tencent-cloud.com'; // 国内
// const baseURL = 'https://demos3w.trtc.tencent-cloud.com'; // 国际
const ENV = 'prod'; // prod: 生产 dev: 测试

const instance = axios.create({
  baseURL: `${baseURL}/${ENV}`,
  headers: { 'content-type': 'application/x-www-form-urlencoded' },
});


export async function getSmsVerifyCode(data: { appId: any; }) {
  const options = buildOptions(data, '/base/v1/auth_users/user_verify_by_picture', 'GET');
  return instance(options);
}

export async function loginSystemByVerifyCode(loginInfo: any) {
  const options = buildOptions(loginInfo, '/base/v1/auth_users/user_login_code');
  return instance(options);
}

export async function loginSystemByToken(data: any) {
  const options = buildOptions(data, '/base/v1/auth_users/user_login_token');
  return instance(options);
}

export  async function cancellation(data:any) {
  const options = buildOptions(data, '/base/v1/auth_users/user_delete');
  return  instance(options);
}
function buildOptions(data:any, url:string, method?:string) {
  const options:any = {
    method: method || 'POST',
    url,
  };
  if (options.method === 'GET') {
    options.params = data;
  } else {
    options.data = qs.stringify(data);
  }
  return options;
}
