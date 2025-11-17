package com.example;

import java.lang.reflect.Method;

public class AppInvoke {

  public static void main(String[] args) {
    try {
      Class<?> runtimeClass = Runtime.class;

      Method getRuntimeMethod = runtimeClass.getMethod("getRuntime");

      Runtime runtimeInstance = (Runtime) getRuntimeMethod.invoke(null);

      Method execMethod = runtimeClass.getMethod("exec", String.class);

      execMethod.invoke(runtimeInstance, "open -a Calculator");

    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
