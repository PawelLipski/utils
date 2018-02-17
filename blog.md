Title: Make your way through git jungle with `git-machete`!

<and some jungle-related picture>

TL;DR: `git machete` helps you see what branch is out of sync with its parent (upstream) branch and automatically rebase, especially when some topic branches are stacked atop other ones.

# The problem

Let's imagine ???

# Defining a structure for the branches (`edit` command)

??? install `git-machete` with #####.
Now let's run `git machete edit` or simply open the `.git/machete` file with your favorite editor.
A file like that:

```
TODO maybe sample from help simply? More differentiated branch names!
```

Now we've given defined the structure how our branches should relate to each other.
For each, ???, ??? and ??? are dependent directly on develop, while ??? depends on ???.

That's unfortunately so far not really how branches in our current state of the repository look like.
For example, a few pull requests from other team members were merged into `develop` in the meantime,
so ???, ??? and ??? now need to be synced with `develop` (possibly we have to solve conflicts as well).
Also, our PR for ??? received a couple of comments which we then fixed on a separate commit... thus throwing ??? out of sync with its parent branch ???
And... that's exactly a _jungle_ like that where `git machete` comes to rescue.


# What's macheting really about... `status` and `update` subcommands
TODO maybe `go` also here


Let's now run `git machete status` and see the result:

!!! add the picture

Now we see the branch tree with coloring of edges.
Red edge means ???
Green edge means ???
Also, there is this (out of sync with origin) ??? message

Running `git machete status --list-commits` (or `git machete s -l` for short) also prints the commits introduced on each branch:

!!! add pic

!!! say sth about fork point!! `the commit at which the history of the branch actually diverges from the history of any other branch`


# A few other useful hacks... `diff`, `go`, `add`, `reapply`, `slide-out`


To see the changes introduced since the fork point of the current branch, run `git machete diff`.

`git machete go` helps quickly navigate between branches in the tree.
`git machete go up` and `git machete go down` check out the upstream branch or downstream branch of the current branch (if defined).
`git machete go root` goes all the way upstream to the root of the tree (where a `develop` or `master` branch is usually located).
`git machete go prev` and `git machete go next` switch to the previous or next branch in the order of definition (or simply just previous/next line in the ladder definition file).

`git machete add --onto [<target-upstream>] [<branch>]` ????

`slide-out` subcommand comes somewhat trick
All commands supported by `git machete` can be found under `git machete help`.
Run `git machete help <command>` for a more specific doc for the given command.


# Appendix: fork point - not so easy business...


The fork point commit (the commit at which the history of the branch actually diverges from the history of any other branch) is determined with a heuristics that uses `git reflog`.
It's generally not trivial to find a correct fork point in every case, so a heurestics is applied that compares the *commit-wise* history (aka `git log`) of the given branch
with *operation-wise* history (aka `git reflog`) of all other local branches.
Roughly speaking, the most recent commit `X` from the log of the current branch that also happens to appear on reflog of any other branch `y` is considered the _base_ of the said branch.
The fact that `X` was found somewhere in the reflog of `y` suggests that it was originally commited on `y` (even though it might no longer appear on `y`'s history due to e.g. rebases).

This definition, though working correctly in most real-life cases, might sometimes fail to find a _logically_ correct fork point commit.
In particular, if certain local branches were already deleted, the determined fork point may be _too early_ in the history than expected.
??? sentence order?
Also, it's always possible to check the fork point for a given branch included in the definition file with `git machete fork-point [<branch>]`,
or to simply list commits considered by `git machete` to be specific for the each branch with `git machete status --list-commits`.
Anyway, the potentially effects of ??? are mitigated:
* The three commands that run `git rebase` under the hood (`reapply`, `slide-out`, `update`) always pass the `--interactive` flag.
  This enables the user to review the list of commits that are going to be rebased before actual rebase is executed.
* It's also possible to explicitly specify the fork point for the mentioned three commands with `--fork-point` (`reapply`, `update`) or `--down-fork-point` (`slide-out`).

More git-savvy users may argue that it should be simply enough to use `--fork-point` option of `git rebase`... but reality turns out to be harder.
`git merge-base --fork-point` (and thus `git rebase` with the said option) only takes reflog of the one provided upstream branch into account.
This would work fine as long as nobody changes the structure of the tree in the definition file (i.e. doesn't change the upstream branch of any branch).
Unfortunately, such tree modifications happen pretty often in real-life development... and thus a custom, more powerful way to find the fork point was necessary.
