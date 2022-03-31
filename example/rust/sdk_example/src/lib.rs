use ic_cdk::api;
use ic_cdk_macros::*;
use candid::{Nat, Principal};
use ices_sdk::{Transaction, EventValue, Indexed, EventBuilder, ICESBuilder};

/// set local ices router canister_id, The main network does not need to be set up to override 
static mut CESCANISTER: &str = "rrkah-fqaaa-aaaaa-aaaaq-cai";

#[update(name = "register")]
pub async fn register() -> bool{
    
    unsafe {
        let ices_builder = ICESBuilder::new()
            // The main network does not need to be set up to override
            .override_id(Some(CESCANISTER.to_string()))
            .build()
            .unwrap();

        let _call_result = ices_sdk::register(ices_builder).await;
        match _call_result {
            Ok(r) => {
                ic_cdk::println!("{:?}",r);
                true
            },
            Err(msg) => {
                ic_cdk::println!("msg:{}", msg);
                false
            } 
        }
    }
}

#[update(name = "login")]
async fn login(event_key: String) -> bool {

    let event = EventBuilder::new()
        .caller(api::caller())
        .key(event_key)
        .values(vec![
            (String::from("sub_key"), EventValue::Text("hello ices!".to_owned()), Indexed::Indexed)
        ])
        .build()
        .unwrap();
    unsafe {
        let ices_builder = ICESBuilder::new()
            // The main network does not need to be set up to override
            .override_id(Some(CESCANISTER.to_string()))
            .event(event)
            .build()
            .unwrap();

        let _call_result = ices_sdk::emit(ices_builder).await;

        match _call_result {
            Ok(r) => {
                ic_cdk::println!("{:?}",r);
                true
            },
            Err(msg) => {
                ic_cdk::println!("msg:{}", msg);
                false
            }
        }
        
    }
}

#[update(name = "transfer")]
async fn transfer(from: Principal, to: Principal, amount: Nat) -> bool {

    let transaction  = Transaction {
        from: from.to_string(),
        to: to.to_string(),
        amount,
    };
    let event = EventBuilder::new()
        .caller(ic_cdk::caller())
        .key(String::from("Transaction"))
        .values(vec![
            (String::from("sub_key"),EventValue::Transaction(transaction), Indexed::Indexed)
        ])
        .build()
        .unwrap();

    unsafe {
        let ices_builder = ICESBuilder::new()
            // The main network does not need to be set up to override
            .override_id(Some(CESCANISTER.to_string()))
            .event(event)
            .build()
            .unwrap();

        let _call_result = ices_sdk::emit(ices_builder).await;

        match _call_result {
            Ok(r) => {
                ic_cdk::println!("{:?}",r);
                true
            },
            Err(msg) => {
                ic_cdk::println!("msg:{}", msg);
                false
            }
        }
    }
}

#[update(name = "set_ices_canister")]
fn set_ices_canister(canister_id: String) {
    unsafe {
        CESCANISTER = Box::leak(canister_id.into_boxed_str());
    }
}

#[query]
fn get_ices_canister() -> String {
    unsafe { String::from(CESCANISTER) }
}
