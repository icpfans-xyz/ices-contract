import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
module {

    // Metadata of a storage canister.
    public type StorageInfo = {
        canisterId       : Principal;
        startIndex       : Nat;
        endIndex         : Nat;
        storageStatus    : Bool; 
    };

    public type EventLog = {
        index           : Nat;
        projectId      : ?Text;
        caller          : Text; 
        eventKey       : Text; 
        eventValue     : [Text]; 
        timestamp      : Time.Time;
    };

    public type  Project = {
        projectId      : ?Text;
        currentNum     : Nat;
        approve        : Bool;
    };


    
};
