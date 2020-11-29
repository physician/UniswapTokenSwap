// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "./IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapTokenSwap {

    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter;
    address private _owner;

    constructor() public {
        _owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner.");
        _;
    }

    function convertETHtoExactERC20(address _token, uint _amount) public payable {
        uint deadline = block.timestamp + 15;
        uint256 amount = _amount * 1e18;
        address[] memory path = getPathFromETHtoERC20(_token);
        uniswapRouter.swapETHForExactTokens{value: msg.value}(amount, path, address(this), deadline);

        //(bool success,) = msg.sender.call{value: address(this).balance}("");
        //require(success, "refund failed");
    }

    function convertExactERC20toETH(address _token, uint _amountIn, uint _amountOutMin) public payable {
        uint deadline = block.timestamp + 15;
        uint256 amountIn = _amountIn * 1e18;
        uint256 amountOutMin = _amountOutMin * 1e18;
        IERC20 token = IERC20(_token);
        token.approve(UNISWAP_ROUTER_ADDRESS, amountIn);
        address[] memory path = getPathFromERC20toETH(_token);
        uniswapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), deadline);
    }

    function convertExactERC20toERC20(address _tokenIn, uint _amountIn, address _tokenOut, uint _amountOutMin) public payable {
        uint deadline = block.timestamp + 15;
        uint256 amountIn = _amountIn * 1e18;
        uint256 amountOutMin = _amountOutMin * 1e18;
        IERC20 tokenIn = IERC20(_tokenIn);
        tokenIn.approve(UNISWAP_ROUTER_ADDRESS, amountIn);
        address[] memory path = getPathFromERC20toERC20(_tokenIn, _tokenOut);
        uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), deadline);
    }

    function convertERC20toExactERC20(address _tokenIn, uint _amountInMax, address _tokenOut, uint _amountOut) public payable {
        uint deadline = block.timestamp + 15;
        uint256 amountInMax = _amountInMax * 1e18;
        uint256 amountOut = _amountOut * 1e18;
        IERC20 tokenIn = IERC20(_tokenIn);
        tokenIn.approve(UNISWAP_ROUTER_ADDRESS, amountInMax);
        address[] memory path = getPathFromERC20toERC20(_tokenIn, _tokenOut);
        uniswapRouter.swapTokensForExactTokens(amountOut, amountInMax, path, address(this), deadline);
    }

    function getEstimatedETHforERC20(address _token, uint _amount) public view returns (uint) {
        uint256 amount = _amount * 1e18;
        uint[] memory estimated = uniswapRouter.getAmountsIn(amount, getPathFromETHtoERC20(_token));
        return estimated[0];
    }

    function getPathFromETHtoERC20(address _token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = _token;
        return path;
    }

    function getPathFromERC20toETH(address _token) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = uniswapRouter.WETH();
        return path;
    }

    function getPathFromERC20toERC20(address _tokenIn, address _tokenOut) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return path;
    }

    // fallback function
    receive() payable external {}

    function withdrawETH() external payable onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawERC20(IERC20 token) external payable onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}