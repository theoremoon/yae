extern crate rustbox;

use std::default::Default;

use rustbox::{Color, RustBox};
use rustbox::Key;

fn main() {
    let rustbox = match RustBox::init(Default::default()) {
        Result::Ok(v) => v,
        Result::Err(e) => panic!("{}", e),
    };

    rustbox.print(0, 0, rustbox::RB_NORMAL, Color::White, Color::Default, "Hello, world!");
    rustbox.print(0, 1, rustbox::RB_NORMAL, Color::White, Color::Default, "press q to quit");

    loop {
        rustbox.present();
        match rustbox.poll_event(false) {
            Ok(rustbox::Event::KeyEvent(key)) => {
                match key {
                    Key::Char('q') => { break; }
                    _ => {}
                }
            },
            Err(e) => panic!("{}", e),
            _ => {}
        }
    }
}
