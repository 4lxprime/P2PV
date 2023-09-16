module node

import net
 
struct Version {
	ver string
	laddr string
	peers []string

	mut: conn net.TcpConn
}

fn (v Version) to_bytes() []u8 {
	block := "${handshake_match}[ver=${v.ver},laddr=${v.laddr},peers=${v.peers}]"

	return block.bytes()
}

// just read peerlist from encoded version
fn read_version_bytes_peer(peer string) []string {
	mut peers := []string{}

	if peer.contains("'") {
		if peer.contains(",") {
			peerl := peer.split("[")[1].split("]")[0].split(", ")

			for p in peerl {
				peers << p.replace("'", "")
			}

		} else {
			peers << peer.split("[")[1].split("]")[0].replace("'", "")

		}
	}

	return peers
}

// read version from encoded version
// in bytes 
pub fn read_version_bytes(bblock []u8) !Version {
	block := bblock.bytestr()

	if block == "" {
		return error("block len is == 0")
	}
	if block.split("[")[0] != handshake_match {
		return error("version signature is invalid")
	}

	datas := block.split("[")[1].split("]")[0].split(",")

	ver := datas[0].split("=")[1]
	laddr := datas[1].split("=")[1]
	peers := datas[2].split("=")[1]

	return Version{
		ver: ver,
		laddr: laddr,
		peers: read_version_bytes_peer(peers),
	}
}

// will return our version
pub fn (n Node) get_version() Version {
	v :=  Version{
		ver: "x",
		laddr: n.listen_addr,
		peers: n.get_peers(),
	}

	return v
}