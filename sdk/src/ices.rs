use ic_cdk::api::call;
use candid::{Principal};
use crate::event::{Event};



/// Register the current Canister to ICES Main (Router) Canister
pub async fn register(mainnet_id: &str) -> Result<String, String> {
    // let mainnet : &str = "ydetr-mqaaa-aaaah-aa6lq-cai";
    let canister_id = Principal::from_text(mainnet_id).unwrap();
    let _call_result : Result<(), _>=
            call::call(canister_id, "register", ()).await;
    match _call_result {
        Ok(r) => {
            println!("{:#?}",r);
            Ok(String::from("success"))
        },
        Err((code, msg)) => {
            ic_cdk::println!("An error happened during the call: {}: {}",code as u8,msg);
            let error_str = format!("msg:{}", msg);
            Err(error_str)
        }
        
    }
}

pub async fn emit(event: Event, mainnet_id: &str) -> Result<String, String> {
    // call ices
    // let mainnet : &str = "ydetr-mqaaa-aaaah-aa6lq-cai";
    let canister_id = Principal::from_text(mainnet_id).unwrap();
    let _call_result: Result<(), _> =
            call::call(canister_id, "emit", (event,)).await;
    match _call_result {
        Ok(r) => {
            println!("{:#?}",r);
            Ok(String::from("success"))
        },
        Err((code, msg)) => {
            ic_cdk::println!("An error happened during the call: {}: {}",code as u8,msg);
            let error_str = format!("msg:{}", msg);
            Err(error_str)
        }
        
    }
}