use ic_cdk::export::Principal;

use ic_cdk_macros::*;

static mut CESCANISTER: &str = "ydetr-mqaaa-aaaah-aa6lq-cai";


#[update]
async fn register() {
    ic_cdk::println!("Rust register");
    
    // let this_canister: Principal =
    //         Principal::from_text("ryjl3-tyaaa-aaaaa-aaaba-cai").unwrap();
    unsafe {
        let project_id = String::from("your project id or name");
        let canister_id: Principal =
            Principal::from_text(CESCANISTER).unwrap();

            let _call_result: Result<(), _> =
            ic_cdk::api::call::call(canister_id, "register", (project_id,)).await;
        match _call_result {
            Ok(_) => Ok(()),
            Err((code, msg)) => Err(ic_cdk::println!(
                "An error happened during the call: {}: {}",
                code as u8,
                msg
            )),
        };
    }
}

#[update]
async fn login(event_key: String) {
    ic_cdk::println!("eventkey:{}", &event_key);
    let event_value = ["rust value1", "rust value2"];
    unsafe {
        let canister_id: Principal =
            Principal::from_text(CESCANISTER).unwrap();
            let _call_result: Result<(), _> =
            ic_cdk::api::call::call(canister_id, "emit", (event_key, event_value)).await;
        match _call_result {
            Ok(_) => Ok(()),
            Err((code, msg)) => Err(ic_cdk::println!(
                "An error happened during the call: {}: {}",
                code as u8,
                msg
            )),
        };
    }
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
