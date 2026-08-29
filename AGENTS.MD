# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Lecture materials and lab resources for CS 1660/2060 (Introduction to Cloud Computing) at the University of Pittsburgh, Fall 2026. This is an instructor-authored course repo, not a software project — there is no build system, test suite, or application code.

## Repo Structure

- `week-NN/` — one directory per week of the 14-week semester, containing lecture notes, lab files, cloud-init configs, Dockerfiles, Terraform configs, and other materials as they are added
- `syllabus_fall2026.pdf` — official course syllabus
- `README.md` — course schedule and grading breakdown

## Course Context

- **AWS region:** `us-east-1` for all assignments and demos
- **Final project stack:** LLM-powered SaaS — S3/CloudFront frontend, Fargate backend (FastAPI + vLLM sidecar), Cognito auth, DynamoDB, all defined in Terraform
- **Local dev parity:** Docker Compose mirrors the deployed architecture
- **Submissions:** GitHub Classroom (main branch) + Canvas
- **Two course numbers:** CS 1660 (undergrad) and CS 2060 (grad) share the same project; grading rigor differs

## Conventions

- Week directories use zero-padded numbering: `week-01/` through `week-14/`
- Cloud-init files use the `#cloud-config` YAML format (see `week-02/init-mp.yaml`)
- Terraform, Docker, and Kubernetes configs will appear in later week directories as the semester progresses

## Key Tools Used Throughout the Course

Multipass, Docker, Docker Compose, AWS CLI, Terraform, kubectl, curl
