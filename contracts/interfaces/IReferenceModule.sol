// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @title IReferenceModule
 * @author Lens Protocol
 *
 * @notice This is the standard interface for all Lens-compatible ReferenceModules.
 */
interface IReferenceModule {
    // function getModuleVersion() external view returns (uint256);

    // function processModuleChange(
    // uint256 profileId,
    // uint256 pubId,
    // bytes calldata data
    // ) external;

    /**
     * @notice Initializes data for a given publication being published. This can only be called by the hub.
     *
     * @param profileId The token ID of the profile publishing the publication.
     * @param executor The owner or an approved delegated executor.
     * @param pubId The associated publication's LensHub publication ID.
     * @param data Arbitrary data passed from the user to be decoded.
     *
     * @return bytes An abi encoded byte array encapsulating the execution's state changes. This will be emitted by the
     * hub alongside the collect module's address and should be consumed by front ends.
     */
    function initializeReferenceModule(
        uint256 profileId,
        address executor,
        uint256 pubId,
        bytes calldata data
    ) external returns (bytes memory);

    /**
     * @notice Processes a comment action referencing a given publication. This can only be called by the hub.
     *
     * @param profileId The token ID of the profile associated with the publication being published.
     * @param executor The commenter or an approved delegated executor.
     * @param profileIdPointed The profile ID of the profile associated the publication being referenced.
     * @param pubIdPointed The publication ID of the publication being referenced.
     * @param referrerProfileId The profile ID of the profile that referred the commenter via mirror.
     * @param data Arbitrary data __passed from the commenter!__ to be decoded.
     */
    function processComment(
        uint256 profileId,
        address executor,
        uint256 profileIdPointed,
        uint256 pubIdPointed,
        uint256 referrerProfileId,
        bytes calldata data
    ) external;

    /**
     * @notice Processes a mirror action referencing a given publication. This can only be called by the hub.
     *
     * @param profileId The token ID of the profile associated with the publication being published.
     * @param executor The mirror creator or an approved delegated executor.
     * @param profileIdPointed The profile ID of the profile associated the publication being referenced.
     * @param pubIdPointed The publication ID of the publication being referenced.
     * @param data Arbitrary data __passed from the mirrorer!__ to be decoded.
     */
    function processMirror(
        uint256 profileId,
        address executor,
        uint256 profileIdPointed,
        uint256 pubIdPointed,
        bytes calldata data
    ) external;
}
