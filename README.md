# Android CI/CD Pipeline with Docker & GitHub Actions

## Overview
This repository demonstrates a production-grade **DevOps** setup for mobile applications. It implements a complete CI/CD pipeline for Android using **Infrastructure as Code (IaC)** principles with Docker and **Automated Workflows** with GitHub Actions.

## Key Features (DevOps Highlights)
- **Containerized Build Environment**: Uses a custom Dockerfile with OpenJDK 17 and Android SDK 34 to ensure ensuring 100% reproducibility across environments ("Infrastructure as Code").
- **Automated CI Pipeline**: Triggers builds on feature branches (`feat/*`) and the main branch.
- **Conditional Build Logic**: Automatically distinguishes between development builds (`debug`) and production artifacts (`release`) based on the branch.
- **Artifact Management**: Automatically packages and uploads APKs for testing and distribution.
- **Quality Checks**: Includes linting and static analysis integration.

## Project Structure
- `.github/workflows/`: CI/CD definitions.
- `Dockerfile`: Build environment definition.
- `app/`: Android application source code.
- `TUTORIAL.md`: **[Build Guide & Interview Prep Details](./TUTORIAL.md)**.

## Quick Start
1. Fork this repository.
2. Create a feature branch: `git checkout -b feat/my-feature`.
3. Push changes to trigger a **Debug Build**.
4. Merge to `main` to trigger a **Release Build**.
