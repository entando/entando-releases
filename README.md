# entando-releases

Coordination repository for the Entando releases

# Directory Structure:
 - The **`dist`** directory contains the data required by the installations procedures
 - The **`build.sh`** script is the one that generates the **./dist** directory
 - The **`manifest`** file contains the parameters after which **./dist** is generated
 - The **`script`** directory that contains utilities and a cache areas used by the build.sh script

# Usage:

**CONFIGURE:**

 - `Edit the *manifest* file`


**BUILD:**

 - `Run ./build.sh`

**SAVE:**

 - `Commit, Push`

**PUBLISH:**

- `Set a release tag`
- `Generate a github release`
- `Remember to use release braches`
