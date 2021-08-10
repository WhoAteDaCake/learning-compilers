![Overview](http://www.craftinginterpreters.com/image/a-map-of-the-territory/mountain.png)

https://github.com/munificent/craftinginterpreters

* Scaning (lexer)
    * Scan all characters in order to build up a list of tokens, which are defined in the language
* Parsing
    * Second step, where we use found keywords to start building up execution model
    * We build up larger expressions and statements
    * AST (Abstract syntax trees) are created at this stage
* Static analysis
    * Starting to give context to our AST
    * Understand scope
    * Variable binding and resolution


Single-pass compilers: Interleave parsing, analysis and code generation, this way no ASTs are allocated
and the program has smaller memory usage. This has the drawback, of the language compiler needing to know
all the information, as soon as an item is read, types can't be generated automatically.

Tree-walk interpreters: As soon as AST is generated, the compiler starts evaluating the program.

Transpilers: Compile your own language to valid code of an already existing language, avoiding the need to do heavy lifting.

Just-in-time compilation: Compiler generates native code on the end-user's machine as the code is being read. It can have advanced
features, such as re-compiling hot areas with more optimised code, as JIT is aware of program flow execution.