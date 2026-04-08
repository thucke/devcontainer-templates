# Devcontainer template `typo3`

Homepage: [Github](https://github.com/thucke/devcontainer-templates/tree/main/src/typo3)

## Working in the TYPO3 Devcontainer

  After the TYPO3 devcontainer environment came up you will find in a container running Debian Trixie:

  * User: `typo3dev`
  * Homedirectory: `/home/typo3dev`
  * SUDO-command: *passwordless for any command*
  * Git-Repository: checked out to `${WORKSPACE_ROOT}`

## Re-Initialize TYPO3 environment

  If you need to get a clean TYPO3 environment based upon your configuration you may spawn a terminal window and execute

   `${WORKSPACE_ROOT}/.devcontainer/docker/igniteEnvironment.sh`

## Update devcontainer template

If you want to update the devcontainer configuration e.g. after a new template version has been published you can make use of the [Dev Container CLI](https://github.com/devcontainers/cli) with the following command (**make sure you're in the root directory of your repository**):

    devcontainer templates apply --template-id ghcr.io/thucke/devcontainer-templates/typo3  --template-args "{\"database\": \"mysql\", \"phpVersion\": \"8.4\"}" -w .

Valid values:
* `database`: `mysql` || `sqlite`
* `phpVersion`: `8.2` || `8.3` || `8.4` || `8.5`

## TYPO3 environment configuration

  You may modify the file `${WORKSPACE_ROOT}/.devcontainer/.env` with caution if you want to adjust some core TYPO3 settings. After this file has been modified it is recommended to rebuild the whole devcontainer.

  **In this file you can find the password of the database root as well as the TYPO3 backend user credentials.**

## Database connection (Default settings)

### `mysql`

You may prefer to use a db client extension of your IDE or the preinstalled adminer web UI that can be reached out with [this link](http://127.0.0.1:8080) after all containers started successfully.

* Host: `127.0.0.1`
* Port: `3306`
* Database: `db`
* Username: `root`
* Password: `dbroot`