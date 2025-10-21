package com.example;

import static org.junit.Assert.*;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import org.junit.Test;

public class VigilIntegrationTest {

  private static final String VIGIL_VERSION = "1.0";

  private static String runToyAppWithRule(String ruleName) throws Exception {
    Path projectRoot = Paths.get("").toAbsolutePath();

    // Find the helper bundle created by createHelperJar
    Path helperJar = projectRoot.resolve("build/libs/vigil-agent-" + VIGIL_VERSION + ".jar");
    if (!Files.exists(helperJar)) {
      throw new FileNotFoundException("Helper bundle missing: " + helperJar);
    }

    // Find the rule to use for the test
    Path rule = projectRoot.resolve("src/test/resources/rules/" + ruleName);
    if (!Files.exists(rule)) {
      throw new FileNotFoundException("Rule file missing: " + rule);
    }

    // Build the classpath for the target application (compiled classes)
    Path classes = projectRoot.resolve("build/classes/java/test");
    if (!Files.exists(classes)) {
      throw new FileNotFoundException("App classes not found (run :test?): " + classes);
    }

    // Build the java command. We run the target App class in a fresh JVM.
    List<String> cmd = new ArrayList<>();
    cmd.add(System.getProperty("java.home") + "/bin/java");

    // IMPORTANT: pass both byteman agent JAR and helper on boot: (and include agent jar in script=)
    String agentArg =
        String.format(
            "-javaagent:%s=script:%s,boot:%s",
            helperJar.toAbsolutePath(), rule.toAbsolutePath(), helperJar.toAbsolutePath());
    cmd.add(agentArg);

    cmd.add("-cp");
    cmd.add(classes.toString());

    cmd.add("com.example.App"); // Main class of the toy application

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

    int exit = p.waitFor();
    if (exit != 0) {
      throw new IllegalStateException("Process did not exit normally, output:\n" + out.toString());
    }

    return out.toString();
  }

  @Test(timeout = 20_000)
  public void testDiscover() throws Exception {
    String output = runToyAppWithRule("discover.btm");

    assertTrue(
        "Expected markers not found in output:\n" + output,
        output.contains(
            "com.example.App.endChain\n"
                + "com.example.App.midChain\n"
                + "com.example.App.beginChain\n"
                + "com.example.App.main"));
  }

  @Test(timeout = 20_000)
  public void testSerialize() throws Exception {
    String output = runToyAppWithRule("serialize.btm");

    assertTrue(
        "Expected markers not found in output:\n" + output,
        output.contains("<stack><frame method=\"com.example.App.main(java.lang.String[])\">")
            && output.contains("oid=\"1\"")
            && output.contains("</frame></stack>"));
  }
}
