# Upgrade this Project

This SpringBoot application is currently running on Java 11 and SpringBoot 2.5.x.

I want this project to be upgraded to the latest Java version and the latest SpringBoot version.

## Hints

1. Remember the context for the GenAI tool you are using. Make sure any relevant files are visible to the tool.
2. If you are unsure where to start, then I would begin with the pom.xml file.
3. There are two main changes to the code that have to happen. One is the package name for the javax.persistence library changes to jakarta.persistence. The other is the Swagger support changes and no longer requires any config classes (SwaggerConfig.java is no longer required). Look out to see if the tool is clever enough to sort that for you.
4. If you are trying this in the Virtual machine, you can test the code by running the SQL script in the sql directory using MySQL Workbench. The tool should be able to explain that for you as well.

