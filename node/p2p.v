module node

import net

// start our node
pub fn (mut n Node) start(bootstrap_nodes []string) ! {
    mut ln := net.listen_tcp(net.AddrFamily.ip, n.listen_addr)!

	n.logger.set_level(.info)

	n.logger.info("running on ${n.listen_addr}")

	go n.bootstrap_net(bootstrap_nodes)

    for {
        mut c := ln.accept()!
        go n.handle(mut c)
    }
}

//this function will handle all 
// tcp remote connections
fn (mut n Node) handle(mut conn net.TcpConn) ! {
	n.logger.info("Handle")

    mut req := []u8{len: 1024}
	conn.read(mut req)!

    match req.bytestr().split("[")[0] {
		// Handshake
		handshake_match {
			n.logger.info("Handle: handshake match")

			rver := read_version_bytes(req)! // read remote version
			n.logger.debug("Handshake: remote version: ${rver}") // debug log of ver

			pip := conn.peer_ip()!
			n.logger.debug("Peer IP: ${pip}")

			n.add_peer(rver) // add remote version to our peers

			conn.write(n.get_version().to_bytes())! // write our own version
		}

		ping_match {
			n.logger.info("Handle: ping match")

			ping := read_ping_bytes(req)!
			n.logger.debug("Ping: remote ping: ${ping}")

			pong := from_ping(ping).to_bytes()

			conn.write(pong)!
		}
		
		else {
			n.logger.info("Handle: does not match with: ${req.bytestr()}")
		}
	}
    
    conn.close()!
}