## arch-mirror
> Scripts for syncing arch repositories, adding to IPFS and maintaining publishes to IPNS

# Requirements

- go-ipfs version 0.4.14 or later (might work with earlier but tested with 0.4.14)
- about 100GB of diskspace (real usage will be around ~70GB but good with a buffer)

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

The final output of `./ipfsify.sh` should print a IPNS address you can use as the link
to the repository.

Make sure to run both of these scripts via cron (or similar software) at least
once per day to maintain a updated repository.

# License

MIT 2018 - Victor Bjelkholm
