import { StyleSheet } from 'react-native';
const stylesheet = StyleSheet.create({
    container: {
        margin: 10
    },
    itemContainergray: {
        flexDirection: "row",
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        paddingTop: 15,
        height: 55,
    },
    itemContainerblue: {
        flexDirection: "row",
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#2F80ED",
        paddingTop: 15,
        height: 55
    },
    textInput:{
        fontSize: 14
    },
    textInputblue: {
        fontSize: 14
    },
    textInputgray: {
        height: 35,
        fontSize: 16
    },
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    userContentTitle:{
        fontSize: 11,
        color: '#808080',
    },
    userContentTitlegray: {
        height:0,
        fontSize: 11,
        color: '#808080',
        opacity: 0
    },
    userContentTitleblue: {
        fontSize: 11,
        color: '#2F80ED'
    },
    textContainer:{
        width:'100%'
    },
    itemContainergrayandroid: {
        borderBottomWidth: 1,
        borderBottomColor: "#c0c0c0",
        flexDirection:'row',
        alignItems: 'center',
        height: 68
    },
    itemContainerblueandroid: {
        borderBottomWidth: 1,
        borderBottomColor: "#2F80ED",
        flexDirection:'row',
        alignItems: 'center',
        height: 68
    },
    textInputgrayandroid: {
        height: 40,
        fontSize: 16,
    },
    userIconandroid: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    userContentTitleandroid:{
        fontSize:12,
        marginLeft:5,
        marginBottom:-10,
        paddingTop:10,
        color: '#808080' 
    },
    userContentTitlegrayandroid: {
        height:0,
        color: '#808080',
        opacity: 0
    },
    userContentTitleblueandroid: {
        fontSize:12,
        marginLeft:5,
        marginBottom:-10,
        paddingTop:10,
        color: '#2F80ED'
    },
    detailButton: {
        backgroundColor: '#2F80ED',
        color: '#fff',
        margin: 10,
        fontSize: 14,
        lineHeight: 35,
        height: 35,
        textAlign: 'center'
    },
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    switchcontainer: {
        flexDirection: 'row',
        margin: 10
    },
    switchtext: {
        lineHeight: 35,
        marginRight: 8
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems:'center',
        width:'100%',
        overflow:'hidden'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    },
})

export default stylesheet