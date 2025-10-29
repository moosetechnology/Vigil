# Vigil

Automatic instrumentation for vulnerability analysis.

Vigil is a framework designed to analyze Java vulnerabilities dynamically within Moose.
It allows executing and observing Java applications while instrumenting them automatically.

This repository hosts both **Java** and **Moose** components.

## Project Structure

- **`java/`** — Java agent project for automatic instrumentation using [Byteman](https://byteman.jboss.org/).
- **`moose/`** — integrates Vigil into the Moose environment for visualization and analysis.


## Java Component

The Java agent instruments Java applications to capture runtime behavior.
It is built using **Gradle** and depends on:
- [Byteman](https://byteman.jboss.org/)
- [XStream](https://x-stream.github.io/)
- Gradle wrapper for reproducible builds

For details about building and using the Java agent, see [java/README.md](java/README.md).


## Moose Component

The Moose component serves as the main analysis interface.  
Given information about the **application**, its **dependencies**, and a **vulnerability**, it automatically analyzes the vulnerability and constructs a metamodel that allows users to study it interactively within Moose.

This component bridges the dynamic data collected by the Vigil Java agent with the modeling and visualization power of the Moose environment.



