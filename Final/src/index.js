import React from 'react';
import ReactDOM from 'react-dom';// 
import 'bootstrap/dist/css/bootstrap.css'
import App from './components/App'; // this file is created automatically for us 
// all web page elements shuld be in components folder
import * as serviceWorker from './serviceWorker';

ReactDOM.render(<App />, document.getElementById('root'));

// INDEX FILE IS GIVEN TO US AND NOT CHANGE IT . ENTRANCE OF PROJECT . 
// npx create-react-project myAPP// to create react project 
//  search on google and follow steps on first link  
// 



// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
