// Copyright 2024 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ImageID} from "./ImageID.sol"; // auto-generated contract after running `cargo build`.

contract Verifier {
    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;
    /// @notice Image ID of the only zkVM binary to accept verification from.
    bytes32 public constant imageId = ImageID.IS_EVEN_ID;

    // Mapping that shows when the user's location has been verified.
    mapping(address => mapping(bool => uint256)) public locationVerified;

    /// @notice Initialize the contract, binding it to a specified RISC Zero verifier.
    constructor(IRiscZeroVerifier _verifier) {
        verifier = _verifier;
    }

    /// @notice Using bytes since floating point numbers are not supported in Solidity.
    function verifyLocation(
        bytes32 start_long,
        bytes32 start_lat,
        bytes32 dest_long,
        bytes32 dest_lat,
        bytes32 distance,
        bytes32 postStateDigest,
        bytes calldata seal
    ) public {
        require(start_long != bytes32(0), "Verifier: invalid start_long");
        require(start_lat != bytes32(0), "Verifier: invalid start_lat");
        require(dest_long != bytes32(0), "Verifier: invalid dest_long");
        require(dest_lat != bytes32(0), "Verifier: invalid dest_lat");
        require(distance != bytes32(0), "Verifier: invalid distance");
        // Construct the expected journal data. Verify will fail if journal does not match.
        bytes memory journal = abi.encode(start_long, start_lat, dest_long, dest_lat, distance);
        require(verifier.verify(seal, imageId, postStateDigest, sha256(journal)), "Verifier: invalid proof");
        locationVerified[msg.sender][true] = block.timestamp;
    }
}
