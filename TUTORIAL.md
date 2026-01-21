# Tutorial: Android GitHub Actions in Docker

This tutorial guides you through setting up a CI/CD pipeline for your Android application using GitHub Actions and Docker. This ensures a consistent build environment and automates your build process.

## Prerequisites

- An Android project (already set up in this repository).
- Docker installed on your development machine (for local testing).
- A GitHub repository.

## 1. The Docker Build Environment

We use a `Dockerfile` to define an immutable build environment. This container includes:
- **OpenJDK 17**: The Java version required by the Gradle build.
- **Android Command Line Tools**: Necessary for managing the Android SDK.
- **Android SDK Components**: Specifically `platforms;android-34` and `build-tools;34.0.0` as defined in `app/build.gradle`.

### Key Dockerfile Sections

```dockerfile
# Base image
FROM openjdk:17-jdk-slim

# Install system dependencies
RUN apt-get update && apt-get install -y curl unzip git ...

# Download Command Line Tools
RUN curl -o cmdline-tools.zip ...

# Install SDK Packages
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## 2. GitHub Actions Workflow

The workflow is defined in `.github/workflows/android-docker.yml`. It triggers on pushes and pull requests to the `main` branch.

### Workflow Breakdown

1.  **Checkout Code**: Retrieves your project source code.
2.  **Build Docker Image**: Builds the container defined in your `Dockerfile`.
3.  **Run Build**: Mounts the project source code into the container and runs `./gradlew build`.

```yaml
    - name: Run Gradle Build in Docker
      run: |
        docker run --rm \
          -v ${{ github.workspace }}:/app \
          -w /app \
          android-ci \
          ./gradlew build
```

## 3. Running Locally

You can test the build environment locally using Docker before pushing to GitHub.

### Step 1: Build the Image

```bash
docker build -t android-ci .
```

### Step 2: Run the Build

```bash
docker run --rm -v $(pwd):/app -w /app android-ci ./gradlew assembleDebug
```

This command:
- `--rm`: Removes the container after it exits.
- `-v $(pwd):/app`: Maps your current directory to `/app` inside the container.
- `-w /app`: Sets the working directory to `/app`.
- `android-ci`: Uses the image you just built.
- `./gradlew assembleDebug`: Runs the Gradle task to build the debug APK.

## Conclusion

By containerizing your build environment, you eliminate "it works on my machine" issues and simplify your CI configuration. This setup forms the foundation for more advanced pipelines, including running tests and deploying to the Play Store.

## 4. Downloading Artifacts

After a successful build on GitHub:
1. Go to the **Actions** tab in your repository.
2. Click on the specific workflow run.
3. Scroll down to the **Artifacts** section.
4. Click on `app-debug` to download the zip file containing your APK.

## 5. Android Configuration Explained (Interview Prep)

For a DevOps role involving mobile apps, understanding how the Android build system is configured is crucial. Here are the key files and concepts:

### 1. `app/build.gradle`
This is the build configuration for your specific app module.
- **`compileSdk`**: The Android SDK version used to compile the code (e.g., `34`). *DevOps Note: Your Docker image must have this specific SDK platform installed.*
- **`minSdk`**: The minimum Android version the app supports.
- **`targetSdk`**: The version the app is tested against.
- **`versionCode`**: An integer used by the Play Store to track updates. *DevOps Note: CI pipelines often auto-increment this.*
- **`versionName`**: The user-visible version string (e.g., "1.0").

### 2. `gradle.properties`
Project-wide configuration settings for the Gradle build system.
- **`android.useAndroidX=true`**: Required for modern Android libraries.
- **`org.gradle.jvmargs`**: Sets JVM memory for the build daemon. *DevOps Note: Important for preventing OOM (Out of Memory) errors in CI containers.*

### 3. `AndroidManifest.xml`
The manifest describes essential information about the app to the Android build tools, the Android OS, and Google Play.
- **`package`**: Unique ID for the app.
- **Permissions**: e.g., `<uses-permission android:name="android.permission.INTERNET" />`.
- **Activities**: Defines the screens of your app (`MainActivity`).

### 4. SDK Location
- **Local Development**: Typically defined in `local.properties` (which is git-ignored).
- **CI/Docker**: Defined using the `ANDROID_HOME` environment variable. This is why we set `ENV ANDROID_HOME` in the Dockerfile.

## Conclusion
