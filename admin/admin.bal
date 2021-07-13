import ballerina/http;
import madusha/commons as x;
import ballerina/io;
import ballerina/log;

final http:Client cartClient = check new("http://localhost:8080/ShoppingCart");
final http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");
final http:Client billingClient = check new("http://localhost:8082/Billing");
final http:Client shippingClient = check new("http://localhost:8083/Shipping");
final http:Client invClient = check new("http://localhost:8084/Inventory");

listener http:Listener ep = new (8085);

service /Admin on ep {

    resource function get invsearch/[string query](http:Caller caller, http:Request request) returns error? {
        log:printInfo("Reached get invsearch", Query = query);
        json resp = check invClient->get("/search/" + query, targetType = json);
        io:println(resp.toJsonString());
        check caller->respond(resp);
    }

    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post cartitems/[string accountId](http:Caller caller, @http:Payload x:Item item) returns error? {
        log:printInfo("Reached post cartitems", accountId = accountId, item = item);
        http:Response resp = check cartClient->post("/items/" + accountId, item.toJson());
        check caller->respond(resp);
    }

    resource function get checkout/[int accountId](http:Caller caller, http:Request request) returns @tainted error? {
        log:printInfo("Reached get checkout", accountId = accountId);
        http:Response resp = check cartClient->get("/items/" + accountId.toString());
        json j = check resp.getJsonPayload();
        log:printInfo("payload from get cart", payload = j);
        x:Items items = check j.cloneWithType(x:Items);
        log:printInfo("items from get cart", items = items.toString());
        if items.length() == 0 {
            http:Response respx = new;
            respx.statusCode = 400;
            respx.setTextPayload("Empty cart");
            check caller->respond(respx);
            return;
        }
        x:Order 'order = { accountId: accountId, items: items };
        resp = check orderMgtClient->post("/order", 'order.toJson());
        string orderId = check resp.getTextPayload();
        x:Payment payment = { orderId };
        resp = check billingClient->post("/payment", payment.toJson());
        string receiptNumber = check resp.getTextPayload();
        x:Delivery delivery = { orderId };
        resp = check shippingClient->post("/delivery", delivery.toJson());
        string trackingNumber = check resp.getTextPayload();
        _ = check cartClient->delete("/items/" + accountId.toString(), targetType = http:Response);
        check caller->respond({ accountId: accountId, orderId: orderId, receiptNumber: receiptNumber, 
                                        trackingNumber: trackingNumber });
    }
}
