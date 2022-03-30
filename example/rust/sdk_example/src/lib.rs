use ic_cdk::export::{Principal};
use ic_cdk_macros::*;
use candid::{candid_method, Nat};
use ices_sdk::{Transaction, EventValue, Indexed, EventBuilder};


static mut CESCANISTER: &str = "rrkah-fqaaa-aaaaa-aaaaq-cai";



#[update(name = "register")]
#[candid_method(update)]
pub async fn register() -> bool{
    ic_cdk::println!("Rust canister register");
    unsafe {
        let _call_result = ices_sdk::register(CESCANISTER).await;
        match _call_result {
            Ok(r) => {
                println!("{:#?}",r);
            },
            Err(msg) => {
                // let error_str = format!("msg:{}", msg);
                println!("msg:{}", msg)
            }
            
        };
    }
    true

}

#[update]
async fn login(event_key: String) -> bool {
    ic_cdk::println!("eventkey:{}", &event_key);
    let event_value  = EventValue::Text("hello ices!".to_owned());
    let values = vec![(String::from("sub_key"),event_value,Indexed::Indexed)];
    let evnent = EventBuilder::new()
        .caller(ic_cdk::caller())
        .key(event_key)
        .values(values)
        .build()
        .unwrap();
    unsafe {
        let _call_result = ices_sdk::emit(evnent, CESCANISTER).await;
        match _call_result {
            Ok(r) => {
                println!("{:#?}",r);
            },
            Err(msg) => {
                // let error_str = format!("msg:{}", msg);
                println!("msg:{}", msg)
            }
            
        };
        true
        // let canister_id: Principal =
        //     Principal::from_text(CESCANISTER).unwrap();
        //     let _call_result: Result<(), _> =
        //     ic_cdk::api::call::call(canister_id, "emit", (event_key, event_value)).await;
        // match _call_result {
        //     Ok(_) => Ok(()),
        //     Err((code, msg)) => Err(ic_cdk::println!(
        //         "An error happened during the call: {}: {}",
        //         code as u8,
        //         msg
        //     )),
        // };
    }
}

#[update]
async fn tranfer(from: Principal, to: Principal, amount: Nat) -> bool {
    ic_cdk::println!("eventkey:{}", "tranfer".to_string());
    // let from_str = from.to_string();

    let transaction  = Transaction {
        from: from.to_string(),
        to: to.to_string(),
        amount,
    };
    let event_value  = EventValue::Transaction(transaction);
    let values = vec![(String::from("sub_key"),event_value,Indexed::Indexed)];
    let evnent = EventBuilder::new()
        .caller(ic_cdk::caller())
        .key(String::from("Transaction"))
        .values(values)
        .build()
        .unwrap();
    unsafe {
        let _call_result = ices_sdk::emit(evnent, CESCANISTER).await;
        match _call_result {
            Ok(r) => {
                println!("{:#?}",r);
            },
            Err(msg) => {
                // let error_str = format!("msg:{}", msg);
                println!("msg:{}", msg)
            }
            
        };
    }
    true
}

#[update(name = "set_ces_canister")]
fn set_ces_canister(canister_id: String) {
    unsafe {
        CESCANISTER = Box::leak(canister_id.into_boxed_str());
    }
}

#[query]
fn get_ces_canister() -> String {
    unsafe { String::from(CESCANISTER) }
}
