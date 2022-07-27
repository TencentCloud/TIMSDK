import React, { useState } from 'react';

import { Text, TouchableWithoutFeedback, StyleSheet, TextInput, View, Platform } from 'react-native';
import mystylesheet from '../../stylesheets';


const BasicInputComponent = ({ content, placeholdercontent, getContent }: { content: string, placeholdercontent, getContent: (val: string) => void }) => {
    const [value, onChangeText] = React.useState('')
    const textInputref = React.useRef<TextInput>(null)
    const [styleState, setstyleState] = React.useState(false)
    const [placeholder, setPlaceholder] = useState(content)

    if (Platform.OS === 'android') {
        return (
            <TouchableWithoutFeedback onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
                <View style={styleState ? mystylesheet.itemContainerblueandroid : mystylesheet.itemContainergrayandroid}>
                    <View style={mystylesheet.textContainer}>
                        <Text style={styleState ? mystylesheet.userContentTitleblueandroid : (value === '' ? mystylesheet.userContentTitlegrayandroid : mystylesheet.userContentTitleandroid)}>{content}</Text>
                        <TextInput style={mystylesheet.textInputgrayandroid} placeholder={placeholder} ref={textInputref} onChangeText={text => { onChangeText(text); getContent(text) }} onFocus={() => { setstyleState(!styleState); setPlaceholder(placeholdercontent) }} onBlur={() => { setstyleState(!styleState); setPlaceholder(content) }} value={value}></TextInput>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    }
    return (
        <TouchableWithoutFeedback onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
            <View style={styleState ? styles.containerblue : styles.containergray}>
                <View>
                <Text style={styleState ? mystylesheet.userContentTitleblue : (value === '' ? mystylesheet.userContentTitlegray : mystylesheet.userContentTitle)}>{content}</Text>
                    <TextInput style={styleState ? mystylesheet.textInputblue : (value===''?mystylesheet.textInputgray:mystylesheet.textInput)} placeholder={placeholder} ref={textInputref} onChangeText={text => { onChangeText(text); getContent(text) }} onFocus={() => { setstyleState(!styleState); setPlaceholder(placeholdercontent) }} onBlur={() => { setstyleState(!styleState); setPlaceholder(content) }} value={value}></TextInput>
                </View>
            </View>
        </TouchableWithoutFeedback>
    )
}

export default BasicInputComponent
const styles = StyleSheet.create({
    containergray: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        height: 55,
        paddingTop: 25
    },
    containerblue: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#2F80ED",
        height: 55,
        paddingTop: 10
    }
})