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
   
   uint public myEtherValue=1 ether; // to convert any given value to ether
 
  event productCreated(
        address owner,
        uint price,
        bool isSold,
        string name,
        uint productId,
        bool isCompleted,
        uint productCount
      );
     
   mapping (address => product[]) products;
   mapping( string => component[]) components;
   
   mapping(string=>string[]) productToComponentMapping;
    
   
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
    
    
  
  
  	     function orderCompleted(uint _orderId) public payable // change according to manufacturer
    {
        Order memory order1=partnerOrders[msg.sender][_orderId];
        order1.status="completed";
        string memory _Componentname = order1.name; // to set the inventory of component we have fetched component name from
        inventory memory inventory1= companyInventory[companyAddress][_Componentname];
        inventory1.productCount=inventory1.productCount+ order1.quantity;
        companyInventory[companyAddress][_Componentname] = inventory1;
        component memory component1=fetchIndividualComponent[msg.sender][order1.name];
        component1.owner = companyAddress;
        fetchIndividualComponent[companyAddress][component1.componentName]=component1;
        msg.sender.transfer(order1.orderPayment);       // transfer payment to the manufacturer
        component1.owner=companyAddress;
    }
   
   
    function createProduct(string memory _productName, uint _makingPrice) public // product created by the company
    {
           inventory memory inventory1= companyInventory[msg.sender][_productName]; // fetching initial inventory
           require(msg.sender==companyAddress);
           uint price=0;
           string[] memory ingredients = productToComponentMapping[_productName];
           
           for (uint i = 0; i < ingredients.length; i++)
           {
           inventory memory ingredientInventory = companyInventory[msg.sender][ingredients[i]];
           require(ingredientInventory.productCount>0);
           ingredientInventory.productCount = ingredientInventory.productCount-1;
           components[_productName].push(manuComponent[ingredients[i]]);
           companyInventory[msg.sender][ingredients[i]]=ingredientInventory;
           price = price+fetchIndividualComponent[msg.sender][ingredients[i]].price;
           }
   
        product memory product1;
       
        product1.name=_productName;
        product1.owner=msg.sender;
        _makingPrice=_makingPrice*myEtherValue;
        product1.price=price+_makingPrice;
        product1.isSold=false;
        product[] memory productsList = products[msg.sender]; // for adding product to the product list.
        product1.productId=productsList.length+1;
        product1.isCompleted=true;
        inventory1.productCount=inventory1.productCount+1; // increasing inventory
       
        products[msg.sender].push(product1);
        companyInventory[msg.sender][_productName]=inventory1;
        emit productCreated(product1.owner,product1.price,product1.isSold,product1.name, product1.productId,product1.isCompleted,inventory1.productCount);
       
       
    }
   
   
  
    
}
