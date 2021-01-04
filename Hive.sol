// solium-disable linebreak-style
pragma solidity ^0.4.25;

import "./ERC20.sol";
import "./SafeMath.sol";

contract Hive is ERC20 {

    using SafeMath for uint;
    string public constant name = "UHIVE";
    string public constant symbol = "HVE";    
    uint256 public constant decimals = 18;
    uint256 _totalSupply = 80000000000 * (10**decimals);

    //mapping (address => bool) public frozenAccount;    

    event burnHives(address target, uint256 uhives);

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // Owner of this contract
    address public owner;

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "action is only valid for contract owner");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "invalid or no ethereum address specified");
        owner = _newOwner;
    }

    // function freezeAccount(address target, bool freeze) onlyOwner public {
    //     frozenAccount[target] = freeze;
    //     FrozenFunds(target, freeze);
    // }

    // function isFrozenAccount(address _addr) public constant returns (bool) {
    //     return frozenAccount[_addr];
    // }

    function burn(uint256 uhives) public onlyOwner {        
        require(uhives > 0, "burned uhives must be greater than 0.");
        require(uhives <= balances[msg.sender], "caller does not have enough uhives to burn");
        balances[msg.sender] -= uhives;    
        _totalSupply -= uhives;
        emit burnHives(msg.sender, uhives);
    }

    // Constructor
    constructor() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    function totalSupply() public view returns (uint256 supply) {
        supply = _totalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) public returns (bool success) {        
        if (_to != address(0) && balances[msg.sender] >= _value && _value > 0 && balances[_to].add(_value) > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from,address _to, uint256 _value) public returns (bool success) {
        if (_to != address(0) && balances[_from] >= _value) {
            if(allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to].add(_value) > balances[_to]){
                balances[_from] = balances[_from].sub(_value);
                allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
                balances[_to] = balances[_to].add(_value);
                Transfer(_from, _to, _value);
                return true;
            }            
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
}