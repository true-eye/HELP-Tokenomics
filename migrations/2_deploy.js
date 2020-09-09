const usingProvable = artifacts.require('usingProvable')
const HelpToken = artifacts.require('./HelpToken.sol')
const HelpRewardPool = artifacts.require('./HelpRewardPool.sol')

module.exports = async function (deployer) {
  await deployer.deploy(usingProvable)
  await deployer.link(usingProvable, HelpToken)
  deployer.deploy(HelpToken).then(() => {
    deployer.deploy(HelpRewardPool, HelpToken.address)
  })
}
