import termbox;
import yae.buffer;
import yae.key : Key, toYaeKey;
import dcharwidth;

void draw(Buffer buf)
{
  clear();

  long w = width();
  int y = 0;
  foreach (line; buf.lines) {
    int x = 0;
    foreach (dchar c; line) {
      auto cw = c.dcharWidth;
      if (x + cw > w) {
        y++;
        x = 0;
      }
      setCell(x, y, c, Color.basic, Color.basic);
      x += cw;
    }
    y++;
  }

  int cx = buf.lines[buf.cursor.y][0..buf.cursor.x].stringWidth();
  int cy = cast(int)buf.cursor.y;
  while (cx > w) {
    cy++;
    cx -= w;
  }
  setCursor(cx, cy);

  flush();
}

import std.stdio;
import std.format;
void main()
{
  auto buf = new Buffer();

  init();
  scope(exit) shutdown();
  clear();

  setInputMode(InputMode.esc | InputMode.mouse);

  int x = 0, y = 0;
  setCursor(x, y);
  flush();

  buf.insertAt(5, 10, "HELLO WORLD");
  buf.draw();

main_loop:
  while (true) {

    Event e;
    pollEvent(&e);

    final switch (e.type) {
      case EventType.key:
        auto k = e.toYaeKey;
        if (k == Key.ctrl('q')) {
          break main_loop;
        }
        else if (k == Key.ctrl('a')) {
          buf.setCursor(0, buf.cursor.y);
        }
        else if (k == Key.ctrl('e')) {
          buf.setCursor(int.max, buf.cursor.y);
        }
        else if (k == Key.ctrl('h')) {
          buf.moveCursorLeft();
        }
        else if (k == Key.ctrl('n')) {
          buf.moveCursorDown();
        }
        else if (k == Key.ctrl('p')) {
          buf.moveCursorUp();
        }
        else if (k == Key.ctrl('l')) {
          buf.moveCursorRight();
        }
        else if (k == Key.Backspace) {
          buf.deleteLeftN(1, true);
        }
        else if (k.code != 0) {
          buf.insertChar(cast(dchar)k.code);
        }
        buf.draw();
        break;
      case EventType.resize:
        break;
      case EventType.mouse:
        break main_loop;
    }
  }

}
