# Contributing to this project.

This document is intended a brief cheatsheet for using git, docker, and singularity.


## Git

Git is a version control tool.
It tracks differences of *lines* between changes of text documents.

The basic workflow using git with other people goes a bit like this:

1. Clone (or fork and then clone) the repository to your computer with `git clone`.
2. Create a new branch just for yourself with `git checkout -b mybranchname`.
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

```bash
```


To "stage" files that you have modified and want to keep track of:

```bash
# Add all files in the current working directory
git add -A

# Add a specific file with changes to be tracked.
git add bin/my_new_script.sh

# Add a whole directory
git add bin/
```

If you decide that you 

```bash

```
