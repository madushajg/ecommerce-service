import ballerina/http;
import madusha/commons as x;
import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/log;
import ballerinax/prometheus as _;

final jdbc:Client dbClient = check new (url =  "jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", 
                                        user = "root",
                                        password = "root",
                                        connectionPool = {
                                            maxOpenConnections: 50
                                        }
                                    ); 

service /ShoppingCart on new http:Listener(8080) {

    @http:ResourceConfig {
        consumes: ["application/json"]
    }
    resource function post items/[int accountId](http:Caller caller, @http:Payload x:Item item) returns error? {
        log:printDebug("Reached post items", accountId = accountId, item = item);
        _ = check dbClient->execute(`INSERT INTO ECOM_ITEM (inventory_id, account_id, quantity) VALUES (${item.invId}, ${accountId}, ${item.quantity})`);

        check caller->respond();
    }

    resource function get items/[int accountId](http:Caller caller, http:Request request) returns error? {
        log:printDebug("Reached get items", accountId = accountId);
        stream<record{}, error> rs = dbClient->query(`SELECT inventory_id as invId, quantity FROM ECOM_ITEM WHERE account_id = ${accountId}`, x:Item);
        stream<x:Item, sql:Error> itemStream = <stream<x:Item, sql:Error>>rs;

        json[] j = [];
        int invId = 0;
        int quantity = 0;

        error? e = itemStream.forEach(function(x:Item item) {
            invId = item.invId;
            quantity = item.quantity;
            j.push({invId: invId, quantity: quantity});
        });

        check itemStream.close();

        check caller->respond({"items":j});
    }

    resource function delete items/[string accountId](http:Caller caller, http:Request request) returns error? {
        log:printDebug("Reached delete items", accountId = accountId);
        _ = check dbClient->execute(`DELETE FROM ECOM_ITEM WHERE account_id = ${accountId}`);
        check caller->respond();
    }
}
