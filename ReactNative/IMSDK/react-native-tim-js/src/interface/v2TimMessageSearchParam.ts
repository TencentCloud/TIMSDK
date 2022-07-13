/**
 * @module interface
 */
interface V2TimMessageSearchParam {
    conversationID?: String;
    keywordList: String[];
    type: number;
    userIDList?: String[];
    messageTypeList?: number[];
    searchTimePosition?: number;
    searchTimePeriod?: number;
    pageSize?: number;
    pageIndex?: number;
}

export default V2TimMessageSearchParam;
