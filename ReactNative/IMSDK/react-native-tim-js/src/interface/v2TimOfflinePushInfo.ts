/**
 * @module interface
 */
interface V2TimOfflinePushInfo {
    title?: String;
    desc?: String;
    disablePush?: boolean;
    iOSSound?: String;
    ignoreIOSBadge?: boolean;
    androidOPPOChannelID?: String;
    androidVIVOClassification?: String;
    androidSound?: String;
    ext?: String;
}

export default V2TimOfflinePushInfo;
