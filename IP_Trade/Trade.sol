// SPDX-License-Identifier: MIT
pragma solidity^0.8.7; 


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

}

//       作品id、作者（发行方）、买家、描述、价格、状态、时间戳
struct WorkInfo{
    address author;
    address buyer;
    string desc;
    uint256 price;
    uint8 status;//0-出售中 1-下单 2-确认卖出 
    uint256 timestamp;
}


contract Trade {
    WorkInfo[] works;
    address token;
    uint8 constant WORK_ONSALE = 0;
    uint8 constant WORK_ORDER = 1;
    uint8 constant WORK_SOLD = 2;
    uint256 constant FAUCETS = 100;
    mapping (address => bool) alreadyFaucets;

    event WorkIssue(address indexed  _author, uint256 _price,string _desc );

    constructor(address _token) {
        token = _token;
    }


    //1.发布作品函数
    function issue(string memory _desc, uint256 _price) public {
        require(_price > 0, "price <= 0");
        require(bytes(_desc).length >0, "desc is null");
        
        WorkInfo memory work = WorkInfo(msg.sender,address(0),_desc,_price,WORK_ONSALE,block.timestamp);
        works.push(work);
        emit WorkIssue(msg.sender, _price, _desc);

    }


    //2.下单作品函数
    function order(uint256 _index) public  {
        require(_index < works.length,"index put of range");
        require(works[_index].status ==WORK_ONSALE , "work's status invalid");
        require(works[_index].buyer == address(0), "work's buyer already exists");
        WorkInfo storage work = works[_index];
        require(IERC20(token).balanceOf(msg.sender)>work.price,"buyer's balance not enough");
        work.buyer = msg.sender;
        work.status = WORK_ORDER;

    }
   
    //4.确认卖出作品函数函数
    function sold(uint256 _index) public  {
        require(_index < works.length,"index put of range");
        require(works[_index].status ==WORK_ORDER , "work's status invalid");
        require(works[_index].author == msg.sender, "only work's author can do");

        WorkInfo storage work = works[_index];
        work.status = WORK_SOLD;
        //付款--买家（付款方，要给Trade合约授权转账功能）
        IERC20(token).transferFrom(work.buyer,work.author,work.price);

    }

    //5. 查看某一作品的信息
    function getOnework(uint256 _index) public view  returns (WorkInfo memory){
        return works[_index];
    }

    //6. 查看所有任务的信息
    function getAllworks() public view  returns (WorkInfo[] memory){
        return works;
    }

    //7.注册送//申请水龙头需要合约中有钱 所以要先给合约转点钱
    function register() public  {
        require(!alreadyFaucets[msg.sender], "user already call faucets");
        alreadyFaucets[msg.sender] =true;
        IERC20(token).transfer(msg.sender,FAUCETS);
    }
}