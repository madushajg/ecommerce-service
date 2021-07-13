import ballerina/http;
import ballerinax/java.jdbc;
import madusha/commons as x;
import ballerina/log;
import ballerinax/prometheus as _;

type Value record {
    x:Description value;
};

final jdbc:Client dbClient = check new (url =  "jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", 
                                user = "root",
                                password = "root",
                                connectionPool = {
                                    maxOpenConnections: 50
                                }
                             ); 

service /Inventory on new http:Listener(8084) {

    resource function get search/[string query](http:Caller caller, http:Request request) returns @tainted error? {

        log:printDebug("Reached get search", Query = query);
        string q = string `SELECT id, description FROM ECOM_INVENTORY WHERE description LIKE '%${query}%'`;
        stream<record{}, error> resultStream = dbClient->query(q);

        json jj = <json> check resultStream.next();
        Value v = check jj.fromJsonWithType(Value);

        check resultStream.close();

        check caller->respond(v.value.toJson());
    }

}
