import ballerina/http;
import madusha/commons as x;
import ballerinax/java.jdbc;
import ballerina/sql;

final jdbc:Client dbClient = check new (url =  "jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", 
                                        user = "root",
                                        password = "root"
                                    ); 

service /ShoppingCart on new http:Listener(8080) {

    resource function post items/[int accountId](http:Caller caller, http:Request request) returns error? {
        string item = check <string|error> request.getQueryParamValue("item");
        json j = item.toJson();
        string invId = <string> check j.invId;
        string quantity = <string> check j.quantity;
        
        _ = check dbClient->execute(`INSERT INTO ECOM_ITEM (inventory_id, account_id, quantity) VALUES (${invId}, ${accountId}, ${quantity})`);

        check caller->respond();
    }

    resource function get items/[int accountId](http:Caller caller, http:Request request) returns @tainted error? {
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

        check caller->respond(j);
    }

    resource function delete items/[string accountId](http:Caller caller, http:Request request) returns error? {
        _ = check dbClient->execute(`DELETE FROM ECOM_ITEM WHERE account_id = ${accountId}`);
        check caller->respond();
    }
}
