import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;
import ballerinax/prometheus as _;

final http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");

service /Billing on new http:Listener(8082) {

    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post payment(http:Caller caller, @http:Payload x:Payment payment) returns error? {
        log:printDebug("Reached post payment", payment = payment);
        http:Response resp = check orderMgtClient->get("/order/" + payment.orderId);
        json payload = check resp.getJsonPayload();
        x:Order 'order = check payload.cloneWithType(x:Order);
        string receiptNumber = uuid:createType1AsString();
        log:printDebug("receiptNumber created", receiptNumber = receiptNumber);
        check caller->respond(receiptNumber);
        log:printInfo("Billing - OrderId: " + payment.orderId + " ReceiptNumber: " + receiptNumber);
    }
}
