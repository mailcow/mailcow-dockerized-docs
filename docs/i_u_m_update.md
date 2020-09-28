## Automatic update

An update script in your mailcow-dockerized directory will take care of updates.

But use it with caution! If you think you made a lot of changes to the mailcow code, you should use the manual update guide below.

Run the update script:
```
./update.sh
```

If it needs to, it will ask you how you wish to proceed.
Merge errors will be reported.
Some minor conflicts will be auto-corrected (in favour for the mailcow: dockerized repository code).

### Options

```
# Options can be combined

# - Check for updates
./update.sh --check

# Do not try to update docker-compose, **make sure to use the latest docker-compose available**
./update.sh --no-update-compose

# - Do not start mailcow after applying an update
./update.sh --skip-start

# - Force update (unattended, but unsupported, use at own risk)
./update.sh --force

# - Run garbage collector to cleanup old image tags and exit
./update.sh --gc

# - Update with merge strategy option "ours" instead of "theirs"
#   This will **solve conflicts** when merging in favor for your local changes and should be avoided. Local changes will always be kept, unless we changed file XY, too.
./update.sh --ours

# - Don't update, but prefetch images and exit
./update.sh --prefetch
```

### I forgot what I changed before running update.sh

See `git log --pretty=oneline | grep -i "before update"`, you will have an output similar to this:

```
22cd00b5e28893ef9ddef3c2b5436453cc5223ab Before update on 2020-09-28_19_25_45
dacd4fb9b51e9e1c8a37d84485b92ffaf6c59353 Before update on 2020-08-07_13_31_31
```

Run `git diff 22cd00b5e28893ef9ddef3c2b5436453cc5223ab` to see what changed.

### Can I role back?

Yes.

See the topic above, instead of a diff, you run checkout:

```
docker-compose down
# Replace commit ID 22cd00b5e28893ef9ddef3c2b5436453cc5223ab by your ID
git checkout 22cd00b5e28893ef9ddef3c2b5436453cc5223ab
docker-compose pull
docker-compose up -d
```

## Manual update (not maintained anymore, please use update.sh)

### Step 1

```
docker-compose down
```

Fetch new data from GitHub, commit changes and merge remote repository:

```
# 1. Get updates/changes
git fetch origin master
# 2. Add all changed files to local clone
git add -A
# 3. Commit changes, ignore git complaining about username and mail address
git commit -m "Local config at $(date)"
# 4. Merge changes, prefer mailcow repository, replace "theirs" by "ours" to change merge strategy
git merge -Xtheirs -Xpatience

# If it conflicts with files that were deleted from the mailcow repository, just run...
git status --porcelain | grep -E "UD|DU" | awk '{print $2}' | xargs rm -v
# ...and repeat step 2 and 3
```

### Step 2

Pull new images (if any) and recreate changed containers:

```
docker-compose pull
docker-compose up -d --remove-orphans
```

### Step 3
Clean-up dangling (unused) images and volumes:

It is **very important** to _not_ run these commands when your containers are deleted.
Running `docker-compose down` - for example - will delete your containers. Your volumes are now in a dangling state! Running the commands shown below, _will_ remove your volumes and therefore your data.


```
docker rmi -f $(docker images -f "dangling=true" -q)
docker volume rm $(docker volume ls -qf dangling=true)
```


## Footnotes

- There is no release cycle regarding updates.
