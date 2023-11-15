const { ChainId, Token, TokenAmount, Pair, Fetcher, Route } = require('@uniswap/sdk');

async function getEthDaiPrice() {
    const DAI = new Token(ChainId.MAINNET, '0x6B175474E89094C44Da98b954EedeAC495271d0F', 18);
    const WETH = new Token(ChainId.MAINNET, '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 18);

    const pair = await Fetcher.fetchPairData(DAI, WETH);
    const route = new Route([pair], WETH);

    return route.midPrice.toSignificant(6);
}
getEthDaiPrice().then((price) => console.log(price));