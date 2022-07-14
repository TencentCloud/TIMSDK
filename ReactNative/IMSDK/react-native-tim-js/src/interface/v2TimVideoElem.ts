/**
 * @module interface
 */
export interface V2TimVideoElem {
    videoPath?: string;
    UUID?: string;
    videoSize?: number;
    duration?: number;
    snapshotPath?: string;
    snapshotUUID?: string;
    snapshotSize?: number;
    snapshotWidth?: number;
    snapshotHeight?: number;
    videoUrl?: string;
    snapshotUrl?: string;
    localVideoUrl?: string;
    localSnapshotUrl?: string;
}
