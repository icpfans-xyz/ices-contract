import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor CESExample  {
    
    type ICPCES = actor {
        register : shared (projectId: Text, canisterId: Principal) -> async Result.Result<Text, Text>;
        emit : shared (eventKey: Text, eventValue: [Text]) -> async Result.Result<Nat, Text>;
    };


    private var icasActor : ICPCES = actor("ark2z-fiaaa-aaaah-aa4ta-cai");


    public func setICESCanister(canisterId : Text) : async Bool {
        icasActor := actor(canisterId);
        true;
    };

    // User data example
    public shared({caller}) func register() : async Bool {
        // TODO Your business
        let projectId = "MO_Project";
        let thisCanister = Principal.fromActor(CESExample);
        let result = await icasActor.register(projectId, thisCanister);
        switch result {
            case(#ok(msg)) Debug.print("emit success MSG:" # msg);
            case(#err(errmsg)) Debug.print("emit fail: " # errmsg);
        };
        true;
    };

    // User data example
    public shared({caller}) func login(param1: Text, param2: Text) : async Bool {
        // TODO Your business

        let eventKey = "CES_USER";
        let eventValue = [param1, param2];
        let result = await icasActor.emit(eventKey, eventValue);
        switch result {
            case(#ok(index)) Debug.print("emit success");
            case(#err(errmsg)) Debug.print("emit fail: " # errmsg);
        };
        true;
    };


    // Event log example
    public shared({caller}) func eventLogExample(param1: Text, param2: Text) : async Bool {
        // TODO Your business

        let eventKey = "your key";
        let eventValue = [param1, param2];
        let result = await icasActor.emit(eventKey, eventValue);
        switch result {
            case(#ok(index)) Debug.print("emit success");
            case(#err(errmsg)) Debug.print("emit fail: " # errmsg);
        };
        true;
    };

   




   
};
