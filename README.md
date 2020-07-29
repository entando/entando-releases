# entando-releases

Coordination repository for the Entando releases

# Structure:
 - The **`./dist`** dir contains the info for deployments/installations
 - The **`./manifest`** file contains the parameters after which **dist** is generated
 - everything else is here to help generating the **dist** dir

# Usage:

**CONFIGURE:**

 - `Edit the *manifest* file`


**BUILD:**

 - `Run ./build.sh`

**SAVE:**

 - `Commit, Push`

**PUBLISH:**

- `Eventually merge to master and tag the commit according with ENTANDO_VERSION`

