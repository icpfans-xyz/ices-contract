import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Cycles "mo:base/ExperimentalCycles";
import Type "Types";
import EventStorage "./storage/EventStorage";
import EventUtil "./utils/EventUtil";
import IC "./utils/ic";
import Buffer "mo:base/Buffer";


shared ({caller = owner}) actor class ICES() = this {
    
    type Event = Type.Event;
    type EventLog = Type.EventLog;
    type StorageInfo = Type.StorageInfo;
    type Project = Type.Project;

    type CanisterStatus = IC.CanisterStatus;
    type canister_settings = IC.canister_settings;

    type EventLogStorageActor = actor {
        addEventLog : (item: EventLog) -> async Bool;
        getCanisterId : () -> async Principal;
        getLastIndex : () -> async Nat;
        getPageByIndex : (start: Nat, pageSize: Nat) -> async [EventLog];
    };

    private let ic : IC.Self = actor "aaaaa-aa";

    private var registerMap = HashMap.HashMap<Principal, Project>(1, Principal.equal, Principal.hash);
    private stable var _registerEntries : [(Principal, Project)] = [];

    private stable var eventLogStorage : ?EventLogStorageActor = null;
    // EventLog Record
    private stable var eventLogs : [var EventLog] = [var];
    // eventlog buffer
    private let eventLogsBuffer = Buffer.Buffer<EventLog>(0);

    // 
    private let eventBuffer = Buffer.Buffer<Event>(0);

    private stable var eventLogsTmp : [var EventLog] = [var];
    // tmp buffer
    private let eventLogsTmpBuffer = Buffer.Buffer<EventLog>(0);
    private stable var indexNonce : Nat = 0;

    private stable var autoNumber : Nat = 1000;
    private stable var projectMaxNumber : Nat = 2000;
    private stable var moveFlag : Bool = false;
    private stable var maxQuerySize : Nat = 20;

    private stable var maxStorageMemorySize : Nat = 7 * 1024 * 1024 * 1024;

    private stable var storageArr : [var StorageInfo] = [var];
    // Storage buffer
    private let storageBuffer = Buffer.Buffer<StorageInfo>(0);

    private let MSG_PERMISSION_DENIED = "Caller permission denied";
    private let MSG_ALREADY_REGISTER = "Canister is already registered";
    private let MSG_NOT_REGISTER = "Canister is not registered";
    private let MSG_SUCCESS_REGISTER = "Canister register success";
    private let MSG_RECORD_EXCEEDS = "The number of records requested by the canister exceeds the limit";
    // add other admins 
    private stable var admins = [owner];
    private let adminsBuffer = Buffer.Buffer<Principal>(0);

    adminsBuffer.add(owner);



    private func _isAdmin(p : Principal) : Bool {
        for (a in admins.vals()) {
            if (a == p) { return true; };
        };
        false;
    };

    public shared({caller}) func testEvent(event : Event) : async [Event] {
        eventBuffer.add(event);
        eventBuffer.toArray();
    };


    // Set auto-scaling number
    public shared({caller}) func setAutoNumber(num : Nat) : async Bool {
        assert(_isAdmin(caller));
        autoNumber := num;
        true;
    };

    // Adds a new principal as an admin.
    // @auth: owner
    public shared({caller}) func addAdmin(p : Principal) : async Bool {
        assert(caller == owner);
        // admins := Array.append(admins, [p]);
        adminsBuffer.clear();
        for (a in admins.vals()) {
            if (a == p) { 
                return true;
             };
            adminsBuffer.add(a);
        };
        // add new 
        adminsBuffer.add(p);
        // override
        admins := adminsBuffer.toArray();
        return true;
    };

    // Removes the given principal from the list of admins.
    // @auth: owner
    public shared({caller}) func removeAdmin(p : Principal) : async () {
        assert(caller == owner);
        admins := Array.filter(
            admins,
            func (a : Principal) : Bool {
                a != p;
            },
        );
    };

    public query({caller}) func showOwner(): async [Text] {
        let res : [Text] = [Principal.toText(caller), Principal.toText(owner)];
        res;
    };

    // Check whether the given principal is an admin.
    // @auth: admin
    public query({caller}) func isAdmin(p : Principal) : async Bool {
        assert(_isAdmin(caller));
        for (a in admins.vals()) {
            if (a == p) return true;
        };
        return false;
    };

    public shared({caller}) func getEventStorageCanisterId() : async Text {
        switch eventLogStorage {
            case(?s) {
                let p = Principal.fromActor(s);
                return Principal.toText(p);
            };
            case(_) {""};
        };
        
    };

    /// create a new userLogStroage canister
    public shared(msg) func setUserLogCaniserId(canister_id : Text) : async Bool {
        assert(_isAdmin(msg.caller));
        eventLogStorage := ?actor(canister_id);
        return true;
    };

    public query func getstorageArr() : async [StorageInfo] {
        Array.freeze(storageArr);
    };

    // /// create a new userLogStroage canister
    public shared(msg) func neweventLogStorage(owner: Principal) : async Bool {
        assert(_isAdmin(msg.caller));
        let s = await createStorage();
        true;
    };

    private func createStorage() : async EventLogStorageActor {
        let storage = await EventStorage.EventStorage(owner);
        let startIndex = getEventLogsFirstIndex();
        let s : StorageInfo = {
            canisterId = Principal.fromActor(storage); // 
            startIndex = startIndex;
            endIndex   = 0;
            storageStatus = true; 
        };
        // put in array 
        // storageArr := Array.thaw(Array.append(Array.freeze(storageArr), Array.make(s)));
        storageBuffer.add(s);
        eventLogStorage := ?storage;
        storage;
    };

    private func getEventLogsFirstIndex() : Nat {
        let startIndex = if (eventLogs.size() > 0) {
            eventLogs[0].index;
        } else {
            1;
        };
        startIndex;
    };

    

    
    public shared({caller}) func approveProject(canisters: [Principal]) : async Bool {
        assert(_isAdmin(caller));
        for(v in canisters.vals()) {
            switch (registerMap.get(v)) {
                case (?project) {
                    let newProject : Project = {
                        canisterId = project.canisterId;
                        projectId = project.projectId;
                        currentNum = project.currentNum;
                        nonce = project.nonce;
                        approve = true;
                    };
                    registerMap.put(v, newProject);
                };
                case (_) {};
            };
        };
        true;
    };

    // Methods that needs to be called to register 
    public shared({caller}) func register() : async Result.Result<Text, Text> {
        switch (registerMap.get(caller)) {
            case (?project) {
                #err(MSG_ALREADY_REGISTER);
            };
            case(_) {
                let project : Project = {
                    canisterId = caller;
                    projectId = null;
                    nonce = 0;
                    currentNum = 0;
                    approve = false;
                };
                registerMap.put(caller, project);
                #ok(MSG_SUCCESS_REGISTER);
            };
        };

    };

    // record event log
    public shared({caller}) func  emit(event : Event) : async Result.Result<Nat, Text>{
        switch (registerMap.get(caller)) {
            case(?project) {
                if (project.approve == false) {
                    if (project.currentNum > projectMaxNumber) {
                        return #err(MSG_RECORD_EXCEEDS);
                    };
                };
                indexNonce := indexNonce + 1;
                let nonce = project.nonce + 1;
                if (moveFlag == false and eventLogs.size() >= autoNumber) {
                    moveFlag := true;
                    let r = await moveToStorage();
                };
                // event value to json
                let newLog : EventLog = {
                    index       = indexNonce;
                    block       = indexNonce;
                    nonce       = nonce;
                    canisterId  = caller;
                    event       = event;
                    icesTime  = Time.now();
                };
                if (moveFlag == false) {
                    // eventLogs := Array.thaw(Array.append(Array.freeze(eventLogs), Array.make(newLog)));
                    eventLogsBuffer.add(newLog);
                } else {
                    // eventLogsTmp := Array.thaw(Array.append(Array.freeze(eventLogsTmp), Array.make(newLog)));
                    eventLogsTmpBuffer.add(newLog);
                };
                let mr = _modifyProjectNonce(project, nonce);
                #ok(indexNonce);
            };
            case(_){
                #err(MSG_NOT_REGISTER);
            };
        };
    };

    // save project nonce
    private func _modifyProjectNonce(p : Project, nonce : Nat) : Bool {
        let newProject : Project = {
            canisterId = p.canisterId;
            projectId = p.projectId;
            currentNum = p.currentNum;
            nonce = nonce;
            approve = p.approve;
        };
        registerMap.put(p.canisterId, newProject);
        return true;
    };

    private func moveToStorage() : async Bool {
        switch eventLogStorage {
            case(?storage) {
                storageArr := storageBuffer.toVarArray();
                // if current storage has enough space to store
                let canisterId = Principal.fromActor(storage);
                let memorySize = await getMemorySize(canisterId);
                if (memorySize > maxStorageMemorySize) {
                    // get last index
                    let endIndex = await storage.getLastIndex();
                    var storageInfo = storageArr[storageArr.size()-1];
                    storageInfo := {
                        canisterId = canisterId;
                        startIndex = storageInfo.startIndex;
                        endIndex   = endIndex;
                        storageStatus = false; 
                    };
                    storageArr[storageArr.size()-1] := storageInfo;
                    let newStorage = await createStorage();
                    // reset
                    storageArr := [var];
                    return await _moveToStorage(newStorage);
                };
                return await _moveToStorage(storage);
            };
            case(_) {
                let newStorage = await createStorage();
                return await _moveToStorage(newStorage);
            };
        };  
    };

    private func _moveToStorage(storage : EventLogStorageActor) : async Bool {
        // use buffer 
        for (v in eventLogsBuffer.vals()) {
            let result = await storage.addEventLog(v);
        };

        // for(i in Iter.range(0, autoNumber-1)) {
        //     let log = eventLogs[i];
        //     let result = await storage.addEventLog(log);
        // };
    
        // eventLogs := [var];
        // eventLogs := Array.thaw(Array.append(Array.freeze(eventLogs), Array.freeze(eventLogsTmp)));
        // eventLogsTmp := [var];
        eventLogsBuffer.clear();
        eventLogsBuffer.append(eventLogsTmpBuffer);
        eventLogsTmpBuffer.clear();
        moveFlag := false;
        true;
    };

    public query func getLogSize() : async [Nat] {
        [eventLogsBuffer.size(), eventLogsTmpBuffer.size()];
    };

    public func getStorageMemorySize(canisterId: Principal) : async Nat {
        switch eventLogStorage {
            case(?storage) {
                let memorySize = await getMemorySize(canisterId);
                memorySize;
            };
            case(_) 0;
        };
        
    };

    // Get Record by index.
    public query func getByIndex(index: Nat) : async EventLog {
        return eventLogs[index];
    };

    public query func getStorageList() : async [StorageInfo] {
        return Array.freeze(storageArr);
    };

    //
    public func getEventLogs(start: Nat, number: Nat) : async [EventLog] {
        let arrFirstIndex = getEventLogsFirstIndex();
        var pageSize = number;
        if (number > maxQuerySize) {
            pageSize := maxQuerySize;
        };
        if (start >= arrFirstIndex) {
            // get from current eventlog arr
            // eventLogs := eventLogsBuffer.toArray();
            return EventUtil.getPage(eventLogsBuffer.toArray(), start, pageSize);
        } else {
            // get from storage
            let r = await _getStorageLogs(start, pageSize);
            return r;
        };
    };


    private func _getStorageLogs(start: Nat, pageSize: Nat) : async [EventLog] {
        // get from storage
        let result = Array.filter<StorageInfo>(Array.freeze(storageArr), func x { (start >= x.startIndex and start <= x.endIndex)
                    or (start >= x.startIndex and x.endIndex == 0) });
        if (result.size() > 0 ) {
            let sinfo = result[0];
            let queryStorage : EventLogStorageActor = actor(Principal.toText(sinfo.canisterId));
            let r =  await queryStorage.getPageByIndex(start, pageSize);
            return r;
        } else {
            return [];
        };
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

    private func getMemorySize(canisterId: Principal) : async Nat{
        let status = await ic.canister_status({ canister_id=canisterId });
        status.memory_size;
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

    system func preupgrade() {
        _registerEntries := Iter.toArray(registerMap.entries());
    };

    system func postupgrade() {
        registerMap := HashMap.fromIter<Principal, Project>(_registerEntries.vals(), 1, Principal.equal, Principal.hash);
        _registerEntries := [];
    };

    
};
