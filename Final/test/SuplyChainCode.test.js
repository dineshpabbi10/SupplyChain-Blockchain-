const SupplyChain = artifacts.require("SupplyChainCode");

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract(SupplyChain, ([deployer, manufacturer1, manufacturer2, distributor, transporter, retailer, customer]) => {

    let business;

    before(async () => {
        business = await SupplyChain.deployed()
    })

    //first describe block 

    describe('Deployment should be successful', async () => {

        it('The deployment should be done successfully', async () => {
            const address = await business.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })

        it('The deployment contract has correct name', async () => {
            const name = await business.company_name();
            assert.equal(name, 'BLOCKCHAIN MANUFACTURERS')
        })
    })

    describe('Creating orders for manufactuers, changing its status and completing the orders', async () => {

        let result, madeResult

        it('Giving order should be successful if all correct', async () => {
            result = await business.giveOrderToManufacturer('thread', 1, manufacturer1, { from: deployer, value: web3.utils.toWei('1', 'Ether') })
            const event = result.logs[0].args;
            assert.equal(event.name, 'thread', 'Order name is correct');
            assert.equal(event.quantity, 1, 'Order quantity is correct');
            assert.equal(event.status, 'pending', 'Order status is Pending');
            assert.equal(event.orderId.toNumber(), 1, 'Order id is correct'); // to check if 1 should be replaced by a global variable like totalNumber
        })

        it('Order should not be made if component is empty or quantity is 0', async () => {
            //Component must have a name
            await business.giveOrderToManufacturer('', 5, manufacturer1, { from: deployer, value: web3.utils.toWei('5', 'Ether') }).should.be.rejected;
            // Quantity can not be 0
            await business.giveOrderToManufacturer('fur', 0, manufacturer1, { from: deployer, value: web3.utils.toWei('5', 'Ether') }).should.be.rejected;

        })

        it('Giving order should be successful if all correct', async () => {
            result = await business.giveOrderToManufacturer('cotton', 1, manufacturer1, { from: deployer, value: web3.utils.toWei('1', 'Ether') })
            const event = result.logs[0].args;
            assert.equal(event.name, 'cotton', 'Order name is correct');
            assert.equal(event.quantity, 1, 'Order quantity is correct');
            assert.equal(event.status, 'pending', 'Order status is Pending');
            assert.equal(event.orderId.toNumber(), 2, 'Order id is correct'); // to check if 1 should be replaced by a global variable like totalNumber
        })

        it('Order should not be made if deployer is not the company', async () => {
            //Order can only be given by the company itself
            await business.giveOrderToManufacturer('fur', 5, manufacturer1, { from: manufacturer2, value: web3.utils.toWei('5', 'Ether') }).should.be.rejected;

        })

        it('Giving order with insufficient amaount should be rejected', async () => {
            // FAILURE: Invalid Value in Payment
            await business.giveOrderToManufacturer('fur', 5, manufacturer1, { from: deployer, value: web3.utils.toWei('2', 'Ether') }).should.be.rejected;

        })

        it('Order status to be updated as inProgress only by the assigned manufacturer', async () => {

            result = await business.orderInProgress(0, { from: manufacturer1 });
            const event = result.logs[0].args;
            assert.equal(event.name, 'thread', 'Order name is correct');
            assert.equal(event.quantity, 1, 'Order quantity is correct');
            assert.equal(event.status, 'inProgress', 'Order status is Pending');
            assert.equal(event.orderId.toNumber(), 1, 'Order id is correct');

        })


        it('Order status to be updated as inProgress only by the assigned manufacturer', async () => {
            result = await business.orderInProgress(1, { from: manufacturer1 });
            const event = result.logs[0].args;
            assert.equal(event.status, 'inProgress', 'Ordernnnn name is correct');
            assert.equal(event.name, 'cotton', 'Order name is correct');
            assert.equal(event.quantity, 1, 'Order quantity is correct');
            assert.equal(event.orderId.toNumber(), 2, 'Order id is correct');

        })



        it('Order status to be updated as completed only by the assigned manufacturer', async () => {
            result = await business.orderCompleted(0, { from: manufacturer1 });
            const event = result.logs[0].args;
            assert.equal(event.status, 'completed', 'Order name is correct');
        })

        it('Create product should be rejected as of now as now the inventory of all ingredients is not there', async () => {
            //SUCCESSFUL
            await business.createProduct('FormalShirt', 1, { from: deployer }).should.be.rejected;
        })

        it('Orders to be updated as inProgress only by the assigned manufacturer', async () => {
            result = await business.orderCompleted(1, { from: manufacturer1 });
            const event = result.logs[0].args;
            assert.equal(event.status, 'completed', 'Order name is correct');
        })
        it('Creating item should be successful if all correct', async () => {
            //SUCCESSFUL
            result = await business.createProduct('FormalShirt', 1, { from: deployer })
            const event = result.logs[0].args;
            assert.equal(event.owner, deployer, 'item owner is correct');
            assert.equal(event.price, web3.utils.toWei('3', 'Ether'), 'price is correct');
            assert.equal(event.isSold, false, 'price is correct');
            assert.equal(event.name, 'FormalShirt', 'price is correct');
            assert.equal(event.productId, 1, 'price is correct');
            assert.equal(event.isCompleted, true, 'price is correct');
            assert.equal(event.productCount, 1, 'price is correct');

        })

        it('Create product can be done only by company', async () => {
            //SUCCESSFUL
            await business.createProduct('FormalShirt', 1, { from: manufacturer1 }).should.be.rejected;
        })

        it('distributor requirement by the company should be rejected', async () => {
            //SUCCESSFUL
            await business.distributorRequirement('FormalShirt', 1, { from: deployer, value: web3.utils.toWei('3', 'Ether') }).should.be.rejected;
        })

        it('distributor requirement by the distributor should be rejected if less money', async () => {
            //SUCCESSFUL
            await business.distributorRequirement('FormalShirt', 1, { from: deployer, value: web3.utils.toWei('2', 'Ether') }).should.be.rejected;
        })

        it('distributor requirement by the distributor should be accepted if all correct', async () => {
            //SUCCESSFUL
            result = await business.distributorRequirement('FormalShirt', 1, { from: distributor, value: web3.utils.toWei('3', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.name, 'FormalShirt', 'Order name is correct');
            assert.equal(event.quantity, 1, 'quantity is correct');
            assert.equal(event.status, 'pending', 'order status is correct');
            assert.equal(event.orderId, 0, 'orderId is correct');
            assert.equal(event.orderPayment, web3.utils.toWei('3', 'Ether'), 'price is correct');
        })

        it('check stock by the manufacturer should be rejected', async () => {
            //SUCCESSFUL
            await business.checkStock(0, distributor, transporter, { from: manufacturer1 }).should.be.rejected;
        })

        it('check stock should be accepted if all correct', async () => {
            //SUCCESSFUL
            result = await business.checkStock(0, distributor, transporter, { from: deployer, value: web3.utils.toWei('1', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.status, 'completed', 'Order name is correct');
            assert.equal(event.productCount, 0, 'quantity is correct');
            assert.equal(event.productCount2, 1, 'quantity is correct');
            assert.equal(event.owner, distributor, 'owner is correct');
            assert.equal(event.price, web3.utils.toWei('4', 'Ether'), 'price is correct');
        })


        it('distributor requirement by the distributor should be accepted if all correct', async () => {
            //SUCCESSFUL
            result = await business.distributorRequirement('FormalShirt', 1, { from: distributor, value: web3.utils.toWei('3', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.name, 'FormalShirt', 'Order name is correct');
            assert.equal(event.quantity, 1, 'quantity is correct');
            assert.equal(event.status, 'pending', 'order status is correct');
            assert.equal(event.orderId, 0, 'orderId is correct');
            assert.equal(event.orderPayment, web3.utils.toWei('3', 'Ether'), 'price is correct');
        })

        it('distributor requirement by the deployer should be rejected as not enough stock', async () => {
            //SUCCESSFUL
            await business.checkStock(0, distributor, transporter, { from: manufacturer1 }).should.be.rejected;
        })
        it('retailer requirement by the company should be rejected', async () => {
            //SUCCESSFUL
            await business.retailerRequirement('FormalShirt', 1, { from: deployer, value: web3.utils.toWei('4', 'Ether') }).should.be.rejected;
        })

        it('retailer requirement by the retailer should be rejected if less money', async () => {
            //SUCCESSFUL
            await business.retailerRequirement('FormalShirt', 1, distributor, { from: retailer, value: web3.utils.toWei('3', 'Ether') }).should.be.rejected;
        })

        it('retailer requirement by the retailer should be accepted if all correct', async () => {
            //SUCCESSFUL
            result = await business.retailerRequirement('FormalShirt', 1, distributor, { from: retailer, value: web3.utils.toWei('4', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.name, 'FormalShirt', 'Order name is correct');
            assert.equal(event.quantity, 1, 'quantity is correct');
            assert.equal(event.status, 'pending', 'order status is correct');
            assert.equal(event.orderId, 0, 'orderId is correct');
            assert.equal(event.orderPayment, web3.utils.toWei('4', 'Ether'), 'price is correct');

        })

        it('check distributor stock by the company should be rejected', async () => {
            //SUCCESSFUL
            await business.checkdistributorStock(0, retailer, transporter, { from: deployer }).should.be.rejected;
        })

        it('check distributor requirement by the distributor should be accepted if all correct', async () => {
            //SUCCESSFUL
            result = await business.checkdistributorStock(0, retailer, transporter, { from: distributor, value: web3.utils.toWei('1', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.status, 'completed', 'Order name is correct');
            assert.equal(event.productCount, 0, 'quantity is correct');
            assert.equal(event.productCount2, 1, 'quantity is correct');
            assert.equal(event.owner, retailer, 'owner is correct');
            assert.equal(event.price, web3.utils.toWei('5', 'Ether'), 'price is correct');

        })

        it('sell the product to the customer if all correct', async () => {
            //SUCCESSFUL
            result = await business.sellProductToCustomer(retailer, 'FormalShirt', { from: customer, value: web3.utils.toWei('5', 'Ether') });
            const event = result.logs[0].args;
            assert.equal(event.owner, customer, 'owner is correct');

        })
    })
});
