// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Strings.sol";

contract Dtube {
    
    struct Video {
        uint id;
        string name;
        uint noofpeopleviewed;
        uint likes;
        uint dislikes;
        string url;
    }
    
    struct Subscriber {
        uint id;
        address addr;
        string name;
        string email;
        string[] subcribedchannels;
        uint tokenbalance;
    }
    
    
    struct Youtuber {
        uint id;
        address addr;
        string youtubername;
        string channelname;
        string email;
        uint[] videoid;
        uint[] subcribers;
        uint tokenbalance;
    }
    
    
    uint public  TotalToken;
    uint public TokenPerEther = 100;
    
    mapping(address => uint) public subscriberBalances;
    
    constructor() {
        TotalToken = 10 ** 10;
    }
    
    uint public youtuberCount = 0;
    uint public videoCount = 0;
    uint public subscriberCount = 0;
    
    mapping(uint => Youtuber) youtuberList;
    mapping(uint => Subscriber) subscriberList;

    mapping(string => Youtuber) youtubeChannels;
    mapping(string => bool) channelsnameAlreadyExists;
    mapping(address => bool) youtuberalreadyRegistered;
    mapping(address => bool) subscriberalreadyRegistered;
    mapping(address => mapping(uint => bool)) alreadyLiked;
    mapping(address => mapping(uint => bool)) alreadyDisliked;
    mapping(address => mapping(string => bool)) alreadySubscribed;
    mapping(uint => Video) videoList;
    mapping(address => mapping(uint => bool)) alreadyViewed;
    mapping(address => uint[]) myVideos;
    
    
    function BuyToken() payable  public {
        
        require(subscriberalreadyRegistered[msg.sender] == true , "you are not a subscriber in Dtube");
        require( msg.value >= 1 ether , "Please Take atleast 1 ether");
        
        subscriberBalances[msg.sender] += (msg.value/10 ** 18) * TokenPerEther;
        TotalToken -= (msg.value/10 ** 18) * TokenPerEther;
        
        }
    
    
     function TransferTokenToYoutubeChannel(uint _tokenToTransfer , string memory _channelname) payable public {
    
        require(youtuberalreadyRegistered[youtubeChannels[_channelname].addr] == true , "Channel is not present");
        require(subscriberalreadyRegistered[msg.sender] == true , "Subscriber is not present");
        require(subscriberBalances[msg.sender] >= _tokenToTransfer , "Your balance is insufficient to transfer");
        subscriberBalances[msg.sender] -= _tokenToTransfer;
        youtubeChannels[_channelname].tokenbalance  += _tokenToTransfer;
    }
    
    
   
    
    
    function registerAsYoutuber(string memory _name, string memory _email , string memory _channelname) public {
        
      
        require(bytes(_name).length >= 1 , "name is invalid");
        require(bytes(_channelname).length >= 1 , "channelname is invalid");
        require(youtuberalreadyRegistered[msg.sender] == false , "Youtuber already registered");
        require(channelsnameAlreadyExists[_channelname] == false , "channel name already exists please try other channel name");
        
        youtuberList[youtuberCount] = Youtuber(youtuberCount , msg.sender ,  _name , _channelname ,  _email , new uint[](0) , new uint[](0) , 0);
        
        youtubeChannels[_channelname] =  youtuberList[youtuberCount];
        
        youtuberCount++;
        youtuberalreadyRegistered[msg.sender] = true;
        channelsnameAlreadyExists[_channelname] = true;
    }
    
    function registerAsSubscriber(string memory _name , string memory _email) public {
        
        require(bytes(_name).length >= 1 , "name is invalid");
        require(subscriberalreadyRegistered[msg.sender] == false , "Subcriber already registered");
        
        subscriberList[subscriberCount] = Subscriber(subscriberCount , msg.sender ,  _name ,   _email , new string[](0) , 0);
        subscriberCount++;
        subscriberalreadyRegistered[msg.sender] = true;
        
        
    }
    
    function viewYoutuber(uint index) public view returns(string memory youtubername,string memory channelname,uint[] memory videoid, uint[] memory subcribers ){
        
         require(index >=0 && index <youtuberCount , "index is inValid");
         Youtuber memory c = youtuberList[index];
         return (c.youtubername, c.channelname , c.videoid ,  c.subcribers);
    }
    
    
    function uploadVideo(string memory _name )  public {
        require(youtuberalreadyRegistered[msg.sender] == true , "You don't have a channel to upload");
       
        videoList[videoCount] = Video(videoCount , _name , 0 , 0 ,0 ,Strings.concat("https://Dtube.com",_name));
        myVideos[msg.sender].push(videoCount);
        videoCount++;
        
    }
    
    function likeVideo(uint _videoId) public  {
        
        require(alreadyLiked[msg.sender][_videoId] == false ,  "You already liked the video");
        
        videoList[_videoId].likes +=1;
        
        alreadyLiked[msg.sender][_videoId] = true;
        
    }
    
    function dislikeVideo(uint _videoId) public  {
        
        require(alreadyDisliked[msg.sender][_videoId] == false ,  "You already disliked the video");
        
        videoList[_videoId].dislikes +=1;
        
        alreadyDisliked[msg.sender][_videoId] = true;
        
    }
    
    function viewVideo( uint _videoId) public {
        if(alreadyViewed[msg.sender][_videoId] == false){
             videoList[_videoId].noofpeopleviewed +=1;
             alreadyViewed[msg.sender][_videoId] = true;
        }
    }
    
    function noOfLikesForVideo(uint _videoId) public view returns(uint) {
        return videoList[_videoId].likes;
    }
    
     function noOfDislikesForVideo(uint _videoId) public view returns(uint) {
        return videoList[_videoId].dislikes;
    }
    
    function noOfViewersForVideo(uint _videoId) public view  returns(uint) {
        return videoList[_videoId].noofpeopleviewed;
    }
    
    
    function subscribeChannel(uint id , string memory _channelname)  public {
      
        require(alreadySubscribed[msg.sender][_channelname] == false, "You have already subcribed the same channel");
        subscriberList[id].subcribedchannels.push(_channelname);
        alreadySubscribed[msg.sender][_channelname] = true;
        youtubeChannels[_channelname].subcribers.push(id);
        
      
        
    }
    
    function getNumberOfSubcribers(string memory _channelname) public view returns(uint){
        return youtubeChannels[_channelname].subcribers.length;
    }
    
    function getTrendingVideo() public view returns(uint){
        uint c = 0;
        uint trendingvideoid = 0;
        for(uint i =0 ; i < videoCount ; i++){
            if(videoList[i].noofpeopleviewed > c){
                c = videoList[i].noofpeopleviewed;
                trendingvideoid = videoList[i].id;
            }
        }
        
        return trendingvideoid;
    }
}


















