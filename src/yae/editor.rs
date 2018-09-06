extern crate rustbox;


use std::default::Default;
use buffer::Buffer;
use rustbox::{RustBox, Color};
use unicode_width::UnicodeWidthChar;

pub struct Editor {
    pub buf : Buffer,
    pub rustbox : RustBox,
}



impl Editor {
    pub fn new() -> Editor {
        let rustbox = match RustBox::init(Default::default()) {
            Result::Ok(v) => v,
            Result::Err(e) => panic!("{}", e),
        };
        let buf = Buffer::new();
        Editor {
            rustbox: rustbox,
            buf: buf,
        }
    }

    pub fn draw_buffer(&self) {
        self.rustbox.clear();

        for (y, line) in self.buf.lines.iter().enumerate() {
            let mut x = 0;
            for c in line.chars() {
                let s = c.to_string();
                self.rustbox.print(x, y, rustbox::RB_NORMAL, Color::Default, Color::Default, s.as_str());
                x += c.width_cjk().unwrap_or(0);
            }
        }

        self.rustbox.set_cursor(self.buf.vcursor.x as isize, self.buf.vcursor.y as isize);
        self.rustbox.present();
    }

    pub fn append_line(&mut self, s: &str) {
        self.buf.append_line(s);
        self.draw_buffer();
    }

    pub fn append_char(&mut self, c: char) {
        self.buf.append_char(c);
        self.draw_buffer();
    }

    pub fn cursor_next(&mut self) {
        self.buf.cursor_next();
        self.draw_buffer();
    }

    pub fn cursor_prev(&mut self) {
        self.buf.cursor_prev();
        self.draw_buffer();
    }

    pub fn del_left(&mut self) {
        self.buf.del_left();
        self.draw_buffer();
    }

    pub fn event_loop(&self) -> rustbox::EventResult {
        self.rustbox.poll_event(false)
    }

    pub fn resize(&mut self, _ : usize, _ : usize) {
        // do nothing
    }
}
