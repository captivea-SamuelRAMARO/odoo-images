# odoo-images

Image factory for CI. Builds Docker images that bundle **Odoo Community + Enterprise + git**,
and pushes them to GHCR so project repositories can run their tests against a
prebuilt image (no Enterprise checkout, no SSH key on the project side).

## Repository layout

```
odoo-images/
  Dockerfile
  .dockerignore
  .github/workflows/build-odoo-ee-images.yml
  README.md
```

## What it produces

For each Odoo version in the build matrix, two tags are pushed on every build:

- `ghcr.io/YOUR_ORG/odoo-ee:<version>` — moving tag, always the latest build.
- `ghcr.io/YOUR_ORG/odoo-ee:<version>-<YYYYMMDD>` — immutable, dated.

Projects pin the dated tag for stability, or track the moving tag to always get
the freshest Enterprise fixes.

## One-time setup

1. **Replace `YOUR_ORG`** in the build workflow with your GitHub organisation name.

2. **Add the Enterprise SSH key.** In this repo:
   *Settings -> Secrets and variables -> Actions -> New repository secret*
   - Name: `ENTERPRISE_SSH_KEY`
   - Value: the full **private** key (BEGIN/END lines included, trailing newline kept)
     of a key pair whose public key is on a GitHub account with read access to
     `github.com/odoo/enterprise`.
   This is the only repo that needs this secret.

3. **Trigger the first build manually.** Actions tab -> "Build Odoo CE+EE images"
   -> Run workflow. This seeds the tags; without it, projects would reference an
   image that doesn't exist yet.

4. **Make the images consumable by projects.** On the pushed package page
   (Org -> Packages -> odoo-ee -> Package settings), set visibility to
   **Internal** so any repo in the org can pull it with its `GITHUB_TOKEN`.
   (Alternatively keep it Private and grant access repo by repo.)

## Adding / removing an Odoo version

Edit the `matrix.version` list in `build-odoo-ee-images.yml`. The version drives
both the base image (`FROM odoo:<version>`) and the Enterprise branch
(`ref: <version>`), so they always stay aligned.

## Maintenance

The scheduled weekly build keeps the images in sync with Enterprise patches.
Old dated tags are never deleted automatically; prune them occasionally from the
package's "Manage versions" page if storage grows.

## Building locally (optional, to test before pushing)

```bash
# clone Enterprise at the target version next to the Dockerfile
git clone --depth 1 -b 19.0 git@github.com:odoo/enterprise.git enterprise

# build
docker build --build-arg ODOO_VERSION=19.0 -t odoo-ee:19.0 .

# sanity check: Enterprise addons are present
docker run --rm odoo-ee:19.0 ls /mnt/enterprise | head
```
