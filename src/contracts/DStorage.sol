pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract DStorage {
    string public name = "DStorage";
    uint256 public fileCount = 0;
    mapping(uint256 => File) public files;
    mapping(address => User) users;
    struct File {
        uint256 fileId;
        string fileHash;
        uint256 fileSize;
        string fileType;
        string fileName;
        string fileDescription;
        uint256 uploadTime;
        address payable uploader;
    }

    struct User {
        address userAddress;
        string email;
        string password;
    }

    event FileUploaded(
        uint256 fileId,
        string fileHash,
        uint256 fileSize,
        string fileType,
        string fileName,
        string fileDescription,
        uint256 uploadTime,
        address payable uploader
    );

    constructor() public {}

    function createUser(
        address _addr,
        string memory email,
        string memory password
    ) public {
        User memory user = User(_addr, email, password);
        users[_addr] = user;
    }

    function getUser(
        address _addr,
        string memory email,
        string memory password
    ) public view returns (User memory) {
        User memory user = users[_addr];
        if (
            compareStrings(user.email, email) &&
            compareStrings(user.password, password)
        ) {
            return user;
        } else {
            return User(address(0), "", "");
        }
    }

    function uploadFile(
        string memory _fileHash,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName,
        string memory _fileDescription
    ) public {
        // Make sure the file hash exists
        require(bytes(_fileHash).length > 0);
        // Make sure file type exists
        require(bytes(_fileType).length > 0);
        // Make sure file description exists
        require(bytes(_fileDescription).length > 0);
        // Make sure file fileName exists
        require(bytes(_fileName).length > 0);
        // Make sure uploader address exists
        require(msg.sender != address(0));
        // Make sure file size is more than 0
        require(_fileSize > 0);

        // Increment file id
        fileCount++;

        // Add File to the contract
        files[fileCount] = File(
            fileCount,
            _fileHash,
            _fileSize,
            _fileType,
            _fileName,
            _fileDescription,
            now,
            msg.sender
        );
        // Trigger an event
        emit FileUploaded(
            fileCount,
            _fileHash,
            _fileSize,
            _fileType,
            _fileName,
            _fileDescription,
            now,
            msg.sender
        );
    }

    function getFiles() public view returns (File[] memory filteredFiles) {
        File[] memory filesTemp = new File[](fileCount);
        uint256 count = 0;

        for (uint256 i = 0; i < fileCount; i++) {
            if (files[i].uploader == msg.sender) {
                filesTemp[count] = files[i];
                count += 1;
            }
        }

        filteredFiles = new File[](count);
        for (uint256 i = 0; i < count; i++) {
            filteredFiles[i] = filesTemp[i];
        }
    }

    function compareStrings(string memory a, string memory b)
        public
        view
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
