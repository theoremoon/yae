import termbox;
import dcharwidth;

struct Cursor {
  public:
    int x, y;
}

import std.array;
import std.range;
class Buffer {
  public:
    dstring[] lines;
    Cursor cursor;

    this() {
      this.cursor.x = 0;
      this.cursor.y = 0;
      this.lines = [""];
    }

    void insert(S)(int x, int y, S s) {
      if (0 < y || x < 0) { return; }
      if (this.lines.length <= y) {
        this.lines ~= ""d.repeat.take(y - this.lines.length + 1).array;
      }
      if (this.lines[y].length < x) {
        this.lines[y] ~= (cast(dchar)' ').repeat.take(x - this.lines[y].length).array;
      }

      this.lines[y].insertInPlace(x, s.to!(dchar[]));
    }

    void insertChar(dchar c) {
      this.insert(cursor.x, cursor.y, c);
      cursor.x++;
    }
}

void draw(Buffer buf)
{
  int x = 0, y = 0;
  foreach (line; buf.lines) {
    foreach (dchar c; line) {
      setCell(x, y, c, Color.basic, Color.basic);
      x += c.dcharWidth();
    }
    y++;
  }

  int vx = buf.lines[buf.cursor.y][0..buf.cursor.x].stringWidth();
  setCursor(vx, buf.cursor.y);

  flush();
}

import std.conv;
import std.stdio;
void main()
{
  auto buf = new Buffer();

  init();
  clear();

  setInputMode(InputMode.esc | InputMode.mouse);

  int x = 0, y = 0;
  setCursor(x, y);
  flush();

main_loop:
  while (true) {

    Event e;
    pollEvent(&e);

    final switch (e.type) {
      case EventType.key:
        auto c = cast(dchar)e.ch;
        buf.insertChar(c);
        buf.draw();
        break;
      case EventType.resize:
        break;
      case EventType.mouse:
        break main_loop;
    }
  }

  shutdown();
}
