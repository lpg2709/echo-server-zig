const std = @import("std");
const net = std.net;

pub const Server = struct {
    stream_server: net.StreamServer,

    pub fn init() !Server {
        const loopback = try net.Ip4Address.parse("127.0.0.1", 3000);
        const localhost = net.Address{ .in = loopback };

        var server = net.StreamServer.init(.{
            .reuse_port = true,
        });

        try server.listen(localhost);
        std.debug.print("[DEBUG] - Server listening on port {}\n", .{server.listen_address.getPort()});
        return Server{ .stream_server = server };
    }

    pub fn deinit(self: *Server) void {
        self.stream_server.deinit();
    }

    pub fn accept(self: *Server) !void {
        const conn = try self.stream_server.accept();
        defer conn.stream.close();

        var buf: [1024]u8 = undefined;
        @memset(&buf, 0);
        const msg_size = try conn.stream.read(buf[0..]);
        std.debug.print("[DEBUG] - Message recived {d} bytes: {s} \n", .{ msg_size, buf[0..msg_size] });

        _ = try conn.stream.writeAll(buf[0..msg_size]);
    }
};
