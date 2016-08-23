import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.antlr.v4.runtime.tree.ParseTree;

import java.util.Base64;

public class AstPrinter {

    private boolean ignoringWrappers = true;

    public void setIgnoringWrappers(boolean ignoringWrappers) {
        this.ignoringWrappers = ignoringWrappers;
    }

    public void print(RuleContext ctx) {
        explore(ctx);
    }

    private void explore(RuleContext ctx) {
        boolean toBeIgnored = ignoringWrappers
                && ctx.getChildCount() == 1
                && ctx.getChild(0) instanceof ParserRuleContext;
        if (!toBeIgnored) {
            System.out.print("{");
            String ruleName = VBParser.ruleNames[ctx.getRuleIndex()];
            System.out.print("\"type\": \"" + ruleName + "\",");
            System.out.print("\"children\":[");
        }
        Boolean hasChildren = false;
        for (int i=0;i<ctx.getChildCount();i++) {
            ParseTree element = ctx.getChild(i);
            if (element instanceof RuleContext) {
                hasChildren = true;
                explore((RuleContext)element);
            }
        }
        if (!toBeIgnored) {
            System.out.print("]");
            if (!hasChildren) {
                Base64.Encoder Encoder = Base64.getEncoder();
                System.out.print(",\"content\": \"" + Encoder.encodeToString(ctx.getText().getBytes()) + "\"");
            }
            System.out.print("},");
        }
    }

}
