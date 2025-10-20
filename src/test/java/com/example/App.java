package com.example;

import java.util.ArrayList;
import java.util.List;

public class App {
  List<App> apps = new ArrayList<>();
  App parent = null;

  public static void main(String[] args) {
    App main = new App();
    main.apps.add(new App());

    for (App app : main.apps) {
      app.parent = main;
    }

    System.out.println(main.beginChain("hello", 42));
  }

  public String beginChain(String s, int x) {
    return "Result(" + midChain(s) + "," + midChain(x) + ")";
  }

  public String midChain(String s) {
    return s;
  }

  public int midChain(int x) {
    return x + endChain() - 1;
  }

  public int endChain() {
    return 1;
  }
}
