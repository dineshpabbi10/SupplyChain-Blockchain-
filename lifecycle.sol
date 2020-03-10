struct product{

    ready to be shipped
    shipped
    manufactured
    sending customs cleared
    receiving customs cleared
    inspection done

}

struct customer{
    // check if we can create an array of customers only
    name
    id
    order pending


}

function createItem()
{
    // required conditions:
    // balance of customer>= price
    // the person should not have any pending orders
    // person should have a valid address
}


/**
// both customer and manufacturer can deal with one order at a time only
required functions:
confirm_order(){
    // from customer - can not cancel thge order after this
    // require - 
    indicate - send money to smart contract
    
}
confirm_order from manufacturer ()
{
    // required: customer != manufacturer
    // order to be finally confirmed by customer
    action performed:
    indicate that manufacturing has started
    does not have any pending orders to manufacture in pipeline
}
function cancel order()
{
    required:
    order not confirmed from cusrtomer
    order not confirmed from manufacturer
    manufacturer can not cancel the order since payment has already been made to the smart contract
}

function order_manufactured()
{
    from the manufsctured
    action: indicates that the order has been manufactured and is ready to ship
}

function insurance()
{
    required:
    order should be confirmed from both parties
    order should be manufactred and ready to be shipped
    order should bnot have been shipped already
    /// to check - money/ payment
}
function transport()
{
    // this function needs to be implemented at two stages - from sender to sending port, from receiving port to customer
    1. from: manufacfturer
    required: 
    manufacturing done
    insurance done

    indicate 
    // product handed over to transport company
    // check conflict with delivery_confirm-or how you can implement this

}

function confirm_recieve()
{
    // multiple implementations - we also needs a delivery_confirmation to verify from both sides
    1. sender's transport company confirms receiving shipment from sender
    2. Sending port confirms that shipment received from transportation company
    3. receiving port confirms shipment received
    4. Receiving transportation confirms received
    5. Customer reports received
}

function delivery_confirm()
{
    multiple implementations:
    1. manufacturer confirms delivery to transportation company
    2. transportation company reports delivery to shipping company
    3. shipping company reports delivery to receiving port
    4. receivin g port confirms delivery to transport
    5. transport confirms delivery to customer
}
function customs()
{
    // 2 implementations
    1.from sender to sending port

    2. at receiving port

    require:
    shipment is insured
    check some conditions for customs and add to product specification - then emit them in manufactured function
    indicate - customs cleared
}

function payments()
{
    // research this - once final delivery is confirmed - transfer money to customer, insurance and shipping companies as predecided - automated paymemt
    // give customer the chance to inspect the item
    clear the pipeline for cutomer - multiple - we need to see it's attributes- as done in exam - one order at a time for customer
    clear the pipeline for manufacturer- there is only one manufacturer so this is fine
}
*/
