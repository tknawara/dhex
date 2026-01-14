module terminal;

import core.sys.posix.termios;
import core.sys.posix.unistd;
import std.stdio;

struct RawTerm {
    private termios originalState;

    this(int dummy) {
        tcgetattr(STDIN_FILENO, &originalState);
        termios raw = originalState;

        // DISABLING FLAGS:
        // ICANON: Turn off canonical mode (input is processed line-by-line)
        // ECHO:   Turn off echoing (don't print 'w' when I press 'w')
        raw.c_lflag &= ~(ICANON | ECHO);
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
    }

    ~this() {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &originalState);
        write("\033[?25h");
    }
}

char getChar() {
    char c;
    long n = read(STDIN_FILENO, &c, 1);
    if (n <= 0)
        return 0;
    return c;
}
