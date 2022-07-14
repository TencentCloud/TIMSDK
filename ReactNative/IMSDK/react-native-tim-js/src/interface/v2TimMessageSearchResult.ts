/**
 * @module interface
 */
import type { V2TimMessageSearchResultItem } from './v2TimMessageSearchResultItem';

export interface V2TimMessageSearchResult {
    totalCount?: number;
    messageSearchResultItems?: V2TimMessageSearchResultItem[];
}
