import java.io.File;
import java.io.IOException;

public class VBTranspiler {

    public static void main(String[] args) throws IOException {
        ParserFacade parserFacade = new ParserFacade();
        AstPrinter astPrinter = new AstPrinter();
        astPrinter.print(parserFacade.parse(new File("/home/jules/box-vba/sample.bas")));
    }
}
