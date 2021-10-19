It is possible to add pre- and post-update-hooks to the `update.sh` script that upgrades your whole mailcow installation.

To do so, just add the corresponding bash script into your mailcow root directory:  

* `pre_update_hook.sh` for commands that should run before the update
* `post_update_hook.sh` for commands that should run after the update is completed

Keep in mind that `pre_update_hook.sh` runs every time you call `update.sh` and `post_update_hook.sh` will only run if the update was successful and the script doesn't have to be re-run.

The scripts will be run by bash, an interpreter (e.g. `#!/bin/bash`) as well as an execute permission flag ("+x") are not required.
