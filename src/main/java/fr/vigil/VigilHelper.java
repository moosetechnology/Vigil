package fr.vigil;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.converters.ConverterLookup;
import com.thoughtworks.xstream.core.TreeMarshaller;
import com.thoughtworks.xstream.core.TreeMarshallingStrategy;
import com.thoughtworks.xstream.io.HierarchicalStreamWriter;
import com.thoughtworks.xstream.io.xml.CompactWriter;
import com.thoughtworks.xstream.mapper.Mapper;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Stack;
import org.jboss.byteman.rule.Rule;
import org.jboss.byteman.rule.helper.Helper;

public class VigilHelper extends Helper {

  /**
   * Byteman helper subclasses require this constructor. Subclassing is optional. This gives access
   * to its API, such as {@link #debug(String) debug}, and allows overriding it.
   */
  public VigilHelper(Rule rule) {
    super(rule);
  }

  // ===== Step 1: target stack discovery

  public void discoverTargetStack() {
    traceStack(""); // Omit prefix
    System.exit(0); // Terminate
  }

  /** Omit filename and line number. */
  @Override
  protected void printFrame(StringBuffer buffer, StackTraceElement frame) {
    buffer.append(frame.getClassName());
    buffer.append(".");
    buffer.append(frame.getMethodName());
  }

  // ===== Step 2: target stack serialization

  /** Serializer. */
  protected static final XStream XSTREAM = new XStream();

  static { // Use custom marshalling strategy for Object ID injection
    XSTREAM.setMarshallingStrategy(
        new TreeMarshallingStrategy() {
          @Override
          protected TreeMarshaller createMarshallingContext(
              HierarchicalStreamWriter writer, ConverterLookup converterLookup, Mapper mapper) {
            return new ObjectIdMarshaller(writer, converterLookup, mapper);
          }
        });
  }

  /** Contains the current stack data: serialized receiver and arguments of each frame. */
  protected static final Stack<String> STACK = new Stack<>();

  /**
   * Flag indicating whether the current invocation is part of the target stack. The current
   * implementation is naive: It becomes true when finding the first triggering method that is part
   * of the target callstack. For example, if we are interested in A->B->C, we do not care about B
   * if we did not see A before. However, there's currently no guarantee that A is the direct caller
   * of B. See direction for a better solution at
   * https://downloads.jboss.org/byteman/4.0.26/byteman-programmers-guide.html#checking-the-call-tree
   */
  protected static boolean IN_TARGET = false;

  public boolean inTarget() {
    return IN_TARGET;
  }

  protected void pushFrame(String className, String signature, Object[] receiverAndArguments) {
    STACK.push(serializeFrame(className, signature, receiverAndArguments));
  }

  protected String serializeFrame(
      String className, String signature, Object[] receiverAndArguments) {
    try {
      Writer writer = new StringWriter();
      CompactWriter xmlWriter = new CompactWriter(writer);

      // Each frame has its method signature as attribute
      writer
          .append("<frame method=\"")
          .append(className)
          .append('.')
          .append(signature.substring(0, signature.lastIndexOf(' '))) // Omit return type
          .append("\">");
      XSTREAM.marshal(receiverAndArguments, xmlWriter);
      writer.append("</frame>");

      return writer.toString();
    } catch (Throwable t) {
      return "error: " + t.getClass().getSimpleName() + " - " + t.getMessage();
    }
  }

  protected String serializeStack(
      String className, String signature, Object[] receiverAndArguments) {
    StringBuilder sb = new StringBuilder("<stack>");
    for (String frame : STACK) {
      sb.append(frame);
    }
    sb.append(serializeFrame(className, signature, receiverAndArguments));
    sb.append("</stack>");
    return sb.toString();
  }

  /** Entering the first method of the target stack. Data collection begins now. */
  public void enterTargetStack(String className, String signature, Object[] receiverAndArguments) {
    debug(">>> Enter target stack");
    pushFrame(className, signature, receiverAndArguments);
    IN_TARGET = true;
  }

  /**
   * Exiting the first target method of the stack. That means the current stack is not the target.
   * The data collected so far must be purged and the flags reset.
   */
  public void exitTargetStack() {
    debug(">>> Exit target stack");
    STACK.pop();
    assert STACK.empty();
    IN_TARGET = false;
  }

  /** Entering target method potentially part of the target stack. */
  public void enterTargetMethod(String className, String signature, Object[] receiverAndArguments) {
    debug(">>> Enter target method");
    pushFrame(className, signature, receiverAndArguments);
  }

  /**
   * Exiting target method when data collection is active. The last method of the target stack was
   * not found during its execution, otherwise the program would have been stopped. That means this
   * method execution is <b>not</b> part of the target stack.
   */
  public void exitTargetMethod() {
    debug(">>> Exit target method");
    STACK.pop();
  }

  /**
   * Entering final method of the target stack. Dump the serialized stack data and terminate the
   * execution.
   */
  public void foundTargetStack(String className, String signature, Object[] receiverAndArguments) {
    debug(">>> Found target stack");
    System.out.println(
        serializeStack(className, signature, receiverAndArguments)); // TODO: dump to file
    System.exit(0); // Terminate
  }
}
