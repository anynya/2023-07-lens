// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './base/BaseTest.t.sol';

contract PublishingTest is BaseTest {
    // negatives
    function testPostNotExecutorFails() public {
        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.post(mockPostData);
    }

    function testCommentNotExecutorFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.comment(mockCommentData);
    }

    function testMirrorNotExecutorFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.mirror(mockMirrorData);
    }

    // positives
    function testExecutorPost() public {
        vm.prank(profileOwner);
        hub.setDelegatedExecutorApproval(otherSigner, true);

        vm.prank(otherSigner);
        uint256 pubId = hub.post(mockPostData);
        assertEq(pubId, 1);
    }

    function testExecutorComment() public {
        vm.startPrank(profileOwner);
        hub.post(mockPostData);
        hub.setDelegatedExecutorApproval(otherSigner, true);
        vm.stopPrank();

        vm.prank(otherSigner);
        uint256 pubId = hub.comment(mockCommentData);
        assertEq(pubId, 2);
    }

    function testExecutorMirror() public {
        vm.startPrank(profileOwner);
        hub.post(mockPostData);
        hub.setDelegatedExecutorApproval(otherSigner, true);
        vm.stopPrank();

        vm.prank(otherSigner);
        uint256 pubId = hub.mirror(mockMirrorData);
        assertEq(pubId, 2);
    }

    // Meta-tx
    // Negatives
    function testPostWithSigInvalidSignerFails() public {
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getPostTypedDataHash(
            firstProfileId,
            mockURI,
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.SignatureInvalid.selector);
        hub.postWithSig(
            DataTypes.PostWithSigData({
                delegatedSigner: address(0),
                profileId: firstProfileId,
                contentURI: mockURI,
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    function testPostWithSigNotExecutorFails() public {
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getPostTypedDataHash(
            firstProfileId,
            mockURI,
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.postWithSig(
            DataTypes.PostWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                contentURI: mockURI,
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    function testCommentWithSigInvalidSignerFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getCommentTypedDataHash(
            firstProfileId,
            mockURI,
            firstProfileId,
            1,
            '',
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.SignatureInvalid.selector);
        hub.commentWithSig(
            DataTypes.CommentWithSigData({
                delegatedSigner: address(0),
                profileId: firstProfileId,
                contentURI: mockURI,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    function testCommentWithSigNotExecutorFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getCommentTypedDataHash(
            firstProfileId,
            mockURI,
            firstProfileId,
            1,
            '',
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.commentWithSig(
            DataTypes.CommentWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                contentURI: mockURI,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    function testMirrorWithSigInvalidSignerFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getMirrorTypedDataHash(
            firstProfileId,
            firstProfileId,
            1,
            '',
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.SignatureInvalid.selector);
        hub.mirrorWithSig(
            DataTypes.MirrorWithSigData({
                delegatedSigner: address(0),
                profileId: firstProfileId,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    function testMirrorWithSigNotExecutorFails() public {
        vm.prank(profileOwner);
        hub.post(mockPostData);

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getMirrorTypedDataHash(
            firstProfileId,
            firstProfileId,
            1,
            '',
            address(0),
            '',
            nonce,
            deadline
        );

        vm.expectRevert(Errors.ExecutorInvalid.selector);
        hub.mirrorWithSig(
            DataTypes.MirrorWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
    }

    // Positives
    function testExecutorPostWithSig() public {
        vm.prank(profileOwner);
        hub.setDelegatedExecutorApproval(otherSigner, true);

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getPostTypedDataHash(
            firstProfileId,
            mockURI,
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        uint256 pubId = hub.postWithSig(
            DataTypes.PostWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                contentURI: mockURI,
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
        assertEq(pubId, 1);
    }

    function testExecutorCommentWithSig() public {
        vm.startPrank(profileOwner);
        hub.setDelegatedExecutorApproval(otherSigner, true);
        hub.post(mockPostData);
        vm.stopPrank();

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getCommentTypedDataHash(
            firstProfileId,
            mockURI,
            firstProfileId,
            1,
            '',
            address(freeCollectModule),
            abi.encode(false),
            address(0),
            '',
            nonce,
            deadline
        );

        uint256 pubId = hub.commentWithSig(
            DataTypes.CommentWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                contentURI: mockURI,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                collectModule: address(freeCollectModule),
                collectModuleInitData: abi.encode(false),
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
        assertEq(pubId, 2);
    }

    function testExecutorMirrorWithSig() public {
        vm.startPrank(profileOwner);
        hub.setDelegatedExecutorApproval(otherSigner, true);
        hub.post(mockPostData);
        vm.stopPrank();

        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;
        bytes32 digest = _getMirrorTypedDataHash(
            firstProfileId,
            firstProfileId,
            1,
            '',
            address(0),
            '',
            nonce,
            deadline
        );

        uint256 pubId = hub.mirrorWithSig(
            DataTypes.MirrorWithSigData({
                delegatedSigner: otherSigner,
                profileId: firstProfileId,
                profileIdPointed: firstProfileId,
                pubIdPointed: 1,
                referenceModuleData: '',
                referenceModule: address(0),
                referenceModuleInitData: '',
                sig: _getSigStruct(otherSignerKey, digest, deadline)
            })
        );
        assertEq(pubId, 2);
    }
}
