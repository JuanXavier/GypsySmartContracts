// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniV2Mock {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    error InvalidToken();
    error InsuficientAmount();
    error TooLittleShares();
    error TooLittleLiquidity();
    error PriceAffected();

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) internal {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        // Sanity checks
        if (_tokenIn != address(token0) || _tokenIn != address(token1)) revert InvalidToken();
        if (_amountIn == 0) revert InsuficientAmount();

        // Check which of the tokens is
        bool isToken0 = address(token0) == _tokenIn;

        // Declare tokens and reserves for each one
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        // Pull tokens from user
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // Calculate 0.03% fee from inputAmount
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        /*
					How much amountOut (dy) for amountInwithFee (dx) ?
					xy = k
					x= reserveIn                               y = reserveOut
					dx = amountInWithFee             dy = amountOut
					DY = (y * dx) / (x + dx)
				*/

        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);
        tokenOut.transfer(msg.sender, amountOut);

        // Update reserves:
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        // Pull in tokens from user
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        /*
        How much dx, dy to add without affecting price?
        xy = k
        (x + dx)(y + dy) = k'
        x / y = (x + dx) / (y + dy)
        x(y + dy) = y(x + dx)
        x * dy = y * dx

        dy = y / x * dx
        x / y = dx / dy
				x * dy = y * dx
        */

        if (reserve0 > 0 || reserve1 > 0) {
            if (reserve0 * _amount1 != reserve1 * _amount0) revert PriceAffected();
        }

        /*
        How much shares to mint?
        f(x, y) = value of liquidity
        We will define f(x, y) = sqrt(xy)

        L0 = f(x, y)
        L1 = f(x + dx, y + dy)
        T = total shares
        s = shares to mint

        Total shares should increase proportional to increase in liquidity
        L1 / L0 = (T + s) / T
        L1 * T = L0 * (T + s)
        (L1 - L0) * T / L0 = s 

				shares =    dx / x * T         =         dy / y * T
        */

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            //                            dx             *          T            /        x                 dy        *         T            /        y
            shares = _min((_amount0 * totalSupply) / reserve0, (_amount1 * totalSupply) / reserve1);
        }

        if (shares == 0) revert TooLittleShares();
        _mint(msg.sender, shares);

        // Update reserves (assuming no one sends tokens to this contract)
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        /*
        Claim
        dx, dy = amount of liquidity to remove
				s = shares           T = totalSupply          x=reserve0
        dx = s / T * x
        dy = s / T * y
				*/

        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        //    dx      =           s       *    x     /        T
        amount0 = (_shares * bal0) / totalSupply;

        //    dy      =           s       *    y     /        T
        amount1 = (_shares * bal1) / totalSupply;

        if (amount0 == 0 || amount1 == 0) revert TooLittleLiquidity();

        // Burn shares
        _burn(msg.sender, _shares);

        _update(bal0 - amount0, bal1 - amount1);

        token0.transfer(msg.sender, amount0);
        token0.transfer(msg.sender, amount1);
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}
