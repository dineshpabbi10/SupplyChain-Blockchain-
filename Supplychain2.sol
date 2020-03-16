pragma solidity  >=0.5.0 ;

   // NEED A FUNCTION TO SET THE PRICE AND DETAILS OF COMPONENTS
   // NEED TO DEFINE A PARTICULAR SET OF COMPONENTS OR AN INVENTORY OF COMPONENTS
   // NEED TO DO ALL COMMENTED SECTIONS

contract SupplyChain
{
    
    string public company_name;
    uint totalComponents = 0;
    
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
        string componentName; // use this as ID to map the component type
        //string manufacturer;
        address manufacturer; // the manufacturer remains the same - the original company that manufactured the product
    }


       
       struct product{
        address owner;
        uint price;
        bool isSold;
        string name;
        uint productId;
        bool isCompleted; // TO BE MADE INTO ENUM ?
        //string productType;
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

    //my implementation of inventory
    struct inventory{
        uint productCount;
        uint shirt;
        uint pants;
        uint skirt;
        uint shoes;
        uint sweater;
    }

   mapping(address=>mapping(string =>component)) fetchIndividualComponent;  // what does this stand for? //components and company mapping - recheck?
   
   mapping(address => partners) companies;
   
   mapping(string => component) manuComponent; //-? // Assuming this to be inventory or list of defined components
   
  
   
   mapping(address=>Order[]) partnerOrders;
   
   mapping(address=>mapping(string=>inventory)) companyInventory; // string=>inventory - > string component ka name hai - like shirty/ Tshirt, address refers to that person jiska bhi stock set karna hai
   
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

event componentCreates(
    address owner,
        uint price,
        string componentName, // use this as ID to map the component type
        //string manufacturer;
        address manufacturer

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

    constructor () public
    {
     company_name= "DELL";
     companyAddress=msg.sender;
     
    }
   

        // This function is used to set menu for product components' name in a product
  
   function setProductComponents() public returns(string memory){
       //problem: how are the products mapped to the inventory?

        productToComponentMapping["DesignedShirt"].push("rawShirt");
        productToComponentMapping["DesignedShirt"].push("thread");
        return "components have been set";
       }

//below is my implementation:
function setProductComponent(string memory productName, string memory component1, string memory component2) public returns(string memory)
{
    
    // require - only components that are in inventory can be mapped
    require(msg.sender==companyAddress, "Only deployer can set the product components");
    require(productName == 'shirt' || productName == 'pants' || productName == 'skirt' || productName == 'shoes' || productName == 'sweater', "This function can be called only for the products that are in the inventory");
    
    productToComponentMapping[productName].push(component1);
    productToComponentMapping[productName].push(component2);
    return "components have been set";

}
        
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
         Order[] memory orders= partnerOrders[_partnerCompany]; // get all the orders of that particular manufacturer
          order1.orderId=orders.length+1;
        partnerOrders[_partnerCompany].push(order1);
       
       // to let company know of his Id of
     
     emit orderCreated(order1.name, order1.quantity,order1.status,order1.orderId);
       
    }
   // my implementation of giveOrder
   /**
   This function should be called twice as each product has two components that need to be ordered.
   parameters:
   _Componentname : name of the component
   number: quantity of the product required
   _partnerCompany: company to which the order is placed
   note: In this function - only the order is placed not confirmed, hence no payment is made
   
    */
   function giveOrder(string memory _Componentname, uint number, address _partnerCompany)public payable
    {
        require(msg.sender==companyAddress, "Only deployer can set the product components");
        // need to check that the component is actually a part of the product
        // need to check that component is part of component inventory
        Order memory order1;
        order1.status="pending";
        order1.quantity=number;
        order1.name=_Componentname;
        component memory component1=fetchIndividualComponent[msg.sender][order1.name]; // change thisd -?- getting the details of that component
        //fetchIndividualComponent[component1.owner][component1.componentName]=component1; // -? // move this to components function
        //manuComponent[_Componentname]=component1; // -? // move this to components function
        uint totalPrice = component1.price*order1.quantity; // - change this too - fetch from components inventory
        require(msg.value>=totalPrice);
        order1.orderPayment=totalPrice;
        Order[] memory orders= partnerOrders[_partnerCompany]; // get all the orders of that particular manufacturer
        order1.orderId=orders.length+1;
        partnerOrders[_partnerCompany].push(order1);     
     emit orderCreated(order1.name, order1.quantity,order1.status,order1.orderId);
       
    }

    /*
    function - to set the price and details of components 

    */
    function createComponent(uint _price, string memory _componentName ) public{

        // require - component is only set by manufacturing company
        // require - check that component does not already exist in the inventory - we can not have two declarations for let's say cotton.
        require(_price > 0, "Item's price is required!");
        require(msg.sender != companyAddress, "Company can not set the components only manufacturer");
        totalComponents++;
        Components[totalComponents] = component(msg.sender, _price, _componentName, msg.sender); // initially the component belongs to the manufacturer.
        fetchIndividualComponent[msg.sender][_componentName]=component(msg.sender, _price, _componentName, msg.sender); 
        /manuComponent[_Componentname]=component(msg.sender, _price, _componentName, msg.sender); //still don't know the purpose of this mapping
        emit componentCreated(msg.sender, _price, _componentName, msg.sender);
       
    }


   
    function orderInProgress(uint _orderId) public
    {
        //to be done by the manufacturer
        require(msg.sender != companyAddress, "Company can not set the order to be in progress, only manufacturer can do that");
        Order memory order1= partnerOrders[msg.sender][_orderId];
        order1.status="inProgress";
        // we need to update the order status in every mapping as well
        partnerOrders[msg.sender][_orderId]= order1;
        emit orderStatus(order1.name,order1.quantity,order1.status,order1.orderId);
       
    }
    
    function signUp(string memory companyName) public{
       // manufacturer pehle signup kare
       // require - already existing nahi hona chahie partnername
       // This function is redundant
        companies[msg.sender] = partners(companyName);
    }
    
    
  
  
  	function orderCompleted(uint _orderId) public payable // change according to manufacturer
    {
        // status change kar raha hai ki order complete ho gaya hai, inventory of manufacturer reduced, invntory of company ki badha di, payment done
        require(msg.sender != companyAddress, "Company can not set the order to be in progress, only manufacturer can do that");
        Order memory order1=partnerOrders[msg.sender][_orderId];
        order1.status="completed";
         partnerOrders[msg.sender][_orderId]= order1;
        string memory _Componentname = order1.name; // to set the inventory of component we have fetched component name from

        inventory memory inventory1= companyInventory[companyAddress][_Componentname];
        inventory1.productCount=inventory1.productCount+ order1.quantity;
        companyInventory[companyAddress][_Componentname] = inventory1;

        // Changing the ownership of the component
        component memory component1=fetchIndividualComponent[msg.sender][order1.name];
        component1.owner = companyAddress;
        fetchIndividualComponent[companyAddress][component1.componentName]=component1;
        // don't we have to remove the component mapping from the manufacturer in fetchIndividualComponent?
        msg.sender.transfer(order1.orderPayment);       // transfer payment to the manufacturer
        // since we are updating the component owner here, we need to change the mappings-> components, manuComponents also
        //emit 

    }
   
   
   
    function createProduct(string memory _productName, uint _makingPrice) public // product created by the company
    {
       
       // to understand some part of this again

           inventory memory inventory1= companyInventory[msg.sender][_productName]; // fetching initial inventory
           require(msg.sender==companyAddress);
           uint price=0;
           string[] memory ingredients = productToComponentMapping[_productName];
           // Basically calculates the price of the product
           for (uint i = 0; i < ingredients.length; i++)
           {
           inventory memory ingredientInventory = companyInventory[msg.sender][ingredients[i]];
           require(ingredientInventory.productCount>0);
           ingredientInventory.productCount = ingredientInventory.productCount-1;
           components[_productName].push(manuComponent[ingredients[i]]); // to show to customer - to change probably because we are using components as a predefined inventory 
           companyInventory[msg.sender][ingredients[i]]=ingredientInventory;
           price = price+fetchIndividualComponent[msg.sender][ingredients[i]].price;
           }
   
        product memory product1;
       
        product1.name=_productName;
        product1.owner=msg.sender;
        _makingPrice=_makingPrice*myEtherValue;
        product1.price=price+_makingPrice;
        product1.isSold=false;
        product[] memory productsList = products[msg.sender]; // for adding product to the product list. - understand this mapping
        product1.productId=productsList.length+1;
        product1.isCompleted=true;
        inventory1.productCount=inventory1.productCount+1; // increasing inventory
       
        products[msg.sender].push(product1);
        companyInventory[msg.sender][_productName]=inventory1;
        emit productCreated(product1.owner,product1.price,product1.isSold,product1.name, product1.productId,product1.isCompleted,inventory1.productCount);
       
       
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
       
        require(msg.value>=totalPrice); // or greater than equal
        order1.orderPayment=msg.value;
        partnerOrders[companyAddress].push(order1);
     emit orderCreatedforCompany(order1.name, order1.quantity,order1.status,order1.orderId,order1.orderPayment);
       
    }
    
    // The Company checks stock available for the distributor's order and sends the products to the distributor and pays the transportation fees 
    // To work from here
     function checkStock(uint _orderId, address _distributor,address payable _transporter ) public payable{ // change according to new manufacturer 2 layer
        // check if this can be separated - for transporter, make separate function for transport
        // apna stock dekhage - agar hua stock to fir he will send it to distibutor through transporter
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
        // this function is called by retailer, now distributor will check it's own stock, aur uske baad woh usko bhej dega
       
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
    
    
    // function for customer to buy products 
    function sellProductToCustomer(address payable _retailer,string memory _productName) public payable
   {
       product[] memory productList= products[_retailer];
       
       
          Order memory order1;
        order1.status="completed";
       // order1.quantity=quantity;
       // order1.name=_productName;
       
       partnerOrders[_retailer].push(order1);
       
            //uint totalPricetoRetailer = 0;
          for (uint i = 0; i < productList.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            product memory product1=products[_retailer][i];
            string memory productOrderedName = product1.name;
            
            if( (keccak256(abi.encodePacked((productOrderedName))) == keccak256(abi.encodePacked((_productName))) ))
            {
                //totalPricetoRetailer=products[_retailer][i].price*quantity;
                
                _retailer.transfer(msg.value);
                product1.owner=msg.sender;
            }
   
        }
        
        
       
   }
}
