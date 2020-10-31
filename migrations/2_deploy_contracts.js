var Hikari = artifacts.require("Hikari.sol");
var Yami = artifacts.require("Yami.sol");

module.exports = async function(deployer) {
    await deployer.deploy(Hikari, { gas: 6021975 })
    await deployer.deploy(Yami, { gas: 6021975 })
}