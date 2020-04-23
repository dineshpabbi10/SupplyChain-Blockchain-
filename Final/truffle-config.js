require('babel-register');
require('babel-polyfill');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", 
      port: 7545,
      network_id: "*",
      gas:6721975 // Match any network id
    },
  },
  contracts_directory: './src/contracts/', // THIS CONTRACT FOLDER IS KEY WORD N WHERE OUR CONTRACT FOLDER IS 
  // HERE WE TELL . "contract FOLDER"

  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200 // MORE CONDENSED THEN LESS GAS FEE 
      }
    }
  }
}
