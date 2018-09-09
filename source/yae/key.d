module yae.key;

import termbox : termKey = Key, Event, EventType;
import std.conv;

enum ModKey {
  None = 0,
  Alt = 1,
  Ctrl = 2,
}

enum SpecialKey {
  F1     = 0xffff-0,
  F2     = 0xffff-1,
  F3     = 0xffff-2,
  F4     = 0xffff-3,
  F5     = 0xffff-4,
  F6     = 0xffff-5,
  F7     = 0xffff-6,
  F8     = 0xffff-7,
  F9     = 0xffff-8,
  F10    = 0xffff-9,
  F11    = 0xffff-10,
  F12    = 0xffff-11,
  Insert = 0xffff-12,
  Del    = 0xffff-13,
  Home   = 0xffff-14,
  End    = 0xffff-15,
  Pgup   = 0xffff-16,
  Pgdn   = 0xffff-17,
  Up     = 0xffff-18,
  Down   = 0xffff-19,
  Left   = 0xffff-20,
  Right  = 0xffff-21,

  Enter = 1,
  Esc = 2,
  Backspace = 3,
  Tab = 4,
}

string specialKeyToString(uint k) {
  string[uint] map = [
    SpecialKey.F1:       "F1",
    SpecialKey.F2:       "F2",
    SpecialKey.F3:       "F3",
    SpecialKey.F4:       "F4",
    SpecialKey.F5:       "F5",
    SpecialKey.F6:       "F6",
    SpecialKey.F7:       "F7",
    SpecialKey.F8:       "F8",
    SpecialKey.F9:       "F9",
    SpecialKey.F10:      "F10",
    SpecialKey.F11:      "F11",
    SpecialKey.F12:      "F12",
    SpecialKey.Insert:   "Insert",
    SpecialKey.Del:      "Del",
    SpecialKey.Home:     "Home",
    SpecialKey.End:      "End",
    SpecialKey.Pgup:     "Pgup",
    SpecialKey.Pgdn:     "Pgdn",
    SpecialKey.Up:       "Up",
    SpecialKey.Down:     "Down",
    SpecialKey.Left:     "Left",
    SpecialKey.Right:    "Right"
      ];
  return map[k];
}

struct Key {
  public:
    uint code;
    uint sp;
    ubyte mod;

    this(uint code, uint sp = 0, ubyte mod = ModKey.None) {
      this.code =code;
      this.sp = sp;
      this.mod = mod;
    }

    static Key ctrl(uint code) {
      return Key(code, 0, ModKey.Ctrl);
    }

    Key withCtrl() {
      return Key(code, sp, mod | ModKey.Ctrl);
    }
    Key withAlt() {
      return Key(code, sp, mod | ModKey.Alt);
    }

    bool isAlt() {
      return (this.mod & ModKey.Alt) != 0;
    }
    bool isCtrl() {
      return (this.mod & ModKey.Ctrl) != 0;
    }
    bool isEnter() {
      return (this.sp == SpecialKey.Enter && !this.isCtrl) || (this.isCtrl && this.code == 'm') || (!this.isCtrl && this.code == '\n');
    }
    bool isTab() {
      return this.sp == SpecialKey.Tab || (this.isCtrl && this.code == 'i');
    }
    bool isBackspace() {
      return this.sp == SpecialKey.Backspace || (this.isCtrl && this.code == '8');
    }
    bool isEsc() {
      return this.sp == SpecialKey.Esc || (this.isCtrl && (this.code == '3' || this.code == '['));
    }
    bool isCtrlTilde() {
      return this.isCtrl && (this.code == '~' || this.code == '2');
    }
    bool isCtrlBackslash() {
      return this.isCtrl && (this.code == '\\' || this.code == '4');
    }
    bool isCtrlRightBracket() {
      return this.isCtrl && (this.code == ']' || this.code == '5');
    }
    bool isCtrlSlash() {
      return this.isCtrl && (this.code == '/' || this.code == '_' || this.code == '7');
    }

    bool opEquals(Key k) {
      if (this.isAlt != k.isAlt) {
        return false;
      }

      if (this.isEnter && k.isEnter) { return true; }
      if (this.isTab && k.isTab) { return true; }
      if (this.isBackspace && k.isBackspace) { return true; }
      if (this.isEsc && k.isEsc) { return true; }

      if (this.isCtrlTilde && k.isCtrlTilde) { return true; }
      if (this.isCtrlBackslash && k.isCtrlBackslash) { return true; }
      if (this.isCtrlRightBracket && k.isCtrlRightBracket) { return true; }
      if (this.isCtrlSlash && k.isCtrlSlash) { return true; }

      if (this.code == k.code && this.sp == k.sp && this.mod == k.mod) {
        return true;
      }

      return false;
    }
    unittest {
      assert(Key('a', 0, 0) == Key('a', 0, 0));
      assert(Key('a', 0, ModKey.Alt) == Key('a', 0, ModKey.Alt));
      assert(Key('a', 0, ModKey.Ctrl) == Key('a', 0, ModKey.Ctrl));
      assert(Key('a', 0, ModKey.Alt | ModKey.Ctrl) == Key('a', 0, ModKey.Alt | ModKey.Ctrl));

      assert(Key('a', 0, 0) != Key('A', 0, 0));
      assert(Key('a', 0, 0) != Key('a', 0, ModKey.Alt));
      assert(Key('a', 0, ModKey.Alt) != Key('b', 0, ModKey.Alt));
      assert(Key('a', 0, ModKey.Alt) != Key('a', 0, ModKey.Ctrl));
      assert(Key('a', 0, ModKey.Alt) != Key('a', 0, ModKey.Ctrl | ModKey.Alt));

      assert(Key(0, SpecialKey.Enter, 0) == Key(0, SpecialKey.Enter, 0));
      assert(Key(0, SpecialKey.Enter, 0) == Key('m', 0, ModKey.Ctrl));
      assert(Key(0, SpecialKey.Enter, 0) == Key('\n', 0, 0));
      assert(Key(0, SpecialKey.Esc, 0) == Key('[', 0, ModKey.Ctrl));
      assert(Key(0, SpecialKey.Esc, 0) == Key('3', 0, ModKey.Ctrl));

      assert(Key(0, SpecialKey.Enter, ModKey.Ctrl) != Key('m', 0, ModKey.Ctrl));
    }

    static Key Enter() {
      return Key('\n', SpecialKey.Enter, 0);
    }
    static Key Backspace() {
      return Key('\b', SpecialKey.Backspace, 0);
    }

    string toString() {
      char[] s = [];
      if (this.isAlt) { s ~= "M-"; }
      if (this.isEnter) { s ~= "Enter"; }
      else if (this.isTab) { s ~= "Tab"; }
      else if (this.isBackspace) { s ~= "BS"; }
      else if (this.isEsc) { s ~= "ESC"; }
      else if (this.isCtrlTilde) { s ~= "~"; }
      else if (this.isCtrlBackslash) { s ~= "\\"; }
      else if (this.isCtrlRightBracket) { s ~= "]"; }
      else if (this.isCtrlSlash) { s ~= "/"; }
      else {
        if (this.isCtrl) { s ~= "C-"; }
        s ~= (cast(dchar)this.code).to!string;
      }

      return s.to!string;
    }
    unittest {
      assert((Key('a')).toString() == "a");
      assert((Key('a', 0, ModKey.Alt)).toString() == "M-a");
      assert((Key('a', 0, ModKey.Ctrl | ModKey.Alt)).toString() == "M-C-a");
      assert((Key('i', 0, ModKey.Ctrl)).toString() == "Tab");
      assert(this.Backspace.toString() == "BS");
      assert(this.Enter.toString() == "Enter");
    }
}

Key toYaeKey(Event e) {
  if (e.type != EventType.key) {
    return Key(0, 0, 0);
  }

  if (e.key == 0) {
    return Key(e.ch, 0, e.mod);
  }

  if (termKey.arrowRight <= e.key && e.key <= termKey.f1) {
    return Key(0, e.key, e.mod);
  }
  if (e.key == termKey.space) {
    return Key(' ', 0, e.mod);
  }
  if (e.key == termKey.tab) {
    return Key('\t', 0, e.mod);
  }
  if (e.key == termKey.enter) {
    return Key('\n', SpecialKey.Enter, e.mod);
  }
  if (e.key == termKey.esc) {
    return Key('\x1b', SpecialKey.Esc, e.mod);
  }
  if (e.key == termKey.backspace2) {
    return Key('\b', SpecialKey.Backspace, e.mod);
  }
  if (e.key == termKey.ctrlTilde) {
    return Key('~', 0, e.mod | ModKey.Ctrl);
  }
  if (e.key == termKey.ctrlBackslash) {
    return Key('\\', 0, e.mod | ModKey.Ctrl);
  }
  if (e.key == termKey.ctrlRsqBracket) {
    return Key(']', 0, e.mod | ModKey.Ctrl);
  }
  if (e.key == termKey.ctrlSlash) {
    return Key('/', 0, e.mod | ModKey.Ctrl);
  }
  // this is only number key not clashed with any other special characters
  if (e.key == termKey.ctrl6) {
    return Key('6', 0, e.mod | ModKey.Ctrl);
  }
  if (termKey.ctrlA <= e.key && e.key <= termKey.ctrlZ) {
    return Key(0x60 + e.key, 0, e.mod | ModKey.Ctrl);
  }

  return Key(e.key, 0, e.mod);
}
unittest {
  assert(Event(EventType.key, 0, termKey.ctrlQ, 0, 0, 0, 0, 0).toYaeKey() == Key.ctrl('q'));
  assert(Event(EventType.key, 0, termKey.enter, 0, 0, 0, 0, 0).toYaeKey() == Key.Enter);
  assert(Event(EventType.key, 0, termKey.backspace2, 0, 0, 0, 0, 0).toYaeKey() == Key.Backspace);
}
