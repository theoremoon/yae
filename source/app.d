import termbox;
import dcharwidth;

void main()
{
  init();
  clear();

  setInputMode(InputMode.esc | InputMode.mouse);

  int x = 0, y = 0;
  auto s = "こんにちはピヨ";
  foreach (dchar c; s) {
    setCell(x, y, c, Color.basic, Color.basic);
    x += c.dcharWidth();
  }
  setCursor(x, y);
  flush();

main_loop: while (true) {
    dchar k;

    Event e;
    pollEvent(&e);

    final switch (e.type) {
      case EventType.key:
        k = cast(dchar)e.ch;
        setCell(x, y, k, Color.basic, Color.basic);
        x += k.dcharWidth();
        setCursor(x, y);
        flush();
        break;
      case EventType.resize:
        break;
      case EventType.mouse:
        break main_loop;
    }
  }

  shutdown();
}
