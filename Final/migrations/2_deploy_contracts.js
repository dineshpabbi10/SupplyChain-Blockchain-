const SupplyChainCode = artifacts.require("SupplyChainCode");

module.exports = function(deployer) {
  deployer.deploy(SupplyChainCode);
};

