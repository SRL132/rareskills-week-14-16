/*
TODO:
Events

- [ ]  **`event** TransferSingle(**address** **indexed** _operator, **address** **indexed** _from, **address** **indexed** _to, **uint256** _id, **uint256** _value);`
- [ ]  **`event** TransferBatch(**address** **indexed** _operator, **address** **indexed** _from, **address** **indexed** _to, **uint256**[] _ids, **uint256**[] _values);`
- [ ]  **`event** ApprovalForAll(**address** **indexed** _owner, **address** **indexed** _operator, **bool** _approved);`
- [ ]  **`event** URI(**string** _value, **uint256** **indexed** _id);`

Functions

- [ ]  **`function** safeTransferFrom(**address** _from, **address** _to, **uint256** _id, **uint256** _value, **bytes** **calldata** _data) **external**;`
- [ ]  **`function** safeBatchTransferFrom(**address** _from, **address** _to, **uint256**[] **calldata** _ids, **uint256**[] **calldata** _values, **bytes** **calldata** _data) **external**;`
- [ ]  **`function** balanceOf(**address** _owner, **uint256** _id) **external** **view** **returns** (**uint256**);`
- [ ]  **`function** balanceOfBatch(**address**[] **calldata** _owners, **uint256**[] **calldata** _ids) **external** **view** **returns** (**uint256**[] **memory**);`
- [ ]  **`function** setApprovalForAll(**address** _operator, **bool** _approved) **external**;`
- [ ]  **`function** isApprovedForAll(**address** _owner, **address** _operator) **external** **view** **returns** (**bool**);`

https://eips.ethereum.org/EIPS/eip-1155
*/

object "ERC1155" {
    code {
        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        return(0, datasize("Runtime"))
    }
    object "Runtime" {
        code {
            require(iszero(callvalue()))

            switch getSelector()

            case 0x00fdd58e /* balanceOf(address,uint256) */ {
                let account := calldataload(4)
                let id := calldataload(36)
                let bal := balanceOf(0xBEEF, 1337)
                mstore(0, bal)
                return(0, 32)
            }

            case 0xb48ab8b6 {
                batchMint()
           return(0, 0)
            }

            default {
                revert(0,0)
            }
        

        /* -------- storage layout ---------- */

//    mapping(address owner => mapping(uint256 => uint256)) public balanceOf;

  //  mapping(address => mapping(address => bool)) public isApprovedForAll;


        function accountToStorageOffset(account, id) -> offset {
            offset := add(keccak256(account, id), 1)
        }

        /* -------- storage access ---------- */

        function balanceOf(account, id) -> bal {
            bal := sload(accountToStorageOffset(account, id))
        }

        /* -------- external functions ---------- */
        function safeBatchTransferFrom(from, to, ids, values, data) {

        }

        function balanceOfBatch(owners, ids) -> balances {

        }

        function mint(to, id, amount, data) {

        }
            /*
    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender,
                    address(0),
                    ids,
                    amounts,
                    data
                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }
*/
        function batchMint() {
      //      uint256 idsLength = ids.length; // Saves MLOADs.

         //   require(idsLength == amounts.length, "LENGTH_MISMATCH");
         let to := calldataload(4)
         let idsLength := calldataload(36)

         let idsOffset := add(calldataload(0x24), 0x20)
         let amountsLength:= calldataload(0x54)
         let amountsOffset := add(calldataload(0x44), 0x20)
         let dataOffset := add(calldataload(0x64), 0x20)
  
        //    ids and amounts layout
        //    offset
         //   length
      //      first item
     //       second item
     //       third item
            let i :=0
            for { } lt(i, idsLength) { i := add(i, 1) } {
                // Load the id and amount
                let id := calldataload(add(idsOffset, mul(add(i, 1), 0x20)))
                let amount := calldataload(add(amountsOffset, mul(add(i, 1), 0x20)))

                // Calculate the storage slot for balanceOf[to][id]
                let balanceSlot := accountToStorageOffset(0xBEEF, 1337)

                // Load the current balance, add the amount, and store it back
                let currentBalance := sload(balanceSlot)
                sstore(balanceSlot, 100)
            }
        }

        /* -------- internal functions ---------- */
        function _mint(to, id, amount, data){}

        function _batchMint(to, ids, amounts, data){}

        function _batchBurn(from, ids, amounts){}

         /* -------- helper functions ---------- */

         function require(condition) {
            if iszero(condition) { revert(0, 0) }
        }

        function decodeAsAddress(offset) -> v {
            v := decodeAsUint(offset)
            if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                revert(0, 0)
            }
        }

        function decodeAsUint(offset) -> v {
            let pos := add(4, mul(offset, 0x20))
            if lt(calldatasize(), add(pos, 0x20)) {
                revert(0, 0)
            }
            v := calldataload(pos)
        }

        function getSelector() -> sel {
            // Shift right by 224 bits (32 - 4 bytes) to get the first 4 bytes
            sel := shr(224, calldataload(0))
        }
    }
    }
}