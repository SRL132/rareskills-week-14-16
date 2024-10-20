/*
TODO:
Events

- [x]  **`event** TransferSingle(**address** **indexed** _operator, **address** **indexed** _from, **address** **indexed** _to, **uint256** _id, **uint256** _value);`
- [x]  **`event** TransferBatch(**address** **indexed** _operator, **address** **indexed** _from, **address** **indexed** _to, **uint256**[] _ids, **uint256**[] _values);`
- [x]  **`event** ApprovalForAll(**address** **indexed** _owner, **address** **indexed** _operator, **bool** _approved);`
- [ ]  **`event** URI(**string** _value, **uint256** **indexed** _id);`

Functions

- [x]  **`function** safeTransferFrom(**address** _from, **address** _to, **uint256** _id, **uint256** _value, **bytes** **calldata** _data) **external**;`
- [x]  **`function** safeBatchTransferFrom(**address** _from, **address** _to, **uint256**[] **calldata** _ids, **uint256**[] **calldata** _values, **bytes** **calldata** _data) **external**;`
- [x]  **`function** balanceOf(**address** _owner, **uint256** _id) **external** **view** **returns** (**uint256**);`
- [x]  **`function** balanceOfBatch(**address**[] **calldata** _owners, **uint256**[] **calldata** _ids) **external** **view** **returns** (**uint256**[] **memory**);`
- [x]  **`function** setApprovalForAll(**address** _operator, **bool** _approved) **external**;`
- [x]  **`function** isApprovedForAll(**address** _owner, **address** _operator) **external** **view** **returns** (**bool**);`

https://eips.ethereum.org/EIPS/eip-1155
*/

object "ERC1155" {
    code {
        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        return(0, datasize("Runtime"))
    }
    object "Runtime" {
        code {
            /*
         * slot0: owner
         * slot1: uriLen
         * slot (keccak256(urlLen) + i): uri value
         * slot keccak256(id,account) : balances[id][account]
         * slot keccak256(owner,operator) : operatorApproval[owner][operator]
         */
            require(iszero(callvalue()))

            switch getSelector()

            case 0x00fdd58e /* balanceOf(address,uint256) */ {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }

            case 0x731133e9 /* mint(address,uint256,uint256,bytes) */ {
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2), decodeAsUint(3))
            }

            case 0xb48ab8b6 /* batchMint(address to, uint256[] calldata ids, uint256[] calldata amounts,
            bytes calldata data)*/ 
            {
                batchMint()
            }

            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), decodeAsUint(4))
            }

            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {
                returnUint(isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1)))
            }

            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), decodeAsUint(4))
            }

            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                setApprovalForAll(decodeAsAddress(0), decodeAsBool(1))
            }

            case 0x01ffc9a7 /* "supportsInterface(bytes4)" */ {
                returnBool(supportsInterface())
            }

            case 0x0e89341C /* uri(uint256) */ {
                uri(decodeAsUint(0))
            }

            case 0x02fe5305 /* setURI(string) */ {
                setURI(decodeAsUint(0))
            }

            //TODO: 
            //events
            //custom errors

            case 0x4e1273f4 /*balanceOfBatch(address[],uint256[]*/ {
                balanceOfBatch(decodeAsUint(0), decodeAsUint(1))
            }

            case 0xf5298aca /* burn(address,uint256,uint256) */ {
                burn(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2))
            }

            case 0xf6eb127a /* batchBurn(address,uint256[],uint256[]) */ {    
                batchBurn(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2))
            }

            default {
                revert(0,0)
            }
        

        /* -------- storage layout ---------- */

  //  mapping(address owner => mapping(uint256 => uint256)) public balanceOf;

  //  mapping(address => mapping(address => bool)) public isApprovedForAll;

        function uriLenPos() -> p { p := 1 }

        function _setURI(strOffset) {
            /* resetting old URI slots to zero */
            let oldStrLen := sload(uriLenPos())
            mstore(0x00, oldStrLen)
            let oldStrFirstSlot := keccak256(0x00, 0x20)

            if oldStrLen {
                // reset old uri slot variables to zero
                let bound := div(oldStrLen, 0x20)

                if mod(oldStrLen, 0x20) {
                    bound := add(bound, 1)
                }

                for { let i := 0 } lt(i, bound) { i := add(i, 1)}
                {
                    sstore(add(oldStrFirstSlot, i), 0)
                }
            }

            /* setting new URI */
            let strLen := decodeAsArrayLen(strOffset)

            sstore(uriLenPos(), strLen) // store length of uri

            let strFirstPtr := add(strOffset, 0x24)

            mstore(0x00, strLen)
            let strFirstSlot := keccak256(0x00, 0x20)

            let bound := div(strLen, 0x20)
            if mod(strLen, 0x20) {
                bound := add(bound, 1)
            }

            for { let i := 0 } lt(i, bound) { i := add(i, 1) }
            {
                let str := calldataload(add(strFirstPtr, mul(0x20, i)))
                sstore(add(strFirstSlot, i), str)
            }
        }

        function accountToStorageOffset(account, id) -> offset {
            mstore(0, id)
            mstore(0x20, account)
            offset := keccak256(0, 0x40)
        }

        function accountToApprovalStorageOffset(owner, operator) -> offset {
            mstore(0, owner)
            mstore(0x20, operator)
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

        function uri(id) {
            let oldMptr := mload(0x40)
            let mptr := oldMptr

            mstore(mptr, 0x20)
            mptr := add(mptr, 0x20)

            let uriLen := sload(uriLenPos())
            mstore(mptr, uriLen)
            mptr := add(mptr, 0x20)

            let bound := div(uriLen, 0x20)
            if mod(bound, 0x20) {
                bound := add(bound, 1)
            }

            mstore(0x00, uriLen)
            let firstSlot := keccak256(0x00, 0x20)

            for { let i := 0 } lt(i, bound) { i := add(i, 1) } {
                let str := sload(add(firstSlot, i))
                mstore(mptr, str)
                mptr := add(mptr, 0x20)
            }

            return(oldMptr, sub(mptr, oldMptr))
        }
        /* -------- external functions ---------- */
        function safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset) {
            _safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset)
        }

        function safeTransferFrom(from, to, id, amount, dataOffset) {
            let fromBalance:= sload(balanceStorageOffset(id, from))
            require(lt(amount, fromBalance))
            _addBalance(to, id, amount)
            _subBalance(from, id, amount)

            emitTransferSingle(caller(), from, to, id, amount)
        }

        function _safeBatchTransferFrom(from, to, idsOffset, amountsOffset, dataOffset) {
            let idsLen := decodeAsArrayLen(idsOffset)
            let amountsLen := decodeAsArrayLen(amountsOffset)

            require(from)

            require(to)

            require(eq(idsLen, amountsLen))

            let firstIdPtr := add(idsOffset, 0x24)
            let firstAmountPtr := add(amountsOffset, 0x24)

            for { let i := 0} lt(i, idsLen) { i := add(i, 1) }
            {
                let id := calldataload(add(firstIdPtr, mul(i, 0x20)))
                let amount := calldataload(add(firstAmountPtr, mul(i, 0x20)))

                let fromBalance := sload(balanceStorageOffset(id, from))

                _subBalance(from, id, amount)
                _addBalance(to, id, amount)

            }
            let operator := caller()

            _doSafeBatchTransferAcceptanceCheck(operator, from, to, idsOffset, amountsOffset, dataOffset)
        }

        function balanceOfBatch(accountsOffset, idsOffset) {
            let accountsLen := decodeAsArrayLen(accountsOffset)
            let idLen := decodeAsArrayLen(idsOffset)

            require(eq(accountsLen, idLen))

            let mptr := 0x80
            mstore(mptr, 0x20) // array offset
            mptr := add(mptr, 0x20)

            mstore(mptr, accountsLen) // array len
            mptr := add(mptr, 0x20)

            let accountsStartOffset := add(accountsOffset, 0x24) // ptr to 1st element of accounts
            let idsStartOffset := add(idsOffset, 0x24) // ptr to 1st elements of ids

            // return array
            for { let i := 0 } lt(i, accountsLen) { i:= add(i, 1)}
            {    
                let account := calldataload(add(accountsStartOffset, mul(0x20, i)))
                let id := calldataload(add(idsStartOffset, mul(0x20, i)))
                mstore(mptr, balanceOf(account, id)) // store i th element
                mptr := add(mptr, 0x20)
            }

            return(0x80, sub(mptr, 0x80))
        }

        function setApprovalForAll(operator, approved) {
            sstore(accountToApprovalStorageOffset(caller(), operator), approved)
        }

        function _doSafeBatchTransferAcceptanceCheck(operator, from, to, id, amount, dataOffset){
          if requireNoRevert(gt(extcodesize(to), 0)) {
                let selector := 0xf23a6e6100000000000000000000000000000000000000000000000000000000 // onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)
                let selectorMemoryPtr := mload(0x40)
                mstore(selectorMemoryPtr, selector)
                mstore(add(selectorMemoryPtr, 0x04), operator)
                mstore(add(selectorMemoryPtr, 0x24), from)
                mstore(add(selectorMemoryPtr, 0x44), id)
                mstore(add(selectorMemoryPtr, 0x64), amount)
                mstore(add(selectorMemoryPtr, 0x84), 0xa0) //0xa0  -->160, 
                let endPtr := copyBytesToMemory(add(selectorMemoryPtr, 0xa4), dataOffset) // Copies 'data' to memory
                mstore(0x40, endPtr)

                mstore(0x00, 0) // clear memory
                if requireNoRevert(call(gas(), to, 0, selectorMemoryPtr, sub(endPtr, selectorMemoryPtr), 0x00, 0x04)) {
                    if gt(returndatasize(), 0x04) {
                        returndatacopy(0x00, 0, returndatasize())
                        revert(0x00, returndatasize())
                    }
                   revert(0, 0)
                }

                // reverts if it does not return proper selector (0xf23a6e61)
                if requireNoRevert(eq(selector, mload(0))) {
                    revert(0, 0)
                }
            }
        }

        function isApprovedForAll(owner, operator) -> approved {
            approved := sload(accountToApprovalStorageOffset(owner, operator))
        }
        function supportsInterface() -> ret {
            let interfaceId := calldataload(0x04)

            let IERC1155InterfaceId := 0xd9b67a2600000000000000000000000000000000000000000000000000000000
            let IERC1155MetdataURIInterfaceId := 0xd9b67a2600000000000000000000000000000000000000000000000000000000
            let IERC165InterfaceId := 0x01ffc9a700000000000000000000000000000000000000000000000000000000

            ret := or(eq(interfaceId, IERC1155InterfaceId), or(eq(interfaceId, IERC1155MetdataURIInterfaceId), eq(interfaceId, IERC165InterfaceId)))
        }

        function setURI(strOffset) {
            _setURI(strOffset)
        }
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

        function batchBurn(from, idsOffset, amountsOffset){
            let idsLength := decodeAsArrayLen(idsOffset)
            let amountsLength := decodeAsArrayLen(amountsOffset)

           require(eq(idsLength, amountsLength))

            let firstIdPtr := add(idsOffset, 0x24)
            let firstAmountPtr := add(amountsOffset, 0x24)

            for { let i := 0} lt(i, idsLength) { i := add(i, 1) }
            {
                let id := calldataload(add(firstIdPtr, mul(i, 0x20)))
                let amount := calldataload(add(firstAmountPtr, mul(i, 0x20)))

                let fromBalance := sload(balanceStorageOffset(id, from))

                _subBalance(from, id, amount)
            }
        }

        function mint(to, id, amount, dataOffset){
            _addBalance(to, id, amount)
        }

        function burn(from, id, amount){
            _subBalance(from, id, amount)
        }

         /* -------- helper functions ---------- */

         function require(condition) {
            if iszero(condition) { revert(0, 0) }
        }

        function requireNoRevert(condition) ->res {
            res := iszero(condition)
        }
        
         /* ----------  calldata decoding ---------- */
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

        function decodeAsBool(offset) -> v {
            let val := decodeAsUint(offset)
            if eq(val, 0x0000000000000000000000000000000000000000000000000000000000000000) {
                v := val
                leave
            }

            if eq(val, 0x0000000000000000000000000000000000000000000000000000000000000001) {
                v := val
                leave
            }

            revert(0, 0)
        }

        function decodeAsArrayLen(offset) -> len {
            len := calldataload(add(offset, 4))
        }
        

         /* ----------  calldata encoding ---------- */
             function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
    
            function returnBool(v) {
                mstore(0, v)
                return(0, 0x20)
            }

            /* ----------  events ---------- */
            function emitTransferSingle(operator, from, to , id, value) {
                let eventSignature := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                mstore(0x00, id)
                mstore(0x20, value)

                log4(0x00, 0x20, eventSignature, operator, from, to)
            }

            function emitTransferBatch(operator, from, to, idsOffset, valuesOffset) {
                /* TransferBatch(address,address,address,uint256[],uint256[]) */
                let signatureHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb

                let freeMemoryPointer := mload(0x40)

                let idsOffsetPtr := freeMemoryPointer
                let valuesOffsetPtr := add(freeMemoryPointer, 0x20)

                mstore(idsOffsetPtr, 0x40) // ids offset

                let valuesPtr := copyArrayToMemory(add(freeMemoryPointer, 0x40), idsOffset) // copy ids array to memory

                mstore(valuesOffsetPtr, sub(valuesPtr, freeMemoryPointer)) // store values Offset
                let endPtr := copyArrayToMemory(valuesPtr, valuesOffset) // copy values array to memory

                log4(freeMemoryPointer, sub(endPtr, freeMemoryPointer), signatureHash, operator, from, to)

                mstore(0x40, endPtr) // update Free Memory Pointer
            }

            function emitApprovalForAll(owner, operator, approved) {
                /* ApprovalForAll(adderss,address,bool) */
                let signatureHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                mstore(0x00, approved)
                log3(0x00, 0x20, signatureHash, owner, operator)
            }

           function emitURI (value, id) {
            //   event URI(string value, uint256 indexed id);
                let signatureHash := 0x7e15c9e84aa0e17b53edaaf59cf4a1ce70dc34cdadd644913e94732dd1c1c150
                let freeMemoryPointer := mload(0x40)
                //infer string length
                
                mstore(freeMemoryPointer, value)
                log2(0x00, 0x20, signatureHash, id)
            }

            /* ----------  utils ---------- */  

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


        function copyBytesToMemory(mptr, dataOffset) -> newMptr {
            let dataLenOffset := add(dataOffset, 4)
            let dataLen := calldataload(dataLenOffset)

            let totalLen := add(0x20, dataLen) // dataLen+data
            let remainder := mod(dataLen, 0x20)
            if remainder {
                totalLen := add(totalLen, sub(0x20, remainder))
            }
            calldatacopy(mptr, dataLenOffset, totalLen)

            newMptr := add(mptr, totalLen)
        }

        function copyArrayToMemory(mptr, arrayOffset) -> newMptr {
            let arrayLen := calldataload(add(arrayOffset, 4))
            let arrayDataOffset := add(arrayOffset, 0x24)

            let totalLen := add(0x20, mul(arrayLen, 0x20)) // arrayLen+array
            calldatacopy(mptr, arrayDataOffset, totalLen)

            newMptr := add(mptr, totalLen)
        }

            /* ----------  Revert string functions ---------- */
            function revertMintToTheZeroAddress() {
                /* "ERC1155: mint to the zero address" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 33)
                mstore(add(mptr, 0x44), 0x455243313135353a206d696e7420746f20746865207a65726f20616464726573)
                mstore(add(mptr, 0x64), 0x7300000000000000000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertZeroAddressOwnerIsNotAValidOwner() {
                /* "ERC1155: address zero is not a valid owner" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 42)
                mstore(add(mptr, 0x44), 0x455243313135353a2061646472657373207a65726f206973206e6f7420612076)
                mstore(add(mptr, 0x64), 0x616c6964206f776e657200000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertAccountsAndIdsLengthMismatch() {
                /* "ERC1155: accounts and ids length mismatch" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 41)
                mstore(add(mptr, 0x44), 0x455243313135353a206163636f756e747320616e6420696473206c656e677468)
                mstore(add(mptr, 0x64), 0x206d69736d617463680000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertIdsAndAmountsLengthMismatch() {
                /* "ERC1155: ids and amounts length mismatch" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 40)
                mstore(add(mptr, 0x44), 0x455243313135353a2069647320616e6420616d6f756e7473206c656e67746820)
                mstore(add(mptr, 0x64), 0x6d69736d61746368000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertSettingApprovalStatusForSelf() {
                /* "ERC1155: setting approval status for self" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 41)
                mstore(add(mptr, 0x44), 0x455243313135353a2073657474696e6720617070726f76616c20737461747573)
                mstore(add(mptr, 0x64), 0x20666f722073656c660000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertInsufficientBalanceForTransfer() {
                /* "ERC1155: insufficient balance for transfer" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 42)
                mstore(add(mptr, 0x44), 0x455243313135353a20696e73756666696369656e742062616c616e636520666f)
                mstore(add(mptr, 0x64), 0x72207472616e7366657200000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertTransferToTheZeroAddress() {
                /* "ERC1155: transfer to the zero address" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 37)
                mstore(add(mptr, 0x44), 0x455243313135353a207472616e7366657220746f20746865207a65726f206164)
                mstore(add(mptr, 0x64), 0x6472657373000000000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertCallerIsNotTokenOwnerOrApproved() {
                /* "ERC1155: caller is not token owner or approved" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 46)
                mstore(add(mptr, 0x44), 0x455243313135353a2063616c6c6572206973206e6f7420746f6b656e206f776e)
                mstore(add(mptr, 0x64), 0x6572206f7220617070726f766564000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertERC1155ReceiverRejectedTokens() {
                /* "ERC1155: ERC1155Receiver rejected tokens" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 40)
                mstore(add(mptr, 0x44), 0x455243313135353a204552433131353552656365697665722072656a65637465)
                mstore(add(mptr, 0x64), 0x6420746f6b656e73000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertTransferToNonERC1155ReceiverImplementer() {
                /* "ERC1155: transfer to non-ERC1155Receiver implementer" */
                let mptr := 0x80
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 52)
                mstore(add(mptr, 0x44), 0x455243313135353a207472616e7366657220746f206e6f6e2d45524331313535)
                mstore(add(mptr, 0x64), 0x526563656976657220696d706c656d656e746572000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertBurnFromTheZeroAddrss() {
                /* "ERC1155: burn from the zero address" */
                let mptr := 0x00
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 35)
                mstore(add(mptr, 0x44), 0x455243313135353a206275726e2066726f6d20746865207a65726f2061646472)
                mstore(add(mptr, 0x64), 0x6573730000000000000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

            function revertBurnAmountExceedsBalance() {
                /* "ERC1155: burn amount exceeds balance" */
                let mptr := 0x00
                mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(mptr, 0x04), 0x20)
                mstore(add(mptr, 0x24), 36)
                mstore(add(mptr, 0x44), 0x455243313135353a206275726e20616d6f756e7420657863656564732062616c)
                mstore(add(mptr, 0x64), 0x616e636500000000000000000000000000000000000000000000000000000000)
                revert(mptr, 0x84)
            }

    }
    }
}