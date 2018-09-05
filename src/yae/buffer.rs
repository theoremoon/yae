
use cursor::Cursor;
use unicode_width::UnicodeWidthChar;

pub struct Buffer {
    pub lines: Vec<String>,
    pub cursor: Cursor,
    pub vcursor: Cursor,

    pub cols: usize,
    pub rows: usize,
}

impl Buffer {
    pub fn new(cols: usize, rows: usize) -> Buffer {
        Buffer{
            lines: Vec::new(),
            cursor: Cursor::new(0, 0),
            vcursor: Cursor::new(0, 0),
            cols: cols,
            rows: rows,
        }
    }

    pub fn resize(&mut self, cols: usize, rows: usize) {
        self.cols = cols;
        self.rows = rows;
    }

    pub fn append_line(&mut self, s : &str) {
        self.append_str(s);
        self.append_char('\n');
    }

    pub fn append_str(&mut self, s : &str) {
        for c in s.chars() {
            self.append_char(c);
        }
    }

    pub fn append_char(&mut self, c : char) {
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

    pub fn cursor_nextline(&mut self) {
        if self.cursor.y < self.lines.len() - 1 {
            self.cursor.y += 1;
            self.cursor.x = 0;

            self.vcursor.y += 1;
            self.vcursor.x = 0;
        }
    }

    pub fn cursor_next(&mut self) {
        let next_char = self.lines[self.cursor.y][self.cursor.x..].chars().nth(0);
        match next_char {
            Some(c) => {
                self.cursor.x += c.len_utf8();
                self.vcursor.x += c.width_cjk().unwrap_or(0);
            },
            None => { self.cursor_nextline(); }
        }
    }

    pub fn cursor_prev(&mut self) {
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

    pub fn del_left(&mut self) {
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
