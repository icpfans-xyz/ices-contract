use candid::{CandidType, Deserialize, Nat,Principal, Int};
use serde::Serialize;
use ic_cdk::api::time;

#[derive(CandidType,Deserialize, Clone, Debug)]
pub struct Transaction  {
    pub from: String,
    pub to: String,
    pub amount: Nat,
}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub struct Event {
    /// The timestamp 
    pub time: Int,
    /// The caller that initiated the call on the token contract.
    pub caller: Principal,
    /// The key that took place.
    pub key: String,
    /// Details of the event.
    pub values: Vec<(String, EventValue, Indexed)>,
}


#[derive(Default, CandidType, Deserialize, Clone, Debug)]
pub struct EventBuilder {
    /// The caller that initiated the call on the token contract.
    pub caller: Option<Principal>,
    /// The key that took place.
    pub key: Option<String>,
    /// Details of the event.
    pub values: Vec<(String, EventValue, Indexed)>,
}


#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub enum Indexed {
    Indexed,
    Not,
}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub enum EventValue {
    I64(i64),
    U64(u64),
    Vec(Vec<EventValue>),
    #[serde(with = "serde_bytes")]
    Slice(Vec<u8>),
    Text(String),
    True,
    False,  
    Float(f64),
    Principal(Principal),
    Transaction(Transaction),
}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub enum EmitResult<T> {
    ok(T),
    err(String),
}


impl EventBuilder {
    pub fn new() -> Self {
        Default::default()
    }

    /// Sets the caller of the event.
    #[inline(always)]
    pub fn caller(mut self,caller: Principal) -> Self {
        self.caller = Some(caller);

        self
    }

    /// Sets the key of the event.
    #[inline(always)]
    pub fn key(mut self, key: String) -> Self {
        self.key = Some(key);

        self
    }

    /// Sets the key of the values.
    #[inline(always)]
    pub fn values(mut self, values: Vec<(String, EventValue, Indexed)>) -> Self {
        self.values = values;

        self
    }

    /// already been set.
    #[inline(always)]
    pub fn build(self) -> Result<Event, ()> {
        // get timestamp
        Ok(Event {
            caller: self.caller.unwrap(),
            key: self.key.unwrap(),
            values: self.values,
            time: Int::from(time()),
        })
    }
}



