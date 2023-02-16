import React, { ReactNode, useState, useEffect } from 'react';
import { Radio } from 'tea-component';

import './index.scss';

type OptionItem = {
    text: string | ReactNode,
    id: string,
}

type Props = {
    isMultiSelect?: boolean,
    options: Array<OptionItem>,
    onSelect?: (optionItem: OptionItem | string) => void
}

export const Menu = (props: Props) => {
    const { isMultiSelect = false, options, onSelect } = props;

    const handleClick = (e) => {
        // console.log('handle click', e);
        if(e.target.className.includes('menu-content')) return;
        console.log('handle click', e, e.target);
        onSelect('');
    };

    useEffect(() => {
        document.addEventListener('click', handleClick);
        return () => {
            document.removeEventListener('click', handleClick);
        }
    }, []);

    const handleRadioButtonClick = (item: OptionItem) => {
        console.log(item);
    }

    const handleItemClick = (item: OptionItem) => {
        !isMultiSelect && onSelect && onSelect(item);
    };

    return <div className="menu-content">
        {
            options.map(item => {
                const { text, id } = item;
                return (
                    <li className="menu-content__item" key={id} onClick={() => handleItemClick(item)}>
                        {isMultiSelect && <Radio onClick={() => handleRadioButtonClick(item)} />    }
                        <span className="menu-content__item--text">{text}</span>
                    </li>
                )
            })
        }
    </div>
};