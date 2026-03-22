### Disclaimer

Development with TYPO3 is commonly done using [DDEV environment](https://docs.ddev.com/en/stable/users/quickstart/#typo3). Mainly designed for local use in Docker environment DDEV is being brought also to Codespaces and Kubenetes environments. Anyway DDEV is likely a form of 

# Additional information

Normally a TYPO3 setup consists of the following main parts

* PHP version as required by TYPO3 with the needed extensions enabled
  * XDebug support enabled for development needs
* a webserver that
  * is enabled to process the *.php files in the TYPO3 folders
  * properly configured with secure filters and rewrite rules
* a database backed supported by TYPO3 version

This Devcontainer blueprint is based upon the following ruleset:

* we make use of Docker-In-Docker (DIND) within the core devcontainer to provide the best "local-lookalike-feeling" for developers who could thereby launch any additional docker service they want
* the core devcontainer environment (based on Debian Trixie) contains the PHP environment needed for the designated TYPO3 version in addtion to the souce code checked out into the working directory
* a database backend is started as a separate docker service based on the selected `TYPO3_INSTALL_DB_DRIVER` in the file `.devcontainer/.env`

## Provided variances

Currently only variances of FrankenPHP integrated webserver (Caddy) with the following PHP versions are provided:

* 8.2
* 8.3
* 8.4
* 8.5

FrankenPHP currently *only* runs in classic mode comparable to Apache/mod_php or PHP-FPM. Unfortunately worker mode is not supported by TYPO3 at this point of time.

![Architecture overview](doc/Devcontainer_FrankenPHP.drawio.png)

## Getting started using Github Codespaces

* Login to Github WebUI and select the desired branch
* select the dropdown field `<> Code` / Tab `Codespaces`
* in the rown `Codespaces` select the three dots</br>
  (choosing `+` will launch the default configuration)
* select `+ New with options...`
  * verify that the correct branch is selected
  * choose the default devcontainer configuration
  * verify the region
  * choose a machine type (2 cores should be fine to start)
* select `Create codespace`</br>
  Now a VS Code UI opens in the browser window.
  * please be VERY patient now because all containers have to be build initially including the whole TYPO3 environment. You may follow the progress by pressing `Building codespace...` link in the bottom right corner:</br>
  ![Building codespace](doc/Github_VsCodeBuildingCodespace.png)</br>
  If you later start the codespace again it will come up quickly.
