const Ethbay = artifacts.require("Ethbay");
//const Hospital = artifacts.require("Hospital");
require('chai')
.use(require('chai-as-promised'))
.should();

contract(Ethbay,([company, manufacturer1, manufacturer2])=>{
    let business;
    before(async () =>{
        business = await Ethbay.deployed()
    })
    //first describe block 
    describe('Deployment should be successful',async () =>{
        it('The deployment should be done successfully',async() =>{
            const address = await business.address
            assert.notEqual(address,0x0)
            assert.notEqual(address,'')
            assert.notEqual(address,null)
            assert.notEqual(address,undefined) 
        })

        it('The deployment contract has correct name',async() =>{
            const name = await business.company_name();
            assert.equal(name, 'DELL')
        })

    })
   
    describe('Creating orders for manufactuers, changing its status and completing the orders', async () => {
        let result, madeResult
        
        before(async ()=>{
            //result = await giftshop.makeOrder('Harry', '2075 Vancouver BC', web3.utils.toWei('3', 'Ether'),{from: customer1, value: web3.utils.toWei('3', 'Ether')} )
            //totalNumber = await hospital.totalNumber()
            result = await business.giveOrderToManufacturer('fur', 5, manufacturer1, {from: company, value: web3.utils.toWei('5', 'Ether')})
        })

        //If everything is ok, company should be able to give order successfully
        it ('Giving order should be successful if all correct', async ()=>{
            //SUCCESSFUL
            const event = result.logs[0].args;
            assert.equal(event.name,'fur', 'Order name is correct');
            assert.equal(event.quantity, 5,'Order quantity is correct');
            assert.equal(event.status, 'pending','Order status is Pending');
            assert.equal(event.orderId.toNumber(), 1, 'Order id is correct'); // to check if 1 should be replaced by a global variable like totalNumber
            
        })
       
        it ('Order should not be made if component is empty or quantity is 0', async ()=>{
            //Component must have a name
            await business.giveOrderToManufacturer('', 5, manufacturer1, {from: company, value: web3.utils.toWei('5', 'Ether')}).should.be.rejected;
           // Quantity can not be 0
           await business.giveOrderToManufacturer('fur', 0, manufacturer1, {from: company, value: web3.utils.toWei('5', 'Ether')}).should.be.rejected;
            
        })
        /// my added code - verify if correct
        it ('Order should be rejected if component name is not from the set of predefined components', async ()=>{
            //Silk is not a defined component hence this test should be rejected.
            await business.giveOrderToManufacturer('silk', 5, manufacturer1, {from: company, value: web3.utils.toWei('5', 'Ether')}).should.be.rejected;
           
            
        })
        it ('Order should not be made if deployer is not the company', async ()=>{
            //Order can only be given by the company itself
            await business.giveOrderToManufacturer('fur', 5, manufacturer1, {from: manufacturer2, value: web3.utils.toWei('5', 'Ether')}).should.be.rejected;
   
        })

        it('Giving order with insufficient amaount should be rejected', async () => {
            // FAILURE: Invalid Value in Payment
            await business.giveOrderToManufacturer('fur', 5, manufacturer1, {from: company, value: web3.utils.toWei('2', 'Ether')}).should.be.rejected;
            
        })

        
        // check the order given

        it ('Check the order given', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            const order = await business.giveOrders(manufacturer1)(orderNumber); // recheck this code if it is fine- doubt if we call the double mapping like this
            

            assert.equal(order.name,'fur', 'Order name is correct');
            assert.equal(order.quantity, 5,'Order quantity is correct');
            assert.equal(order.status, 'pending','Order status is Pending');
            assert.equal(order.orderId.toNumber(), orderNumber.toNumber(), 'Order id is correct'); 
        })

        // check component details after creating the order
        it ('Check the component details set', async ()=>{
    
            const component = await business.fetchComponents('fur');
            assert.equal(component.owner,manufacturer1, 'Component owner is correct');
            assert.equal(component.price, '1000000000000000000', 'Component price is correct');
            assert.equal(company.componentName, 'fur', 'Component name is correct');
            assert.equal(component.manufacturer, manufacturer1, 'Component manufacturer is correct');
        })

        // check the order in progress function now
        it ('Check order in progress', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            result = await business.orderInProgress(orderNumber);
            const event = result.logs[0].args;
            assert.equal(event.name,'fur', 'Order name is correct');
            assert.equal(event.quantity, 5,'Order quantity is correct');
            assert.equal(event.status, 'inProgress','Order status is Pending');
            assert.equal(event.orderId.toNumber(), orderNumber.toNumber(), 'Order id is correct');
        })

        // check the order details have changed and updated in the array
        it ('Check the order given', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            const order = await business.giveOrders(manufacturer1)(orderNumber); // recheck this code if it is fine- doubt if we call the double mapping like this
            
            assert.equal(order.name,'fur', 'Order name is correct');
            assert.equal(order.quantity, 5,'Order quantity is correct');
            assert.equal(order.status, 'inProgress','Order status is in progress');
            assert.equal(order.orderId.toNumber(), orderNumber.toNumber(), 'Order id is correct'); 
        })


        // check that the component's ownership has not changed
        it ('Check that the component details have not changed even though order is in progress', async ()=>{
    
            const component = await business.fetchComponents('fur');
            assert.equal(component.owner,manufacturer1, 'Component owner is correct, it is still the same manufacturing company');
            assert.equal(component.price, '1000000000000000000', 'Component price is correct');
            assert.equal(company.componentName, 'fur', 'Component name is correct');
            assert.equal(component.manufacturer, manufacturer1, 'Component manufacturer is correct');
        })

        // the function can only be called by manufacturer1

        it ('Order status to be updated as inProgress only by the assigned manufacturer', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            
            await business.orderInProgress(orderNumber, {from:company}).should.be.rejected; // need to check if this is correct
    
           await business.orderInProgress(orderNumber, {from:manufacturer2}).should.be.rejected; // need to check if this is correct
            
        })

        /// Now check after order is completed
        it ('If all went well, order should be completed successfully', async ()=>{
            let manufacturerOldBalance;
            manufacturerOldBalance = await web3.eth.getBalance(manufacturer1);
            manufacturerOldBalance = new web3.utils.BN(manufacturerOldBalance);

            // check log

            orderNumber = await business.giveOrders(manufacturer1).length;
            result = await business.orderCompleted(orderNumber);
            const event = result.logs[0].args;
            const inventory1= companyInventory[company]['fur'];
            let productCount = inventory1.productCount// data type of productCount to define
            assert.equal(event.status,'completed', 'Order was completed');
            assert.equal(event.productCount.toNumber(),productCount.toNumber() ,'Product count in the company inventory is correcct');
            assert.equal(event.owner, company, 'Component is owned by the company now and not the manufacturer');

            let manufacturerNewBalance;
            manufacturerNewBalance = await web3.eth.getBalance(manufacturer1);
            manufacturerNewBalance = new web3.utils.BN(manufacturerOldBalance);

            let price;
            price = web3.utils.toWei('1', 'Ether');
            price = new web3.utils.BN(price);

            const expectedBalacne = manufacturerOldBalance.add(price*5); // hardcoding 5 into this - don't know any other way
            assert.equal(expectedBalacne.toString(), sellerNewBalance.toString());           

            
          
        })


        // after calling the function check status of orders - owner should be changed, status should be changes

         // check the order details have changed and updated in the array
         it ('Check the order given', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            const order = await business.giveOrders(manufacturer1)(orderNumber); // recheck this code if it is fine- doubt if we call the double mapping like this
            assert.equal(order.name,'fur', 'Order name is correct');
            assert.equal(order.quantity, 5,'Order quantity is correct');
            assert.equal(order.status, 'completed','Order status is completed');
            assert.equal(order.orderId.toNumber(), orderNumber.toNumber(), 'Order id is correct'); 
        })


        // check that the component's ownership has not changed
        it ('Check that the component details have changed since the order is now completed', async ()=>{
    
            const component = await business.fetchComponents('fur'); //check if I am calling the mapping in correct way
            assert.equal(component.owner,company, 'Component owner is now the company');
            assert.equal(component.price, '1000000000000000000', 'Component price is correct');
            assert.equal(company.componentName, 'fur', 'Component name is correct');
            assert.equal(component.manufacturer, manufacturer1, 'Component manufacturer is correct');
        })

     
        
        // check companyInventory array as well

        it ('Check that the inventory of the company has changed as needed', async ()=>{
    
            const component = await business.companyInventory(company)('fur'); //check if I am calling the mapping in correct way
            assert.equal(component.productCount.toNumber(),5, 'Since this is the first order of 5 furs'); // again hardcoding 5 here - not sure if we can assign some variable

        })

        // only maufacturer 1 can call

        it ('Order status to be updated as completed only by the assigned manufacturer', async ()=>{
            orderNumber = await business.giveOrders(manufacturer1).length;
            
            await business.orderCompleted(orderNumber, {from:company}).should.be.rejected; // need to check if this is correct
    
           await business.orderCompleted(orderNumber, {from:manufacturer2}).should.be.rejected; // need to check if this is correct
            
        })
        // More test cases can be added only if we add to code that manufacturer inventory is decreased

        /////////////////////////

    })

    

});
