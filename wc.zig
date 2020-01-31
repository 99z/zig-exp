const std = @import("std");

const Line = struct {
    chars: usize,
    words: usize,
};

const Output = struct {
    lines: usize,
    words: usize,
    chars: usize,
};

fn combine(a: Output, b: Line) Output {
    return Output{
        .lines = a.lines + 1,
        .words = a.words + b.words,
        .chars = a.chars + b.chars,
    };
}

fn toLine(l: []const u8) Line {
    var ti: std.mem.TokenIterator = std.mem.tokenize(l, " ");
    var count: usize = 0;

    while (ti.next()) |_| {
        count += 1;
    }

    return Line{
        .chars = l.len,
        .words = count,
    };
}

pub fn main() !void {
    const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;
    const args = try std.process.argsAlloc(allocator);
    const cwd = std.fs.cwd();

    for (args[1..]) |arg| {
        const file = cwd.openFile(arg, .{}) catch |err| {
            std.debug.warn("Unable to open file: {}\n", .{@errorName(err)});
            return err;
        };
        defer file.close();
        try wc_file(file);
    }
}

fn wc_file(file: std.fs.File) !void {
    var file_unbuf = file.inStream();
    const in = &std.io.BufferedInStream(@TypeOf(file_unbuf).Error).init(&file_unbuf.stream).stream;
    var o = Output{
        .lines = 0,
        .words = 0,
        .chars = 0,
    };

    var line_buf: [1024 * 4]u8 = undefined;
    while (try in.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        const l = toLine(line);
        o = combine(o, l);
    }

    std.debug.warn("{}\n", .{o});
}
