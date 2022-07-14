/**
 * @module interface
 */
export interface V2TimMessageSearchParam {
    conversationID?: string;
    keywordList: string[];
    type: number;
    userIDList?: string[];
    messageTypeList?: number[];
    searchTimePosition?: number;
    searchTimePeriod?: number;
    pageSize?: number;
    pageIndex?: number;
}
