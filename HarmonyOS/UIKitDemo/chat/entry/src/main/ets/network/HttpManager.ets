import axios, { AxiosInstance, AxiosResponse } from "@ohos/axios"
import Prompt from '@system.prompt';

interface CaptchaData {
  captcha_web_appid?: number;
  service?: string;
}

interface ResponseData {
  errorCode?: number;
  errorMessage?: string;
  data?: CaptchaData;
}

interface LoginInfo {
  token: string;
  name: string;
  userId: string;
  userSig: string;
  sdkAppId: number;
}

interface SessionData {
  sessionId: string;
}

interface SessionDataContainer {
  data: SessionData;
}

interface SessionResponse {
  data: SessionDataContainer;
}

interface LoginInfoContainer {
  data: LoginInfo;
}

interface LoginResponse {
  data: LoginInfoContainer;
}

class GlobalSchedule {
  static readonly TIME_OUT = 15 * 1000;
  // China service address
  static readonly GS_BASE_URL = "https://demos.trtc.tencent-cloud.com";
  // Singapore service address
  static readonly GS_BASE_URL_SGP = "https://demos3w.trtc.tencent-cloud.com";
  // China IM AppID
  static readonly APAAS_APP_ID = "1026227964";
  // Singapore IM AppID
  static readonly APAAS_APP_ID_SGP = "1000227999";
  // dev env
  static readonly ENV_DEV = "/dev";
  // prod env
  static readonly ENV_PROD = "/prod";
  // global schedule api address
  static readonly API_GSLB = "/base/v1/gslb";
  // get SMS
  static readonly API_GET_SMS = "/base/v1/auth_users/user_verify_by_picture";
  // verification code login
  static readonly API_LOGIN_CODE = "/base/v1/auth_users/user_login_code";
  // token login
  static readonly API_LOGIN_TOKEN = "/base/v1/auth_users/user_login_token";
  // logout
  static readonly API_LOGOUT = "/base/v1/auth_users/user_logout";
  // delete accout
  static readonly API_DELETE_ACCOUNT = "/base/v1/auth_users/user_delete";
  private axiosInstance: AxiosInstance;
  private service?: string;
  private captchaAppID?: number;

  constructor() {
    this.axiosInstance = axios.create({
      timeout: GlobalSchedule.TIME_OUT,
    });
  }

  getGlobalScheduleAddress() {
    return GlobalSchedule.GS_BASE_URL;
  }

  getEnv() {
    return GlobalSchedule.ENV_PROD;
  }

  getApaasAppID() {
    return GlobalSchedule.APAAS_APP_ID;
  }

  async request<T>(api: string, params?: Map<string, string>): Promise<T> {
    if (!this.service) {
      this.getGlobalScheduleService().then(() => {
        return this.request<T>(api, params);
      }).catch((reason: Object) => {
        return Promise.reject(reason);
      });
    }
    let finalParams = new Map(params);
    finalParams.set("apaasAppId", this.getApaasAppID());
    let paramsStr = "";
    finalParams.forEach((v, k) => {
      paramsStr += `${k}=${v}&`
    })
    let url = this.service + this.getEnv() + api + "?" + paramsStr;
    return this.axiosInstance.get(url);
  }

  async getGlobalScheduleService() {
    if (this.service) {
      return this.service;
    }
    return this.axiosInstance.get<ResponseData>(this.getGlobalScheduleAddress() + this.getEnv() + GlobalSchedule.API_GSLB)
      .then((response: AxiosResponse<ResponseData>) => {
        let responseData = response.data;
        let errorCode = responseData?.errorCode;
        let errorMessage = responseData?.errorMessage;
        // errorMessage = parseErrorMessage(errorMessage);
        if (errorCode !== 0) {
          return Promise.reject({ code: errorCode, message: errorMessage });
        }
        this.captchaAppID = responseData?.data?.captcha_web_appid;
        this.service = responseData?.data?.service;
        return Promise.resolve();
      })
      .catch((reason: Object) => {
        return Promise.reject(reason);
      });
  }

  async getCaptchaAppID(): Promise<number | undefined> {
    if (this.captchaAppID) {
      return this.captchaAppID;
    }
    return this.getGlobalScheduleService().then(() => {
      return this.captchaAppID;
    }).catch((reason: Object) => {
      return Promise.reject(reason);
    })
  }
}

export default class HttpManager {
  private static readonly TAG = "HttpManager";
  private static readonly instance = new HttpManager();
  private globalSchedule: GlobalSchedule;

  private constructor() {
    this.globalSchedule = new GlobalSchedule();
  }

  static async getCaptchaAppID() {
    return HttpManager.instance.globalSchedule.getCaptchaAppID();
  }

  static async getSms(captchaAppID?: string, ticket?: string, randStr?: string, phoneNumber?: string) {
    if (!captchaAppID || !ticket || !randStr || !phoneNumber) {
      return;
    }
    let params = new Map<string, string>();
    params.set("appId", captchaAppID);
    params.set("ticket", ticket);
    params.set("randstr", randStr);
    params.set("phone", phoneNumber);
    return HttpManager.instance.globalSchedule.request<SessionResponse>(GlobalSchedule.API_GET_SMS, params);
  }

  static async login(phoneNumber: string, verifyCode: string, sessionID: string) {
    let params = new Map<string, string>();
    params.set("sessionId", sessionID);
    params.set("code", verifyCode);
    params.set("phone", phoneNumber);
    return HttpManager.instance.globalSchedule.request<LoginResponse>(GlobalSchedule.API_LOGIN_CODE, params);
  }

  static async deleteAccount(userID: string, token: string) {
    let params = new Map<string, string>();
    params.set("userId", userID);
    params.set("token", token);
    return HttpManager.instance.globalSchedule.request<void>(GlobalSchedule.API_DELETE_ACCOUNT, params);
  }
}
