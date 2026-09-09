# Development setup

For learning Docker, start with [module 00](docker-mastery-multitrack/00-prerequisites/index.md). This page describes contributing to the repository and building the course website. Run all commands from the repository root.

## Validate changes

Use Python 3.12+, Git and Docker with Linux containers and Compose supporting `up --wait`.

```bash
python3 -m venv .venv-ci
. .venv-ci/bin/activate
python -m pip install -r requirements-ci.txt
python scripts/validate.py static
python -m unittest discover -s tests -v
python scripts/validate.py configs
```

Run the relevant container checks from [the script reference](scripts/scripts-utilities-guide.md). Shared API changes require all three tracks. Runtime checks use isolated projects, remove their own test volumes and write logs and JSON to `reports/`. The regular CI runner is Ubuntu 24.04; report additional platform checks separately.

## Build the course website

The course uses Sphinx, MyST Markdown and the Furo theme. Lessons are the single content source under `docker-mastery-multitrack/`; the website is generated, not edited separately.

```bash
python -m pip install -r requirements-docs.txt
python -m sphinx -n -W --keep-going -b html -c docs docker-mastery-multitrack _build/html
python -m http.server 8000 --directory _build/html --bind 127.0.0.1
```

Open `http://127.0.0.1:8000`. Check the landing page, nested sidebar, previous/next links and search. Ctrl+C stops the local server. The strict build fails on warnings, including broken internal references and documents missing from the navigation. The PR workflow uploads the HTML as `course-site-preview`; download and serve it using the same HTTP server command, pointing at the extracted folder.

## Publish with GitHub Pages

GitHub Pages supports public repositories on GitHub Free; Pro is not needed for this public repository. The workflow builds static HTML and does not require a paid hosting provider.

After merging the workflow into the default branch:

1. In repository **Settings → Pages**, choose **GitHub Actions** as the build source.
2. In **Actions**, run **Publish course website** from `main`.
3. Follow the deployment URL from the `github-pages` environment.

Publishing is manual. Pull requests build a preview artifact without publishing it. Later course changes require another manual run after merging. The same generated `_build/html` directory can be hosted by another static host if needed.

Reading: [GitHub Pages availability](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), [custom Pages workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages), [MyST content organisation](https://myst-parser.readthedocs.io/en/latest/syntax/organising_content.html).

## Maintain dependencies and lessons

- Python: update `pyproject.toml`, run `uv lock`, verify `uv sync --locked`, then regenerate `requirements.txt` with `uv export --locked --no-dev --no-emit-project --output-file requirements.txt` in the track directory.
- Rust: maintain `Cargo.lock` and verify `cargo build --locked` through the image build.
- Java: maintain the Maven parent/dependencies and compatible JDK/JRE together; run build verification and the HTTP contract.
- Images: review version tags, support periods and security findings; rebuild and test updates. Digests also need an update process.
- Actions: update commit SHAs and version comments together. Keep permissions scoped to each job's needs.
- Documentation: keep English learner-facing text, observable exercises and inline links to primary documentation. Update `curriculum.json`, the course guide and module `index.md` navigation together.

The API reference belongs in module 02 beside the quickstarts. Keep review discussions in pull requests and outstanding maintenance work in issues, outside the learning path. Advisory scan success does not establish that the built images are free of vulnerabilities.

The optional kind validation requires kind and kubectl. Its separate manual workflow can run once available on the default branch; it is not a prerequisite for the Docker course.
