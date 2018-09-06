extern crate rustbox;
extern crate unicode_width;
extern crate yae;

use std::default::Default;

use rustbox::{Color, RustBox};
use rustbox::Key;
use unicode_width::UnicodeWidthChar;

use yae::buffer::Buffer;


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
    let mut buf = Buffer::new(rustbox.width(), rustbox.height());
    buf.append_line("Hello World");
    buf.append_line("press ^q to quit");

    draw_buffer(&rustbox, &buf);
    rustbox.present();

    loop {
        match rustbox.poll_event(false) {
            Ok(rustbox::Event::KeyEvent(key)) => {
                match key {
                    Key::Ctrl('q') => {
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
            Ok(rustbox::Event::ResizeEvent(width, height)) => buf.resize(width as usize, height as usize),
            Err(e) => panic!("{}", e),
            _ => {}
        }
    }
}
