/**
 * @module interface
 */
interface V2TimVideoElem {
    videoPath?: String;
    UUID?: String;
    videoSize?: number;
    duration?: number;
    snapshotPath?: String;
    snapshotUUID?: String;
    snapshotSize?: number;
    snapshotWidth?: number;
    snapshotHeight?: number;
    videoUrl?: String;
    snapshotUrl?: String;
    localVideoUrl?: String;
    localSnapshotUrl?: String;
}

export default V2TimVideoElem;
