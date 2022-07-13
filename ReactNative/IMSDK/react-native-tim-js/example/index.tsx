import { AppRegistry } from 'react-native';
import App from './src/App';
import { name as appName } from './app.json';
import { Provider as PaperProvider } from 'react-native-paper';
import React from 'react';

function Main() {
    return (
        <PaperProvider>
          <App />
        </PaperProvider>
    );
}

AppRegistry.registerComponent(appName, () => Main);
