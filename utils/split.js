const splitIn32Bytes = (input) => {
  // Delete 0x prefix in case there is one
  if (input.substring(0, 2) === "0x") input = input.slice(2, input.length);

  const originalInput = input;
  let output = [];

  // Input is not divisible by 64
  if (input.length % 64 != 0) {
    let extraBytes = input.slice(0, input.length % 64);
    output.push("0x" + extraBytes);
    input = input.slice(input.length % 64, input.length);
    for (i = 0; i < input.length; i += 64) {
      output.push("0x" + input.substring(i, i + 64));
    }
  } // Input is exactly divisible by 64
  else if (input.length % 64 === 0) {
    for (i = 0; i < input.length; i += 64) {
      output.push("0x" + input.substring(i, i + 64));
    }
  }

  console.log(`INPUT HAS ${originalInput.length} CHARACTERS:`);
  return output;
};

console.log(splitIn32Bytes(process.argv[2]));
