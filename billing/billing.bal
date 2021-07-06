import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import madusha/commons as x;

final http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");

service /Billing on new http:Listener(8082) {

    resource function post payment(http:Caller caller, http:Request request) returns error? {
        string payment = check <string|error> request.getQueryParamValue("payment");
        json j = payment.toJson();
        string orderId = <string> check j.orderId;
        http:Response resp = check orderMgtClient->get("/order/" + orderId);
        json payload = check resp.getJsonPayload();
        x:Order 'order = check payload.cloneWithType(x:Order);
        string receiptNumber = uuid:createType1AsString();
        check caller->respond(receiptNumber);
        log:printInfo("Billing - OrderId: " + orderId + " ReceiptNumber: " + receiptNumber);
    }
}
