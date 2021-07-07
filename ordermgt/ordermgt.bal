import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;

isolated map<x:Order> orderMap = {};

service /OrderMgt on new http:Listener(8081) {

    isolated resource function post 'order(http:Caller caller, http:Request request) returns error? {
        string orderString = check <string|error> request.getQueryParamValue("order");

        string orderId = uuid:createType1AsString();
        lock {
            json j = orderString.toJson();
            x:Order 'order = check j.cloneWithType(x:Order);
            orderMap[orderId] = 'order;
            log:printInfo("OrderMgt - OrderId: " + orderId + " AccountId: " + 'order.accountId.toString());
        }
        check caller->respond(orderId);
    }

    isolated resource function get 'order/[string orderId](http:Caller caller, http:Request request) returns error? {
        lock {
            check caller->respond(orderMap[orderId].toJson());
        }
    }

}
