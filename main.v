module main

import node
import time

[console]
fn main() {
	mut n1 := node.new_node("127.0.0.1:80")
	mut n2 := node.new_node("127.0.0.1:81")
	mut n3 := node.new_node("127.0.0.1:82")

	go fn(mut n node.Node) {
		n.start([]) or { panic(err) }
	}(mut n1)

	go fn(mut n node.Node) {
		n.start(["127.0.0.1:80"]) or { panic(err) }
	}(mut n2)

	go fn(mut n node.Node) {
		n.start(["127.0.0.1:80", "127.0.0.1:81"]) or { panic(err) }
	}(mut n3)

	go fn(mut n1 node.Node, mut n2 node.Node, mut n3 node.Node) {

		time.sleep(2*time.second)
		
		for peer in n1.get_peers() {
			n1.ping(peer) or { panic(err) }
		}

		time.sleep(2*time.second)
		for peer in n2.get_peers() {
			n2.ping(peer) or { panic(err) }
		}

		time.sleep(2*time.second)
		for peer in n3.get_peers() {
			n3.ping(peer) or { panic(err) }
		}

	}(mut n1, mut n2, mut n3)

	for {}
}
