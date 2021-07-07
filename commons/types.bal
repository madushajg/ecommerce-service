public type Item record {
    int invId;
    int quantity;
};

public type Order record {
    int accountId;
    Items items;
};

public type Payment record {
    string orderId;
};

public type Delivery record {
    string orderId;
};

public type Items record {
    Item[] items;
};

public type Description record {
    int id;
    string description;
};
