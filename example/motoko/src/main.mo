import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor CESExample  {
    
    type ICPCES = actor {
        register : shared (projectId: Text) -> async Result.Result<Text, Text>;
        emit : shared (eventKey: Text, eventValue: [Text]) -> async Result.Result<Nat, Text>;
    };


    private var icasActor : ICPCES = actor("ydetr-mqaaa-aaaah-aa6lq-cai");


    public func setICESCanister(canisterId : Text) : async Bool {
        icasActor := actor(canisterId);
        true;
    };

    // Register the current Canister to ICES Main (Router) Canister
    public shared({caller}) func register() : async Bool {
        // TODO Your Project ID or Name （customize）
        let projectId = "your project id or name";
        let result = await icasActor.register(projectId);
        switch result {
            case(#ok(msg)) Debug.print("Register success :" # msg);
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
