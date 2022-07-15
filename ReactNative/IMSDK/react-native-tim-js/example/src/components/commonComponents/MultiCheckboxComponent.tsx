import React from 'react';
import BouncyCheckbox from 'react-native-bouncy-checkbox';

const MultiCheckboxComponent = (props) => {
    const { text, getSelectedUser, type } = props
    return (
        <>
            {(() => {
                switch (type) {
                    case 'friend':
                        return (
                            <BouncyCheckbox
                                text={`userID: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'group':
                        return (
                            <BouncyCheckbox
                                text={`groupID: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'black':
                        return (
                            <BouncyCheckbox
                                text={`userID: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'selectgroup':
                        return (
                            <BouncyCheckbox
                                text={`name: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'member':
                        return (
                            <BouncyCheckbox
                                text={`name: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'message':
                        return (
                            <BouncyCheckbox
                                text={`messageID: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    case 'conversation':
                        return (
                            <BouncyCheckbox
                                text={`conversationID: ${text}`}
                                fillColor='#2F80ED'
                                unfillColor='white'
                                iconStyle={{
                                    height: 20,
                                    width: 20,
                                    borderRadius: 5,
                                    borderColor: '#c0c0c0',
                                    margin: 5
                                }}
                                textStyle={{ textDecorationLine: 'none' }}
                                onPress={(isChecked: boolean) => { getSelectedUser(isChecked, text) }}
                            />
                        );
                    default:
                        return <></>;
                }
            })()}
        </>


    )
}

export default MultiCheckboxComponent