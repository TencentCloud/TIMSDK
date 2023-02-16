import React from 'react';
import { isEqual } from "lodash";

const areEqual = (prevProps, curProps) => isEqual(prevProps, curProps);

const withMemo = (component) => React.memo(component, areEqual);

export default withMemo;