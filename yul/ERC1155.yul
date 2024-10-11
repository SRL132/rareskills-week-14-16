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
              //  let account := calldataload(4)
               // let id := calldataload(36)
               // let bal := balanceOf(account, id)
               // mstore(0, bal)
              //  return(0, 32)
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }

            case 0xb48ab8b6 /* batchMint(address to, uint256[] calldata ids, uint256[] calldata amounts,
            bytes calldata data)*/ 
            {
                batchMint()
                return(0, 0)
            }

            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), decodeAsUint(4))
            }

            default {
                revert(0,0)
            }
        

        /* -------- storage layout ---------- */

//    mapping(address owner => mapping(uint256 => uint256)) public balanceOf;

  //  mapping(address => mapping(address => bool)) public isApprovedForAll;


        function accountToStorageOffset(account, id) -> offset {
            mstore(0, id)
            mstore(0x20, account)
            offset := keccak256(0, 0x40)
        }

        /* -------- storage access ---------- */

        function balanceOf(account, id) -> bal {
            bal := sload(accountToStorageOffset(account, id))
        }

        function balanceStorageOffset(id, account) -> offset {
            mstore(0, id)
            mstore(0x20, account)
            offset := keccak256(0, 0x40)
        }

        /* -------- external functions ---------- */
        function safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset) {
            _safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset)
        }

        function _safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset) {
            let idsLen := decodeAsArrayLen(idsOffset)
            let amountsLen := decodeAsArrayLen(amountsOffset)

            let firstIdPtr := add(idsOffset, 0x24)           // ptr to first id element
            let firstAmountPtr := add(amountsOffset, 0x24)   // ptr to first amount element

            for { let i := 0} lt(i, idsLen) { i := add(i, 1) }
            {
                let id := calldataload(add(firstIdPtr, mul(i, 0x20)))
                let amount := calldataload(add(firstAmountPtr, mul(i, 0x20)))

                let fromBalance := sload(balanceStorageOffset(id, from))

                _subBalance(from, id, amount)
                _addBalance(to, id, amount)

            }
            let operator := caller()

     //       _doSafeBatchTransferAcceptanceCheck(operator, from, to, idsOffset, amountsOffset, dataOffset)
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
//address to, uint256[] calldata ids, uint256[] calldata amounts,
//            bytes calldata data
        function batchMint() {
          //      uint256 idsLength = ids.length; // Saves MLOADs.
         //   require(idsLength == amounts.length, "LENGTH_MISMATCH");
         let to := decodeAsAddress(0)
    // 0x1fe457d7                                                         - function signature
    //  0000000000000000000000000000000000000000000000000000000000000020 - offset of [1,2,3]
    //  0000000000000000000000000000000000000000000000000000000000000003 - count for [1,2,3]
    //  0000000000000000000000000000000000000000000000000000000000000001 - encoding of 1
    //  0000000000000000000000000000000000000000000000000000000000000002 - encoding of 2
    //  0000000000000000000000000000000000000000000000000000000000000003 - encoding of 3
    //TODO: understand decodeAsUint
         let idsOffset := add(decodeAsUint(1), 0x04)
         
         let idsLength := calldataload(idsOffset)

         let amountsOffset := add(decodeAsUint(2), 0x04)

         let amountsLength:= calldataload(amountsOffset)

         let dataOffset :=  add(decodeAsUint(3), 0x04)
            //TODO: add custom error
         if iszero(eq(idsLength, amountsLength)) {
            //ERC1155_LENGTH_MISMATCH
               // mstore(0x00, 0x3b3b57de)
                revert(0, 0) // Revert with the error selector
        }

        //    ids and amounts layout
        //    offset
         //   length
      //      first item
     //       second item
     //       third item
            let i :=0
            for { } lt(i, idsLength) { i := add(i, 1) } {
                // Load the id and amount
                let id  := calldataload(add(idsOffset, mul(i, 0x20)))
                let amount := calldataload(add(amountsOffset, mul(i, 0x20)))

                // Calculate the storage slot for balanceOf[to][id]
                let balanceSlot := accountToStorageOffset(to, id)

                // Load the current balance, add the amount, and store it back
                let currentBalance := sload(balanceSlot)
                sstore(balanceSlot,  amount)
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
            // Decode the value as a uint256
            v := decodeAsUint(offset)
            // Check if the value fits within the address size (20 bytes)
            //This operation inverts all the bits of the 160-bit hexadecimal value 0xffffffffffffffffffffffffffffffffffffffff, so fs become 0s and 0s become fs
            //The result is 0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            //v & not(0xffffffffffffffffffffffffffffffffffffffff) will be 0 if the value is less than 2^160
            if iszero(iszero(and(v, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000))) {
                revert(0, 0)
            }
        }

        function decodeAsUint(offset) -> v {
            // Calculate the position in calldata
            let pos := add(4, mul(offset, 0x20))

            // Check if calldata size is sufficient to read 32 bytes from the calculated position
            if lt(calldatasize(), add(pos, 0x20)) {
                revert(0, 0)
            }

            // Load the 32-byte value from calldata at the calculated position
            v := calldataload(pos)
        }

        function decodeAsArrayLen(offset) -> len {
            len := calldataload(add(offset, 4))
        }

        function getSelector() -> sel {
            // Shift right by 224 bits (32 - 4 bytes) to get the first 4 bytes
            sel := shr(224, calldataload(0))
        }

        function _addBalance(to, id, amount) {
            let offset := balanceStorageOffset(id, to)
            let prev := sload(offset)
            sstore(offset, safeAdd(prev, amount))
        }

        // this function does not check underflow, so needs to be checked before using
        function _subBalance(to, id, amount) {
            let offset := balanceStorageOffset(id, to)
            let prev := sload(offset)
            sstore(offset, sub(prev, amount))
        }

        function safeAdd(a, b) -> r {
            r := add(a, b)
            if or(lt(r, a), lt(r, b)) { revert(0, 0) }
        }

        function returnUint(v) {
            mstore(0, v)
            return(0, 0x20)
        }

    }
    }
}