## Deploying Sonarqube on Cloud.gov (Cloud Foundry)

### Setup
You'll need the following:
- [Cloud.gov account](https://cloud.gov/docs/getting-started/accounts/)
- [cf-cli](https://github.com/cloudfoundry/cli#installers-and-compressed-binaries)
- [jq](https://stedolan.github.io/jq/) Used to retrive VCAP_SERVICES from Cloud.gov's service broker. E.g. `brew install jq`

### Installation
- [Login to Cloud.gov Dashboard](https://login.fr.cloud.gov/login)
- [Login on the command line](https://cloud.gov/docs/getting-started/setup/#set-up-the-command-line) - `cf login -a api.fr.cloud.gov  --sso` copy and paste the [Temporary Authentication Code](https://login.fr.cloud.gov/passcode).
- Select your organization to target

Open your command line from this directory and follow these steps:
```
$ cf create-space sonarqube
$ cf create-app sonar

# Before the next step, review the service marketplace from the cloud.gov organization dashboard or use `cf marketplace` to find the mysql service(s) to target - suggest using `mysql-shared` for testing. 
$ cf marketplace

# To provision a new service instance for your app, you can use the dashboard GUI or use the cf-cli create-service command - the command looks like this: `cf create-service {{service}} {{plan}} {{service_name}}`. Example:

$ cf create-service aws-rds shared-mysql sonar-db
$ cf create-service-key sonar-db sonar
$ cf service-key sonar-db sonar

```

That's it you now run the cf push command which will take your manifest.yml file, pull down the docker container, and parse the service credentials (from [VCAP_SERVICES](https://docs.cloudfoundry.org/services/binding-credentials.html)) using the `run.sh` script.
```
cf push --random-route
```

### Manually provide credentials 
>`credentials.yml` should be created via the `run.sh` script automatically. But, if you don't have access to the service broker for some odd reason; you can manually input values into the credentials.yml file directly and the manifest.yml file will inject them for you.

```
cp credentials.yml.sample credentials.yml
```

## Installing additional plugins

Installing plugins via Marketplace doesn't work well since download files exist in the ephemeral disk and will disapper when the container is restarted.
You can use [Manual Installation](https://docs.sonarqube.org/display/SONAR/Installing+a+Plugin#InstallingaPlugin-ManualInstallation).
You need to have plugins before sonar starts and place them into `/opt/sonarqube/extensions/plugins`.

Here is an example to install [GitHub Authentication Plugin](https://docs.sonarqube.org/display/PLUG/GitHub+Authentication+Plugin).

```yaml
cat <<EOF > manifest.yml
applications:
- name: sonar
  memory: 2g
  health-check-type: http
  health-check-http-endpoint: /
  command: |
    wget -q -P /opt/sonarqube/extensions/plugins/ https://binaries.sonarsource.com/Distribution/sonar-auth-github-plugin/sonar-auth-github-plugin-1.4.0.695.jar && \
    ./run.sh 
  docker:
    image: sonarqube:7.4-community
  env:
    SONARQUBE_JDBC_USERNAME: ((username))
    SONARQUBE_JDBC_PASSWORD: ((password))
    SONARQUBE_JDBC_URL: jdbc:mysql://((hostname)):((port))/((name))?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
EOF
```
