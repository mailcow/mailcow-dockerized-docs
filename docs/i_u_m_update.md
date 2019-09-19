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
# Check for updates
./update.sh --check

# Update with merge strategy "ours" instead of "theirs" 
# This will merge in favor for your local changes.
./update.sh --ours

# Don't update, but prefetch images and exit
./update.sh --prefetch
```

## Manual update

### Step 1

You may want to backup your certificates, as an upgrade from an older mailcow: dockerized version may remove these files:

```
cp -rp data/assets/ssl /tmp/ssl_backup_mailcow
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

Check data/assets/ssl for your certificates (and dhparams.pem). If you miss them, recover your files:

```
cp -rp /tmp/ssl_backup_mailcow/* data/assets/ssl/
```

### Step 2

When upgrading from a version older than May 13th, 2017 to a version released after that date, you need to run the following command first as network settings have been changed:

```
docker-compose down
```

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
