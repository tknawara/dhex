module renderer;

void render(string filename) {
    import std.file;
    import std.stdio;
    import terminal;
    import hexreader;

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

    auto term = RawTerm(0);

    // Hide Cursor (ANSI Code)
    write("\033[?25l");

    while (running) {
        // 1. CLEAR SCREEN (ANSI Code: \033[2J clears, \033[H moves home)
        write("\033[2J\033[H");

        writeln("D-HEX VIEW :: ", filename);
        writeln("Controls: [w/Up] up, [s/Down] Down, [q] Quit");
        writeln("----------------------------------------------");

        f.seek(currentOffset);

        foreach (i; 0 .. rowsPerPage) {
            ubyte[16] buffer;
            ubyte[] chunk = f.rawRead(buffer);

            long lineOffset = currentOffset + (i * 16);
            if (chunk.length > 0) {
                printHexLine(chunk, lineOffset);
            }
            else {
                writeln("~");
            }

            if (f.eof)
                break;
        }

        char input = getChar();
        if (input == 'q') {
            running = false;
        }
        // Handle arrow keys
        // Esc (27) followed by '[' follwed by ('A' | 'B')
        else if (input == 27) {
            char c2 = getChar();
            if (c2 == '[') {
                char c3 = getChar();
                if (c3 == 'A') {
                    if (currentOffset >= 16)
                        currentOffset -= 16;
                }
                else if (c3 == 'B') {
                    if (currentOffset + (rowsPerPage * 16) < fileSize) {
                        currentOffset += 16;
                    }
                }
            }
        }
        else if (input == 's') {
            if (currentOffset + (rowsPerPage * 16) < fileSize) {
                currentOffset += 16;
            }
        }
        else if (input == 'w') {
            if (currentOffset >= 16) {
                currentOffset -= 16;
            }
        }
    }
}
