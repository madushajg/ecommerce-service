import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;

final http:Client ordermgtClient = check new("http://localhost:8081/OrderMgt");

service /Shipping on new http:Listener(8083) {

    resource function post delivery(http:Caller caller, http:Request request) returns error? {
        string deliveryString = check <string|error> request.getQueryParamValue("delivery");
        json j = deliveryString.toJson();
        x:Delivery delivery = check j.cloneWithType(x:Delivery);

        json resp = check ordermgtClient->get("/order/" + delivery.orderId, targetType = json);

        x:Order 'order = check resp.cloneWithType(x:Order);

        string trackingNumber = uuid:createType1AsString();
        check caller->respond(trackingNumber);
        log:printInfo("Shipping - OrderId: " + delivery.orderId + " TrackingNumber: " + trackingNumber);
    }

}
