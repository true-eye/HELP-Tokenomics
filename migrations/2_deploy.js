// const HelpToken = artifacts.require('HelpToken')
// const HelpRewardPool = artifacts.require('HelpRewardPool')
const HelpTeamLock = artifacts.require('HelpTeamLock')

module.exports = async function (deployer) {
  // await deployer.deploy(HelpToken)
  // await deployer.deploy(HelpRewardPool)
  await deployer.deploy(HelpTeamLock, '0xc53fed364d066aceA57FcAcf0E5A22Cb707EfBE1')
}
