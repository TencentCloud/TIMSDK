const { DOWNLOADFILE, RENDERPROCESSCALL, SHOWDIALOG, GET_VIDEO_INFO, SELECT_FILES, DOWNLOAD_PATH, GET_FILE_INFO_CALLBACK, SUPPORT_IMAGE_TYPE } = require("./const/const");
const { ipcMain, BrowserWindow, dialog } = require('electron')
const fs = require('fs')
const os = require('os')
const path = require('path')
const url = require('url')
const fetch = require("node-fetch");
const progressStream = require('progress-stream');
const child_process = require('child_process')
const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const FFmpeg = require("fluent-ffmpeg")
const sizeOf = require('image-size')
const FileType = require('file-type')
const ffprobe = require('ffprobe-static');

const setPath = isDev => {
    const ffprobePath = isDev ? ffprobe.path : ffprobe.path.replace('app.asar', 'app.asar.unpacked');
    const formateFfmpegPath = isDev ? ffmpegPath : ffmpegPath.replace('app.asar', 'app.asar.unpacked');
    FFmpeg.setFfprobePath(ffprobePath);
    FFmpeg.setFfmpegPath(formateFfmpegPath);
}

class IPC {
    win = null;
    constructor(win) {
        const env = process.env?.NODE_ENV?.trim();
        this.mkDownloadDic(); // Create download file directory
        const isDev = env === 'development';
        setPath(isDev);
        this.win = win;
        ipcMain.on(RENDERPROCESSCALL, (event, data) => {
            console.log("get message from render process", event.processId, data)
            const { type, params } = data;
            switch (type) {
                case SHOWDIALOG:
                    this.showDialog();
                    break;
                case DOWNLOADFILE:
                    this.downloadFilesByUrl(params);
                    break;
                case GET_VIDEO_INFO:
                    this.getVideoInfo(event, params);
                    break;
                case SELECT_FILES:
                    this.selectFiles(event, params);
                    break;
            }
        });


    }
    showDialog() {
        child_process.exec(`start "" ${path.resolve(os.homedir(), 'Download/')}`);
    }
    mkdirsSync(dirname) {
        if (fs.existsSync(dirname)) {
            return true;
        } else {
            if (this.mkdirsSync(path.dirname(dirname))) {
                fs.mkdirSync(dirname);
                return true;
            }
        }
    }
    mkDownloadDic() {
        const downloadDicPath = path.resolve(os.homedir(), 'Download/')
        this.mkdirsSync(downloadDicPath)
    }
    downloadFilesByUrl(file_url) {
        try {
            const cwd = process.resourcesPath;
            const downloadDicPath = path.resolve(os.homedir(), 'Download/')
            if (!fs.existsSync(downloadDicPath)) {
                fs.mkdirSync(downloadDicPath)
            }

            const file_name = url.parse(file_url).pathname.split('/').pop()
            const file_path = path.resolve(downloadDicPath, file_name)
            const file_path_temp = `${file_path}.tmp`
            if (!fs.existsSync(file_path)) {

                // Create write stream 
                const fileStream = fs.createWriteStream(file_path_temp).on('error', function (e) {
                    console.error('error==>', e)
                }).on('ready', function () {
                    console.log("start download :", file_url);
                }).on('finish', function () {
                    try {
                        // Rename the file after the download is complete
                        fs.renameSync(file_path_temp, file_path);
                        console.log('file download complete :', file_path);
                    } catch (err) {

                    }
                });
                // request file
                fetch(file_url, {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/octet-stream' },
                }).then(res => {
                    // Get the file size data in the request header
                    let fsize = res.headers.get("content-length");
                    // Create progress
                    let str = progressStream({
                        length: fsize,
                        time: 100 /* ms */
                    });
                    // Download progress 
                    str.on('progress', function (progressData) {
                        // output without wrapping
                        let percentage = Math.round(progressData.percentage) + '%';
                        console.log(percentage);
                    });
                    res.body.pipe(str).pipe(fileStream);
                }).catch(e => {
                    // Custom exception handling
                    console.log(e);
                });
            } else {
                // existed
                console.log(path.resolve(downloadDicPath, file_name), 'already exists, do not download')
            }
        } catch (err) {
            console.log('Failed to download file, please try again later.', err)
        }
    }
    async _getVideoInfo(event, filePath) {
        let videoDuration, videoSize
        const screenshotName = path.basename(filePath).split('.').shift() + '.png'
        const screenshotPath = path.resolve(DOWNLOAD_PATH, screenshotName)

        const { ext } = await FileType.fromFile(filePath)

        return new Promise((resolve, reject) => {
            try {
                FFmpeg(filePath)
                    .on('end', async (err, info) => {
                        const { width, height, type, size } = await this._getImageInfo(screenshotPath)
                        resolve({
                            videoDuration,
                            videoPath: filePath,
                            videoSize,
                            videoType: ext,
                            screenshotPath,
                            screenshotWidth: width,
                            screenshotHeight: height,
                            screenshotType: type,
                            screenshotSize: size,
                        })
                    })
                    .on('error', (err, info) => {
                        event.reply('main-process-error', err);
                        reject(err)
                    })
                    .screenshots({
                        timestamps: [0],
                        filename: screenshotName,
                        folder: DOWNLOAD_PATH
                    }).ffprobe((err, metadata) => {
                        if (!err) {
                            videoDuration = metadata.format.duration
                            videoSize = metadata.format.size
                        } else {
                            event.reply('main-process-error', err);
                            console.log(err)
                        }
                    })
            } catch (err) {
                event.reply('main-process-error', err);
                console.log(err)
            }
        })
    }
    async _getImageInfo(path) {
        const { width, height, type } = await sizeOf(path)
        const { size } = fs.statSync(path)
        return {
            width, height, type, size
        }
    }

    async getVideoInfo(event, params) {
        const { path } = params;
        const data = await this._getVideoInfo(event, path)
        event.reply(GET_FILE_INFO_CALLBACK, { triggerType: GET_VIDEO_INFO, data })
    }

    async selectFiles(event, params) {
        const { extensions, fileType, multiSelections } = params
        const [filePath] = dialog.showOpenDialogSync(this.win, {
            properties: ['openFile'],
            filters: [{
                name: "Images", extensions: extensions
            }]
        })
        const size = fs.statSync(filePath).size;
        const name = path.parse(filePath).base;
        const type = name.split('.')[1];

        const data = {
            path: filePath,
            size,
            name,
            type
        };

        if (SUPPORT_IMAGE_TYPE.find(v => type.includes(v))) {
            const fileContent = await fs.readFileSync(filePath);
            data.fileContent = fileContent;
        }



        event.reply(GET_FILE_INFO_CALLBACK, {
            triggerType: SELECT_FILES,
            data
        })
    }
}

module.exports = IPC;