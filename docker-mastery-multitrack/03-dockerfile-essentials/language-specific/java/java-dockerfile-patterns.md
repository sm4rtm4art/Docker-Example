# Java: build with a JDK, run with a JRE

## Learning objectives

Explain the dependency and artifact boundaries in your chosen image.

## Prerequisites

The two shared Dockerfile lessons.

## Exercise

Read the Java `Dockerfile` and `pom.xml`. Maven and a JDK compile and verify the project in the build stage. The final stage copies the application JAR into a Java 21 JRE image. The compiler and Maven are not runtime requirements.

Change a controller response and rebuild. Compare dependency resolution and application packaging in the build log. Verify the response and the shared API tests.

A container memory limit covers the entire process, not just the Java heap. Native memory, thread stacks and the JVM also consume memory. Diagnose actual usage before adjusting heap settings.

Reading: [Maven lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), [Spring Boot container images](https://docs.spring.io/spring-boot/reference/packaging/container-images/index.html).

## Check your understanding

Show the source change in the running API, identify the final artifact and explain which inputs trigger a rebuild. Restore your exercise edit and clean up your lab.
