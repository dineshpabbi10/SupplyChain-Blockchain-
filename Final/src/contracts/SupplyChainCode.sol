pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract SupplyChainCode {
    string public company_name; // Name of the Company
    address payable companyAddress;

    uint256 profit = 1 ether;
    //uint256 retailer_profit2 = 1 ether;
    uint256 public myEtherValue = 1 ether;
    uint256 public companyOrderNumber = 0;
    uint256 public retailerOrderNumber = 0;

    // 1. Product refers to the Final Product manufactured by the deployer Company (Admin Company which deploys)
    struct product {
        address owner;
        uint256 price;
        bool isSold;
        string name;
        uint256 productId;
        bool isCompleted;
    }

    //1. Refers to the manufacturer struct which gets orders from admin Company
    struct manufacturer {
        string name;
    }

    struct component {
        address owner;
        uint256 price;
        string componentName;
        string manufacturer; // to display customer the name of the manufacturer.
    }

    struct inventory {
        uint256 productCount;
    }
    struct partners {
        string Partnername;
    }

    modifier Owner {
        require(
            msg.sender == companyAddress
        );
        _;
    }

    mapping(address => product[]) public products; // refers to the products the Admin Company has manufactured
    mapping(string => component) fetchComponent; // to fetch component from its name
    mapping(address => Order[]) public giveOrders; //1. general mapping to give orders up the hierarchy
    mapping(string => component[]) components; // to access product components through component name
  //  mapping(string => product) fetchproducts; // to fetch products through product's name
    mapping(address => partners) companies; //mapping to fetch partner companies
    mapping(address => mapping(string => component)) fetchIndividualComponent; // to fetch individual components made by a company with company address and component name
    mapping(address => mapping(string => inventory)) public companyInventory;
    mapping(string => string[]) public productToComponentMapping;
   //mapping(uint => uint[]) public prod;
    //mapping(uint => string[]) public prod2;
    mapping(string => string[]) public productDetailsMapping;
   // mapping(address => distributor) distributorInventory;

 /*   struct distributor {
        string distributor_name;
        string location;
       // uint256 distributor_profit;
    }*/

    //1. Defines the properties of the order.
    struct Order {
        string name;
        uint256 quantity;
        string status;
       // uint256 orderId;
        uint256 orderPayment;
    }

    // EVENT LIST
    event orderCreatedforCompany(
        string name,
        uint256 quantity,
        string status,
       // uint256 orderId,
        uint256 orderPayment
    );

    event orderCreatedfordistributor(
        string name,
        uint256 quantity,
        string status,
        //uint256 orderId,
        uint256 orderPayment
    );

    event orderCompletedByDistributor(
        string status,
        uint256 productCount,
        address owner
    );

    event productCreated(
        address owner,
        uint256 price,
        bool isSold,
        string name,
        uint256 productId,
        bool isCompleted,
        uint256 productCount
    );

    event checkStockByCompany(
        string status,
        uint256 productCount,
        uint256 productCount2,
        address owner,
        uint256 price
    );

    event transportStockDistributor(uint256 cost);

    event stockCheckedByDistributor(
        string status,
        uint256 productCount,
        uint256 productCount2,
        address owner,
        uint256 price
    );

    event transportationToRetailer(uint256 cost);

    event ordertoManufacturerCreated(
        string name,
        uint256 quantity,
        string status
        //uint256 orderId
    );

    event orderStatus(
        string name,
        uint256 quantity,
        string status
        //uint256 orderId
    );

    event sellProductToCustomerEvent(address owner);

    constructor() public {
        company_name = "BLOCKCHAIN MANUFACTURERS";
        companyAddress = msg.sender;
        setComponentsOfProducts();
    }

    //1. this function is used to set product's components for each product that the AdminCompany manufacturers
    //2. the company will add each product it manufactures here
    // to be called in constructor.
    function setComponentsOfProducts() public {

        productToComponentMapping["FormalShirt"].push("cotton");

        productToComponentMapping["FormalShirt"].push("thread");
        productToComponentMapping["Jeans"].push("cotton");
        productToComponentMapping["Jeans"].push("zippers");

       // return "components have been set";
    }

    //1. Function used by manufacturer to sign-up
    function signUp(string memory companyName) public {
        companies[msg.sender] = partners(companyName);
    }

    //1. This function is executed by admin company to give order of the components to the manufacturer company
    //2. Admin company passes the component name which it requires along with the quantity and address of the manufacturer company

    function giveOrderToManufacturer(
        string memory _Componentname,
        uint256 number,
        address _manufacturerCompany
    ) public payable{
       // require(number > 0);
        //bytes memory _cName2 = bytes(_Componentname);
        //require(!(_cName2.length == 0));
        Order memory order1;
        order1.status = "pending";
        order1.quantity = number;
        order1.name = _Componentname;
        component memory component1 = fetchComponent[_Componentname];
        component1.price = 1 ether;
        component1.componentName = order1.name;
        component1.owner = _manufacturerCompany;
        component1.manufacturer = companies[_manufacturerCompany].Partnername;
        fetchComponent[_Componentname] = component1;
        uint256 totalPrice = component1.price * order1.quantity;
        require(msg.value == totalPrice);
        order1.orderPayment = msg.value;
      
     //   order1.orderId = orders.length + 1;
        giveOrders[_manufacturerCompany].push(order1);
        emit ordertoManufacturerCreated(
            order1.name,
            order1.quantity,
            order1.status
           // order1.orderId
        );

    }

    //1. This function is used by the manufacturer company for its internal progress as a step to complete order for Admin Company
    function orderInProgress(uint256 _orderId) public {
        Order memory order1 = giveOrders[msg.sender][_orderId]; // orders of the respective manufacturer will be shown
        order1.status = "inProgress";
        giveOrders[msg.sender][_orderId] = order1;
        emit orderStatus(
            order1.name,
            order1.quantity,
            order1.status
          //  order1.orderId
        );
    }

    //1. This function is also called by Manufacturer  to notify that order has been completed and components have been made
    // modifier to be added.
    function orderCompleted(uint256 _orderId) public payable {
        // require(
        //     msg.sender != companyAddress
        // );

        Order memory order1 = giveOrders[msg.sender][_orderId];
        order1.status = "completed";
        giveOrders[msg.sender][_orderId] = order1;
        string memory _Componentname = order1.name; // to set the inventory of component we have fetched component name from
        inventory memory inventory1 = companyInventory[companyAddress][_Componentname];
        inventory1.productCount = inventory1.productCount + order1.quantity;
        companyInventory[companyAddress][_Componentname] = inventory1;
        component memory component1 = fetchComponent[order1.name];
        component1.owner = companyAddress;
        fetchComponent[component1.componentName] = component1;
        msg.sender.transfer(order1.orderPayment);
        emit orderCompletedByDistributor(
            order1.status,
            inventory1.productCount,
            component1.owner
        );
    }

    //1. This function is run by Admin Company to create products after getting raw materials from manufacturers
   function createProduct(string memory _productName, uint256 _makingPrice,uint256 _count)public {
        inventory memory inventory1 = companyInventory[msg.sender][_productName];
        uint256 price = 0;
        string[] memory ingredients = productToComponentMapping[_productName];
        for (uint256 i = 0; i < ingredients.length; i++) {
            inventory memory ingredientInventory = companyInventory[msg
                .sender][ingredients[i]];
           // require(ingredientInventory.productCount > 0);
            ingredientInventory.productCount =
                ingredientInventory.productCount -
                _count;
            components[_productName].push(fetchComponent[ingredients[i]]);
            companyInventory[msg.sender][ingredients[i]] = ingredientInventory;
            price = price + fetchComponent[ingredients[i]].price;
        }

        product memory product1;
        product1.name = _productName;
        product1.owner = msg.sender;
        _makingPrice = _makingPrice * myEtherValue;
        product1.price = price + _makingPrice;
        product1.isSold = false;
        product[] memory productsList = products[msg.sender];
        product1.productId = productsList.length + 1;
        product1.isCompleted = true;
        inventory1.productCount = inventory1.productCount + _count;
        products[msg.sender].push(product1);
        companyInventory[msg.sender][_productName] = inventory1;
        seeDetails(_productName);
        emit productCreated(
            product1.owner,
            product1.price,
            product1.isSold,
            product1.name,
            product1.productId,
            product1.isCompleted,
            inventory1.productCount
        );
    }

    // 1.The distributor sends his requirement to the company, mentioning the productname and quantity required
    function distributorRequirement(
        string memory _productName,
        uint256 quantity
    ) public payable {
      //  require(msg.sender != companyAddress);
        product[] memory productList = products[companyAddress];
        Order memory order1;
        order1.status = "pending";
        order1.quantity = quantity;
        order1.name = _productName;
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < productList.length; i++) {
            // fetch the product which the company has
            product memory product1 = products[companyAddress][i];
            string memory productOrderedName = product1.name;
            if (
                (keccak256(abi.encodePacked((productOrderedName))) ==
                    keccak256(abi.encodePacked((_productName))))
            ) // match which product the distributor has required.qquantity
            {
                totalPrice = products[companyAddress][i].price * quantity;
            }

        }
        require(msg.value == totalPrice);
        companyOrderNumber = companyOrderNumber +1;
        order1.orderPayment = msg.value;
        giveOrders[companyAddress].push(order1);
        emit orderCreatedforCompany(
            order1.name,
            order1.quantity,
            order1.status,
            //order1.orderId,
            order1.orderPayment
        );
    }

    //1. This function is called by Admin Company to check if it has sufficient stock to give to distibutor and initiates product transport
    function checkStock(
        uint256 _orderId,
        address _distributor,
        address payable _transporter
    ) public payable Owner {
        Order memory order1 = giveOrders[msg.sender][_orderId];
        inventory memory inventory1 = companyInventory[companyAddress][order1.name];
        require(inventory1.productCount >= order1.quantity); // added newwwwwww
        order1.status = "completed";
        string memory _productOrderedName = order1.name; // to set the inventory of component we have fetched component name from
        inventory1.productCount = inventory1.productCount - order1.quantity;
        companyInventory[companyAddress][_productOrderedName] = inventory1;
        giveOrders[msg.sender][_orderId] = order1;
        msg.sender.transfer(order1.orderPayment);
        inventory memory inventory2 = companyInventory[_distributor][order1
            .name];
        inventory2.productCount = inventory2.productCount + order1.quantity;
        companyInventory[_distributor][order1.name] = inventory2;
        uint256 transportation_cost = order1.orderPayment / 100;
        product memory product2 = products[companyAddress][_orderId];
        product2.owner = _distributor;
        product2.price = product2.price + profit;
        products[_distributor].push(product2);

        transportStocktoDistributor(transportation_cost, _transporter);

        emit checkStockByCompany(
            order1.status,
            inventory1.productCount,
            inventory2.productCount,
            product2.owner,
            product2.price
        );
    }

    // 1. The Admin Company transfers one hundredth amount of the order received to transporter as part of transporter fees
    function transportStocktoDistributor(
        uint256 _transportationcost,
        address payable transporteraddress
    ) public payable {
        transporteraddress.transfer(_transportationcost);
    }

    //1 . The retailer orders for the required product in this function
    function retailerRequirement(
        string memory _productName,
        uint256 quantity,
        address _distributor
    ) public payable {
       // require(msg.sender != companyAddress);

        product[] memory productList = products[_distributor];
        Order memory order1;
        order1.status = "pending";
        order1.quantity = quantity;
        order1.name = _productName;
        uint256 totalPricetoRetailer = 0;

        for (uint256 i = 0; i < productList.length; i++) {
            product memory product1 = products[_distributor][i];
            string memory productOrderedName = product1.name;
            if (
                (keccak256(abi.encodePacked((productOrderedName))) ==
                    keccak256(abi.encodePacked((_productName))))
            ) {
                totalPricetoRetailer =
                    products[_distributor][i].price *
                    quantity;
            }

        }
        require(msg.value == totalPricetoRetailer);
        order1.orderPayment = msg.value;
        giveOrders[_distributor].push(order1);
        retailerOrderNumber +=1;

        emit orderCreatedfordistributor(
            order1.name,
            order1.quantity,
            order1.status,
            //order1.orderId,
            order1.orderPayment
        );

    }

    //1. This function is called by Distributor to check if it has sufficient stock to give to retailer and initiates product transport
    function checkdistributorStock(
        uint256 _orderId,
        address _retailer,
        address payable _transporter // change according to new manufacturer 2 layer
    ) public payable {
        //require(msg.sender != companyAddress);
        Order memory order1 = giveOrders[msg.sender][_orderId];
        inventory memory inventory1 = companyInventory[msg.sender][order1.name];
      //  require(inventory1.productCount >= order1.quantity);
        order1.status = "completed";
        string memory _productOrderedName = order1.name; // to set the inventory of component we have fetched component name from
        inventory1.productCount = inventory1.productCount - order1.quantity;
        companyInventory[msg.sender][_productOrderedName] = inventory1;
        giveOrders[msg.sender][_orderId] = order1;
        msg.sender.transfer(order1.orderPayment);
        inventory memory inventory2 = companyInventory[_retailer][order1.name];
        inventory2.productCount = inventory2.productCount + order1.quantity;
        companyInventory[_retailer][order1.name] = inventory2;
        uint256 transportation_cost = order1.orderPayment / 100;
        product memory product2 = products[msg.sender][_orderId];
        product2.owner = _retailer;
        product2.price = product2.price + profit;
        products[_retailer].push(product2);
        transportStocktoRetailer(transportation_cost, _transporter);

        emit stockCheckedByDistributor(
            order1.status,
            inventory1.productCount,
            inventory2.productCount,
            product2.owner,
            product2.price
        );

    }
    // 1. The Distributor transfers one hundredth amount of the order received to transporter as part of transporter fees
    function transportStocktoRetailer(
        uint256 _transportationcost,
        address payable transporteraddress
    ) public payable {
        transporteraddress.transfer(_transportationcost);
    }

    // function for customer to buy products
    //1. This function is used by customers to buy products from retailer
    //2. The customer can only buy one product at a time
    function sellProductToCustomer(
        address payable _retailer,
        string memory _productName
    ) public payable {
        product[] memory productList = products[_retailer];
        Order memory order1;
        order1.status = "completed";
        giveOrders[_retailer].push(order1);
        inventory memory inventory2 = companyInventory[_retailer][_productName];
        inventory2.productCount = inventory2.productCount - 1;
        companyInventory[_retailer][_productName] = inventory2;
        product memory product1;
        
        for (uint256 i = 0; i < productList.length; i++) {
            product1 = products[_retailer][i];
            string memory productOrderedName = product1.name;
            if (
                (keccak256(abi.encodePacked((productOrderedName))) ==
                    keccak256(abi.encodePacked((_productName))))
            ) {
                _retailer.transfer(msg.value);
                product1.owner = msg.sender;
            }
        }
        emit sellProductToCustomerEvent(product1.owner);

    }

    //1. This function is used by the cutomer to see product details, especially, the manufacturer of raw materials of the product
    function seeDetails(string memory _productName) public {
      //  require(msg.sender == companyAddress);
        component[] memory productComponentList = components[_productName];
        for (uint256 i = 0; i < productComponentList.length; i++) {
            productDetailsMapping[_productName].push(
                string(
                    abi.encodePacked(
                        (productComponentList[i].componentName),
                        (" is manufactured by "),
                        (productComponentList[i].manufacturer)
                    )
                )
            );
        }
    }

   // function see(string memory pn) public view returns (string[] memory) {
     //   return productDetailsMapping[pn];
  //  }
}