import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;
import madusha/commons as x;

http:Client adminClient = check new("http://localhost:8085/Admin");

public function main(decimal interval, int count) returns @tainted error? {
    foreach var i in 1...count {
        check doSession(<@untainted> i % 2 + 1, i % 10 == 0, i % 30 == 0);
        runtime:sleep(interval);
    }
}

public function doSession(int accountId, boolean doError1, boolean doError2) returns @tainted error? {
    json rsx = check adminClient->get("/invsearch/mango", targetType = json);
    x:Description d = check rsx.fromJsonWithType(x:Description);
    int id1 = d.id;
    rsx = check adminClient->get("/invsearch/water", targetType = json);
    d = check rsx.fromJsonWithType(x:Description);
    int id2 = d.id;
    x:Item item1 = { invId: id1, quantity: 5 };
    x:Item item2 = { invId: id2, quantity: 10 };
    _ = check adminClient->post("/cartitems/" + accountId.toString(), item1.toJson(), {"Content-Type": "application/json"}, targetType=http:Response);
    _ = check adminClient->post("/cartitems/" + accountId.toString(), item2.toJson(), {"Content-Type": "application/json"}, targetType=http:Response);
    if doError1 {
        // try to add the same item again
        _ = check adminClient->post("/cartitems/" + accountId.toString(), item2.toJson(), {"Content-Type": "application/json"}, targetType=http:Response);
    }
    string s = check adminClient->get("/checkout/" + accountId.toString(), targetType = string);
    if doError2 {
        // try to checkout an empty cart
        rsx = check adminClient->get("/checkout/" + accountId.toString());
    }
    io:println(s);
}
