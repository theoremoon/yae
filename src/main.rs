extern crate rustbox;
extern crate unicode_width;

use std::default::Default;

use rustbox::{Color, RustBox};
use rustbox::Key;

use unicode_width::UnicodeWidthChar;

struct Cursor {
    x: usize,
    y: usize
}

impl Cursor {
    pub fn new(x: usize, y: usize) -> Cursor {
        Cursor{x: x, y: y}
    }
}

struct Buffer {
    lines: Vec<String>,
    cursor: Cursor,
    vcursor: Cursor,
}

impl Buffer {
    pub fn new() -> Buffer {
        Buffer{
            lines: Vec::new(),
            cursor: Cursor::new(0, 0),
            vcursor: Cursor::new(0, 0),
        }
    }

    fn append_line(&mut self, s : &str) {
        self.append_str(s);
        self.append_char('\n');
    }

    fn append_str(&mut self, s : &str) {
        for c in s.chars() {
            self.append_char(c);
        }
    }

    fn append_char(&mut self, c : char) {
        if self.lines.len() == 0 {
            self.lines.push(String::from(""));
        }

        if c == '\n' {
            self.lines.insert(self.cursor.y + 1, String::from(""));
            self.cursor_nextline();
        }
        else {
            self.lines[self.cursor.y].insert(self.cursor.x, c);
            self.cursor_next();
        }
    }

    fn cursor_nextline(&mut self) {
        if self.cursor.y < self.lines.len() - 1 {
            self.cursor.y += 1;
            self.cursor.x = 0;

            self.vcursor.y += 1;
            self.vcursor.x = 0;
        }
    }

    fn cursor_next(&mut self) {
        let next_char = self.lines[self.cursor.y][self.cursor.x..].chars().nth(0);
        match next_char {
            Some(c) => {
                self.cursor.x += c.len_utf8();
                self.vcursor.x += c.width_cjk().unwrap_or(0);
            },
            None => { self.cursor_nextline(); }
        }
    }

    fn cursor_prev(&mut self) {
        if self.cursor.x == 0 && self.cursor.y > 0 {
            self.cursor.y -= 1;
            self.cursor.x = self.lines[self.cursor.y].len();

            self.vcursor.y -= 1;
            self.vcursor.x = self.lines[self.cursor.y].chars()
                .fold(0, |sum, x| sum + x.width_cjk().unwrap_or(0));
        }
        else {
            match self.lines[self.cursor.y][..self.cursor.x].chars().next_back() {
                Some(c) => {
                    self.cursor.x -= c.len_utf8();
                    self.vcursor.x -= c.width_cjk().unwrap_or(0);
                }
                None => {},
            }
        }
    }

    fn del_left(&mut self) {
        if self.cursor.x == 0 {
            if self.cursor.y > 0 {
                let s = self.lines[self.cursor.y].clone();
                self.lines[self.cursor.y - 1].push_str(s.as_str());
                self.lines.remove(self.cursor.y);
                self.cursor_prev();
            }
        }
        else {
            let s = self.lines[self.cursor.y].clone();

            let mut left_chars = s[..self.cursor.x].chars();
            let right_chars = s[self.cursor.x..].chars();
            let removed_char = left_chars.next_back().unwrap_or('\0');

            self.lines[self.cursor.y] = String::from(left_chars.as_str());
            self.lines[self.cursor.y].push_str(right_chars.as_str());

            self.cursor.x -= removed_char.len_utf8();
            self.vcursor.x -= removed_char.width_cjk().unwrap_or(0);
        }
    }
}

fn draw_buffer(rustbox : &RustBox, buf : &Buffer) {
    rustbox.clear();

    for (y, line) in buf.lines.iter().enumerate() {
        let mut x = 0;
        for c in line.chars() {
            let s = c.to_string();
            rustbox.print(x, y, rustbox::RB_NORMAL, Color::Default, Color::Default, s.as_str());
            x += c.width_cjk().unwrap_or(0);
        }
    }

    rustbox.set_cursor(buf.vcursor.x as isize, buf.vcursor.y as isize);
}


fn main() {
    let rustbox = match RustBox::init(Default::default()) {
        Result::Ok(v) => v,
        Result::Err(e) => panic!("{}", e),
    };
    let mut buf = Buffer::new();
    buf.append_line("Hello World");
    buf.append_line("press q to quit");

    draw_buffer(&rustbox, &buf);
    rustbox.present();

    loop {
        match rustbox.poll_event(false) {
            Ok(rustbox::Event::KeyEvent(key)) => {
                match key {
                    Key::Char('q') => {
                        break;
                    }
                    Key::Char(c) => {
                        buf.append_char(c);
                        draw_buffer(&rustbox, &buf);
                        rustbox.present();
                    },
                    Key::Enter => {
                        buf.append_char('\n');
                        draw_buffer(&rustbox, &buf);
                        rustbox.present();
                    },
                    Key::Left => {
                        buf.cursor_prev();
                        draw_buffer(&rustbox, &buf);
                        rustbox.present();
                    }
                    Key::Right => {
                        buf.cursor_next();
                        draw_buffer(&rustbox, &buf);
                        rustbox.present();
                    }
                    Key::Backspace => {
                        buf.del_left();
                        draw_buffer(&rustbox, &buf);
                        rustbox.present();
                    }
                    _ => { }
                }
            },
            Err(e) => panic!("{}", e),
            _ => {}
        }
    }
}
