import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;

final http:Client ordermgtClient = check new("http://localhost:8081/OrderMgt");

service /Shipping on new http:Listener(8083) {

    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post delivery(http:Caller caller, @http:Payload x:Delivery delivery) returns error? {

        log:printDebug("Reached post delivery", delivery = delivery);
        json resp = check ordermgtClient->get("/order/" + delivery.orderId, targetType = json);

        x:Order 'order = check resp.cloneWithType(x:Order);

        string trackingNumber = uuid:createType1AsString();
        log:printDebug("trackingNumber created", trackingNumber = trackingNumber);
        check caller->respond(trackingNumber);
        log:printInfo("Shipping - OrderId: " + delivery.orderId + " TrackingNumber: " + trackingNumber);
    }

}
