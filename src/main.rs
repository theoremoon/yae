extern crate ncurses;

use ncurses::*;

fn main() {
    // init screen and print Hello World at top-left, wait-key, exit
    initscr();
    printw("Hello World");
    refresh();
    getch();
    endwin();
}
