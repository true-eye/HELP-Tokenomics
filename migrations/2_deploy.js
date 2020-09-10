// const usingProvable = artifacts.require('usingProvable')
const HelpToken = artifacts.require('HelpToken')
// const HelpRewardPool = artifacts.require('HelpRewardPool')

module.exports = async function (deployer) {
  await deployer.deploy(HelpToken)
  // await deployer.deploy(HelpRewardPool)
  // deployer.deploy(HelpToken).then(() => {
  //   deployer.deploy(usingProvable).then(() => {
  //     deployer.link(usingProvable, HelpRewardPool)
  //     deployer.deploy(HelpRewardPool, HelpToken.address)
  //   })
  // })
}
