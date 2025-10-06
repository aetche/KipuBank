// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

/**
 * @title KipuBank
 * @author Ayelen Etchegoyen
 * @notice This contract implements a simple ETH vault that allows users to deposit
 *         and withdraw native tokens under fixed security and operational limits.
 * @dev Includes immutable withdrawal and deposit caps, custom errors,
 *      reentrancy protection, and event logging.
 */

contract KipuBank {
    /// @notice Maximum withdrawal allowed per transaction.
    uint256 immutable public WITHDRAWAL_LIMIT;

    /// @notice Global cap on total deposits allowed.
    uint256 immutable public BANK_CAP;

    /// @notice Total number of withdrawals executed.
    uint256 public withdrawalCount;

    /// @notice Total number of deposits executed.
    uint256 public depositCount;

    /// @notice Cumulative deposited amount.
    uint256 public totalBalance;

    // @notice Mapping that stores the vault balance of each user.
    mapping(address usuario => uint256 valor) public vault;

    /// @notice Internal flag used to prevent reentrancy attacks.
    bool private flag;


    // ========= EVENTS =========

    /// @notice Emitted when a deposit is successfully received.
    /// @param sender The address that made the deposit.
    /// @param amount The amount of ETH deposited.
    event DepositReceived(address sender, uint256 amount);

    /// @notice Emitted when a withdrawal is successfully executed.
    /// @param owner The address of the user withdrawing funds.
    /// @param amount The amount of ETH withdrawn.
    event WithdrawalPerformed(address owner, uint256 amount);

    // ========= ERRORS =========
    
    /// @notice Thrown when a transaction fails unexpectedly.
    error TransactionFailed(bytes reason);

    /// @notice Thrown when the total deposits reach or exceed the bank cap.
    error BankCapReached(uint256 totalBalance);

    /// @notice Thrown when an invalid or unauthorized amount is provided.
    error InvalidAmount(uint amount);


    // ========= CONSTRUCTOR =========
    /**
     * @param _withdrawalLimit The maximum amount of ETH that can be withdrawn per transaction.
     * @param _bankCap The maximum total amount of ETH that the contract can hold in deposits.
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap){
        WITHDRAWAL_LIMIT = _withdrawalLimit;
        BANK_CAP = _bankCap;
    }

    
    // ========= MODIFIERS =========

    /// @notice Prevents reentrant calls during withdrawals.
    modifier reentrancyGuard() {
      if(flag != false) revert();
      flag = true;
      _;
      flag = false;
    }


    /// @notice Validates that the withdrawal amount is positive, within limits, and does not exceed the user’s balance.
    /// @param amount The withdrawal amount to validate.
    modifier validAmount(uint256 amount){
        if(amount == 0 || vault[msg.sender] < amount || amount > WITHDRAWAL_LIMIT) revert InvalidAmount(amount);
        _;
    }

    /// @notice Ensures that the total balance never exceed the global bank cap.
    modifier validBankCap{
        if(totalBalance + msg.value > BANK_CAP) revert BankCapReached(totalBalance);
        _;
    }

    
    // ========= FUNCTIONS =========
    
    /// @notice Allows users to deposit native ETH into their personal vault.
    function deposit() external payable validBankCap {
        if(msg.value == 0) revert TransactionFailed("no eth received");
        emit DepositReceived(msg.sender, msg.value); 
        vault[msg.sender] += msg.value; 
        _setDepositCount();
        totalBalance += msg.value;

    }

    
    /// @notice Allows users to withdraw ETH from their personal vault, respecting the per-transaction limit.
    function withdraw(uint256 amount) external reentrancyGuard validAmount(amount) {
        emit WithdrawalPerformed(msg.sender, amount);
        vault[msg.sender] -= amount;
        totalBalance -= amount;
        _setWithdrawalCount();
        _transferEth(msg.sender, amount);
    }

    /// @notice ETH transfer helper.
    function _transferEth(address to, uint256 amount) private returns (bytes memory) {
        (bool success, bytes memory data) = to.call{value:amount}("");
        if(!success) revert TransactionFailed("tx failed");
        return data;
    }

    /// @notice Increments the global withdrawal counter.
    function _setWithdrawalCount() private {
        withdrawalCount += 1;
    }

    /// @notice Increments the global deposit counter.
    function _setDepositCount() private {
        depositCount += 1;
    }

    /// @notice Get vault balance from address.
    function getVaultBalance(address account) external view returns (uint256) {
        return vault[account];
    }
}
