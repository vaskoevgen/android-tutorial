# DevOps Guide: Android CI/CD with Docker

This guide explains the "Why" and "How" of this project's architecture, specifically tailored for DevOps interview preparation.

## Part 1: The Architecture (Interview Concept)

**Question:** "How do you ensure consistent builds across different developer machines and CI servers?"
**Answer:** "By containerizing the build environment. I use **Docker** to define the exact version of the JDK, Android SDK, and Build Tools. This verifies that 'it works on my machine' means it works everywhere."

### The Dockerfile Explained
[View Dockerfile](./Dockerfile)
- **`FROM eclipse-temurin:17-jdk`**: We start with a stable, lightweight Java base image.
- **`ENV ANDROID_HOME`**: We adhere to standard conventions for SDK location.
- **`sdkmanager`**: We programmatically install specific SDK versions (`platform-34`) matching our `build.gradle` config.

## Part 2: The Pipeline (Interview Concept)

**Question:** "Describe your CI/CD strategy for mobile apps."
**Answer:** "I implement a branching strategy where feature branches trigger flexible debug builds for rapid feedback, while the main branch triggers strict production/release builds."

### The Workflow Explained
[View Workflow](./.github/workflows/android-docker.yml)

#### 1. Conditional Logic
We use shell scripting within the workflow to determine the build target dynamically:
```bash
if [ "${{ github.ref }}" == "refs/heads/main" ]; then
  # Production: Build Release
  echo "TASK=assembleRelease" >> $GITHUB_OUTPUT
else
  # Development: Build Debug
  echo "TASK=assembleDebug" >> $GITHUB_OUTPUT
fi
```

#### 2. Isolation
The build runs *inside* the Docker container:
```bash
docker run --rm -v $(pwd):/app ... ./gradlew $TASK
```
This ensures the CI runner's pre-installed tools don't interfere with our build.

#### 3. Artifact Retention
We use `actions/upload-artifact` to save the correct APK (`app-debug.apk` or `app-release-unsigned.apk`) allowing QA teams to download and test immediately without access to the code.

## Part 3: Android Configuration Basics for DevOps

**Question:** "What files do you need to configure in an Android project?"
**Answer:**
1.  **`app/build.gradle`**: Defines the *compileSdk* (must match Dockerfile) and *versionCode* (should be auto-incremented in CI).
2.  **`gradle.properties`**: Controls build performance (JVM args) and library compatibility (`android.useAndroidX=true`).
3.  **`local.properties`**: **IGNORED** by git. Used for local SDK paths. In CI, we use environment variables instead.

## Part 4: Common Interview Troubleshooting

- **"Gradle not found"**: Often means the wrapper script (`gradlew`) relies on a system gradle that isn't installed. *Fix: Install Gradle in the Docker image or use the wrapper correctly.*
- **"Permission denied"**: `gradlew` script often loses executable permission in git. *Fix: `chmod +x gradlew` or `git update-index --chmod=+x`.*
- **"License not accepted"**: The Android SDK requires explicit license acceptance. *Fix: Run `yes | sdkmanager --licenses` in the Dockerfile.*
