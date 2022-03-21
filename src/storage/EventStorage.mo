import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Cycles "mo:base/ExperimentalCycles";
import Type "../Types";
import HttpUtil "../utils/HttpUtil";
import TextUtil "../utils/TextUtil";
import EventUtil "../utils/EventUtil";
import IC "../utils/ic";
import Buffer "mo:base/Buffer";

shared ({caller = owner}) actor class EventStorage(_owner: Principal) = this {
    
    type EventLog = Type.EventLog;

    type CanisterStatus = IC.CanisterStatus;
    type canister_settings = IC.canister_settings;

    type HttpRequest = HttpUtil.HttpRequest;
    type HttpResponse = HttpUtil.HttpResponse;

    // EventLog Record
    private stable var eventLogs : [var EventLog] = [var];
    // EventLog buffer
    private let eventLogsBuffer = Buffer.Buffer<EventLog>(1);

    private let ic : IC.Self = actor "aaaaa-aa";


    public shared({caller}) func addEventLog(item : EventLog) : async Bool {
        
        eventLogsBuffer.add(item);
        // eventLogs := Array.thaw(Array.append(Array.freeze(eventLogs), Array.make(newLog)));
        return true;
    };
    

    public query func getByIndex(index: Nat) : async ?EventLog {
        eventLogs := eventLogsBuffer.toVarArray();
        let queryResult = Array.filter<EventLog>(Array.freeze(eventLogs), func x { index == x.index });
        let result : ?EventLog = if (queryResult.size() > 0) {
            ?queryResult[0];
        } else {
            null;
        };
        eventLogs := [var];
        result;
    };

    public func getLastIndex() : async Nat {
        eventLogs := eventLogsBuffer.toVarArray();
        let log = eventLogs[eventLogs.size() - 1];
        eventLogs := [var];
        return log.index;
    };

    public func getPageByIndex(start: Nat, pageSize: Nat) : async [EventLog] {
        eventLogs := eventLogsBuffer.toVarArray();
        let result = EventUtil.getPage(Array.freeze(eventLogs), start, pageSize);
        eventLogs := [var];
        return result;
    };



    public func getCanisterId() : async Principal{
        Principal.fromActor(this);
    };


    /** 
    * returns the canister cycles balance
    *
    */
    public shared (msg) func canisterBalance(): async Nat {
        return Cycles.balance()
    };

    /**
    *   accept all canisters cycles top-up
    *   
    */
    public shared (msg) func topUp(): async Nat {
        let available = Cycles.available();
        let accepted = Cycles.accept(available);
        return Cycles.balance();
    };

    
    public shared({ caller }) func transferCycles(canisterId: Principal): async Bool {
        assert(Principal.equal(owner, caller));
        let balance: Nat = Cycles.balance();
        // We have to retain some cycles to be able to transfer the balance and delete the canister afterwards
        let cycles: Nat = balance - 100_000_000_000;
        if (cycles > 0) {
            Cycles.add(cycles);
            await ic.deposit_cycles({ canister_id = canisterId });
        };
        true;
        
    };

    public shared(msg) func getCanisterStatus(): async ?CanisterStatus {
        let canisterId = Principal.fromActor(this);
        let status = await ic.canister_status({ canister_id=canisterId });
        return ?status;
    };

    public shared(msg) func setController(canisterId: Principal): async Bool {
        assert(Principal.equal(owner, msg.caller));
        let thisCanisterId = Principal.fromActor(this);
        let controllers: ?[Principal] = ?[owner, thisCanisterId, canisterId];
        let settings: canister_settings = {
            controllers = controllers;
            compute_allocation = null;
            memory_allocation = null;
            freezing_threshold = null;
        };
        await ic.update_settings({
            canister_id = canisterId;
            settings = settings;
        });
        return true;
    };

    
    public query func http_request(req: HttpRequest): async (HttpResponse) {
        let path = TextUtil.removeQuery(req.url);
        let parmMap = TextUtil.queryParamsMap(req.url);
        if(path == "/") {
            return {
                body = Text.encodeUtf8("Welcome to CAS!");
                headers = [];
                status_code = 200;
                streaming_strategy = null;
            };
        };
        return {
            body = Text.encodeUtf8("404 Not found :" # path);
            headers = [];
            status_code = 404;
            streaming_strategy = null;
        };
    };

    
};
