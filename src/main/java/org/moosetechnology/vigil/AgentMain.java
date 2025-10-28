package org.moosetechnology.vigil;

import java.lang.instrument.Instrumentation;
import org.jboss.byteman.agent.Main;

public class AgentMain {

  public static void premain(String args, Instrumentation inst) throws Exception {
    // Check for output file property
    String path = System.getProperty("org.moosetechnology.vigil.output");
    if (path != null && !path.isEmpty()) {
      VigilHelper.setOutputFile(path);
    }

    // Delegate to Byteman agent
    Main.premain(args, inst);
  }
}
