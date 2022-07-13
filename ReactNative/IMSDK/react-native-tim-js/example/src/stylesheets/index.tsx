import { StyleSheet} from 'react-native';
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
    textInputblue:{
        fontSize:14
    },
    textInputgray:{
        height:35,
        fontSize: 16
    },
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    userContentTitlegray: {
        fontSize: 11,
        color: '#808080',
        opacity: 0
    },
    userContentTitleblue: {
        fontSize: 11,
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
})

export default stylesheet