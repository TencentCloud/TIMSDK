import React, { Component } from "react";
import { Button } from "tea-component";
import { withRouter }  from 'react-router-dom';
import { connect } from "react-redux";

import timRenderInstance from "../../utils/timRenderInstance";
import { setIsLogInAction, userLogout } from "../../store/actions/login";
import { clearConversation } from '../../store/actions/conversation'
import { clearHistory } from '../../store/actions/message';

import './index.scss';

class ErrorBoundary extends Component {
    state = {
        error: null,
        errorInfo: null,
        loading: false,
    }

    constructor(props) {
      super(props);
      this.state = { error: null, errorInfo: null, loading: false };
    }
    
    componentDidCatch(error, errorInfo) {
      // Catch errors in any components below and re-render with error message
      this.setState({
        error: error,
        errorInfo: errorInfo
      });
      // You can also log error messages to an error reporting service here
    }

    handleClick = async () => {
        await timRenderInstance.TIMLogout();
        // @ts-ignore
        const {dispatch, history } = this.props;
        dispatch(userLogout());
        window.localStorage.clear()
        history.replace('/login');
        dispatch(setIsLogInAction(false));
        dispatch(clearConversation());
        dispatch(clearHistory());
    }
    
    render() {
      if (this.state.errorInfo) {
        return (
          <div className="error-boundary">
              <div className="error-boundary__content">
                <div className="error-boundary__content--header">

                </div>
                <div className="error-boundary__content--text">
                    <h3>系统开了点小差!</h3>
                    <h4>系统除了点错, 请重新登录</h4>
                    <Button type="primary" loading={this.state.loading} disabled={this.state.loading} onClick={this.handleClick}>返回登录</Button>
                </div>
                
              </div>
          </div>
        );
      }
      return this.props.children;
    }  
  }

const mapStateToProps = state => {
    return {
        userId: state.userInfo.userId
    }
}

export default connect(mapStateToProps, null)(withRouter(ErrorBoundary));