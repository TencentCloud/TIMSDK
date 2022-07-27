import React,{useState} from 'react';

import { Image, StyleSheet } from 'react-native';

import HomeScreen from './pages/Home';
import DetailsScreen from './pages/Details';
import UserScreen from './pages/User';
import CallBackScreen from './pages/CallBack';
import { createAppContainer } from 'react-navigation';
import { createStackNavigator } from 'react-navigation-stack';
import { TouchableOpacity } from 'react-native-gesture-handler';
import {CallBackContext} from './useContext';

const AppNavigator = createStackNavigator({
  Home: {
    screen: HomeScreen,
    navigationOptions: ({ navigation }) => ({
      title: "API Example for React native",
      headerRight: () => (
        <TouchableOpacity onPress={() => navigation.navigate('User')}>
          <Image style={styles.rightHeaderIcon} source={require('./icon/person.png')} />
        </TouchableOpacity>
      ),
      headerStyle: { backgroundColor: '#2F80ED' },
      headerTitleStyle: { color: '#fff' }
    }),
  },
  Details: {
    screen: DetailsScreen,
    navigationOptions: ({ navigation }) => ({
      title: `${navigation.getParam('nameStr')} ${navigation.getParam('idStr')}`,
      headerTitleStyle: { color: '#fff' },
      headerStyle: { backgroundColor: '#2F80ED' },
      headerLeft: () => (
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Image style={styles.leftHeaderIcon} source={require('./icon/turnleft.png')} />
        </TouchableOpacity>
      ),
    }),

  },
  User: {
    screen: UserScreen,
    navigationOptions: ({ navigation }) => ({
      title: '配置信息',
      headerTitleStyle: { color: '#fff' },
      headerStyle: { backgroundColor: '#2F80ED' },
      headerLeft: () => (
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Image style={styles.leftHeaderIcon} source={require('./icon/turnleft.png')} />
        </TouchableOpacity>
      )
    })
  },
  CallBack:{
    screen: CallBackScreen,
    navigationOptions:({navigation})=>({
      title: '事件回调',
      headerTitleStyle: { color: '#fff' },
      headerStyle: { backgroundColor: '#2F80ED' },
      headerLeft: () => (
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Image style={styles.leftHeaderIcon} source={require('./icon/turnleft.png')} />
        </TouchableOpacity>
      ),
    })
  }
},
  {
    initialRouteName: 'Home',
  }
);

const AppContainer = createAppContainer(AppNavigator)

const App = () => {
  const setCallbackDataHandle = (dataObj)=>{
    const temp = callbackData.contextData
    temp.push(dataObj)
    setCallbackData({contextData:temp,setCallbackData:setCallbackDataHandle,clearCallbackData:clearCallbackHandle})
  }
  
  const clearCallbackHandle = ()=>{
    setCallbackData({contextData:[],setCallbackData:setCallbackDataHandle,clearCallbackData:clearCallbackHandle})
  }
  const [callbackData,setCallbackData] = useState<any>({
    contextData:[],
    setCallbackData:setCallbackDataHandle,
    clearCallbackData:clearCallbackHandle
  })
  return (
    <CallBackContext.Provider value={callbackData}>
      < AppContainer />
    </CallBackContext.Provider>
  )
}

export default App

const styles = StyleSheet.create({
  rightHeaderIcon: {
    width: 30,
    height: 30,
    marginRight: 10
  },
  leftHeaderIcon:{
    width: 30,
    height: 30,
    marginLeft: 10
  }
})