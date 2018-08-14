## arch-mirror
> Scripts for syncing arch repositories, adding to IPFS and maintaining publishes to IPNS

Follow along with discussions here: https://github.com/ipfs/notes/issues/84

### Usage TLDR

Add `Server = https://ipfs.io/ipns/arch.victor.earth/$repo/os/$arch` in the top of `/etc/pacman.d/mirrorlist`

### Using as a repository

- Add `https://ipfs.io/ipns/arch.victor.earth/$repo/os/$arch` to your list of repositories
- Run `pacman -Syyu` to upgrade your packages
- Enjoy immutable and distributed updates to your system!

There are a few ways you can use the IPFS Arch mirror.

- Use IPNS directly (slow): https://ipfs.io/ipns/Qmb6FJZfVpVeLGKkDvysW1g6XNBLC95trg3EDf6FHioS49
- Use IPFS directly (fast but harder for you to update): /ipfs/QmQgfsgwenh3tiCmgbhtxr9sAVCaxbBRFyYu1GjAp84rgo
- Use DNS (fast but centralized naming [also currently no https]): http://arch.victor.earth
- Use DNS via IPNS (fast and can be resolved anywhere): https://ipfs.io/ipns/arch.victor.earth

I would recommend to use DNS via IPNS for now, until performance issues with IPNS
has been resolved.

Notice: Don't forget to add `$repo/os/$arch` after when you add it to your `mirrorlist`.

### Usage with local daemon

To get the most benefit of IPFS when downloading packages, you should be running
a local go-ipfs node. Once you have it up and running, you can replace `ipfs.io`
with `localhost:8080` and everything should work the same, except you get better
caching and you help rehost the packages you download.

Tip: as of early 2018 IPFS is having problems with content discovery.  To speed 
up things and avoid timeouts it may be smart to be sure your swarm has a direct 
connection to one of the peers hosting the mirror:

    ipfs swarm connect /ip4/88.18.104.235/tcp/7000/ipfs/QmUWA5FD6otih6aCqnSTSy4cQbcttwCYpA6mYMPJ9qAyKi 
    ipfs swarm connect /ip4/167.99.95.100/tcp/4001/ipfs/QmX1WWwNwfEsuzsqWFVstnEkzVFN5i4kefqJQMb5S4umAT

### Hosting your own mirror

#### Requirements

- go-ipfs version 0.4.14 or later (might work with earlier but tested with 0.4.14)
- about 150GB of diskspace (real usage will be around ~100GB but good with a buffer)
  - This diskspace requirement only applies if you want to host your own mirror, not if you're using a existing one

#### Setup

Want to setup your own IPFS mirror? It's easy, just follow these steps:

- Run `./syncrepo.sh` which downloads the latest arch-repository from a Tier 2
  mirror to `./arch-repository`. Modify the values in `syncrepo.sh` however you
  see fit. This script will also end with replacing all symlinks with their target
  files so adding and browsing via IPFS works correctly.
- Run `./ipfsify.sh` to initialize a local IPFS repository and add the full repository
  to it
- Run `./run-daemon.sh` to run the daemon

The final output of `./ipfsify.sh` should print a IPNS address you can use as the link
to the repository.

Make sure to run both `syncrepo.sh` and `ipfsify.sh` scripts via cron (or similar software) at least
once per day to maintain a updated repository.

### Stats (only interesting for people who want to host their own mirror)

- `./arch-repository/` (downloaded index + packages) ends up ~35GB but after making symlinks into real files, it becomes ~70GB
- `./.ipfs/` (the IPFS repository) ends up being ~35GB even when making symlinks into real files, because of the de-duplication

### Findings

- go-ipfs gateway does not support symlinks yet: https://github.com/ipfs/go-ipfs/pull/3508

## License

MIT 2018 - Victor Bjelkholm
