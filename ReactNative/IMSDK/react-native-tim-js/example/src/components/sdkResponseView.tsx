import React from 'react';
import { ScrollView } from 'react-native-gesture-handler';
import { Text } from 'react-native-paper';

const SDKResponseView = ({ codeString }) => {
    // return <ScrollView><ScrollView/>
    return (
        <ScrollView>
            <Text>{codeString}</Text>
        </ScrollView>
    );
};

export default SDKResponseView;
