/**
 * @module interface
 */
export interface V2TimOfflinePushInfo {
    title?: string;
    desc?: string;
    disablePush?: boolean;
    iOSSound?: string;
    ignoreIOSBadge?: boolean;
    androidOPPOChannelID?: string;
    androidVIVOClassification?: string;
    androidSound?: string;
    ext?: string;
}
