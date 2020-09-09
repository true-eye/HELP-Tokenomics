const usingProvable = artifacts.require('usingProvable')
const HelpToken = artifacts.require('./HelpToken.sol')

module.exports = async function (deployer) {
  await deployer.deploy(usingProvable)
  await deployer.link(usingProvable, HelpToken)
  await deployer.deploy(HelpToken)
}
