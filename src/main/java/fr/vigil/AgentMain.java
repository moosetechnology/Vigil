package fr.vigil;

import java.lang.instrument.Instrumentation;
import org.jboss.byteman.agent.Main;

public class AgentMain {

  public static void premain(String agentArgs, Instrumentation inst) {
    try {
      String path = System.getProperty("fr.vigil.output");
      if (path != null && !path.isEmpty()) {
        VigilHelper.setOutputFile(path);
      }

      Main.premain(agentArgs, inst); // Delegate to Byteman agent
    } catch (Throwable t) {
      throw new RuntimeException(t);
    }
  }
}
