## arch-mirror
> Scripts for syncing arch repositories, adding to IPFS and maintaining publishes to IPNS

# Using as a repository

- Add `https://ipfs.io/ipns/:insert-ipns-here` to your list of repositories
- Run `pacman -Syy` to upgrade your local package list
- Enjoy

# Using as a repository mirror

Want to setup your own IPFS mirror? It's easy, just follow these steps:

- Run `./syncrepo.sh` which downloads the latest arch-repository from a Tier 1
  mirror to `./arch-repository`. Modify the values in `syncrepo.sh` however you
  see fit
- Run `./ipfsify.sh` to initialize a local IPFS repository and add the full repository
  to it
- Run`./publish.sh` at least one time manually to publish the latest IPFS hash to IPNS
- Add `./publish.sh` to be run at least once per day to ensure the IPNS record it kept
  up to date
