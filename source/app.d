import std.stdio;
import renderer;

void main(string[] args) {
	if (args.length < 2) {
		writeln("Usage: dhex <file>");
		return;
	}

	string filename = args[1];
	render(filename);
}
