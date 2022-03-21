import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
module {

    // Metadata of a storage canister.
    public type StorageInfo = {
        canisterId       : Principal;
        startIndex       : Nat;
        endIndex         : Nat;
        storageStatus    : Bool; 
    };

    public type Transfer = {
        from : Principal;
        to: Principal;
        amount: Nat64;
    };

    public type EventValue = {
        #I64 : Int64;
        #U64 : Nat64;
        #Vec : [EventValue];
        #Slice : [Nat8];
        #Text : Text;
        #True;
        #False;
        #Float : Float;
        #Principal : Principal;
        #Transfer : Transfer;
    };

    public type Indexed = {
        #Indexed;
        #Not;
    };

    public type Event = {
        time : Time.Time;
        key : Text;
        values : [(Text, EventValue, Indexed)];
        caller : Principal;
    };

    public type EventType = {
        key : Text;
        values : [(Text, EventValue, Indexed)];
        caller : Principal;
    };

    public type EventLog = {
        index          : Nat;
        block          : Nat;
        nonce          : Nat;
        canisterId     : Principal;
        event          : Event; 
        icesTime       : Time.Time;
    };

    // public type EventLog = {
    //     index           : Nat;
    //     projectId      : ?Text;
    //     caller          : Text; 
    //     eventKey       : Text; 
    //     eventValue     : [Text]; 
    //     timestamp      : Time.Time;
    // };

    public type  Project = {
        canisterId     : Principal;
        projectId      : ?Text;
        nonce          : Nat;
        currentNum     : Nat;
        approve        : Bool;
    };


    
};
