package org.moosetechnology.vigil;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
// import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Stack;
import org.jboss.byteman.rule.Rule;
import org.jboss.byteman.rule.helper.Helper;

/**
 * Implements tools to discover and serialize execution stacks.
 *
 * @see https://downloads.jboss.org/byteman/4.0.26/byteman-programmers-guide.html
 */
public class VigilHelper extends Helper {

  /**
   * Byteman helper subclasses require this constructor. Subclassing is optional. This gives access
   * to its API, such as {@link #debug(String) debug}, and allows overriding it.
   */
  public VigilHelper(Rule rule) {
    super(rule);
  }

  // ==============================================
  // ===== Output management ======================
  // ==============================================

  protected static String OUTPUT_FILE;

  /** Set the output file path. If <code>null</code> (default), Vigil uses standard output. */
  public static void setOutputFile(String path) {
    OUTPUT_FILE = path;
  }

  protected void output(String data) {
    if (OUTPUT_FILE == null) {
      System.out.println(data);
      return;
    }

    File file = new File(OUTPUT_FILE);
    file.getParentFile().mkdirs(); // Ensure parent directory exists

    try (Writer out = new BufferedWriter(new FileWriter(file))) {
      out.write(data);
    } catch (IOException e) {
      debug("Error writing output file: " + e.getMessage());
    }
  }

  // ==============================================
  // ===== Step 1: target stack discovery =========
  // ==============================================

  /** Output the fully qualified names of the methods in the stack. */
  public void discoverTargetStack() {
    debug("Discover target stack");
    output(formatStack("")); // Empty string to omit prefix
    terminate();
  }

  // ==============================================
  // ===== Step 2: target stack serialization =====
  // ==============================================

  /** Entering the first method of the target stack. Data collection begins now. */
  public void enterTargetStack(String className, String signature, Object[] receiverAndArguments) {
    debug("Enter target stack");
    pushFrame(className, signature, receiverAndArguments);
    IN_TARGET = true;
  }

  /**
   * Exiting the first target method of the stack. That means the current stack is not the target.
   * The data collected so far must be purged and the flags reset.
   */
  public void exitTargetStack() {
    debug("Exit target stack");
    popFrame();
    assert STACK.empty(); // NOOP unless the -ea JVM argument is used
    IN_TARGET = false;
  }

  /** Entering target method potentially part of the target stack. */
  public void enterTargetMethod(String className, String signature, Object[] receiverAndArguments) {
    debug("Enter target method");
    pushFrame(className, signature, receiverAndArguments);
  }

  /**
   * Exiting target method when data collection is active. The last method of the target stack was
   * not found during its execution, otherwise the program would have been stopped. That means this
   * method execution is <b>not</b> part of the target stack.
   */
  public void exitTargetMethod() {
    debug("Exit target method");
    popFrame();
  }

  /**
   * Entering final method of the target stack. Dump the serialized stack data and terminate the
   * execution.
   */
  public void foundTargetStack(String className, String signature, Object[] receiverAndArguments) {
    debug("Found target stack");
    output(serializeStack(className, signature, receiverAndArguments));
    terminate();
  }

  // ==============================================
  // ===== Utilities ==============================
  // ==============================================

  protected static final ObjectMapper SERIALIZER;

  static {
    SERIALIZER = new ObjectMapper();

    SERIALIZER
        .disable(SerializationFeature.FAIL_ON_EMPTY_BEANS)
        .enable(MapperFeature.PROPAGATE_TRANSIENT_MARKER)
        .addMixIn(Object.class, MixIn.class);

    // SimpleModule oidModule = new SimpleModule();
    // oidModule.setSerializerModifier(new OidInjectorModifier());
    // SERIALIZER.registerModule(oidModule);

    SERIALIZER.setVisibility(
        SERIALIZER
            .getVisibilityChecker()
            .withFieldVisibility(JsonAutoDetect.Visibility.ANY)
            .withGetterVisibility(JsonAutoDetect.Visibility.NONE)
            .withIsGetterVisibility(JsonAutoDetect.Visibility.NONE));
  }

  /** Used to add Jackson annotations to a type without having to modify its source. */
  @JsonIdentityInfo(generator = PersistentObjectIdGenerator.class, property = "@id")
  @JsonTypeInfo(
      use = JsonTypeInfo.Id.CLASS,
      // TODO use JsonTypeInfo.As.WRAPPER_ARRAY when Famix-Value importer implements it
      include = JsonTypeInfo.As.PROPERTY,
      property = "@type")
  private interface MixIn {}

  /** Contains the current stack data: serialized receiver and arguments of each frame. */
  protected static final Stack<String> STACK = new Stack<>();

  /**
   * Flag indicating whether the current invocation is part of the target stack.
   *
   * <p>The current implementation is naive: It becomes true when finding the first triggering
   * method that is part of the target callstack. For example, if we are interested in A->B->C, we
   * do not care about B if we did not see A before. However, the VigilHelper API makes no guarantee
   * that A is the direct caller of B. <b>This must be ensured by the generated rules.</b> See
   * directions at
   * https://downloads.jboss.org/byteman/4.0.26/byteman-programmers-guide.html#checking-the-call-tree.
   */
  protected static boolean IN_TARGET = false;

  public boolean inTarget() {
    return IN_TARGET;
  }

  protected void pushFrame(String className, String signature, Object[] receiverAndArguments) {
    debug("Push frame " + className + "." + signature);
    STACK.push(serializeFrame(className, signature, receiverAndArguments));
  }

  protected void popFrame() {
    debug("Pop frame");
    STACK.pop();
  }

  protected String serializeFrame(
      String className, String signatureAndType, Object[] receiverAndArguments) {
    debug("Serialize frame " + className + "." + signatureAndType);

    // Omit the signature's return type and prepend fully qualified class name
    String signature =
        className + "." + signatureAndType.substring(0, signatureAndType.lastIndexOf(' '));

    try {
      Writer writer = new StringWriter();

      // Each frame has its method signature as the "method" attribute
      writer
          .append("{\"method\":\"")
          .append(signature)
          .append("\",\"values\":")
          .append(SERIALIZER.writeValueAsString(receiverAndArguments))
          .append("}");

      return writer.toString();
    } catch (Exception e) { // Submit an issue if this happens
      return "Error serializing frame "
          + signature
          + ": "
          + e.getClass().getSimpleName()
          + " - "
          + e.getMessage();
    }
  }

  protected String serializeStack(
      String className, String signature, Object[] receiverAndArguments) {
    debug("Serialize stack");
    StringBuilder sb = new StringBuilder("[");
    for (String frame : STACK) {
      sb.append(frame).append(',');
    }
    sb.append(serializeFrame(className, signature, receiverAndArguments));
    sb.append("]");
    return sb.toString();
  }

  protected void terminate() {
    debug("Terminate");
    System.exit(0);
  }

  /**
   * Used by {@link #formatStack(String) formatStack} and its family of methods to print the details
   * of stack frame to buffer.
   *
   * @see
   *     https://downloads.jboss.org/byteman/4.0.26/byteman-programmers-guide.html#tracing-the-caller-stack
   */
  @Override
  protected void printFrame(StringBuffer buffer, StackTraceElement frame) {
    buffer.append(frame.getClassName());
    buffer.append(".");
    buffer.append(frame.getMethodName());
    // Omit filename and line number
  }
}
