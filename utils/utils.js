const splitIn32Bytes = (val) => {
	let output = []

	if (val.length % 64 === 0) {
		for (i = 0; i < val.length; i += 32) {
			output.push('0x' + val.substring(i, i + 32))
		}
	} else return `Input length (${val.length}) is not divisible for 32 bytes`

	return output
}
