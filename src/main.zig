const std = @import("std");
const net = std.net;
const builtin = @import("builtin");
const zig_version = builtin.zig_version;
const is_zig_13 = zig_version.minor == 13;
const Server = @import("server.zig").Server;

pub fn main() !void {
    const stderr = std.io.getStdErr();
    if (!is_zig_13) {
        try stderr.writer().print("Invalid zig version. Expected: zig 0.13.0 | Get: {}.{}.{}\n", .{ zig_version.major, zig_version.minor, zig_version.patch });
        return;
    }
    var server = try Server.init();
    defer server.deinit();

    while (true) {
        _ = try server.accept();
    }
}

fn client(listen_address: net.Address) !void {
    const testeMessage = "This message is a test.";
    var clientCon = try net.tcpConnectToAddress(listen_address);
    defer clientCon.close();
    _ = try clientCon.writeAll(testeMessage);

    var buf: [1024]u8 = undefined;
    @memset(&buf, 0);
    const resp_size = try clientCon.read(&buf);

    try std.testing.expectEqualStrings(testeMessage, buf[0..resp_size]);
}

test "Echo server" {
    var server = try Server.init();
    defer server.deinit();

    const client_thread = try std.Thread.spawn(.{}, client, .{server.server.listen_address});
    defer client_thread.join();

    try server.accept();
}
