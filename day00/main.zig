const std = @import("std");
const fs = std.fs;
const io = std.io;
const fmt = std.fmt;

fn partition(ptr: *[]u32, low: usize, high: usize) !usize {
    var arr = ptr.*;
    const pivot = arr[high];
    var i = low;
    var j = low;

    while (j < high) : (j += 1) {
        if (arr[j] <= pivot) {
            std.mem.swap(u32, &arr[i], &arr[j]);
            i += 1;
        }
    }
    std.mem.swap(u32, &arr[i], &arr[high]);
    ptr.* = arr;
    return i;
}

fn qs(ptr: *[]u32, low: usize, high: usize) !void {
    if (low < high) {
        const p = try partition(ptr, low, high);
        try qs(ptr, low, @min(p, p -% 1));
        try qs(ptr, p + 1, high);
    }
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

    var l_list = std.ArrayList(u32).init(allocator);
    var r_list = std.ArrayList(u32).init(allocator);

    defer l_list.deinit();
    defer r_list.deinit();
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var num1: []u8 = undefined;
        var num2: []u8 = undefined;
        var idx: usize = 0;
        while (idx < line.len) : (idx += 1) {
            if (line[idx] == ' ') {
                num1 = try allocator.dupe(u8, line[0..idx]);
                while (line[idx] == ' ') : (idx += 1) {}
                num2 = try allocator.dupe(u8, line[idx..]);
            }
        }
        try l_list.append(try fmt.parseInt(u32, num1, 10));
        try r_list.append(try fmt.parseInt(u32, num2, 10));
        allocator.free(num1);
        allocator.free(num2);
    }
    var l_pointer = try l_list.toOwnedSlice();
    var r_pointer = try r_list.toOwnedSlice();
    defer allocator.free(l_pointer);
    defer allocator.free(r_pointer);

    try qs(&l_pointer, 0, l_pointer.len - 1);
    try qs(&r_pointer, 0, r_pointer.len - 1);
    var sum: u32 = 0;
    for (0.., l_pointer) |idx, num| {
        if (num < r_pointer[idx]) {
            sum += r_pointer[idx] - num;
        } else {
            sum += num - r_pointer[idx];
        }
    }
    std.debug.print("part_1: {d}\n", .{sum});
    const last_num1 = l_pointer[l_pointer.len - 1];
    const last_num2 = r_pointer[r_pointer.len - 1];
    var mul_table: []u32 = undefined;

    mul_table = if (last_num1 > last_num2) try allocator.alloc(u32, last_num1 + 1) else try allocator.alloc(u32, last_num2 + 1);
    defer allocator.free(mul_table);

    @memset(mul_table, 0);
    for (r_pointer) |num| {
        mul_table[num] += 1;
    }

    sum = 0;
    for (l_pointer) |num| {
        sum += num * mul_table[num];
    }
    std.debug.print("part_2: {d}\n", .{sum});
}
