import React, { useState } from 'react';

import { Text, TouchableWithoutFeedback, Image, TextInput, View, Platform } from 'react-native';
import mystylesheet from '../../stylesheets';


const UserInputComponent = (props) => {
    const { content, placeholdercontent, getContent, isNumber } = props
    const [value, onChangeText] = React.useState('')
    const textInputref = React.useRef<TextInput>(null)
    const [styleState, setstyleState] = React.useState(false)
    const [placeholder, setPlaceholder] = useState(content)
    if (Platform.OS === 'android')
        return (
            <TouchableWithoutFeedback onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
                <View style={styleState ? mystylesheet.itemContainerblueandroid : mystylesheet.itemContainergrayandroid}>
                    <Image style={mystylesheet.userIconandroid} source={styleState ? require('../../icon/personblue.png') : require('../../icon/persongray.png')} />
                    <View style={mystylesheet.textContainer}>
                        <Text style={styleState ? mystylesheet.userContentTitleblueandroid : (value === '' ? mystylesheet.userContentTitlegrayandroid : mystylesheet.userContentTitleandroid)}>{content}</Text>
                        <TextInput
                            style={mystylesheet.textInputgrayandroid}
                            placeholder={placeholder}
                            value={value}
                            onChangeText={text => { onChangeText(text); getContent(text) }}
                            ref={textInputref}
                            onFocus={() => { setstyleState(!styleState); setPlaceholder(placeholdercontent) }}
                            onBlur={() => { setstyleState(!styleState); setPlaceholder(content) }}
                            keyboardType={isNumber ? 'numeric' : 'default'}
                        ></TextInput>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    return (
        <TouchableWithoutFeedback onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
            <View style={styleState ? mystylesheet.itemContainerblue : mystylesheet.itemContainergray}>
                <Image style={mystylesheet.userIcon} source={styleState ? require('../../icon/personblue.png') : require('../../icon/persongray.png')} />
                <View>
                    <Text style={styleState ? mystylesheet.userContentTitleblue : (value === '' ? mystylesheet.userContentTitlegray : mystylesheet.userContentTitle)}>{content}</Text>
                    <TextInput
                        style={styleState ? mystylesheet.textInputblue : (value===''?mystylesheet.textInputgray:mystylesheet.textInput)}
                        placeholder={placeholder}
                        ref={textInputref}
                        onChangeText={text => { onChangeText(text); getContent(text) }}
                        onFocus={() => { setstyleState(!styleState); setPlaceholder(placeholdercontent) }}
                        onBlur={() => { setstyleState(!styleState); setPlaceholder(content) }}
                        value={value}
                        keyboardType={isNumber ? 'numeric' : 'default'}
                    ></TextInput>
                </View>
            </View>
        </TouchableWithoutFeedback>
    )
}

export default UserInputComponent