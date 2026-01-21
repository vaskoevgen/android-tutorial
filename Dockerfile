FROM eclipse-temurin:17-jdk

# Set environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Install necessary system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android Command Line Tools
# Version: cmdline-tools;latest (checked from developer.android.com, typically part of commandlinetools-linux-*.zip)
# Using specific version suitable for stability. 
# As of early 2024, cmdline-tools 11.0 is common, checking official link pattern.
# https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip is a recent one.
# We will use a reasonably recent valid URL.
ARG CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -o cmdline-tools.zip ${CMDLINE_TOOLS_URL} \
    && unzip cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Accept licenses
RUN yes | sdkmanager --licenses

# Install SDK packages
# Based on build.gradle: compileSdk 34, minSdk 24
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

WORKDIR /app
