const HelpToken = artifacts.require("./HelpToken.sol")

module.exports = function (deployer) {
  deployer.deploy(HelpToken)
}
