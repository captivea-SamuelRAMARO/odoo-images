# Community image + Enterprise addons + git.
#
# - Enterprise sources are copied from ./enterprise, checked out by the build
#   workflow just before the build (branch = ODOO_VERSION).
# - git is needed by the test workflow's changed-module detection, so it's
#   baked in here once instead of apt-get'ing it on every CI run.

ARG ODOO_VERSION=19.0
FROM odoo:${ODOO_VERSION}

# apt needs root; the base image otherwise runs as the "odoo" user.
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Enterprise addons live here; the test workflow adds /mnt/enterprise to the
# addons_path. Files are world-readable, so the odoo user can read them.
COPY enterprise /mnt/enterprise

# Restore the base image's default user so the image behaves like odoo:* when
# run outside CI. (CI overrides this with --user root anyway.)
USER odoo
