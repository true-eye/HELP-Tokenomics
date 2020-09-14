const PrinzToken = artifacts.require('PrinzToken')
// const PrinzRewardPool = artifacts.require('PrinzRewardPool')
// const PrinzTeamLock = artifacts.require('PrinzTeamLock')

// const PrinzTokenPresale = artifacts.require('PrinzTokenPresale')

module.exports = async function (deployer) {
  await deployer.deploy(PrinzToken)
  // await deployer.deploy(PrinzRewardPool)
  // await deployer.deploy(PrinzTeamLock, '0xc703a9A6587e2a7b137256BCaF473BBE4015F51C')

  // await deployer.deploy(PrinzTokenPresale)
}
