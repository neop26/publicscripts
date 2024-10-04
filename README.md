# Introduction

Share Scripts that I use.

1. Clean up Azure Container Registry - [Script1](https://github.com/neop26/publicscripts/blob/main/Scripts/cleanupacr.sh)
   - This script will go through your ACR and a specified Repository to delete old container images , in this case older than 7 days. It also checks if there is only 1 image left in the repository, it skips deleting it, so that the repository does not get removed.