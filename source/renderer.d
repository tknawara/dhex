module renderer;

import std.file;
import std.stdio;
import terminal;
import hexreader;
import std.string : strip;
import std.conv : to;

void render(string filename) {
    File f;
    try {
        f = File(filename, "rb");
    }
    catch (Exception e) {
        writeln("Error: ", e.msg);
        return;
    }

    long fileSize = f.size();
    long currentOffset = 0;
    bool running = true;
    int rowsPerPage = 20;

    RawTerm* term = new RawTerm(0);
    write("\033[?25l"); // Hide Cursor

    while (running) {
        renderScreen(f, filename, currentOffset, rowsPerPage);

        char input = getChar();

        if (input == 0)
            break;

        switch (input) {
        case 'q':
            running = false;
            break;

        case 'g':
            destroy(*term);
            write("\033[?25h"); // Show cursor

            currentOffset = promptForJump(currentOffset, fileSize);

            term = new RawTerm(0);
            write("\033[?25l"); // Hide cursor
            break;

        case 'w':
            if (currentOffset >= 16)
                currentOffset -= 16;
            break;

        case 's':
            if (currentOffset + (rowsPerPage * 16) < fileSize)
                currentOffset += 16;
            break;

        case 27: // Arrows (ESC sequence)
            handleArrows(currentOffset, fileSize, rowsPerPage);
            break;

        default:
            break;
        }
    }

    // Cleanup
    destroy(*term);
    write("\033[?25h");
}

private:

void renderScreen(File f, string filename, long currentOffset, int rowsPerPage) {
    // Clear Screen (2J) and Move Home (H)
    write("\033[2J\033[H");

    // Header
    writeln("D-HEX VIEW :: ", filename);
    writeln("Controls: [w/Up] Scroll Up, [s/Down] Scroll Down, [g] Jump, [q] Quit");
    writefln("Offset: 0x%08X", currentOffset);
    writeln("---------------------------------------------------------------------");

    // Content
    f.seek(currentOffset);
    foreach (i; 0 .. rowsPerPage) {
        ubyte[16] buffer;
        ubyte[] chunk = f.rawRead(buffer);

        long lineOffset = currentOffset + (i * 16);

        if (chunk.length > 0) {
            hexreader.printHexLine(chunk, lineOffset);
        }
        else {
            writeln("~"); // Visual padding for end of file
        }

        // Stop if we hit EOF mid-page
        if (f.eof)
            break;
    }
}

long promptForJump(long currentOffset, long fileSize) {
    write("\n\033[33mGo to Offset (Hex): 0x\033[0m");
    string line = readln().strip();
    if (line.length == 0)
        return currentOffset; // Cancelled

    try {
        long target = to!long(line, 16);
        target = (target / 16) * 16;
        if (target >= 0 && target < fileSize) {
            return target;
        }
    }
    catch (Exception e) {
    }

    return currentOffset;
}

void handleArrows(ref long currentOffset, long fileSize, int rowsPerPage) {
    char c2 = getChar();
    if (c2 == '[') {
        char c3 = getChar();
        if (c3 == 'A') { // Up
            if (currentOffset >= 16)
                currentOffset -= 16;
        }
        else if (c3 == 'B') { // Down
            if (currentOffset + (rowsPerPage * 16) < fileSize)
                currentOffset += 16;
        }
    }
}
