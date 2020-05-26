# Contributing to this project.

This document is intended to be a brief cheatsheet for people wanting to contribute.

We have some short guides on how to use git, docker, and singularity etc.
For now while we're still developing the first version of the pipeline, this document is fine.
Once we publish (version 1), we'll need to re-organise these guidelines a bit to follow something more like the [git workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) model.


## Git

Git is a version control tool.
It tracks differences of *lines* between changes of text documents.

The basic workflow for using git with other people goes a bit like this:

1. Clone (or fork and then clone) the repository to your computer with `git clone`.
2. Create a new branch just for yourself with `git checkout -b my_branch_name`.
3. Create changes to the code, or add or delete files.
4. Add the files that you've created or modified to be tracked by git using `git add`.
   This is called staging. It's like a declaration that these are changes that I want to keep.
5. Commit the staged changes to your branch using `git commit`.
   This creates a semi-permanent record of the files in the branch.
6. Pull any changes to the master branch that your co-workers have made from github with `git pull`.
   This will attempt to merge any changes with your changes, and you may have to resolve merge conflicts if you have both modified the same lines.
7. Push your new branch with your special features added to the repository with `git push`.
8. Create a "pull-request" to merge your branch with the master branch.
   This allows other team members to review your changes, and it will check for merging conflicts again.
9. Accept the pull request, to merge the branch back into master and make your changes available to other people.
10. Repeat steps 3-9 using the your existing branch (or delete it and create a new branch if you want to rename it, the changes are now in master).


#### important commands

Here are some copy-pastable examples that you might use.


```bash
git clone git@github.com:ccdmb/predector.git ./predector
```

"Clone" the repository to your computer to a new folder `predector`.


```bash
git branch my_new_branch
git checkout my_new_branch

# Shorthand for the two commands above
git checkout -b my_new_branch
```

Create a new branch called `my_new_branch` and then tell git that you want to work in that new branch.
To switch back to the `master` branch (or any other branch or commit id) you can use:

```bash
git checkout master
```

If you have made changes to a file that you haven't `commit`ted or `add`ed yet,
you can revert the file back to the last `commit`ed version by checking out the `HEAD` (the most recent commit in this branch).
For example say you had edited `README.md` and wanted to discard those changes.

```bash
git checkout -- README.md
```

Would reset the file to the last commit state.

To "stage" files that you have modified and want to keep track of:

```bash
# Add all files in the current working directory
git add -A

# Add a specific file with changes to be tracked.
git add README.md

# Add a whole directory
git add bin/
```

To see what files you have `add`ed, and that you have modified but not yet added you can check its "status".

```bash
git status
```


If you decide that you want to unstage something that you've staged and haven't yet `commit`ed you can use.
E.G. say you decided that you didn't want to stage the changes to files in `bin/` yet.

```bash
git reset HEAD bin/
```

Your modifications will still be there but the file is no-longer engaged to be `commit`ed.


When you're finished making changes you can `commit` the staged changes.

```bash
git commit -m "This is a message describing briefly what changes you've made."
```

If you don't include the `-m` flag it will open up your default text-editor (usually nano) and you'll have to write a message in there.
Make sure that any text after `-m` either doesn't have spaces or is quoted.

To integrate any changes that other people have made on the github repository `master` branch into your current branch.

```bash
git pull origin master
```

`origin` is the name of the remote repository that you want to pull from.
When you called `git clone` earlier, it automatically puts the github uri in the remotes names `origin`.
You can have multiple remotes, but we'll just be using `origin`.
So this command merges the content of the master branch into your currently checked out branch.
To merge master into your master branch, you first need to `checkout` master.
To merge a different branch, change `master` to the branch that you want.

When you call `pull`, git will attempt to merge the changes into a single coherent set.
**If** you and another person have both modified the same lines, you might receive a "merge conflict".
Don't worry! It's not as complicated as you might think.

Git will tell you which files have the conflicts and will mark the offending regions like so.


```
<<<<<<< HEAD
This might be some text in your current branch that you have modified.
=======
This might be some text on the remote master branch that someone else has modified
that is in the same position in the file.
>>>>>>> remote:master
```

To resolve a merge conflict you need to manually merge the two chunks (separated by `=======`).
Usually this involves deleting one option and keeping the other.

Once you've fixed the merge conflict blocks, you `add` the changes and `commit` them to your branch as you did before.
If any blocks with that `<<< HEAD` etc structure are still in your code, git will raise an error and tell you to fix it.


To "push" your changes to the remote repository you can do:

```bash
git push origin my_new_branch
```

Note that the first time you push a new branch to the remote you should use the `-u` flag, to tell git that we want to track changes to this branch.

```bash
git push -u origin my_new_branch
```


If your changes are ready to be shared and for other people to use, you can open a pull-request on github to merge your branch into master.


To continue working you can just stay in the same branch and continue to create pull requests into master when you're ready to share.
More fancy people will create a new branch for every new "feature" that is going to be implemented, and those branches get removed when the new feature is finished and merged.


## Versioning

We will try to follow the ["semver" guidelines](https://semver.org/).

We're using [bump2version](https://github.com/c4urself/bump2version) to automatically handle version increases.
Because we have to store the version in several places, doing this manually is very error prone so we let a program handle it all for us.

Versions follow the standard semver `major.minor.patch` versioning scheme with optional `alpha`, `beta` pre-releases.
In the context of a bioinformatics pipeline, I interpret the tags like this:

- "Major" version changes should be reserved for restructuring the pipeline, or major changes to the output formats.
  E.G. Adding a lot of new analyses, removing analyses, new summarization and ranking methods etc.
- "Minor" version changes are stable releases that don't really change the analysis or result formats much.
  E.G. Updated versions and/or parameters for software or databases, performance upgrades, retrained models with new databases, new utilities or reporting features.
- "Patches" are used for bug-fixes and very minor changes.
- Pre-releases will be mostly for making sure that continuous integration stuff is working (e.g. conda environment pushes and docker automated builds) and for final checks before saying that something is "stable".
  They'll also be useful if you're trying to debug the CI stuff, since we can create `-alpha.1`, `-alpha.2` versions to trigger builds on dockerhub but indicate that they aren't proper releases.
  We should run `beta` releases through a few different realistic datasets to make sure everything is ok.
  If you're sure that everything is ok, you can just skip through the pre-release stuff and straight into a patch release.


#### Example version change commands

We have some copy-pastable commands that you can use below, but note that these will update several files, commit those changes, tag them with the new version, and push the changes and tags to github.
You'll need to be in the git repository root directory to run the commands because it looks for a file called `.bumpversion.cfg`.
For major and minor releases, you should add a brief message using the `--tag-message` argument.
You can also add a `--commit-message` if you like.

To bump the patch version:

```bash
# version 0.0.1
bump2version patch
# version 0.0.2-alpha
```

Bump the release version:

```bash
# version 0.0.1-alpha

bump2version release
# version 0.0.1-beta

bump2version release
# version 0.0.1

bump2version release
# version 0.0.2-alpha
```


To trigger the automated builds but not indicate a stable version, use a pre-release:

```bash
# BEFORE: version 0.0.1-alpha
bump2version pre
# AFTER: version 0.0.1-alpha.1

# BEFORE: version 0.0.1-beta.2
bump2version pre
# AFTER: version 0.0.1-beta.3

# BEFORE: version 0.0.1
bump2version pre
# AFTER: version 0.0.2-alpha
```


To skip the pre-releases you need to manually specify what it should be updated to.
It's my feeling that the pre-releases should only ever be skipped for patch releases and when they have been pretty thoroughly tested.
Don't just go straight from `0.1.1` to `0.2.0`, use `bump2version minor` instead to go to `0.2.0-alpha`.

```bash
# BEFORE: version 0.0.1-alpha
bump2version --new-version 0.0.1
# AFTER: version 0.0.1
# Remember that alpha is a PRE-release

# BEFORE: version 0.0.1
bump2version --new-version 0.0.2
# AFTER: version 0.0.2

# If the version is already beta, you should just use release.
# BEFORE: version 0.0.1-beta.4
bump2version release
# AFTER: version 0.0.1
```


## Conda

We use conda as our main "supported" way of distributing dependencies.
You can find more information in the `conda` directory where we store some of our own recipes to build conda packages.
Preference packages in `conda-forge` or `bioconda` over packaging something yourself.
My hope is to get those packages into `bioconda` when I have some more time.

If you're developing the pipeline or adding new software, conda is probably the easiest way to run the pipeline because you can modify the environment easily.
But to test that everything is working correctly, i'd suggest building the containers and running there.
This is because it's easy to get software dependencies leaking in from your own computer, which means that the commands might fail for someone else on a different computer.
Since containers try to provide the bare minimum, you have greater assurance that the conda environment (and therefore all containers) contains everything needed to run the pipeline.


## Docker

Docker is a type of container virtualisation system.
It is useful because it gives us a consistent environment on different computers, which means fewer installations and weird headache bugs.

Nextflow handles most of what we need to run the pipeline with nextflow, but if you just want to try out some commands that aren't installed on your computer you can run it in the docker container.

The downside to docker is that it requires root permission to use, and to relieve that requirement is a security issue.


As an example I'll use the existing [bedtools container](https://hub.docker.com/r/biocontainers/bedtools/).

```bash
sudo docker pull biocontainers/bedtools
sudo docker run --rm -v "${PWD}:/data:rw" -w /data biocontainers/bedtools bedtools intersect -a left.bed -b right.bed
```

Breaking this apart. We first `pull` the container from dockerhub and `run` a command inside the container.
`--rm` tells docker that we'd like it to remove the container (not the image) after it has finished running.
`-v "${PWD}:/data:rw` tells docker that we'd like to mount our current working directory to `/data` inside the container, and that we'd like it to be read-writable (`rw`).
We also set the working directory (`-w`) inside the container to be `/data` (where we mounted the files in our current working directory), so we've replicated our current state.
If you don't tell docker to mount your data like this, you won't be able to access your local files.


To view which images you have pulled you can use `sudo docker images`.

To run commands inside a container interactively, you need to add the `-i -t` flags.

```bash
sudo docker run --rm -it -v "${PWD}:/data:rw" biocontainers/bedtools bash
```

You can now interact with the container as if it was your own terminal.


## Singularity

Singularity is similar to docker, it's a bit simpler for bioinformatics but isn't as well documented or popular.

It also doesn't require root permission to use, which makes it much easier to stay safe while developing.

Singularity can run existing docker images, so anything that's available on dockerhub is fine.
I'll use the same bedtools image.

```bash
# Pull the most recent version of the image and save it locally in singularitys format to bedtools.sif
singularity pull bedtools.sif docker://biocontainers/bedtools:latest

singularity exec ./bedtools.sif bedtools intersect -a left.bed -b right.bed
```

This does the same thing as the docker example, but singularity mounts common paths and your current working directory for you so you don't need to worry as much.


You can also interactively work with singularity containers.

```bash
singularity shell ./bedtools.sif
```

There is a bit of a catch with singularity.
Because the containers are essentially immutable, you can't normally read or write to system directories, which includes some temporary file directories (Technically there is a way, but I haven't really been able to get it working).
In practice this means that you can't install software inside a singularity container after it's been built, and for commands that use temporary files you should explicitly set the temporary directory using a flag or the `TMPDIR` environment variable.
`sort` always catches me out with this.
If you get an error about 'read-only' filesystems, this is what that's about.
