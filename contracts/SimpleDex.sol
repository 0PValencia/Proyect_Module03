// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 private constant FEE_NUMERATOR = 997;
    uint256 private constant FEE_DENOMINATOR = 1000;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swapped(address indexed user, string direction, uint256 inputAmount, uint256 outputAmount);

    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        require(_tokenA != address(0) && _tokenB != address(0), "Direcciones invalidas");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB) external onlyOwner {
        require(_amountA > 0 && _amountB > 0, "Cantidad invalida");
        require(tokenA.transferFrom(msg.sender, address(this), _amountA), "Fallo en transferencia de TokenA");
        require(tokenB.transferFrom(msg.sender, address(this), _amountB), "Fallo en transferencia de TokenB");

        reserveA += _amountA;
        reserveB += _amountB;

        emit LiquidityAdded(msg.sender, _amountA, _amountB);
    }

    function removeLiquidity(uint256 _amountA, uint256 _amountB) external onlyOwner {
        require(_amountA <= reserveA && _amountB <= reserveB, "Reservas insuficientes");

        reserveA -= _amountA;
        reserveB -= _amountB;

        require(tokenA.transfer(msg.sender, _amountA), "Fallo al transferir TokenA");
        require(tokenB.transfer(msg.sender, _amountB), "Fallo al transferir TokenB");

        emit LiquidityRemoved(msg.sender, _amountA, _amountB);
    }

    function swapAforB(uint256 _amountAIn) external {
        require(_amountAIn > 0, "Cantidad invalida");
        require(tokenA.transferFrom(msg.sender, address(this), _amountAIn), "Fallo en transferencia");

        uint256 amountBOut = _getSwapOutput(_amountAIn, reserveA, reserveB);

        reserveA += _amountAIn;
        reserveB -= amountBOut;

        require(tokenB.transfer(msg.sender, amountBOut), "Fallo al transferir TokenB");

        emit Swapped(msg.sender, "A->B", _amountAIn, amountBOut);
    }

    function swapBforA(uint256 _amountBIn) external {
        require(_amountBIn > 0, "Cantidad invalida");
        require(tokenB.transferFrom(msg.sender, address(this), _amountBIn), "Fallo en transferencia");

        uint256 amountAOut = _getSwapOutput(_amountBIn, reserveB, reserveA);

        reserveB += _amountBIn;
        reserveA -= amountAOut;

        require(tokenA.transfer(msg.sender, amountAOut), "Fallo al transferir TokenA");

        emit Swapped(msg.sender, "B->A", _amountBIn, amountAOut);
    }

    function getPrice() external view returns (uint256 priceAperB, uint256 priceBperA) {
        require(reserveA > 0 && reserveB > 0, "Sin liquidez");
        priceAperB = (reserveB * 1e18) / reserveA;
        priceBperA = (reserveA * 1e18) / reserveB;
    }

    function _getSwapOutput(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) internal pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Reservas vacias");

        uint256 inputWithFee = inputAmount * FEE_NUMERATOR;
        uint256 numerator = inputWithFee * outputReserve;
        uint256 denominator = (inputReserve * FEE_DENOMINATOR) + inputWithFee;

        return numerator / denominator;
    }
}
