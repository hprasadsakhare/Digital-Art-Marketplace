// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalArtMarketplace {
    struct Artwork {
        uint256 id;
        address payable artist;
        string title;
        uint256 price;
        bool isForSale;
    }

    mapping(uint256 => Artwork) public artworks;
    uint256 public artworkCount;

    event ArtworkListed(uint256 id, address artist, string title, uint256 price);
    event ArtworkSold(uint256 id, address seller, address buyer, uint256 price);

    function listArtwork(string memory _title, uint256 _price) external {
        require(_price > 0, "Price must be greater than 0");
        artworkCount++;
        artworks[artworkCount] = Artwork(artworkCount, payable(msg.sender), _title, _price, true);
        emit ArtworkListed(artworkCount, msg.sender, _title, _price);
    }

    function buyArtwork(uint256 _id) external payable {
        Artwork storage artwork = artworks[_id];
        require(artwork.isForSale, "Artwork is not for sale");
        require(msg.value >= artwork.price, "Insufficient payment");

        address payable seller = artwork.artist;
        uint256 price = artwork.price;

        artwork.artist = payable(msg.sender);
        artwork.isForSale = false;

        seller.transfer(price);
        emit ArtworkSold(_id, seller, msg.sender, price);

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function updateArtworkPrice(uint256 _id, uint256 _newPrice) external {
        Artwork storage artwork = artworks[_id];
        require(msg.sender == artwork.artist, "Only the artist can update the price");
        require(_newPrice > 0, "Price must be greater than 0");

        artwork.price = _newPrice;
        artwork.isForSale = true;
    }
}