// const PrinzToken = artifacts.require('PrinzToken')
// const PrinzRewardPool = artifacts.require('PrinzRewardPool')
const PrinzTeamLock = artifacts.require('PrinzTeamLock')

module.exports = async function (deployer) {
  // await deployer.deploy(PrinzToken)
  // await deployer.deploy(PrinzRewardPool)
  await deployer.deploy(PrinzTeamLock, '0xc53fed364d066aceA57FcAcf0E5A22Cb707EfBE1')
}
