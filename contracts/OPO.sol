// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomToken {
    // Basic token data
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    // Owner (can mint)
    address public owner;

    // Balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);

        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        uint256 supply = _initialSupply * 10 ** uint256(_decimals);
        totalSupply = supply;
        balanceOf[owner] = supply;

        emit Transfer(address(0), owner, supply);
    }

    // Standard ERC-20 transfer
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "zero address");
        require(balanceOf[msg.sender] >= _value, "not enough balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve spender
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer from (using allowance)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "zero address");
        require(balanceOf[_from] >= _value, "not enough balance");
        require(allowance[_from][msg.sender] >= _value, "allowance too low");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // Mint new tokens to a chosen address (only owner)
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool success) {
        require(_to != address(0), "zero address");

        uint256 value = _amount * 10 ** uint256(decimals);

        totalSupply += value;
        balanceOf[_to] += value;

        emit Transfer(address(0), _to, value);
        return true;
    }

    // Burn tokens from msg.sender
    function burn(uint256 _amount) public returns (bool success) {
        uint256 value = _amount * 10 ** uint256(decimals);
        require(balanceOf[msg.sender] >= value, "not enough balance");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    // Optional: transfer ownership
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}
