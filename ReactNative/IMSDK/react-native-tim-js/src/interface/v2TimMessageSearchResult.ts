/**
 * @module interface
 */
import type V2TimMessageSearchResultItem from './v2TimMessageSearchResultItem';

interface V2TimMessageSearchResult {
    totalCount?: number;
    messageSearchResultItems?: V2TimMessageSearchResultItem[];
}
export default V2TimMessageSearchResult;
