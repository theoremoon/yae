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

    let mut x = 0;
    let mut y = 2;

    loop {
        rustbox.present();
        match rustbox.poll_event(false) {
            Ok(rustbox::Event::KeyEvent(key)) => {
                match key {
                    Key::Char('q') => { break; }
                    Key::Char(c) => {
                        rustbox.print(x, y, rustbox::RB_NORMAL, Color::Default, Color::Default, c.to_string().as_str());
                        x += 1;
                    },
                    Key::Enter => { y += 1; x = 0; }
                    _ => { }
                }
            },
            Err(e) => panic!("{}", e),
            _ => {}
        }
    }
}
