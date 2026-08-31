# Interoperable Session Permissions: First Review Plan

## Status

This plan governs the current research milestone. It replaces the earlier assumption that the first output must be a new companion ERC.

The milestone is complete only when the evidence supports a defensible choice among four standards shapes. It does not include a formal ERC draft, an upstream change, canonical encoding, a TypeScript package, or Solidity.

Use `ERC-XXXX` and `eip: xxxx` only after the review process selects a companion ERC and Ethereum editors assign a number.

## Implementation state

At the 27 August 2026 source cutoff, the repository work for Milestones 0 through 2 is implemented:

- all 16 fixed source checkouts are pinned and reproducible;
- source hierarchy and conflicts are recorded in a stable findings ledger;
- all four standards shapes are compared, with option 3 preferred conditionally and option 4 retained as the explicit fallback;
- the ERC-7715 request, response, discovery, listing, revocation, and compatibility consequences are described;
- framework behaviour and the capability union are separated and source-keyed; and
- the candidate union has stable IDs and one classification per capability.

The review gate remains open. Option 3 is not proven backwards-compatible until ERC-7715 authors accept a legacy-safe listing design, and the profile, asset semantics, commitment algorithm, identifiers, binding interfaces, and revocation status model still require implementer decisions. Later schema documents, packages, bindings, upstream proposals, and formal drafting remain deferred.

## Objective

Determine how a dapp can request, understand, and exercise one scoped session permission through independently implemented external wallets and account systems while retaining the same security meaning.

The target flow is:

1. A user connects an existing account through their external wallet.
2. The dapp creates a restricted session key.
3. The dapp discovers supported session profiles, policy types, and enforcement bindings.
4. The wallet presents every effective target, function, value, asset, validity, and lifecycle restriction.
5. The user approves once through the root wallet.
6. The dapp later acts with the session key without reopening the root wallet for every action.
7. Enforcement rejects any action outside the complete grant.
8. The root wallet can revoke the live grant without the session key.

The dapp must not need a companion account, embedded wallet, separate balance, fund migration, or the user's root key.

## Standards-shape question

The first review package must compare:

1. an amendment to ERC-7715;
2. a companion session-policy ERC with ERC-7715 unchanged;
3. a companion policy ERC plus a narrow backwards-compatible ERC-7715 generalisation; and
4. a versioned successor to ERC-7715.

Option 3 is the current recommendation to test. It is accepted only if additive binding negotiation, a new typed response, exact capability discovery, and legacy-safe listing can support EIP-8130, EIP-8141, ERC-4337, EIP-7702, and optional ERC-7710 paths without exposing new variants to old clients, using dummy fields, or changing policy meaning.

If an additive response cannot be made unambiguous for old and new clients, option 4 is the explicit fallback. Options 1 and 2 remain in the comparison and must not be dismissed without evidence.

## Layer boundary

| Layer | Responsibility |
| --- | --- |
| Wallet request transport | Request, approval, discovery, listing, status, and revocation operations. |
| Canonical permission semantics | Grant envelope, policy meaning, composition, attenuation, display requirements, encoding, commitment, and conformance. |
| Enforcement binding | Session-actor authentication, evaluator selection, state, replay, expiry, and live revocation. |
| Account and execution integration | How an approved call executes as the user's account. |
| Transaction transport | EIP-8130 transaction, EIP-8141 frames, ERC-4337 `UserOperation`, ordinary transaction, or later transport. |

The first review package decides the standards boundary. It does not freeze the lower-level interfaces or canonical encoding.

## Evidence rules

1. Pin every specification, repository, branch, pull request head, and retrieval date used.
2. Prefer primary specifications, canonical contracts, source, tests, and encoders over README claims.
3. Follow each proposal's own source-of-truth declaration. EIP-8130 makes its canonical repository authoritative for contract internals.
4. Classify claims as specification requirement, implementation behaviour, inference, recommendation, or unresolved.
5. Record source conflicts explicitly and state which source governs each conclusion.
6. Do not infer common semantics from a shared ABI, contract address, JSON shape, or opaque bytes field.
7. Keep current wallet support distinct from adapter feasibility and prospective conformance.
8. Recheck fast-moving drafts before implementer review or formal drafting.

## Required evidence set

### Specifications and discussions

- EIP-8130, EIP-8141, EIP-7702;
- ERC-7715, ERC-7710, ERC-4337, ERC-7579, EIP-5792, and ERC-8286;
- ERC-8340 draft pull request and discussion;
- EIP-8141 execution-specs implementation and devnet trackers, implementation branch, tests, and active pull request history; and
- ERC-7715 history, discussion, example handler, and current MetaMask Permissions Snap implementation.

### Implementations

- Base EIP-8130 canonical contracts and the experimental viem branch;
- Smart Sessions v1 and v2;
- Kernel and Kernel ERC-7579 plugins;
- MetaMask Delegation Framework, Smart Accounts Kit, and ERC-7715 Permissions Snap;
- Base Account Policies; and
- the experimental `sm-stack/eip8141-poc` where it provides distinct implementation evidence.

The machine-readable pins are in `research/SOURCE_PINS.tsv`. Upstream worktrees live in ignored `references/` directories and are not part of the repository's authored output.

## Deliverables

- `README.md`: problem, status, repository map, and exact reproduction commands.
- `PLAN.md`: current scope, gates, deferred work, and acceptance criteria.
- `research/SOURCES.md`: source manifest, revisions, source hierarchy, and limitations.
- `research/FINDINGS.md`: claim-level evidence and conflict ledger.
- `research/STANDARDS-SHAPE.md`: four-option comparison, recommendation, field-level ERC-7715 consequences, compatibility, and discussion sequence.
- `research/FRAMEWORK-COMPARISON.md`: evidence-backed behavioural comparison.
- `research/POLICY-CAPABILITY-UNION.md`: observed union with one classification per capability.
- `research/OPEN_QUESTIONS.md`: short questions grouped by intended reviewer.

`research/PROFILE_V0_1.md` is retained as provisional post-gate working material. It is not a completed deliverable or an accepted schema.

## Work sequence and gates

### Milestone 0: repository and evidence closure

1. Make every reference checkout reproducible from a clean clone.
2. Pin missing specification, history, wallet, and EIP-8141 implementation sources.
3. Establish EIP-8130 specification, canonical contract, and viem correspondence.
4. Establish how closely execution-specs and the PoC correspond to the current EIP-8141 draft.
5. Record every material mismatch and source-authority choice.

Gate: every standards-shape and capability conclusion has exact primary evidence, or is labelled unresolved.

### Milestone 1: standards shape

1. Compare all four options against backwards compatibility, separation, EIP independence, implementation burden, interoperability, deterministic semantics, enforcement clarity, extension safety, discovery, testability, and adoption.
2. Test whether one companion-defined ERC-7715 permission type plus additive exact binding negotiation remains legacy-safe.
3. Specify a concrete legacy-preserving typed binding response, exact discovery generalisation, and versioned or filtered listing path.
4. Describe field-level and normative-behaviour changes for ERC-7715 authors to assess.
5. Recommend one option and state its rejection conditions.

Gate: the recommendation is traceable, preserves legacy behaviour, avoids dummy fields, and assigns each responsibility to one standard.

### Milestone 2: framework comparison and policy union

1. Compare the required frameworks across the full set of grant, policy, lifecycle, execution, and failure dimensions.
2. Extract the observed union without flattening distinct semantics.
3. Classify each capability as candidate baseline, candidate standard extension, implementation-specific, or unresolved.
4. Identify a candidate baseline without choosing a codec or presenting it as implementer agreement.
5. Produce focused questions for EIP-8130, ERC-7715, and account-framework reviewers.

Gate: the first review package lets reviewers assess the source evidence, standards boundary, and candidate policy vocabulary without relying on unpublished notes.

## Acceptance criteria

The first review package is complete when:

- a clean clone can restore and verify every pinned source;
- every material finding links to an exact primary source;
- every known source conflict records a governing source or remains explicitly unresolved;
- all four standards shapes are compared and exactly one is recommended;
- any proposed ERC-7715 generalisation is defined at request, response, discovery, listing, revocation, and normative-behaviour level;
- existing ERC-7710 responses remain valid and non-ERC-7710 bindings need no dummy fields;
- legacy clients cannot receive a bound response through either request or unfiltered listing paths;
- the comparison distinguishes implementation behaviour, adapter feasibility, and current wallet support;
- each union capability has exactly one classification with rationale;
- EIP-8141 evidence does not claim full-frame enforcement from a one-frame PoC check;
- EIP-8130 execution questions reflect what the current protocol and reference contracts already specify;
- the README states what has and has not been decided; and
- the work stops before an upstream proposal, canonical codec, implementation package, or claim of consensus.

## Deferred work

After reviewer approval, a later plan may define:

- canonical request and granted objects;
- policy identifiers, versions, extension governance, encoding, and commitment;
- wallet presentation and attenuation rules;
- detailed EIP-8130, EIP-8141, ERC-4337/EIP-7702, ERC-7715, and ERC-7710 bindings;
- TypeScript types, validation, rendering, codec, hashes, and conformance vectors;
- minimal Solidity interfaces or test harnesses where necessary; and
- public discussion and a formal ERC draft.

No production policy manager, universal policy language, privileged precompile, or upgradeable framework is planned by default.

## Editorial constraints

Use UK English, avoid em dashes, keep normative claims precise, and link design recommendations back to the concrete dapp interoperability test.
