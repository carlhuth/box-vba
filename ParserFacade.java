import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;

public class ParserFacade {

    private static String readFile(File file, Charset encoding) throws IOException {
        byte[] encoded = Files.readAllBytes(file.toPath());
        return new String(encoded, encoding);
    }

    public VBParser.StartRuleContext parse(File file) throws IOException {
        String code = readFile(file, Charset.forName("UTF-8"));
        VBLexer lexer = new VBLexer(new ANTLRInputStream(code));

        CommonTokenStream tokens = new CommonTokenStream(lexer);

        VBParser parser = new VBParser(tokens);

        return parser.startRule();
    }
}
