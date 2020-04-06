# Gitpod-AWS

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/JesterOrNot/Gitpod-AWS)

Gitpod running on AWS! This likley will be a temporary repo untill its hopefully
merged into Gitpod Self Hosted! But who knows?

To install it run the following

```
scripts/install-gitpod.sh [IP Address for your site] [Variables for Terraform]
```

An example being

```bash
scripts/install-gitpod.sh "https://example.com" -var 'aws.region=us-west-2'
```

You can find the defaults in src/variables.tf

## Try it in the browser

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/JesterOrNot/Gitpod-AWS)

You will need to setup the following enviornment variables though to get the AWS
setup to work
[configure the following enviornment in Gitpod](https://www.gitpod.io/docs/environment-variables/)
`AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID`
