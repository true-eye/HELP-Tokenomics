// const usingProvable = artifacts.require('usingProvable')
// const HelpToken = artifacts.require('HelpToken')
const HelpRewardPool = artifacts.require('HelpRewardPool')

module.exports = async function (deployer) {
  // await deployer.deploy(HelpToken)
  await deployer.deploy(HelpRewardPool, 0xbf92f805b6114accf99ea0cf8f6056b93a3ac3ac)
  // deployer.deploy(HelpToken).then(() => {
  //   deployer.deploy(usingProvable).then(() => {
  //     deployer.link(usingProvable, HelpRewardPool)
  //     deployer.deploy(HelpRewardPool, HelpToken.address)
  //   })
  // })
}
