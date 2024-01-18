// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VconToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint96)) public allowances;
    mapping(address => uint256) public nonces;

    uint256 public totalSupply;
    string public constant name = "VconToken";
    string public constant symbol = "VCON";
    uint8 public constant decimals = 18;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );
    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) {
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Vcon: transfer amount exceeds balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = safe96(amount, "Vcon: amount exceeds 96 bits");
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balances[sender] >= amount, "Vcon: transfer amount exceeds balance");
        require(allowances[sender][msg.sender] >= amount, "Vcon: transfer amount exceeds allowance");
        
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= safe96(amount, "Vcon: amount exceeds 96 bits");
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // The permit function as provided
    // ...

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    // ... rest of the contract code ...
}
