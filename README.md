# box-vba

A VBA to JavaScript transpiler targeting [CapacitorSet/box-js](https://github.com/CapacitorSet/box-js).

# Usage

Assuming that `antlr` is installed in `/usr/local/lib/antlr-4.5.3-complete.jar`:

```bash
# Create the parser
antlr4 VB.g4
# Compile the parser and the custom walker
javac -cp ".:/usr/local/lib/antlr-4.5.3-complete.jar" *.java
# Run the parser and the walker, and write the AST to AST.json
java -cp ".:/usr/local/lib/antlr-4.5.3-complete.jar" VBTranspiler > AST.json
# Verify that it worked
node transpiler
```