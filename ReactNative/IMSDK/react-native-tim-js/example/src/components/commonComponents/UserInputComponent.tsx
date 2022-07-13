import React,{useState} from 'react';

import { Text, TouchableOpacity, Image, TextInput, View } from 'react-native';
import mystylesheet from '../../stylesheets';


const UserInputComponent = ({content,placeholdercontent,getContent}:{content:string,placeholdercontent:string,getContent:(val:string)=>void}) => {
    const [value, onChangeText] = React.useState('')
    const textInputref = React.useRef<TextInput>(null)
    const [styleState, setstyleState] = React.useState(false)
    const [placeholder,setPlaceholder] = useState(content)

    return (
        <TouchableOpacity style={styleState ? mystylesheet.itemContainerblue : mystylesheet.itemContainergray} onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
            <Image style={mystylesheet.userIcon} source={styleState ? require('../../icon/personblue.png') : require('../../icon/persongray.png')} />
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

export default UserInputComponent