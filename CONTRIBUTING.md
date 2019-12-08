# Contributing guide

A simple way to help out is to check if new versions of packages have been released, and then open a pull request to update it.
The following instructions can be run both from a GNU/Linux computer and from termux.

The script `./scripts/check-updates.sh` can be used to check if any packages have received new releases.

Starting from scratch you need to:

   * [Fork this repo](#forking-this-repo)
   * [Clone your fork](#clone-your-fork)
   * [Create a new branch](#creating-a-new-branch)
   * [Update a package](#updating-a-package)
   * [Commit changes and push to your fork](#commiting-changes-and-pushing-to-your-fork)
   * [Open a pull request](#opening-a-pull-request)

## Forking this repo

To be able to open a pull request you need to first fork this repo to your own github account.
The changes you do will first be pushed to your own fork and thereafter a pull request can be opened against the main repo.
Forking is done by pressing the "Fork" button in the upper right corner of the repository page.
See the github help pages for more details: [fork-a-repo#fork-an-example-repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository).

## Clone your fork

Now that you have your own fork you can clone it to your termux device or computer.
From a suitable location simply run

```sh
git clone https://github.com/<your-username>/termux-root-packages
```

Note that it is also possible to [edit files directly in github](https://help.github.com/en/github/managing-files-in-a-repository/editing-files-in-your-repository), so this step could be skipped.

## Creating a new branch

It is recommended to create a new branch before making changes.
This is done by first checking out the master branch and making sure it is up to date, and then checking out a new branch:
```sh
git checkout master
git pull origin master
git checkout -b <package-name>-update
```

## Updating a package

Minor updates (going from for example v1.0.5 to v1.0.6) most often only means that the fields `TERMUX_PKG_VERSION`, `TERMUX_PKG_REVISION` and `TERMUX_PKG_SHA256` needs to be updated.
The changes in the build.sh would then change something like:
```sh
[ ... ]
TERMUX_PKG_VERSION=1.0.5
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://url.com/download/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=abde02986bc1fb112655bb5a3161dddfdc9436057fd8b305a01fe42b7dd247ae
[ ... ]
```
to
```sh
[ ... ]
TERMUX_PKG_VERSION=1.0.6
TERMUX_PKG_SRCURL=https://url.com/download/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6116e607250198f224d9ce9304eba6bf0792d592c0b55209e496843192cc6860
[ ... ]
```

Note that the `TERMUX_PKG_REVISION` line has been deleted, when a package is updated the REVISION should be reset to 0 and this line hence deleted.
The value for `TERMUX_PKG_SHA256` can be calculated by downloading the source archive and running sha256sum on it:

```sh
wget https://url.com/download/1.0.6.tar.gz
sha256sum 1.0.6.tar.gz
```

Major updates (going from for example v1.0.5 to v2.0.0) can mean that patches needs to be updated, or added.
The CI build of the pull request will fail if patches need to be updated, but only way to discover that new patches are needed is by testing the built package in termux.

## Commiting changes and pushing to your fork

Now that the build.sh is updated we can commit it and push it to github so that a pull request against the main repo can be opened.
To commit with a short message you can run:
```sh
git add packages/<package-name>
git commit -m "<package-name>: update to 1.0.6"
```

To push this to github you then run

```sh
git push origin
```

`origin` here is the repository that you originally cloned, which in this example is your fork.
The full url to this repository can be shown by running `git remote -v`

## Opening a pull request

You can now visit your repo in a browser and open a pull request against this repo by pressing "New pull request".
See [creating-a-pull-request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) for more information on how to do this.

Once a pull request has been created cirrus-ci will attempt to build the changes.
The status of the build can be seen by visiting https://cirrus-ci.com/github/termux/termux-root-packages.
