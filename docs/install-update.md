There is no update routine. You need to refresh your pulled repository clone and apply your local changes (if any). Actually there are many ways to merge local changes.

### Step 1
Fetch new data from GitHub, commit changes and merge remote repository:

```
# 1. Get updates/changes
git fetch origin master
# 2. Add all changed files to local clone
git add -A
# 3. Commit changes, ignore git complaining about username and mail address
git commit -m "Local config at $(date)"
# 4. Merge changes, prefere mailcow repository
git merge -Xtheirs -Xpatience

# If it conflicts with files that were deleted from the mailcow repository, just run...
git status --porcelain | grep -E "UD|DU" | awk '{print $2}' | xargs rm -v
# ...and repeat step 2 and 3
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

```
docker rmi -f $(docker images -f "dangling=true" -q)
docker volume rm $(docker volume ls -qf dangling=true)
```
