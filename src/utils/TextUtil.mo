import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";
import HashMap "mo:base/HashMap";

module {

    public func textToNat( txt : Text) : Nat {
        assert(txt.size() > 0);
        let chars = txt.chars();
        var num : Nat = 0;
        for (v in chars){
            let charToNum = Nat32.toNat(Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };
        num;
    };

    public func removeQuery(str: Text): Text {
        let result = Text.split(str, #char '?').next();
        switch (result) {
            case (?s) s;
            case (_) "";
        };
    };

    public func queryParamsMap(str: Text): HashMap.HashMap<Text, Text> {
        let map = HashMap.HashMap<Text, Text>(1, Text.equal, Text.hash);
        let iters = Text.split(str, #char '?');
        // get path
        let path = iters.next();
        let pathStr =  switch (path) {
            case (?s) s;
            case (_) "/";
        };
        map.put("@path", pathStr); 
        let queryStr = iters.next();
        switch queryStr {
            case (?qs) {
                let queryStrSplitted = Text.split(qs, #char '&');
                for ( q in queryStrSplitted) {
                    let paramSplitted = Text.split(q, #char '=');
                    let name = switch (paramSplitted.next()) {
                        case (?n) {
                            let value = switch (paramSplitted.next()) {
                                case (?v) v;
                                case (_) "";
                            };
                            map.put(n, value);
                        };
                        case (_) {};
                    };
                };
            };
            case (_) {};
        };
        return map;
    };

    public func getParamNat(key : Text, params : HashMap.HashMap<Text, Text>) : Nat {
        switch (params.get(key)) {
            case (?p) textToNat(p);
            case (_) 0;
        };
    };

};
