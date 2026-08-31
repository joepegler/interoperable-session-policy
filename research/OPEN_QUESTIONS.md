# Open Questions for Implementer Review

## Status

These questions remain after the first evidence and standards-shape pass. They are grouped by the reviewer best placed to answer them. Recommendations in [`STANDARDS-SHAPE.md`](./STANDARDS-SHAPE.md) and [`POLICY-CAPABILITY-UNION.md`](./POLICY-CAPABILITY-UNION.md) remain provisional until the relevant answers are recorded.

## Chris Hunter and EIP-8130 implementers

### 1. Is the reference external-manager path intended as a standard binding?

The current EIP specifies account-originated dispatch to the policy manager. The reference manager then calls the account, and `DefaultAccount` accepts it only when the manager is separately registered as a trusted executor.

Should a portable EIP-8130 binding require this two-actor construction, permit `manager == account` with policy-aware account code, or describe both as separate binding types?

### 2. What is the intended non-native path?

On a chain without native EIP-8130 transactions, should the same grant be exercised through EIP-7702 account code, an ERC-4337 hook, a manager's `executeFor` path, EIP-8141 validation, or several explicitly advertised bindings?

Which root-authorised account configuration makes each path trusted?

### 3. What should `policy_commitment` commit to?

Should it equal a transport-independent semantic grant ID, wrap that ID in manager-specific configuration, or retain the current reference commitment format?

Which component binds the semantic grant to the chosen manager, account code, chain, and replay domain?

### 4. Is `SessionPolicy` standards input or only an example?

Which behaviours are intentional common candidates: paired call scopes, empty-selector wildcard, native and ERC-20 accounting, recipients, approvals, `transferFrom`, periods, self-call rejection, and commitment-keyed state?

The current recommendation uses it as evidence and does not copy its ABI.

### 5. What role, if any, should ERC-8340 have?

Was ERC-8340 shared as a companion-ERC layering precedent, or should session permissions investigate reuse of deterministic CBOR or commitment machinery?

Any reuse needs distinct authority-domain separation and must not make descriptive metadata authoritative.

## ERC-7715 and ERC-7710 authors

### 6. Can request and listing paths both preserve legacy clients?

Can the existing ERC-7710 response remain unchanged while an explicitly negotiated permission type returns `{ context, binding: { type, version, data } }` instead of dummy `dependencies` and `delegationManager` fields?

The no-parameter list method currently returns all live grants, so an old client could still receive the new variant. Should bound grants use a new list method, a response-version/filter parameter with a legacy default, or a successor ERC?

### 7. Should `context` remain the common revocation handle?

May a non-ERC-7710 binding use `context` as its wallet grant identifier and opaque proof while returning all effective semantic authority in structured `permission.data`?

Which part of `context` must remain stable across listing, exercise, and revocation?

### 8. How should nested capabilities be discovered?

Should the existing per-permission discovery value gain an array of exact chain-profile-actor-extension-binding configurations, or should companion permission types own one namespaced capabilities field?

Discovery must distinguish parsing support from a complete enforceable binding on each chain without implying unsupported Cartesian products.

### 9. May a permission type narrow `isAdjustmentAllowed`?

Can the session permission define adjustment strictly as equal-or-narrower even though current ERC-7715 wording includes increases?

A wider or substituted result would be a separately approved counter-offer, not attenuation.

### 10. When may wallet revocation report success?

The current section says success returns an empty response, but its schema returns `chainIds`, and no status method exists. Should the session permission wait for binding-specific effectiveness, return pending plus status, or identify a binding-specific status query?

How should pending, effective, failed, and finalised states be represented without treating local wallet removal as onchain revocation?

### 11. Must one session grant be negotiated atomically?

The current request accepts an array of permission requests but does not define cross-entry composition or all-or-none approval. Is one complete session grant as the sole array element, with no external `rules`, acceptable as the v1 rule?

## Wallet and account-framework implementers

### 12. Is the candidate non-asset baseline implementable across stacks?

Can Coinbase, MetaMask, Smart Sessions, Kernel, and other wallets implement one-chain account and address-actor binding, replay resistance, finite validity, exact target-selector and explicit empty-calldata actions, commitment to the complete semantic grant, exact grant return, complete display, fail-closed versions, no implicit widening, account-originated execution, one selected live binding, and live root revocation with identical meaning?

Which field is infeasible or needs to move to a binding?

### 13. Which asset limit, if any, belongs in the mandatory baseline?

Can all intended implementations agree on:

- per-call native value;
- grant-lifetime native total;
- direct `transfer(address,uint256)` requested-amount totals;
- recipient sets;
- pre-call mutation and reentrancy handling;
- rollback and false-return behaviour; and
- aggregate batch accounting and the distinction between declared amount and observed balance delta?

If not, which definitions should be typed extensions rather than mandatory support?

### 14. Can one semantic grant expose more than one live binding?

How would EIP-8130, ERC-4337, EIP-8141, and ERC-7710 paths share one usage counter and live revocation state rather than multiplying capacity?

Until this is demonstrated, the current recommendation is one live binding per grant ID.

### 15. What exactly does full conformance claim?

Should conformance require exact tuple discovery, complete semantic commitment, request and grant presentation, no implicit widening, exact enforcement, replay resistance, account-originated execution, status, and live revocation?

Would separately named request-only and enforcement-adapter attestations be useful without allowing either to claim full profile support?

### 16. How should implementation upgrades affect conformance?

Can a wallet claim a fixed semantic version when an evaluator, module, manager, or account implementation is upgradeable?

Should binding discovery commit to code identity, an implementation version, or only observable conformance vectors and governance assumptions?

Can framework routing identifiers remain stable when policy content changes? In particular, Smart Sessions `PermissionId` omits actions and policies, and v2 enable expiry is signed-config freshness rather than runtime validity. Which separate binding fields and checks prove the complete committed meaning and live validity?

## EIP-8141 and ERC-8286 implementers

### 17. What complete frame set must a session validator inspect?

Must the validator reject every later `SENDER` frame not routed through the policy-consuming account entry point, including direct sender frames targeting another contract?

How should it account for sender frames before or after account-targeted frames and unsupported frame modes?

### 18. Where should stateful limits be consumed?

If `VERIFY` performs read-only checks and a later `SENDER` account hook mutates counters, how are aggregate pre-check, mutation order, reentrancy, rollback, and best-effort execution defined?

How are mempool races between two individually valid transactions handled?

### 19. What existing-EOA installation is required?

For an EIP-7702 delegated EOA, what root-authorised code and module installation makes the session validator active, and how is it removed without allowing an old grant to revive when code is later reinstalled?

### 20. Which implementation revision should reviewers use?

The current EIP, execution-specs branch, and PoC differ materially. When is the execution-specs branch stable enough to support binding test vectors, and which PoC behaviours should be retired?

## Deferred design questions

### 21. What canonical codec and commitment should be selected?

Compare EIP-712-style encoding, deterministic CBOR, and another compact canonical form only after the standards boundary and policy vocabulary are reviewed.

### 22. How are type identifiers and versions governed?

Determine collision resistance, namespacing, incompatible-version rules, registration, and extension change control before formal ERC drafting.

### 23. Which advanced capabilities should be standardised first?

Candidate extensions now include target-only and fallback actions, periodic and streaming allowances, bounded usage, declared gas budgets, exact calldata and argument predicates, fixed runtime witnesses, redeemer and ERC-1271 requester identities, message and application-claim signing, approval grant and revocation, `transferFrom`, ERC-721, ERC-1155, balance deltas, exact batches, permission-use payment, and ownership transfer.

Which of these have identical enough semantics for early shared types? Which should remain separate profiles or binding-specific features? Delegatecall, wildcard actors, shared quota groups, and portable redelegation remain unresolved and should not be implied by a generic extension mechanism.

### 24. When should multichain and alternative actors be introduced?

Passkeys, ERC-1271 actors, modules, and multichain grants need distinct replay, lifecycle, display, and test-vector work. The candidate baseline remains one secp256k1 address actor on one chain.

## Suggested review order

1. Chris answers questions 1 to 5.
2. ERC-7715 and ERC-7710 authors answer questions 6 to 11.
3. Account-framework implementers test questions 12 to 16.
4. EIP-8141 implementers address questions 17 to 20 as the specification stabilises.
5. Only then resolve the deferred schema and codec questions.
