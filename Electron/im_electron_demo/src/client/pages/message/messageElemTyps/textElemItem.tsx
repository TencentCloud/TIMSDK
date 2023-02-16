import React from "react";
import { isEqual } from "lodash";
import { decodeText } from "../../../utils/decodeText";
import withMemo from "../../../utils/componentWithMemo";

const TextElemItem = (props: any): JSX.Element => {
    const splitItem = props.text_elem_content.split('\n');
    const item = (item) => (
        <div className="message-view__item--text text right-menu-item">
            {
                item.map((text, index) => {
                    const formatedText = decodeText(text);
                    return <div key={index}>
                        {
                            formatedText.map((item, textIndex) => {
                                return <span key={textIndex}>
                                    {
                                        item.name === 'text' ? <span>{item.text}</span>: <img src={item.src} style={{
                                            width: 30,
                                            height: 30
                                        }} />
                                    }
                                </span>
                            })
                        }
                    </div>
                })
            }
        </div>
    )

    return (
        item(splitItem)
    );
}

export default withMemo(TextElemItem)