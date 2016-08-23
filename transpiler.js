const fs = require("fs");
const source = fs.readFileSync("AST.json", "utf8").replace(/,]/g, "").replace(/,$/, "");
const AST = JSON.parse(AST);
console.log(AST);