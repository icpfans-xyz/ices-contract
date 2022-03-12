import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import ICES "mo:ices/ICES";
import Router "mo:ices/Router";

shared actor class ICESExample(overrideId: ?Text) = Self  {
    
    
    let routerId = Option.get(overrideId, Router.mainnetId);

    let ices = ICES.ICES(?routerId);
    

    // Register the current Canister to ICES Main (Router) Canister
    public shared({caller}) func register() : async Bool {
        // TODO Your Project ID or Name （customize）
        let projectId = "your project id or name";
        let result = await ices.register(projectId);
        switch result {
            case(#ok(msg)) Debug.print("Register success :" # msg);
            case(#err(errmsg)) Debug.print("emit fail: " # errmsg);
        };
        true;
    };

    // User data example
    public shared({caller}) func login(param1: Text, param2: Text) : async Bool {
        // TODO Your business

        // let eventKey = "CES_USER";
        let eventValue = [param1, param2];
        let result = await ices.login(eventValue);
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
        let result = await ices.emit(eventKey, eventValue);
        switch result {
            case(#ok(index)) Debug.print("emit success");
            case(#err(errmsg)) Debug.print("emit fail: " # errmsg);
        };
        true;
    };

   




   
};
