# Radicle cheat sheet

Commands verified against `rad 1.10.0 (4641c342c)`.

Two ideas carry most of this: a repo's **identity document** (delegates +
threshold) is its access control, and **delegate** is the only privileged role.
There is no owner — the person who ran `rad init` is just the first delegate and
can be removed by the others.

## Identity and delegates (repo "admin")

```shell
rad self --did                  # your DID — did:key:z6Mk… — send this to a maintainer
rad self                        # alias, DID, node ID, storage paths
rad self --ssh-fingerprint      # key fingerprint
```

Run these inside a working copy, or add `--repo rad:z3gqcJUoA1n9…` from anywhere.

```shell
# Add a delegate (grant admin)
rad id update --title "Add Bob" --description "Bob co-maintains this" \
  --delegate did:key:z6Mkt67GdsW7715MEfRuP4pSZxJRJh6kj6Y48WRqVv4N1tRk

# Remove a delegate
rad id update --title "Remove Bob" --description "stepped down" \
  --rescind did:key:z6Mkt67Gds…

# Other identity changes
rad id update --threshold 2                                  # canonical-branch quorum
rad id update --visibility private                           # or: public
rad id update --allow did:key:z6Mk…                          # read access, private repos
rad id update --disallow did:key:z6Mk…                       # revoke read access
rad id update --payload xyz.radicle.project name '"newname"' # rename; null deletes a field
rad id update --edit                                         # edit the JSON directly

rad sync --announce             # publish the accepted revision to the network
```

Voting on proposals:

```shell
rad id                    # = rad id list — all revisions and their status
rad id show <rev>         # diff + per-delegate votes + Quorum yes/no
rad id accept <rev>       # you must be a delegate
rad id reject <rev>
rad id redact <rev>       # withdraw your own not-yet-accepted revision
rad id cache              # re-read the identity into the local cache
```

Useful flags on all of the above: `--no-confirm`, `-q`, `-v`.

## How a revision passes — measured, not from the docs

Proposals need a **strict majority of delegates** to accept. Authoring counts as
your own accept; you cannot open a second revision while your vote sits on a
pending sibling (redact it first).

| Delegates | Threshold | Accepts | Quorum             |
| --------- | --------- | ------- | ------------------ |
| 1         | 1         | 1       | yes (auto-applied) |
| 2         | 1         | 1       | no                 |
| 2         | 1         | 2       | yes                |
| 3         | 1         | 1       | no                 |
| 3         | 1         | 2       | yes                |
| 3         | 3         | 2       | yes                |

Consequences:

- **Two delegates means unanimity** — a majority of two is two. Lose one key and
  the identity is frozen: nobody can rescind the dead key or add a replacement.
  Three delegates is the first setup that survives losing one.
- `--threshold` did **not** raise the bar on identity revisions in 1.10.0, even
  though `rad-id(1)` describes it as "the number of delegates required to accept
  a revision". `rad(1)` describes threshold as what makes a default-branch commit
  canonical ("the commit … that a threshold of delegates have published"), which
  is likely where it still applies. Untested here — don't rely on it to gate
  identity changes.
- The `rad init` runner has no special standing: two later-added delegates
  removed the original creator without her vote, and the repo kept its RID.

## Inspecting

```shell
rad .                      # RID of the repo in the current directory
rad inspect --rid
rad inspect --identity     # the whole identity document
rad inspect --delegates
rad inspect --payload
rad inspect --visibility
rad inspect --policy       # this node's seeding policy for the repo
rad inspect --history      # history of the identity document
rad inspect --refs
rad inspect --sigrefs
rad ls                     # repos in local storage
```

## Getting a copy, publishing changes

```shell
rad init --name demo --description "…" --default-branch main --public --no-confirm
rad init --private                     # or start private
rad clone rad:z3gqcJUoA1n9…            # over the network (needs a running node)
rad clone rad:z3gq… --seed <NID>       # private repos: clone from a known seed
rad checkout rad:z3gq…                 # working copy from local storage
rad checkout rad:z3gq… --remote did:key:z6Mk…   # check out a specific peer's fork

git push rad                           # publish your fork / branch
rad sync                               # fetch + announce
rad sync --fetch / --announce          # one direction only
rad sync status
```

**A new delegate must `git push rad` once before anyone proposes the next
revision.** Until their namespace exists, identity updates fail with:

```text
✗ Error: failed to verify delegates for rad:z3fhBog…
✗ Error: the delegate did:key:z6Mkor32B8… is missing
```

Non-delegates need none of this to contribute: they clone, push to their own
namespace, and open patches (`rad patch`). Delegate status is only for people who
should control the identity and the canonical branch.

## Node and seeding

```shell
rad node status            # sessions; ↗ = we dialed out, ↘ = peer dialed in
rad node routing
rad node start / stop
rad seed                   # list seeding policies
rad seed rad:z3gq… --scope all
rad unseed rad:z3gq…
rad follow / rad unfollow did:key:z6Mk…
rad block / rad unblock
rad stats
rad config
rad path
```

## This cluster's seed node (`apps/radicle`)

The seed holds no delegate key — it replicates identity revisions, it doesn't
make them. Do identity work from your own working copy, then `rad sync --announce`.

```shell
kubectl -n radicle exec -it deploy/radicle -- rad node status
kubectl -n radicle exec -it deploy/radicle -- rad self
kubectl -n radicle exec -it deploy/radicle -- rad seed
kubectl -n radicle rollout restart deployment radicle   # after editing seeded-repos.txt
```

Seeded repos are reconciled from `apps/radicle/seeded-repos.txt` at pod start, so
`rad seed`/`rad unseed` inside the pod is reverted on the next restart.

## Sandbox for experiments

Point `RAD_HOME` somewhere throwaway to get a scratch identity that can't touch
your real one:

```shell
export RAD_HOME=/tmp/radtest RAD_PASSPHRASE=
rad auth --alias testuser
```
