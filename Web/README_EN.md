# TIMSDK Web Demo
English | [简体中文](./README.md)

## Demo Quick Start

1. Download the source code to a local file.

3. Set `SDKAppID` and `SECRETKEY`. See [Obtain key information](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A42.EF.BC.9A.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5.E4.BF.A1.E6.81.AF) for details.

   2.1 Open the file `/dist/debug/GenerateTestUserSig.js`.

   2.2 Fill in the configurations as instructed and save the file.

   ![Set `SDKAppID` and `SECRETKEY`](_doc/image/demo-init-1.png)

4. Open the file `/dist/index.html` with a browser (`Chrome` is recommended to preview the file).

## Development and Running

The web demo is developed with `Vue` + `Vuex` + `Element-UI`. You can develop applications with reference to this demo, or perform secondary development on this demo. 

> Reference:
>
> - [[TIMSDK Documentation](https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/index.html)

### Directory Structure

```
├───debug/ - Used to set `SDKAppID` and `SECRETKEY`
├───dist/ - Package compiled directory
├───public/ - Public entry
├───src/ - Source code directory
│   ├───assets/ - Static resource directory
│   ├───components/ - Component directory
│   ├───store/ - Vuex store directory
│   ├───locales/ - internationalization directory
│   ├───styles/ - css styles directory
│   ├───views/ - views page directory
│   ├───utils/ - Tool function directory
│   ├───app.vue - Entry file
│   ├───main.ts - Global Vue configuration
│   └───TUIKit - TUIKit directory
├───_doc/ - Documentation
├───.eslintignore - eslintignore configuration
├───babel.config.js - babel configuration
├───package.json
├───tsconfig.json - ts configuration
├───README.md
└───vue.config.js - vue-cli configuration file
```

### Preparations

1. Get your `SDKAppID` and `SECRETKEY` ready. For how to obtain them, see [Obtain key information](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A41.EF.BC.9A.E5.88.9B.E5.BB.BA.E5.BA.94.E7.94.A8).

2. Set up the [Node.js environment](https://nodejs.org/zh-cn/) (Node.js 8.0 or a later version is recommended). You just need to download the package recommended on the website and install Node.js.

   After installation is finished, open the command line window and enter the following command:

   ```shell
   node -v
   ```

   If the corresponding version number is returned by the above command, the environment is set up successfully.

### Start Process

1. Clone this repository to a local file.

   ```shell
   # Run in CLI
   git clone https://github.com/tencentyun/TIMSDK.git

   # Open the web demo project
   cd TIMSDK/Web/Demo
   ```

2. Set `SDKAppID` and `SECRETKEY`. See [Obtain key information](https://cloud.tencent.com/document/product/269/36838#.E6.AD.A5.E9.AA.A42.EF.BC.9A.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5.E4.BF.A1.E6.81.AF) for details.

   2.1 Open the file `/public/debug/GenerateTestUserSig.js`.

   2.2 Fill in the configurations as instructed and save the file.

   ![Set `SDKAppID` and `SECRETKEY`](_doc/image/demo-init-1.png)

3. Start the project.

   ```shell
   # Sync dependencies
   yarn install
   # Sync TUIKit dependencies
   cd src/TUIKit
   yarn install
   # Start the project
   cd ../../
   yarn serve
   ```

   > If a problem occurs during dependency synchronization, change the NPM source and try again.
   >
   > ```shell
   > # Change to the CNPM source
   > npm config set registry http://r.cnpmjs.org/
   > ```

4. Visit `http://localhost:8080/` in the browser.

### Notes

1. Avoid calculating the signature in the frontend.

   To optimize your trial experience, the `userSig` is calculated in the frontend in this demo. If this demo is directly launched, the `SECRETKEY` may be disclosed.

   The correct `userSig` distribution method is to integrate the calculation code of `userSig` into your server and provide the corresponding API. When `userSig` is needed, your application can send a request for a dynamic `userSig`. For more information, see [Generating UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

