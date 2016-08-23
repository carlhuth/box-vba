const fs = require("fs");
const source = fs.readFileSync("AST.json", "utf8").replace(/,]/g, "]").replace(/,$/, "");
let AST = JSON.parse(source);
console.log(AST);