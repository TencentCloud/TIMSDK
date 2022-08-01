// 软著申请需要贴所有代码，这个脚本就是获取所有代码，并且写到txt中，方便复制到Word
const path = require("path");
const fs = require('fs-extra')
const CONSTVARS = {
    "EXCLUDE": ["country_list_pick-1.0.1+5", "openSourceTmp"]
}
async function exec() {
    const examplePaths = await getAllFiles(path.resolve(__dirname, 'lib'), '.dart', CONSTVARS.EXCLUDE);
    const uikitPaths = await getAllFiles(path.resolve(__dirname, 'package_src/tim_ui_kit/lib'),'.dart',[]);
    const allFilesPath = examplePaths.concat(uikitPaths)
    console.log(allFilesPath)
    await generateAllCodeText(allFilesPath);
}
async function generateAllCodeText(filesPath){
    console.log(`文件总数:${filesPath.length}`)
    fs.removeSync(path.resolve(__dirname,'code.text'));
    for(let i in filesPath){
        const filePath = filesPath[i];
        await fs.appendFileSync(path.resolve(__dirname,'code.text'),`文件：${filePath.replace(path.resolve(__dirname,'../'),'')}\n`)
        const content = await fs.readFileSync(filePath);
        await fs.appendFileSync(path.resolve(__dirname,'code.text'),content);
    }
}



function getAllFiles(current_dir_path, type, exclude) {
    const res = [];
    return new Promise((resolve) => {
        const files = fs.readdirSync(current_dir_path);
        files.forEach(async (name) => {
            const filePath = path.join(current_dir_path, name);
            const stat = fs.statSync(filePath);
            if (stat.isFile()) {
                if (filePath.endsWith(type) && exclude.filter((item) => { return filePath.includes(item) }).length == 0) {
                    res.push(filePath);
                }
            } else {
                const innerFiles = await getAllFiles(filePath, type, exclude);
                innerFiles.map((i) => res.push(i));
            }
        });
        resolve(res);
    });
}



exec();