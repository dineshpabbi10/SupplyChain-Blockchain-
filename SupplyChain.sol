pragma solidity  >=0.5.0 ;


contract SupplyChain
{
    
    string public company_name;
    
    address payable companyAddress;
    
        struct Order{
       
        string name;
        uint quantity;
        string status;
        uint orderId;
        uint orderPayment;
       
       
    }
    
        struct component{
        address owner;
        uint price;
        //bool isSold;
        //uint componentId;
        string componentName;
        string manufacturer;
   

    }
    
       
       struct product{
        address owner;
        uint price;
        bool isSold;
        string name;
        uint productId;
        bool isCompleted; // TO BE MADE INTO ENUM
    // component[] components;
    }
    
      struct partners
    {
        string Partnername;
        //address payable partner;
       
       
       
    }
    
    
      struct inventory
    {
        uint productCount;
        uint cotton;
        uint shirt;
        uint pants;
        uint tshirt;
   
       
    }
   
   mapping(address=>mapping(string =>component)) fetchIndividualComponent;
   
   mapping(address => partners) companies;
   
   mapping(string => component) manuComponent;
   
   mapping(address=>Order[]) partnerOrders;
   
   mapping(address=>mapping(string=>inventory)) companyInventory;
   
   
   
      event orderCreated
      (
          string name,
          uint quantity,
          string status,
          uint orderId
         
         );
         
         
            event orderStatus
        (
             string name,
          uint quantity,
          string status,
          uint orderId
            );
   
   
function giveOrder(string memory _Componentname, uint number, address _partnerCompany)public payable
    {
       
//Order memory order1= partnerOrders[_partnerCompany][_orderId]; // we assume har ek product ki id oth company n manufacturer know
       
        Order memory order1;
        order1.status="pending";
        order1.quantity=number;
        order1.name=_Componentname;
        
          component memory component1=fetchIndividualComponent[msg.sender][order1.name];
        component1.price=1 ether;// change price and make contsnats on top
        component1.componentName = order1.name;
        component1.owner = _partnerCompany;
        component1.manufacturer = companies[_partnerCompany].Partnername;
        fetchIndividualComponent[component1.owner][component1.componentName]=component1;
        manuComponent[_Componentname]=component1;
        uint totalPrice = component1.price*order1.quantity;
        require(msg.value==totalPrice);
        order1.orderPayment=msg.value;
         Order[] memory orders= partnerOrders[_partnerCompany];
          order1.orderId=orders.length+1;
        partnerOrders[_partnerCompany].push(order1);
       
       // to let company know of his Id of
     
     emit orderCreated(order1.name, order1.quantity,order1.status,order1.orderId);
       
    }
   
   
    function orderInProgress(uint _orderId) public
    {
        Order memory order1= partnerOrders[msg.sender][_orderId];
        order1.status="inProgress";
        emit orderStatus(order1.name,order1.quantity,order1.status,order1.orderId);
       
    }
   
   
  
    
}