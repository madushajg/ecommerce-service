import ballerina/http;
import ballerinax/java.jdbc;
import madusha/commons as x;
import ballerina/sql;

final jdbc:Client dbClient = check new (url =  "jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", 
                             user = "root",
                             password = "root"
                             ); 

service /Inventory on new http:Listener(8084) {

    resource function get search/[string query](http:Caller caller, http:Request request) returns @tainted error? {

        stream<record{}, error> rs = dbClient->query(`SELECT id, description FROM ECOM_INVENTORY WHERE description LIKE '% ${query} %'`, x:Description);
        stream<x:Description, sql:Error> itemStream = <stream<x:Description, sql:Error>>rs;

        json[] j = [];
        int id = 0;
        string description = "";

        error? e = itemStream.forEach(function(x:Description item) {
            id = item.id;
            description = item.description;
            j.push({id: id, description: description});
        });

        check caller->respond(j);
    }

}
