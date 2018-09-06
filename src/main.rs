extern crate rustbox;
extern crate yae;

use rustbox::Key;
use yae::editor::Editor;


fn main() {
    let mut editor = Editor::new();

    editor.append_line("Hello World");
    editor.append_line("press ^q to quit");
    editor.draw_buffer();

    loop {
        match editor.event_loop() {
            Ok(rustbox::Event::KeyEvent(key)) => {
                match key {
                    Key::Ctrl('q') => {
                        break;
                    }
                    Key::Char(c) => {
                        editor.append_char(c);
                    },
                    Key::Enter => {
                        editor.append_char('\n');
                    },
                    Key::Left => {
                        editor.cursor_prev();
                    }
                    Key::Right => {
                        editor.cursor_next();
                    }
                    Key::Backspace => {
                        editor.del_left();
                    }
                    _ => { }
                }
            },
            Ok(rustbox::Event::ResizeEvent(width, height)) => editor.resize(width as usize, height as usize),
            Err(e) => panic!("{}", e),
            _ => {}
        }
    }
}
