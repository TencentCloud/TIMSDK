import log, { ElectronLog, variables } from "electron-log";
import path from "path";

const date = new Date();
const year = date.getFullYear();
const month = date.getMonth() + 1;
const day = date.getDate();

const logFileName = `sdk-log-${year}-${month}-${day}.log`;

log.transports.console.level = false;
log.transports.file.format = "[{y}-{m}-{d} {h}:{i}:{s}.{ms}] [{level}] {text}";
log.transports.file.resolvePath = variables => {
    return path.join(variables.libraryDefaultDir, logFileName);
};

export default log;
