const std = @import("std");
const fs = std.fs;

fn errorCheck(allocator: std.mem.Allocator, arr: []u32) !bool {
    var no_error = try allocator.alloc(u32, arr.len - 1);
    defer allocator.free(no_error);
    for (0.., arr) |idx, _| {
        var i: usize = 0;
        var j: usize = 0;
        while (j < arr.len) : (j += 1) {
            if (idx != j) {
                no_error[i] = arr[j];
                i += 1;
            }
        }
        i = 0;
        var diff: i64 = 0;
        var last: i64 = 0;
        var increase: i64 = 0;
        var err: u32 = 0;
        while (i < no_error.len - 1) : (i += 1) {
            if (no_error[i] >= no_error[i + 1]) {
                increase = -1;
                diff = @abs(no_error[i] - no_error[i + 1]);
            } else {
                increase = 1;
                diff = @abs(no_error[i + 1] - no_error[i]);
            }
            if (last != 0 and last != increase) {
                err += 1;
            }
            last = increase;

            if (diff > 3 or diff < 1) {
                err += 1;
            }
        }
        if (err == 0) return true;
    }
    return false;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    try file.reader().readNoEof(buffer);
    var it = std.mem.splitScalar(u8, buffer, '\n');
    var arr = std.ArrayList(u32).init(allocator);
    var part_1: u32 = 0;
    var part_2: u32 = 0;
    defer arr.deinit();
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var it_num = std.mem.splitScalar(u8, line, ' ');
        var i: usize = 0;
        while (it_num.next()) |num| : (i += 1) {
            try arr.append(try std.fmt.parseInt(u32, num, 10));
        }
        i = 0;

        var err: u32 = 0;
        var diff: i64 = 0;
        var last: i64 = 0;
        var increase: i64 = 0;
        const slice = try arr.toOwnedSlice();
        while (i < slice.len - 1) : (i += 1) {
            if (slice[i] >= slice[i + 1]) {
                increase = -1;
                diff = @abs(slice[i] - slice[i + 1]);
            } else {
                increase = 1;
                diff = @abs(slice[i + 1] - slice[i]);
            }
            if (last != 0 and last != increase) {
                const check = try errorCheck(allocator, slice);
                if (check) {
                    part_2 += 1;
                    err += 5;
                    break;
                } else {
                    err += 5;
                    break;
                }
            }
            last = increase;

            if (diff > 3 or diff < 1) {
                const check = try errorCheck(allocator, slice);
                if (check) {
                    part_2 += 1;
                    err += 5;
                    break;
                } else {
                    err += 5;
                    break;
                }
            }
        }
        if (err == 0) part_1 += 1;
        allocator.free(slice);
    }
    std.debug.print("part_1: {d}\n", .{part_1});
    std.debug.print("part_2: {d}\n", .{part_1 + part_2});
}
