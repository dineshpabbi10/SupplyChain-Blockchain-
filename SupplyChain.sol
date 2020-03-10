pragma solidity  >=0.5.0 ;


contract SupplyChain
{
    
    string public company_name;
    
    address payable companyAddress;
    uint distributor_profit2=1 ether;
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
    }
    
      struct partners
    {
        string Partnername;     
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
   uint retailer_profit2=1 ether;
   
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
            
            
      event orderCreatedforCompany(
        string name,
        uint quantity,
        string status,
        uint orderId,
        uint orderPayment
        );
   
       event orderCreatedfordistributor(
        string name,
        uint quantity,
        string status,
        uint orderId,
        uint orderPayment   
        );
        
function giveOrder(string memory _Componentname, uint number, address _partnerCompany)public payable
    {
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
    
    
      
  // This function is used to set menu for product components' name in a product
  
   function setProductComponents() public returns(string memory){
        productToComponentMapping["DesignedShirt"].push("rawShirt");
        productToComponentMapping["DesignedShirt"].push("thread");
        return "components have been set";
       }
    
    // The distributor sends his requirement to the company, mentioning the productname and quantity required
     function distributorRequirement(string memory _productName, uint quantity) public payable{
        product[] memory productList= products[companyAddress];
   
         Order memory order1;
        order1.status="pending";
        order1.quantity=quantity;
        order1.name=_productName;
       
        uint totalPrice = 0;
       
        for (uint i = 0; i < productList.length; i++) {
        
            product memory product1=products[companyAddress][i];
            string memory productOrderedName = product1.name;
            if( (keccak256(abi.encodePacked((productOrderedName))) == keccak256(abi.encodePacked((_productName))) ))
            {
                totalPrice=products[companyAddress][i].price*quantity;
            }
   
        }
       
        require(msg.value==totalPrice);
        order1.orderPayment=msg.value;
        partnerOrders[companyAddress].push(order1);
     emit orderCreatedforCompany(order1.name, order1.quantity,order1.status,order1.orderId,order1.orderPayment);
       
    }
    
    // The Company checks stock available for the distributor's order and sends the products to the distributor and pays the transportation fees 
   
     function checkStock(uint _orderId, address _distributor,address payable _transporter ) public payable{ // change according to new manufacturer 2 layer
    
        Order memory order1=partnerOrders[msg.sender][_orderId];
        order1.status="completed";
        string memory _productOrderedName = order1.name; // to set the inventory of component we have fetched component name from
        inventory memory inventory1= companyInventory[companyAddress][order1.name];
        inventory1.productCount=inventory1.productCount- order1.quantity;
        companyInventory[companyAddress][_productOrderedName] = inventory1;
        partnerOrders[msg.sender][_orderId]=order1;
        msg.sender.transfer(order1.orderPayment);
       
        inventory memory inventory2= companyInventory[_distributor][order1.name];
        inventory2.productCount=inventory2.productCount+1;
        
        companyInventory[_distributor][order1.name]=inventory2;
     
        uint transportation_cost=order1.orderPayment/100; // he should know what transportation he has to pay
       
        
        product memory product2= products[companyAddress][_orderId];
        product2.owner=_distributor;
        product2.price=product2.price+distributor_profit2;
        
        products[_distributor].push(product2);
        
        transportStocktoDistributor(transportation_cost,_transporter,_distributor, order1.name ) ;
      }
   
   //This function is used by the company which is automatically called to pay the transporter account
   
    function transportStocktoDistributor(uint _transportationcost, address payable transporteraddress, address _distributor, string memory _name) public payable
    {
       
        transporteraddress.transfer(_transportationcost);
    }
   
     function retailerRequirement(string memory _productName, uint quantity, address _distributor) public payable
    {
       
        product[] memory productList= products[_distributor];
        Order memory order1;
        order1.status="pending";
        order1.quantity=quantity;
        order1.name=_productName;
       
        uint totalPricetoRetailer = 0;
       
        for (uint i = 0; i < productList.length; i++) {
            product memory product1=products[_distributor][i];
            string memory productOrderedName = product1.name;
            if( (keccak256(abi.encodePacked((productOrderedName))) == keccak256(abi.encodePacked((_productName))) ))
            {
                totalPricetoRetailer=products[_distributor][i].price*quantity;
            }
        }
       
        require(msg.value==totalPricetoRetailer);
        order1.orderPayment=msg.value;
        partnerOrders[_distributor].push(order1);
     
        emit orderCreatedfordistributor(order1.name, order1.quantity,order1.status,order1.orderId,order1.orderPayment);
       
    }
   
   
    function checkdistributorStock(uint _orderId, address _retailer,address payable _transporter ) public payable // change according to new manufacturer 2 layer
    {
        Order memory order1=partnerOrders[msg.sender][_orderId];
        order1.status="completed";
        string memory _productOrderedName = order1.name; // to set the inventory of component we have fetched component name from
        inventory memory inventory1= companyInventory[msg.sender][order1.name];
        inventory1.productCount=inventory1.productCount- order1.quantity;
        companyInventory[msg.sender][_productOrderedName] = inventory1;
        partnerOrders[msg.sender][_orderId]=order1;
        msg.sender.transfer(order1.orderPayment);
       
        inventory memory inventory2= companyInventory[_retailer][order1.name];
        inventory2.productCount=inventory2.productCount+order1.quantity;
       
        companyInventory[_retailer][order1.name]=inventory2;
        uint transportation_cost=order1.orderPayment/100; // he should know what transportation he has to pay
        product memory product2= products[msg.sender][_orderId];
        product2.owner=_retailer;
        product2.price=product2.price+retailer_profit2;
        products[_retailer].push(product2);
        transportStocktoRetailer(transportation_cost,_transporter,_retailer, order1.name);
    }
   
    function transportStocktoRetailer(uint _transportationcost, address payable transporteraddress, address _retailer, string memory _name) public payable
    {
        transporteraddress.transfer(_transportationcost);
    }
}
