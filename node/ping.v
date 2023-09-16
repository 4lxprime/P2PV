module node

struct Ping{
	x int
}

pub fn new_ping(x int) Ping {
	return Ping{
		x
	}
}

fn (p Ping) to_bytes() []u8 {
	block := "${ping_match}[x:${p.x}]"

	return block.bytes()
}

pub fn read_ping_bytes(bblock []u8) !Ping {
	block := bblock.bytestr()

	if block == "" {
		return error("block len is == 0")
	}
	if block.split("[")[0] != ping_match {
		return error("ping signature is invalid")
	}

	datas := block.split("[")[1].split("]")[0]

	x := datas.split(":")[1].int()

	return Ping{
		x
	}
}

struct Pong{
	x int
}

pub fn new_pong(x int) Pong {
	return Pong{
		x
	}
}

pub fn from_ping(p Ping) Pong {
	return new_pong(p.x)
}

fn (p Pong) to_bytes() []u8 {
	block := "${ping_match}[x:${p.x}]"

	return block.bytes()
}

pub fn read_pong_bytes(bblock []u8) !Ping {
	block := bblock.bytestr()

	if block == "" {
		return error("block len is == 0")
	}

	datas := block.split("[")[1].split("]")[0]

	x := datas.split(":")[1].int()

	return Ping{
		x
	}
}
