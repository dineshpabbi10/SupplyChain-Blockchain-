import React, { Component } from 'react';
import Web3 from 'web3'; // gets installed when we do npm install. all dependcies of project installed automatically

import logo from '../logo.png';
import './App.css';
import Ethbay from '../abis/Ethbay' // abi is folder whihc has ethbay.json, import it.
// that file has network defined there . Network helps create DOM . so this file helps to create DOM
// these accounts are in metamask n not ganache and we import in metamask 
import Addressbar from './Addressbar'
import Main from './Main'

class App extends Component {
  state = {
    account: '',
    totalNumber: 0,
    items: [],
    loading: true 
  }

  async componentDidMount(){ // always have function called this is APP.js 
    // metamask is wallet or interface for transactions to occur . 
    //
    await this.getWeb3Provider();
    await this.connectToBlockchain();
  }
  
  async getWeb3Provider(){
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider); //this contacts metamask and from componentDidMount()

    }
    else {
        window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
  }

  async connectToBlockchain(){
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();// here we use web 3 fetched from above to get all account info 
    this.setState({account: accounts[0]}) // predefined funcion , when we want applicatn to remember smthing 
    // we use set state 
    //when state was initialisedsending data from one .js file to anohtr. we send data from here to address.js . 


    //set state used for 
    const networkId = await web3.eth.net.getId() // fetch network id 577
    const networkData = Ethbay.networks[networkId]; // ganache network id , or bc network id , 5777
    // we have 5777 in ethbay written 
    if(networkData) {
      const deployedEthbay = new web3.eth.Contract(Ethbay.abi, networkData.address); // 
      // smart contract object and used to transfer data 

      this.setState({deployedEthbay: deployedEthbay}); 
      const totalNumber = await deployedEthbay.methods.totalNumber().call();
      console.log(totalNumber);
      this.setState({totalNumber})
      for (var i = 1;i<= totalNumber;i++) {
        const item = await deployedEthbay.methods.items(i).call();
        this.setState({
          items:[...this.state.items, item] // items added in this array , after each iteration . // to add items 
          // in an array . 

        });
      }
      this.setState({loading: false})
      console.log(this.state.items)
    } else {
      window.alert('Ethbay contract is not found in your blockchain.')
    }
  
  }

 
  createItem = async (itemName, itemPrice) => {
    this.setState ({loading: true})
    const gasAmount = await this.state.deployedEthbay.methods.createItem(itemName, itemPrice).estimateGas({from: this.state.account})
    this.state.deployedEthbay.methods.createItem(itemName, itemPrice).send({from: this.state.account, gas: gasAmount}) // here we use send n give address from where we call 

    .once('receipt', (receipt)=> {
      this.setState({loading: false});
    })
  }


  //gas limit for loops we define

  buyItem = async (itemId, sellingPrice) => {
    this.setState ({loading: true})
    const gasAmount = await this.state.deployedEthbay.methods.buyItem(itemId).estimateGas({from: this.state.account, value: sellingPrice})
    this.state.deployedEthbay.methods.buyItem(itemId).send({from: this.state.account, value: sellingPrice, gas: gasAmount })
    .once('receipt', (receipt)=> {
      this.setState({loading: false});
    })
  }
  
  render() // how to render the layout, the interface of the webpage 
  {
    return (
      <div>
        <Addressbar account={this.state.account}/>
        <div className="container-fluid mt-5">
          <div className="row">
            <main>
              { this.state.loading 
                ? 
                  <div><p className="text-center">Loading ...</p></div> 
                : 
                  <Main items = {this.state.items}  // define components in page 
                        createItem = {this.createItem}// export functtions to next file in this way 
                        buyItem = {this.buyItem}// MAIN is our destination to sendd functions
                  />}
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
