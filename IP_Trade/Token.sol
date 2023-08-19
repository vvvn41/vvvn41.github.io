// SPDX-License-Identifier: MIT
pragma solidity^0.8.7; 

import "./IERC20.sol";

contract Token is IERC20 {
    string tokenName;
    string tokenSym;
    uint8 tokenDecimals = 6;
    uint256 tokenSupply;

    //定义账户余额
    mapping (address=>uint256) balances;
    //定义授权账户
    mapping (address=>mapping (address=>uint256)) allows;
    constructor(string memory _name, string memory _sym,uint256 _supply) {
        tokenName = _name;
        tokenSym = _sym;
        tokenSupply = _supply;
        balances[msg.sender] = _supply*10**tokenDecimals;
    }

    //optional token名字
    function name() override  external view returns (string memory){
        return tokenName;
    }
  //optional token标志
    function symbol() override  external view returns (string memory){
        return tokenSym;
    }
  //optional token精度 如果是3意味着一个token可以被分成1000份
    function decimals() override external view returns (uint8){
        return tokenDecimals;
    }
  //token总共发行量
    function totalSupply() override external view returns (uint256){
        return tokenSupply;
    }
  //_owner的token余额
    function balanceOf(address _owner) override external view returns (uint256 balance){
        return balances[_owner];
    }

  //给 _to转账_value token
    function transfer(address _to, uint256 _value) override external returns (bool success){
        require(_value >0, "approve amount invalid");
        require(_to != address(0), "_spender is invalid");
        require(balances[msg.sender]> _value, "user's balance not enough");
        
        balances[msg.sender] -= _value;//SafeMath
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  //从from 给 _to转账_value token
    function transferFrom(address _from, address _to, uint256 _value) override external returns (bool success){
        require(_value >0, "approve amount invalid");
        require(_to != address(0), "_spender is invalid");
        require(balances[_from]> _value, "user's balance not enough");
        require(allows[_from][msg.sender]> _value, "user's approve not enough");

        balances[_from] -= _value;//SafeMath
        balances[_to] += _value;
        allows[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
  //授权_spender 从账户多次提款 最多_value
  	function approve(address _spender, uint256 _value) override external returns (bool success){
        //require(balances[msg.sender]>_value, message);
        require(_spender != address(0), "_spender is invalid");
        allows[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;

      }
  //返回仍允许 _spender 从 _owner 提取的金额
    function allowance(address _owner, address _spender)override external view returns (uint256 remaining){
        return allows[_owner][_spender];
    }
}