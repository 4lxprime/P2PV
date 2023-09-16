module node

import net
import log

pub struct Node {
	listen_addr string [required]

mut: 
	logger log.Log [required]

pub mut:
	peers map[string]Version
}

// return a new node with addr
pub fn new_node(laddr string) &Node {
	return &Node{
		listen_addr: laddr,
		logger: log.Log{},
	}
}

const (
	handshake_match = "_getversion"
	ping_match = "_getping"
)

pub fn (n Node) get_peers() []string {
	mut p := []string{}

	for addr, _ in n.peers {
		p << addr
	}

	return p
}

// check if we can connect to a node addr
fn (mut n Node) can_connect(node string) bool {
	// check if address is not the same as our listen address
	if node == n.listen_addr {
		return false
	}

	// check if we are already connected
	for _, v in n.peers {
		if v.laddr == node {
			return false
		}
	}

	return true
}

// connect to a remote node
fn connect(addr string) !&net.TcpConn {
	return net.dial_tcp(addr)
}

fn (mut n Node) add_peer(v Version) {
	n.logger.info("Node: add peer ${v.laddr}")

	n.peers[v.laddr] = v
}

fn (mut n Node) bootstrap_net(nodes []string) {
	for node in nodes {
		if n.can_connect(node) {
			n.handshake(node) or { panic(err) }
		}
	}
}

fn (mut n Node) handshake(node string) ! {
	n.logger.info("Handshake")

	mut conn := connect(node)! // get a conn

	// send our version
	conn.write(n.get_version().to_bytes())!

	mut res := []u8{len: 1024}

	// get remote version
	conn.read(mut res)!

	ver := read_version_bytes(res)!
	n.logger.debug("Handshake: recieve version: ${ver}") // debug log of ver

	pip := conn.peer_ip()!
	n.logger.debug("Peer IP: ${pip}")

	n.add_peer(ver)

	conn.close() or { panic(err) }
}

pub fn (mut n Node) ping(node string) ! {
	n.logger.info("Ping")

	mut conn := connect(node)!

	conn.write(new_ping(10).to_bytes())!

	mut res := []u8{len: 1024}

	conn.read(mut res)!

	pong := read_pong_bytes(res)!
	n.logger.debug("Ping: recieve pong: ${pong}")

	conn.close() or { panic(err) }
}
