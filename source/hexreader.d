module hexreader;

// ANSI Color Codes
const string CYAN = "\033[36m";
const string GREEN = "\033[32m";
const string YELLOW = "\033[33m";
const string GREY = "\033[90m"; // Bright Black (looks like grey)
const string RESET = "\033[0m";

void printHexLine(ubyte[] chunk, long offset) {
    import std.stdio;
    import std.ascii : isPrintable;

    write(CYAN);
    writef("%08X  ", offset);
    write(RESET);

    write(GREEN);

    foreach (i, b; chunk) {
        if (b == 0)
            write(GREY); // Dim the nulls
        else
            write(GREEN);
        writef("%02X ", b);
        if (i == 7)
            write(" ");
    }

    write(RESET);

    if (chunk.length < 16) {
        long missing = 16 - chunk.length;
        long spaces = missing * 3;
        if (chunk.length < 8)
            spaces += 1;
        foreach (k; 0 .. spaces)
            write(" ");
    }

    write(GREY, " |", RESET);

    write(YELLOW);
    foreach (b; chunk) {
        char c = cast(char) b;
        if (isPrintable(c)) {
            write(c);
        }
        else {
            write(GREY, ".", YELLOW);
        }
    }

    write(GREY, "|", RESET);
    writeln();
}
