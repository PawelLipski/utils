Title: Make your way through git (rebase) jungle with `git-machete`!

<and some jungle-related picture>

TL;DR: `git machete` helps you see what topic branches are out of sync with their parent (upstream) branches and automatically rebase them, especially when some of them are stacked atop other ones.


# The problem


The `machete` tool is only applicable for rebase flows - 
It doesn't really 
Let's imagine ??? !!!!!!!!rebase flow

?? while the pull request `adjust-reads-prec` -> `develop` was under review, you already started work on another topic branch `block-cancel-order`.
Unfortunately, the changes on `block-cancel-order` depended on what was already done on `adjust-reads-prec`...
So you forked the new branch off `adjust-reads-prec` and when the feature was ready, you made another PR, this time `block-cancel-order` -> `adjust-reads-prec`.
In the meantime, the reviewers posted their fixes on the first PR.
You applied their remarks as `1st round of fixes` on the `adjust-reads-prec` branch.
Since the review process took some time, you managed to start a couple of new refactors and bugfixes (this time on branches `change-table` and `drop-location-type`),
but since each of them was dependent on the changes already waiting in review queue, you began stacking branches on top of each other.
So we ended up with a couple of branches each was dependent on a previous one: `adjust-reads-prec`, `block-cancel-order`, `change-table` and `drop-location-type`.

Let's get this scenario ????
??? Uwaga zeby za duzo nie bylo tych branchy!!!!!!!!!!!!!!!!!!!!!
Other than that, you also independently develop a feature `edit-margin-not-allowed`... but nobody really could ????

Apart from that, also ???

And `hotfix/remove-trigger` on the top of master ???

Now the problem - how to quickly now which of them are in sync with their upstreams?
And also, how to easily rebase each of branches on the top of its parent, especially if the structure of the branch tree changes?


# Defining a structure for the branches (`edit` command)


??? install `git-machete` with #####.

Let's first specify how we would like to organize our branches - basically, what depends on what.
Now let's run `git machete edit` or simply open the `.git/machete` file with your favorite editor.

A file like that:
??? a tree-like structure with `develop`/`master` being the roots ???
```
develop
    adjust-reads-prec
        block-cancel-order
            change-table
                drop-location-type
    edit-margin-not-allowed
        full-load-gatling
    grep-errors-script
master
    hotfix/remove-trigger
```

Now we've given defined the structure how our branches should relate to each other.
For each, ???, ??? and ??? are dependent directly on develop, while ??? depends on ???.

That's unfortunately so far not really how branches in our current state of the repository look like.
For example, a few pull requests from other team members were merged into `develop` in the meantime,
so ???, ??? and ??? now need to be synced with `develop` (possibly we have to solve conflicts as well).
Also, our PR for ??? received a couple of comments which we then fixed on a separate commit... thus throwing ??? out of sync with its parent branch ???
And... that's exactly a _jungle_ like that where `git machete` comes to rescue.


# What's macheting really about... `status`, `go` and `update` subcommands


Let's now run `git machete status` and see the result:

!!! add the picture

Now we see the branch tree with coloring of edges.
Red edge means ???
Green edge means ???
Also, there is this (out of sync with origin) ??? message

Running `git machete status --list-commits` (or `git machete s -l` for short) also prints the commits introduced on each branch:

We see that, for example, the branch ??? is out of sync with its upstream branch, ???.
Let's check out `???` and put it back in sync with `???`.
!!! add pic (maybe some other formatting? how to include colored text - TODO ask ppl!)

This ran an interactive rebase ??? automagically providing the correct parameters. !! resolve possible conflicts etc.

!!! say sth about fork point!! `the commit at which the history of the branch actually diverges from the history of any other branch`

The way fork point is determined ensures that ??? correctly even after structure of the ladder is modified, e.g. upstream branch is swapped with its downstream.
For possible ???, see the appendix (link TODO) at the end of this blog post.

Now let's see the status:

TODO pic

We can check it explicitly that ??? on the top of ???.

After push ??? but with `--force` ???, the status ???

Let's now check out downstream with a handy shortcut `git machete go down` and rebase the downstream branch `???` on the already rebased `???`:

TODO pic, also include git push -f

??? TODO zmiana drzewa, pokazac ze wszystko ladnie hula!


# A few other useful hacks... `diff`, `add`, `reapply` and `slide-out`


To see the changes introduced since the fork point of the current branch, run `git machete diff`.

`git machete go` helps quickly navigate between branches in the tree.
`git machete go up` and `git machete go down` check out the upstream branch or downstream branch of the current branch (if defined).
`git machete go root` goes all the way upstream to the root of the tree (where a `develop` or `master` branch is usually located).
`git machete go prev` and `git machete go next` switch to the previous or next branch in the order of definition (or simply just previous/next line in the ladder definition file).

`git machete add --onto [<target-upstream>] [<branch>]` pushes the branch ???
Let's now add a newly created branch `ignore-whitespace` onto the existing branch `change-table` and see the status:

TODO shell + status now!

The same effect can as well be achieved by editing the definition file `.git/machete` manually e.g. with `git machete edit`.


`reapply` is similar to `update`, but instead of rebasing the commits onto upstream branch, it instead rebases onto fork point.
This means that rebase changes nothing in relation to the upstream branch - if the branches weren't in sync before, they still won't be.


`slide-out` subcommand comes somewhat tricky.
Let's assume the `edit-margin-not-allowed` was already merged to develop.
What we most likely want to do now is to remove `edit-margin-not-allowed` from the tree and then rebase its downstream branch `full-load-gatling`
onto the original upstream `develop`.
Since that's a pretty common combination, there's a shortcut for that, `git machete slide-out`.
Let's check out `edit-margin-not-allowed` and run the command:

TODO pic

and then after completing the rebase we get the following tree:

TODO pic

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

More git-savvy users may argue that it should be enough to simply use `--fork-point` option of `git rebase`... but the reality turns out to be harder.
`git merge-base --fork-point` (and thus `git rebase` with the said option) only takes reflog of the one provided upstream branch into account.
This would work fine as long as nobody changes the structure of the tree in the definition file (i.e. the upstream branch of any branch doesn't change).
Unfortunately, such tree modifications happen pretty often in real-life development... and thus a custom, more powerful way to find the fork point was necessary.

