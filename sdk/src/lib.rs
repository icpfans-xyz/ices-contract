#![allow(clippy::from_over_into)]
#![allow(clippy::result_unit_err)]
#![allow(dead_code)]


mod event;
pub use event::*;

pub mod ices;
pub use ices::*;


#[doc(hidden)]
pub mod prelude {
    pub use crate::*;
}
