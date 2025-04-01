# Dockerfile for local development of PySpark in Microsoft Fabric and to run CI tests locally.

# Create a build stage for Java from the eclipse-temurin image of Java Version 11 (Fabric runtime 1.3 version)
FROM eclipse-temurin:11 AS build-stage

# Use the dev container image with Python 3.11 as base (Fabric runtime 1.3 version)
FROM mcr.microsoft.com/devcontainers/python:3.11

# Set environment variables for Java, copy and update PATH to include Java binaries
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=build-stage $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"