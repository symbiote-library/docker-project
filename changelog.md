# Change Log

A collection of patch notes and upgrade instructions.

Please add newer logs above older logs. See bottom of file for template.

---

## 0.1.0

#### Upgrading:

- Create `docker.env` file in project root.
- Add these vars to `docker.env` (where relevant). Vars should be wrapped in quotes.
    - Add `DOCKER_CONTAINER` with same value as `CONTAINERS` in `du.sh`.
    - Add `DOCKER_PHP_VERSION` with php version from `docker-compose.yml`.
    - Add `DOCKER_MYSQL_VERSION` with mysql version from `docker-compose.yml`.
    - Add `DOCKER_NODE_VERSION` with node version from `docker-compose.yml`.
    - Add `DOCKER_YARN_PATH` with same value as `YARN_DIR` in `dr.sh`.
- Commit `docker.env` to your repo.
- Replace `docker-compose.yml`, `du.sh`, and `dr.sh` and commit to repo.

Optional:

- Create `.env` file in project root and add local docker vars (see below). **Do not commit this file**.

#### Fixes:

- Environment variables are now loaded from `.env` and `docker.env`.

#### Updates:

- Readme updated with these changes and generally cleaned up.

#### Renamed:

- MySQL container renamed from `mysql56` to `mysql`. Existing functionality is unaffected, but keep in mind if running commands directly on containers.
- `PHP_FPM_EXTENSIONS` renamed to `DOCKER_PHP_COMMAND`.

#### Features:

- Environment config overhaul.
- New options for `du.sh`.

#### Environment config overhaul:

Project vars (defined in a remote `docker.env` file).
- `DOCKER_CONTAINERS`
- `DOCKER_PHP_VERSION`
- `DOCKER_MYSQL_VERSION`
- `DOCKER_NODE_VERSION`
- `DOCKER_YARN_PATH`

User vars (defined in a local `.env` file).
- `DOCKER_SHARED_PATH`
- `DOCKER_PROJECT_PATH`
- `DOCKER_ATTACHED_MODE`
- `DOCKER_PHP_COMMAND`

The goal here is to move variables out of the 3 core docker files so that:
- Easier to update the core docker files across projects.
- Easier to update user/project docker config.
- More obvious where user/project docker config is stored (and which is which).

The `DOCKER_PROJECT_PATH` is specifically to separate project data and avoid issues like muddled logs, or using different mysql versions. The shared path still exists for the composer-cache, etc.

#### New flags for du.sh:

- `-s` Stops all running containers before starting new containers.
- `-k` Kills all running containers before starting new containers.
- `-r` Removes all stopped containers before starting new containers.
- `-p` Pulls down latest images for new containers before starting them.
- `-c` Cancel starting containers (like doing 'ctrl+c' right before containers start).

You can combine these flags and each flag will be executed in the given order.

Common uses:
- `./du.sh -s` when swapping projects (or `-k` when you don't care to retain container states).
- `./du.sh -kr` when you want to reset the container environment.
- `./du.sh -p` when starting a project you haven't used in a while.
- `./du.sh -pc` when you want to update a project's images, but not start the containers.

---

# TEMPLATE

# x.x.x (tag here)
Author: Name

#### Upgrading: (instruction on moving to this version)

- Point 1.
- Point 2.

#### Fixes: (was broken, now fixed)

- Point 1.
- Point 2.

#### Updates: (was working, now working differently)

- Point 1.
- Point 2.

#### Renamed: (name changed, affecting usage)

- Point 1.
- Point 2.

#### Features: (didn't exist, now does)

- Feature 1.
- Feature 2.

#### Feature 1

Text about feature 1.

#### Feature 2

Text about feature 2.