import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Type "../Types";


module {

    type EventLog = Type.EventLog;

    public func getPage(eventLogs : [EventLog], start: Nat, pageSize: Nat) : [EventLog] {
        let end : Nat = start + pageSize - 1;
        let result = Array.filter<EventLog>(eventLogs, func x { x.index >= start and x.index <= end });
        result; 
    };

};
