use ic_cdk::api;
use candid::{Principal, Nat};
use crate::event::{Event, EmitResult};

#[derive(Default, Clone, Debug)]
pub struct ICESBuilder {
    /// The caller that initiated the call on the token contract.
    pub event: Option<Event>,
    /// Override the default mainnet id ydetr-mqaaa-aaaah-aa6lq-cai
    pub override_id: String,
}
impl ICESBuilder {
    pub fn new() -> Self {
        Self { 
            event: None,
            override_id: String::from("ydetr-mqaaa-aaaah-aa6lq-cai")
        }
    }

    #[inline(always)]
    pub fn override_id(mut self, override_id: Option<String>) -> Self {
        match override_id {
            Some(x) => self.override_id = x,
            None => self.override_id = String::from("ydetr-mqaaa-aaaah-aa6lq-cai"),
        }

        self
    }

    #[inline(always)]
    pub fn event(mut self, event: Event) -> Self {
        self.event = Some(event);
        
        self
    }

    #[inline(always)]
    pub fn build(self) -> Result<ICESBuilder, ()> {

        Ok(ICESBuilder {
            event: self.event,
            override_id: self.override_id,
        })
    }
}


/// Register the current Canister to ICES Main (Router) Canister
pub async fn register(ices_builder: ICESBuilder) -> Result<EmitResult<String>, String> {
    let canister_id = Principal::from_text(&ices_builder.override_id).unwrap();
    let _call_result : Result<(EmitResult<String>,), _>=
            api::call::call(canister_id, "register", ()).await;
    match _call_result {
        Ok((res,)) => {
            Ok(res)
        },
        Err((code, msg)) => {
            Err(format!(
                "An error happened during the call: {}: {}",
                code as u8, msg
            ))
        }
        
    }
}

/// Emit event logs to ICES 
pub async fn emit(ices_builder: ICESBuilder) -> Result<EmitResult<Nat>, String> {
    let canister_id = Principal::from_text(&ices_builder.override_id).unwrap();
    let event = ices_builder.event.unwrap();
    let _call_result: Result<(EmitResult<Nat>,), _> =
            api::call::call(canister_id, "emit", (event,)).await;      
    match _call_result {
        Ok((res,)) => {
            Ok(res)
        },
        Err((code, msg)) => {
            Err(format!(
                "An error happened during the call: {}: {}",
                code as u8, msg
            ))
        }
        
    }
}