package org.moosetechnology.vigil;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.BeanDescription;
// import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SerializationConfig;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.databind.ser.BeanPropertyWriter;
import com.fasterxml.jackson.databind.ser.BeanSerializerModifier;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;
import org.jboss.byteman.rule.Rule;
import org.jboss.byteman.rule.helper.Helper;
import org.moosetechnology.vigil.VigilHelper.UnserializableValue;

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
  protected static final ObjectWriter VALUE_WRITER;
  protected static final ObjectWriter ERROR_WRITER;

  static {
    SERIALIZER = new ObjectMapper();

    SERIALIZER
        .disable(SerializationFeature.FAIL_ON_EMPTY_BEANS)
        .enable(MapperFeature.PROPAGATE_TRANSIENT_MARKER)
        .addMixIn(Object.class, MixIn.class);

    // SimpleModule oidModule = new SimpleModule();
    // oidModule.setSerializerModifier(new OidInjectorModifier());
    // SERIALIZER.registerModule(oidModule);

    SERIALIZER.registerModule(
        new SimpleModule()
            .setSerializerModifier(
                new BeanSerializerModifier() {
                  @Override
                  public List<BeanPropertyWriter> changeProperties(
                      SerializationConfig config,
                      BeanDescription beanDesc,
                      List<BeanPropertyWriter> beanProperties) {
                    List<BeanPropertyWriter> modifiedProperties = new ArrayList<>();
                    for (BeanPropertyWriter bpw : beanProperties) {
                      BeanPropertyWriter wrappedWriter =
                          new BeanPropertyWriter(bpw) {
                            @Override
                            public void serializeAsField(
                                Object bean, JsonGenerator gen, SerializerProvider prov)
                                throws Exception {
                              try {
                                super.serializeAsField(bean, gen, prov);
                              } catch (Exception e) {
                                System.out.println(
                                    String.format(
                                        "ignoring %s for field '%s' of %s instance",
                                        e.getClass().getName(),
                                        this.getName(),
                                        bean.getClass().getName()));
                              }
                            }
                          };
                      modifiedProperties.add(wrappedWriter);
                    }
                    return modifiedProperties;
                  }
                }));

    SERIALIZER.setVisibility(
        SERIALIZER
            .getVisibilityChecker()
            .withFieldVisibility(JsonAutoDetect.Visibility.ANY)
            .withGetterVisibility(JsonAutoDetect.Visibility.NONE)
            .withIsGetterVisibility(JsonAutoDetect.Visibility.NONE));

    VALUE_WRITER = SERIALIZER.writerFor(Object.class);
    ERROR_WRITER = SERIALIZER.writerFor(UnserializableValue.class);
  }

  /** Used to add Jackson annotations to a type without having to modify its source. */
  @JsonIdentityInfo(generator = PersistentObjectIdGenerator.class, property = "@id")
  @JsonTypeInfo(
      use = JsonTypeInfo.Id.CLASS,
      // TODO use JsonTypeInfo.As.WRAPPER_ARRAY when implemented in Famix-Value
      include = JsonTypeInfo.As.PROPERTY,
      property = "@type")
  private interface MixIn {}

  /** Placeholder for values Jackson can't serialize normally. */
  public static final class UnserializableValue {
    public final String error;
    public final String type;
    public final String toString;

    public UnserializableValue(String error, String type, String toString) {
      this.error = error;
      this.type = type;
      this.toString = toString;
    }
  }

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

    StringBuilder sb = new StringBuilder(256);
    sb.append("{\"method\":\"").append(signature).append("\",\"values\":[");

    for (int i = 0; i < receiverAndArguments.length; i++) {
      if (i > 0) {
        sb.append(',');
      }
      Object value = receiverAndArguments[i];

      try {
        // Normal path: let Jackson serialize this element
        sb.append(VALUE_WRITER.writeValueAsString(value));
      } catch (Exception ex) {
        System.out.println(
            String.format(
                "Ignoring %s while serializing argument %d of %s: %s",
                ex.getClass().getName(), i, signature, ex.getMessage()));

        // Fallback: a small, always-serializable error object
        UnserializableValue placeholder =
            new UnserializableValue(
                ex.getClass().getName() + ": " + ex.getMessage(),
                (value != null ? value.getClass().getName() : "null"),
                (value != null ? safeToString(value) : "null"));

        try {
          sb.append(ERROR_WRITER.writeValueAsString(placeholder));
        } catch (Exception ex2) {
          // Extremely defensive: even serializing the placeholder failed.
          // Fall back to a simple JSON null to keep the array valid.
          System.out.println(
              String.format(
                  "Also failed to serialize placeholder for argument %d of %s: %s",
                  i, signature, ex2.getMessage()));
          sb.append("null");
        }
      }
    }

    sb.append("]}");
    return sb.toString();
  }

  // Avoid surprises in toString() throwing:
  private static String safeToString(Object o) {
    try {
      return String.valueOf(o);
    } catch (Exception e) {
      return "<toString() threw " + e.getClass().getSimpleName() + ">";
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
