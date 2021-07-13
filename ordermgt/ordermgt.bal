import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;

isolated map<x:Order> orderMap = {};

service /OrderMgt on new http:Listener(8081) {

    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    isolated resource function post 'order(http:Caller caller, @http:Payload x:Order o) returns error? {
        log:printInfo("Reached post order", Order = o);

        string orderId = uuid:createType1AsString();
        log:printInfo("OrderId created", orderId = orderId);

        lock {
            orderMap[orderId] = o.clone();
        }
        check caller->respond(orderId);
    }

    isolated resource function get 'order/[string orderId](http:Caller caller, http:Request request) returns error? {
        log:printInfo("Reached get order", orderId = orderId);
        lock {
            check caller->respond(orderMap[orderId].toJson());
        }
    }

}
