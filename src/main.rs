extern crate rustbox;
extern crate unicode_width;

use std::default::Default;

use rustbox::{Color, RustBox};
use rustbox::Key;

use unicode_width::UnicodeWidthStr;

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
                        let s = c.to_string();
                        rustbox.print(x, y, rustbox::RB_NORMAL, Color::Default, Color::Default, s.as_str());
                        x += s.as_str().width_cjk();
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
