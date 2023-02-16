import React from 'react';
import { Input, Icon } from 'tea-component';

import "./searchBox.scss";

export const SearchBox = () => {
    return (
        <div className="search-box">
          <Icon type="search" className="search-icon"/>
          <Input
            type="search"
            className="search-input"
            placeholder="搜索"
          />
        </div>
    )
};

