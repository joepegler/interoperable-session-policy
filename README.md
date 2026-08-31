# Interoperable session policy

This repository investigates how a dapp can request one narrowly scoped session permission from whichever external wallet a user already has, then exercise that permission through different Ethereum account and transaction systems without changing its meaning.

The target is an existing user account with the external wallet remaining the root authorisation, recovery, and revocation boundary. The dapp holds only the restricted session key. A companion account, embedded wallet, separate balance, and access to the root key are outside the target flow.

## Status

This is a standards research repository. It contains no ERC draft, assigned ERC number, consensus claim, production policy manager, or canonical codec.

The current milestone determines which standards shape is defensible:

1. amend ERC-7715 only;
2. define a companion session-policy ERC while leaving ERC-7715 unchanged;
3. define a companion policy ERC plus a narrow backwards-compatible ERC-7715 generalisation; or
4. define a versioned successor to ERC-7715.

Option 3 is the current evidence-backed preferred direction for implementer discussion. It is not an adopted or proven backwards-compatible design: ERC-7715's unfiltered list method is a known blocker until authors accept a legacy-safe versioned or filtered listing path. Otherwise option 4 is the fallback. Encoding, hashing, the mandatory policy profile, and enforcement bindings also remain provisional until the review gate in [PLAN.md](./PLAN.md) is passed.

## Repository map

| Path | Purpose |
| --- | --- |
| [`PLAN.md`](./PLAN.md) | Current scope, work sequence, gates, and acceptance criteria. |
| [`research/SOURCES.md`](./research/SOURCES.md) | Pinned specifications, repositories, revisions, and verification limits. |
| [`research/FINDINGS.md`](./research/FINDINGS.md) | Claim-level evidence and explicit source conflicts. |
| [`research/STANDARDS-SHAPE.md`](./research/STANDARDS-SHAPE.md) | Four-option comparison, recommendation, compatibility analysis, and proposed discussion sequence. |
| [`research/FRAMEWORK-COMPARISON.md`](./research/FRAMEWORK-COMPARISON.md) | Behavioural comparison of the selected session and delegation systems. |
| [`research/POLICY-CAPABILITY-UNION.md`](./research/POLICY-CAPABILITY-UNION.md) | Observed policy union and baseline, extension, implementation-specific, or unresolved classification. |
| [`research/PROFILE_V0_1.md`](./research/PROFILE_V0_1.md) | Retained first-pass schema sketch for possible post-gate work. Not an accepted profile. |
| [`research/OPEN_QUESTIONS.md`](./research/OPEN_QUESTIONS.md) | Questions for EIP-8130, ERC-7715, and framework implementers. |
| [`research/SOURCE_PINS.tsv`](./research/SOURCE_PINS.tsv) | Machine-readable source checkout manifest. |
| `references/` | Ignored upstream checkouts restored at exact commits. |

## Reproduce the evidence base

Requirements are Git, Bash 3.2 or later, ripgrep, and network access to the listed public repositories.

```sh
./scripts/fetch-references.sh
./scripts/verify-research.sh
```

`fetch-references.sh` clones or reuses clean upstream worktrees and checks out the exact commits in `research/SOURCE_PINS.tsv`. It refuses to alter a dirty or incorrectly sourced checkout. `verify-research.sh` checks the manifest, required deliverables, ignored-reference boundary, pinned revisions, local and pinned evidence links, prose constraint, and patch whitespace.

To verify already restored sources without fetching:

```sh
./scripts/fetch-references.sh --verify
```

## Research rules

- Use pinned primary specifications, source files, tests, and encoders for technical claims.
- Distinguish specification requirements, implementation behaviour, inference, recommendation, and unresolved questions.
- Keep request transport, permission semantics, enforcement, account integration, execution, and lifecycle separate.
- Treat opaque context as binding data, not proof of interoperable policy meaning.
- Reject unknown required policy and binding types. Never infer that they are safe to ignore.
- Do not claim that a target observes the user's account as `msg.sender` unless the execution path proves it.
- Recheck fast-moving draft proposals before formal drafting or implementer review.

## Deferred work

Canonical request and grant schemas, deterministic encoding and commitments, detailed bindings, TypeScript conformance tooling, Solidity artefacts, public discussion, and formal ERC drafting are deliberately deferred until the first review package is accepted.
