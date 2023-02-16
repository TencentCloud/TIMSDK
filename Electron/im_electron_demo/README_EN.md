# IM Demo for Electron
The IM demo for Electron provides features of IM and TRTC. Developers can easily access and integrate it to enjoy stable and reliable services via Tencent Cloud services. Tencent Cloud IM is committed to helping developers quickly develop reliable, low-cost, and high-quality communication solutions. For more product information, see [Instant Messaging] (https://cloud.tencent.com/product/im).

## Starting a Project
```
// install package
npm install

cd src/client
npm install

// run 
npm run start
```
## Packaging
```
// Package a Mac app
npm run build:mac

// Package a Windows app
npm run build:windows
```

## FAQs
- 1: For `gypgyp ERR!ERR` reported during development environment installation, see [link](https://stackoverflow.com/questions/57879150/how-can-i-solve-error-gypgyp-errerr-find-vsfind-vs-msvs-version-not-set-from-c).
- 2: White screen appears when you run `npm run start` on macOS. This is because the rendering process code is not completely built and the port 3000 opened by the main process points to an empty page. The error will be resolved after the rendering process code is completely built and you refresh the window. Alternatively, you can run `cd src/client && npm run dev:react` and `npm run dev:electron` to start the rendering process and main process separately.
- 3: For macOS signature and notarization, see [link](https://xingzx.org/blog/electron-builder-macos).
- 4: For some development issues on Windows, see [link](https://blog.csdn.net/Yoryky/article/details/106780254).

## References
- [IM SDK Documentation for Electron](https://comm.qq.com/toc-electron-sdk-doc/index.html)
- [TRTC SDK Documentation for Electron](https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/index.html)

## Contact
- Join group <img src="https://github.com/tencentyun/im_electron_demo/blob/main/icon/group.jpg" width="400" height="500" alt="QR code"/>
