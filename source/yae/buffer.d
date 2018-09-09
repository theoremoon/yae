module yae.buffer;

import yae.cursor;

import std.array;
import std.range;
import std.traits;
import std.string;
import std.conv;
import std.uni;
import std.algorithm;

class Buffer {
  public:
    dstring[] lines;
    Cursor cursor;

    this() {
      this.cursor.x = 0;
      this.cursor.y = 0;
      this.lines = [""];
    }

    /// insert new line at (0, y)
    /// this function doesn't change cursor position
    void insertLineAt(S)(int y, S s) {
      if (y < 0) { return; }
      if (this.lines.length <= y) {
        this.lines ~= ""d.repeat.take(y - this.lines.length).array;
      }
      this.lines.insertInPlace(y, s.to!(dstring));
    }

    /// insert character or string at (x, y)
    /// this function doesn't change cursor position
    void insertAt(S)(int x, int y, S s) {
      if (y < 0 || x < 0) { return; }

      if (this.lines.length <= y) {
        this.lines ~= ""d.repeat.take(y - this.lines.length + 1).array;
      }
      if (this.lines[y].length < x) {
        this.lines[y] ~= (cast(dchar)' ').repeat.take(x - this.lines[y].length).array;
      }

      static if (isArray!(S)) {
        // newline character don't be included in line
        auto ls = s.splitLines;
        lines[y].insertInPlace(x, ls[0]);

        foreach (l; ls[1..$]) {
          y++;
          this.insertLineAt(y, l);
        }
      }
      else {
        this.lines[y].insertInPlace(x, s);
      }
    }

    unittest {
      auto buf = new Buffer();
      buf.insertAt(0, 0, "HELLO WORLD");

      assert(buf.lines.equal(["HELLO WORLD"d]));
      buf.insertAt(0, 0, "Welcome ");
      assert(buf.lines.equal(["Welcome HELLO WORLD"d]));

      buf.insertAt(0, 3, "Goodbye");
      assert(buf.lines.equal(["Welcome HELLO WORLD"d, ""d, ""d, "Goodbye"d]));

      buf.insertAt(1, 1, "wai wai");
      assert(buf.lines.equal(["Welcome HELLO WORLD"d, " wai wai"d, ""d, "Goodbye"d]));
    }

    unittest {
      auto buf = new Buffer();

      buf.insertAt(0, 0, "Hello\nWorld!!");
      assert(buf.lines.equal(["Hello"d, "World!!"d]));

      buf.insertAt(0, 1, "Hello\nWorld!!");
      assert(buf.lines.equal(["Hello"d, "HelloWorld!!"d, "World!!"d]));
    }

    /// insert character at cursor position and set cursor next position
    void insertChar(dchar c) {
      if (c == '\n') {
        this.insertLineAt(cursor.y + 1, "");
        cursor.x = 0;
        cursor.y++;
      }
      else {
        this.insertAt(cursor.x, cursor.y, c);
        cursor.x++;
      }
    }

    unittest {
      auto buf = new Buffer();

      buf.insertChar('H');
      buf.insertChar('e');
      buf.insertChar('l');
      buf.insertChar('l');
      buf.insertChar('o');

      assert(buf.lines.equal(["Hello"d]));
      assert(buf.cursor.x == 5);
      assert(buf.cursor.y == 0);

      buf.insertChar('\n');

      assert(buf.lines.equal(["Hello"d, ""d]));
      assert(buf.cursor.x == 0);
      assert(buf.cursor.y == 1);
    }

    void insertStr(S)(S s) {
      foreach (dchar c; s) {
        this.insertChar(c);
      }
    }

    unittest {
      auto buf = new Buffer();

      buf.insertStr("Hello");
      assert(buf.lines.equal(["Hello"d]));
      assert(buf.cursor.x == 5);
      assert(buf.cursor.y == 0);

      buf.insertStr("\nWorld");
      assert(buf.lines.equal(["Hello"d, "World"d]));
      assert(buf.cursor.x == 5);
      assert(buf.cursor.y == 1);
    }

    /// delete n characters left of cursor and cursor move left
    /// delete newline character too if backline is true
    void deleteLeftN(int n, bool backline=true) {
      if (n <= 0) {
        return;
      }

      if (cursor.x <= n) {
        int n2 = n - cursor.x;
        lines[cursor.y] = lines[cursor.y][cursor.x..$];
        cursor.x = 0;
        if (backline && cursor.y > 0) {
          this.lines = this.lines.remove(cursor.y);
          cursor.y--;
          cursor.x = cast(int)lines[cursor.y].length;
          this.deleteLeftN(n2 - 1, backline);
        }
      }
      else {
        lines[cursor.y] = lines[cursor.y][0..cursor.x-n] ~ lines[cursor.y][cursor.x..$];
        cursor.x -= n;
      }
    }

    unittest {
      auto buf = new Buffer();

      buf.insertStr("Hello\nWorld");
      buf.deleteLeftN(1);
      assert(buf.lines.equal(["Hello"d, "Worl"d]));
      assert(buf.cursor.x == 4);

      buf.deleteLeftN(2);
      assert(buf.lines.equal(["Hello"d, "Wo"d]));
      assert(buf.cursor.x == 2);

      buf.deleteLeftN(3, false);
      assert(buf.lines.equal(["Hello"d, ""d]));
      assert(buf.cursor.x == 0);

      buf.deleteLeftN(3, true);
      assert(buf.lines.equal(["Hel"d]));
      assert(buf.cursor.x == 3);
    }
}

string dumpStr(Buffer buf) {
  string[] s;

  foreach (line; buf.lines) {
    s ~= '"' ~ line.to!string ~ '"';
  }
  return s.join("\n");
}
