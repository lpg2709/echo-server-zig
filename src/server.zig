const std = @import("std");
const net = std.net;

pub const Server = struct {
    server: net.Server,

    pub fn init() !Server {
        const localhost = try net.Address.parseIp("127.0.0.1", 3000);

        var server = try localhost.listen(.{});

        std.debug.print("[DEBUG] - Server listening on port {}\n", .{server.listen_address.getPort()});
        return Server{ .server = server };
    }

    pub fn deinit(self: *Server) void {
        self.server.deinit();
    }

    pub fn accept(self: *Server) !void {
        const conn = try self.server.accept();
        defer conn.stream.close();

        var buf: [1024]u8 = undefined;
        @memset(&buf, 0);
        const msg_size = try conn.stream.read(buf[0..]);
        std.debug.print("[DEBUG] - Message recived {d} bytes: {s} \n", .{ msg_size, buf[0..msg_size] });

        _ = try conn.stream.writeAll(buf[0..msg_size]);
    }
};
