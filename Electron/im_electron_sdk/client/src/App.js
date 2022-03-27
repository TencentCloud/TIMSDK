import React, { Component } from 'react';
import APIS from './apis';
import './App.css';

class App extends Component {
  constructor(){
    super();
    this.state = {
      log:[]
    }
  }
  showConsole(data){
    const { log } = this.state;
    log.push(data)
    this.setState({
      log:log
    })
  }
  clean(){
    this.setState({
      log:[]
    })
  }
  render() {
    const { log } = this.state;
    return (
      <div className="App">
        <div className="btns">
          {
            APIS.map((item,index)=>{
              return (
                <div className="card" key={index}>
                  <div className="title">{item.manager}</div>
                  <div className="btn">
                    {
                      item.method.map((met,idx)=>{
                        return <button key={`${index}${idx}`} onClick={()=>{
                          met.action(this.showConsole.bind(this));
                        }}>{met.name}</button>
                      })
                    }
                  </div>
                </div>
              )
            })
          }
          
        </div>
        <div className="console">
          {
            log.map((item,index)=>{
              return <div className="log-item" key={index}>{item}</div>
            })  
          }
          <button className="clean" onClick={()=>{
            this.clean.bind(this)()
          }}>清除</button>
        </div>
      </div>
    );
  }
}

export default App;
