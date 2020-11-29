let UniSwap = artifacts.require("UniswapTokenSwap")

module.exports = async function (deployer) {
    try {
        deployer.deploy(UniSwap)
    } catch (e) {
        console.log(`Error in migration: ${e.message}`)
    }
}