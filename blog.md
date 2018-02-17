Title: Make your way through git jungle with `git-machete`!

<and some jungle-related picture>

# The problem

Let's imag

# Defining a structure for the branches

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

# A few other useful hacks... `diff-base`, `go`, `add`, `reapply`, `slide-out`

All commands supported by `git machete` can be found under `git machete help`.
Run `git machete help <command>` for a more specific doc for the given command.

# Limitations

The base commit for each branch is determined with a heuristics that uses `git reflog`.
It's generally not trivial to find ### in every case, so a heurestics is applied that compares the *commit-wise* history (aka `git log`) of the given branch
with *operation-wise* history (aka `git reflog`) of all other local branches.
Roughly speaking, the most recent commit `X` from the log of the current branch that also happens to appear on reflog of any other branch `y` is considered the _base_ of the said branch.
The fact that `X` was found somewhere in the reflog of `y` suggests that it was originally commited on `y` (even though it might no longer appear on `y`'s history due to e.g. rebases).

This definition, though working correctly in most real-life cases, might sometimes fail to find a _logically_ correct base commit.
In particular, if certain local branches were already deleted, the determined base commit may be _too early_ in the history than expected.
??? sentence order?
Also, it's always possible to check the base for a given branch included in the definition file with `git machete base [<branch>]`,
or to simply list commits considered by `git machete` to be specific for the each branch with `git machete status --list-commits` (`git machete s -l` for short).
Anyway, the potentially effects of ??? are mitigated:
* The three commands that run `git rebase` under the hood (`reapply`, `slide-out`, `update`) always pass the `--interactive` flag.
  This enables the user to review the list of commits that are getting rebased before actual rebase is executed.
* It's also possible to specify the `git rebase`'s <from> the mentioned three commands

More git-savvy use may argue that it should simply enough to use `--fork-point` option of `git rebase`... but reality tends to be harder.
`git merge-base --fork-point` (and thus `git rebase` with the said option) only takes reflog of one upstream branch into account.
This would work fine as long as nobody changes the structure of the tree in the definition file (i.e. doesn't move downstream branch from one upstream branch to another).
Unfortunately, such modifications happen pretty often in real-life development... and thus a custom implementation of fork point has been necessary.
