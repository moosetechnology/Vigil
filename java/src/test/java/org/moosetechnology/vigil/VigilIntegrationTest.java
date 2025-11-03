package org.moosetechnology.vigil;

import static org.junit.Assert.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import org.junit.Test;

public class VigilIntegrationTest {

  private static final String VIGIL_VERSION = "1.0";

  private static String runApplicationWithRules(String ruleName) throws Exception {
    Path projectRoot = Paths.get("").toAbsolutePath();

    // Find the built agent jar
    Path agentJar = projectRoot.resolve("build/libs/vigil-agent-" + VIGIL_VERSION + ".jar");
    if (!Files.exists(agentJar)) {
      throw new FileNotFoundException("Agent jar missing: " + agentJar);
    }

    // Find the rule to use for the test
    Path rule = projectRoot.resolve("src/test/resources/rules/" + ruleName + ".btm");
    if (!Files.exists(rule)) {
      throw new FileNotFoundException("Rule file missing: " + rule);
    }

    // Build the classpath for the target application
    Path classes = projectRoot.resolve("build/classes/java/test");
    if (!Files.exists(classes)) {
      throw new FileNotFoundException("App classes not found: " + classes);
    }

    // Build the java command. We run the target application in a fresh JVM.
    List<String> cmd = new ArrayList<>();
    cmd.add(System.getProperty("java.home") + "/bin/java");

    // Use vigil-agent.jar and load the specified rule file
    String agentArg =
        String.format("-javaagent:%s=script:%s", agentJar.toAbsolutePath(), rule.toAbsolutePath());
    cmd.add(agentArg);

    cmd.add("-cp");
    cmd.add(classes.toString());

    cmd.add("com.example.App"); // Main class of the target application

    ProcessBuilder pb = new ProcessBuilder(cmd);
    pb.directory(projectRoot.toFile()); // Make sure the working directory is project root
    pb.redirectErrorStream(true); // Merge stdout/stderr so we can inspect both

    Process p = pb.start();

    // Read output asynchronously (avoid deadlock)
    StringBuilder out = new StringBuilder();
    try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
      String line;
      while ((line = r.readLine()) != null) {
        out.append(line).append(System.lineSeparator());
      }
    }

    // Await termination and check exit code
    int exit = p.waitFor();
    if (exit != 0) {
      throw new IllegalStateException("Process did not exit normally, output:\n" + out.toString());
    }

    return out.toString(); // Return application console output
  }

  @Test(timeout = 20_000)
  public void testDiscover() throws Exception {
    String output = runApplicationWithRules("discover");

    String expected =
        "com.example.App.endChain\n"
            + "com.example.App.midChain\n"
            + "com.example.App.beginChain\n"
            + "com.example.App.main";

    assertTrue(
        "Expected serialized output:\n" + expected + "\n=== But got:\n" + output,
        output.contains(expected));
  }

  @Test(timeout = 20_000)
  public void testSerialize() throws Exception {
    String output = runApplicationWithRules("serialize");

    assertTrue(
        "Stack and first frame start tags missing:\n" + output,
        output.contains("[{\"method\":\"com.example.App.main(java.lang.String[])\",\"values\":"));

    assertTrue("Object ID missing in serialized stack:\n" + output, output.contains("\"@id\":1"));

    assertTrue("Last frame and stack end tags missing:\n" + output, output.contains("}]"));
  }
}
