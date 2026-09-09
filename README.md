# Docker Learning Path

Learn Docker by building and operating the same small Task API in **Python, Rust or Java**. Choose one language for the core path; use the others to compare how runtimes affect image builds and development workflows.

The course progresses from containers and Dockerfiles to Compose networks, persistent storage, security, monitoring and CI. Each module includes an exercise and observable completion criteria. A short, optional **Beyond Docker** section introduces other container tools and Kubernetes with kind.

## Start learning

1. Clone this repository:

   ```bash
   git clone https://github.com/sm4rtm4art/Docker-Example.git
   cd Docker-Example
   ```

2. [Prepare your environment](docker-mastery-multitrack/00-prerequisites/index.md).
3. Follow the [learning path](docker-mastery-multitrack/docker-curriculum-guide.md) in order.

You need Git, Docker with Linux containers and Compose, Python 3.12+ for the checks, and curl. Examples use Bash; on Windows, use WSL2. Language compilers run inside the build containers.

The Task API stores tasks in memory. The PostgreSQL lab teaches persistence separately; the monitoring lab combines the API, Prometheus and Grafana. Keep the labs local: the API has no authentication.

## Check your progress

After completing a track, run from the repository root:

```bash
python3 scripts/validate.py track --track python
```

Choose `rust` or `java` as appropriate. The check builds an isolated lab, exercises the API and verifies runtime protections and restart behaviour. [Module 09](docker-mastery-multitrack/09-cicd-automation/index.md) explains the remaining checks and how to evaluate your results.

## Course website and contributions

The Markdown lessons also build as a Sphinx/MyST site with search and sequential navigation. See [development setup](DEVELOPMENT_SETUP.md) to preview the site, run checks or configure GitHub Pages.
