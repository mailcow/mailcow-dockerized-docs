To use pflogsumm with the default logging driver, we need to query postfix-mailcow via docker logs and pipe the output to pflogsumm:

```
docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | pflogsumm
```

The above log output is limited to the past 24 hours.
