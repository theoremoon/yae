import termbox;
import yae.buffer;
import dcharwidth;

void draw(Buffer buf)
{
  clear();

  int y = 0;
  foreach (line; buf.lines) {
    int x = 0;
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
import std.stdio;
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
        if (e.key == Key.backspace2) {
          buf.deleteLeftN(1, true);
          buf.draw();
          break;
        }
        auto c = cast(dchar)e.ch;
        if (e.key == Key.enter) {
          c = '\n';
        }
        else if (e.key == Key.space) {
          c = ' ';
        }
        buf.insertChar(c);
        buf.draw();
        break;
      case EventType.resize:
        break;
      case EventType.mouse:
        break main_loop;
    }
  }

}
