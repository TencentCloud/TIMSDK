import React,{useState} from 'react';

import { Text, TouchableOpacity, StyleSheet, TextInput, View } from 'react-native';
import mystylesheet from '../../stylesheets';


const BasicInputComponent = ({content,placeholdercontent,getContent}:{content:string,placeholdercontent,getContent:(val:string)=>void}) => {
    const [value, onChangeText] = React.useState('')
    const textInputref = React.useRef<TextInput>(null)
    const [styleState, setstyleState] = React.useState(false)
    const [placeholder,setPlaceholder] = useState(content)


    return (
        <TouchableOpacity style={styleState ? styles.containerblue : styles.containergray} onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
            <View>
                {(() => {
                    if (styleState) {
                        return (
                            <Text style={styleState ? mystylesheet.userContentTitleblue : mystylesheet.userContentTitlegray}>{content}</Text>)
                    } else return null

                })()}
                <TextInput style={styleState ? mystylesheet.textInputblue : mystylesheet.textInputgray} placeholder={placeholder} ref={textInputref} onChangeText={text => {onChangeText(text);getContent(text)}} onFocus={() => {setstyleState(!styleState);setPlaceholder(placeholdercontent)}} onBlur={() => { setstyleState(!styleState);setPlaceholder(content)}} value={value}></TextInput>
            </View>
        </TouchableOpacity>
    )
}

export default BasicInputComponent
const styles = StyleSheet.create({
    containergray: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        paddingTop: 15,
        height: 55,
    },
    containerblue: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#2F80ED",
        paddingTop: 15,
        height: 55
    }
})