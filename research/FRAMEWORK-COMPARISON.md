# Framework Comparison

## Purpose and status

This document compares the pinned systems in [`SOURCES.md`](./SOURCES.md) to identify portable permission semantics and binding-specific assumptions. It does not treat any framework ABI as canonical and does not establish current cross-wallet product support.

Exact cross-source conclusions and conflicts are indexed in [`FINDINGS.md`](./FINDINGS.md). The policy union and classification are separate in [`POLICY-CAPABILITY-UNION.md`](./POLICY-CAPABILITY-UNION.md).

## Layer model

| Layer | Question | Examples |
| --- | --- | --- |
| Wallet request | How does a dapp discover, request, receive, list, and revoke a grant? | ERC-7715 and wallet handlers. |
| Permission semantics | What authority does the structured grant mean? | Candidate session profile and typed policies. |
| Enforcement | What checks the action and mutates policy state? | Policy manager, module, validator, or caveat enforcer. |
| Account integration | What authorises the enforcer and executes as the account? | Account code, trusted manager, protocol dispatch. |
| Transaction transport | How is the action packaged and submitted? | EIP-8130, EIP-8141, ERC-4337, ordinary transaction. |

The same semantic grant may have different bindings. Opaque bytes or a shared redemption entry point do not by themselves make those bindings semantically equivalent.

## Systems at a glance

### EIP-8130 and reference policies

EIP-8130 supplies actor authentication, expiry, live revocation, scopes, a protocol-visible manager gate, and an opaque policy commitment. Policy vocabulary lives in manager logic, not the Core EIP ([F-8130-01](./FINDINGS.md#f-8130-01-policy-scope-is-a-protocol-gate-to-one-manager-not-a-policy-vocabulary)).

The reference [`PolicyManager`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L20-L271) and [`SessionPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L10-L104) are one implementation. The external-manager execution path needs a separately trusted account executor ([F-8130-03](./FINDINGS.md#f-8130-03-the-reference-external-manager-path-needs-a-separately-trusted-executor)). The viem branch is transport tooling, not a portable policy schema.

### Smart Sessions v1 and v2

V1 represents an actor through a session validator and configuration, pairs targets and selectors in `ActionData`, and intersects policies attached to the selected action. Its signed session digest commits to more than `PermissionId`, which omits the actions and policies and cannot serve as the complete semantic-grant commitment ([F-POLICY-09](./FINDINGS.md#f-policy-09-smart-sessions-permission-ids-are-not-complete-semantic-grant-commitments)).

Primary sources are [`DataTypes.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/DataTypes.sol#L15-L106), [`PolicyLib.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L27-L303), and [`HashLib.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/HashLib.sol#L14-L263).

V2 is a distinct snapshot. It removes v1 user-operation policy and paymaster fields, adds claim policies and emissary lifecycle data, and uses new enable, disable, and multichain digests. Its enable-data expiry limits use of the signed configuration operation, not later exercise of the live grant ([F-POLICY-10](./FINDINGS.md#f-policy-10-smart-sessions-v2-enable-expiry-is-signature-freshness-not-live-grant-validity)). See v2 [`DataTypes.sol`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol#L38-L118) and [`HashLibV2.sol`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/lib/HashLibV2.sol#L115-L443).

### Kernel and plugins

Kernel installs one signer and ordered policies under a compact permission identifier, intersects signer and policy validation results, and executes through account code. Its generic policy ABI proves adapter feasibility, not a portable session-grant schema.

Primary sources are [`ValidationManager.sol`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L150-L425), [`IERC7579Modules.sol`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/interfaces/IERC7579Modules.sol#L74-L88), and the pinned [`ECDSASigner`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/signers/ECDSASigner.sol), [`CallerPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/CallerPolicy.sol), and [`TimelockPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/TimelockPolicy.sol).

### MetaMask Delegation Framework and wallet tooling

The signed `Delegation` names delegate, delegator, parent authority, caveats, and salt. Caveats use enforcer addresses with signed `terms` and per-redemption `args`. The manager validates a delegation chain, checks revocation, runs caveats, and calls the delegator account.

Primary sources are [`Types.sol`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol#L19-L42), [`EncoderLib.sol`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/libraries/EncoderLib.sol#L11-L53), and [`DelegationManager.sol`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol#L85-L291).

The enforcer catalogue supplies the broadest observed policy union. Smart Accounts Kit and the pinned [`Permissions Snap`](https://github.com/MetaMask/snap-7715-permissions/tree/bfa810be21d8d98ec123ebfde2848f9fc3bb8fdc) add typed ERC-7715 schemas, decoding, presentation, adjustment, and wallet storage evidence. They establish one wallet stack's behaviour, not ecosystem-wide semantics.

### Base Account Policies

Base Account Policies has a manager with typed policy identities, installation, replacement, validity, and uninstallation. Its transfer policy and recurring accounting library provide useful semantic precedents, but concrete account dispatch is Coinbase Smart Wallet-specific and it does not provide one general session actor.

Primary sources are [`PolicyManager.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol#L11-L194), [`TransferSettingsPolicy.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol), and [`RecurringAllowance.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/accounting/RecurringAllowance.sol#L4-L138).

### EIP-8141 PoC

The PoC demonstrates ECDSA validation, Kernel-style permission plumbing, policy contracts, and a split between read-only `VERIFY` checks and later state consumption. It does not demonstrate a complete exact-action or validity adapter: the permission path discards returned timestamp bounds, the selector policy reads the outer account entry selector, and the E2E test skips that selector policy during frame validation ([F-8141-06](./FINDINGS.md#f-8141-06-the-poc-permission-path-discards-policy-validity-bounds), [F-8141-07](./FINDINGS.md#f-8141-07-the-poc-selector-policy-does-not-demonstrate-nested-dapp-action-scope)). It is binding evidence, not a separate portable grant model.

It also demonstrates a failure to treat as non-conformance evidence: the permission path supplies only the first later account-targeted sender frame to policies, while the EIP requires approval to bind every later sender frame ([F-8141-01](./FINDINGS.md#f-8141-01-one-execution-approval-authorises-every-later-sender-frame), [F-8141-03](./FINDINGS.md#f-8141-03-the-current-poc-permission-path-checks-only-the-first-later-account-sender-frame)). The current EIP and execution-specs branch govern when the PoC differs.

## Grant and lifecycle comparison

| Dimension | EIP-8130 reference | Smart Sessions: v1 policies, v2 lifecycle where stated | Kernel | MetaMask Delegation | Base policies | EIP-8141 PoC |
| --- | --- | --- | --- | --- | --- | --- |
| Native object | Actor config plus manager commitment and reference binding | Session, action data, validators, policies | Signer plus ordered policies under permission ID | Delegation plus caveats | Installed policy binding | Account validation configuration and policies |
| Actor | Authenticator returns `bytes32 actorId`; K1 maps to address | Validator contract plus init data | Signer module plus config | Delegate address | No common session actor | Validator or signer module |
| Signing domain | Keystore account-change and transaction domains | Typed session, enable, multichain, disable digests | Kernel validation and module-specific domains | EIP-712 delegation-manager domain | EIP-712 manager domain | Frame transaction signature hash plus module domains |
| Account binding | Explicit Keystore and reference binding account | Stored and signed per account | Account-installed modules | Explicit delegator | Explicit binding account | Transaction sender and account storage |
| Chain binding | Local and multichain change paths; transaction chain | Per-chain and multichain digests | Standard or replayable validation modes | Manager EIP-712 domain | Manager EIP-712 domain | Frame transaction chain ID |
| Validity | Actor inclusive expiry; reference half-open binding window | V1 policy validation ranges; v2 enable/disable expiry is signed-config freshness, not live-grant validity | Intersected validation data | Timestamp caveat | Binding validity | Timestamp policy returns bounds, but the current permission path discards them; transaction expiry verification is separate |
| Replay | Account-change counters/epoch and transaction nonce/replay ID | V1 enable nonces, salts, and session digests; v2 account/lock-tag config nonces and digests; permission ID omits actions and policies | User-operation, installation, selector-generation, and proposal nonce domains | Hash and salt identify reusable authority; repeat redemption needs a stateful caveat, nonce group, call limit, or disable | Salt and policy lifecycle | Transaction nonce and signed frame hash |
| Live revocation | Delete actor config | V1 removes a session; v2 removes config; both distinguish unused-signature nonce invalidation | Uninstall policy and signer | Disable delegation hash | Uninstall policy | Account/module uninstallation |
| Redelegation | No reference authority chain | No general authority chain | No general authority chain | Leaf-to-root signed authority chain; caveat subjects can be link-local while execution effects are root-scoped | No authority chain | No authority chain in the PoC |
| Introspection | Keystore getters and events | Session, action, policy views and events | Module inspection and validation data | Disabled mapping and events | Policy records and events | Account/module storage and events |
| Upgrade assumption | Canonical contracts plus manager/account code assumptions | Module and policy code trust | Upgradeable account/module trust | Manager, enforcer and account trust | Manager/policy/account trust | Experimental account and client code |

Lifecycle operations are analogous, not interchangeable. In particular, cancelling an unused signature is not revoking a live grant ([F-8130-04](./FINDINGS.md#f-8130-04-actor-expiry-live-revocation-and-unlanded-signature-cancellation-are-distinct), [F-POLICY-05](./FINDINGS.md#f-policy-05-revocation-operations-are-analogous-but-not-equivalent)).

## Permission-semantics comparison

| Dimension | EIP-8130 reference | Smart Sessions v1 policies unless stated | Kernel | MetaMask Delegation | Base policies | EIP-8141 PoC |
| --- | --- | --- | --- | --- | --- | --- |
| Target and selector | Paired `CallScope`; empty selector list is wildcard, and empty calldata is allowed for every explicit target scope | Exact paired `ActionData`; all calldata shorter than four bytes maps to one value sentinel | Generic policy must inspect operation | Separate sets or exact-execution enforcer | Application-specific exact calls | Code reads one outer account-entry selector; nested dapp action and E2E enforcement are not demonstrated |
| Call type | Reference policy normal account calls | V1 accepts ordinary single/batch parsing and rejects unsupported or delegatecall modes | ERC-7579 execution modes, including delegate-specific handling | Manager execution supports ordinary single and batch modes and rejects unsupported modes; individual caveats further restrict modes | Policy-specific | Account execution modes and frame modes |
| Native value | Lifetime or periodic token limit | V1 cumulative value policy and per-use bound inside argument policy | No pinned common value policy | Per-call, cumulative, periodic, streaming variants | Exact transfer and recurring library | Value-limit policy code with two-phase consumption; complete integration not demonstrated |
| ERC-20 | `transfer`, `transferFrom`, and approvals decoded under selected rules | Spending policy combines transfer and allowance selectors | Custom policy only at pinned plugins | One-shot, periodic, streaming, and balance-change enforcers | Exact transfer plus application policies | No portable ERC-20 vocabulary demonstrated |
| Recipient | Token-limit recipients; identity varies by selector | Argument policy can express it | Custom policy | Payee, recipient, redeemer caveats | Exact transfer recipient | Custom frame/account policy |
| Calldata | Selector plus hard-coded asset decoding | Argument policies | Full operation available to generic policy | Allowed, exact, and equality enforcers | Application-specific decoding | Cross-frame calldata inspection |
| ERC-721 | No common reference type | Custom policy | Custom policy | Transfer, approval-relevant exact calls, and balance-change enforcers | Application-specific | Not a common PoC type |
| ERC-1155 | No common reference type | Custom policy | Custom policy | Balance-change and multi-operation enforcers; generic exact calls can express transfer or operator calls | Application-specific | Not a common PoC type |
| Usage/count | Spend state keyed by commitment | V1 permission- or action-scoped usage policy | Exact prepared-operation timelock can be one-shot | Limited-call, shared-choice ID, and nonce-epoch enforcers with different state scopes | One-shot flag and recurring usage | Stateful policy consumption pattern |
| Gas/cost quota | Transaction gas fields, not a policy quota | V1 `SimpleGasPolicy` accumulates declared ERC-4337 gas limits and derived maximum cost; v2 removes v1 user-operation policies | No pinned common quota policy | No pinned quota enforcer | No common quota policy | Frame budgets and payer settlement are transport fields, not a portable policy quota |
| Recurrence | Reference period limit | Policy-specific | Custom | Periodic and streaming types | Recurring allowance library | Not a common PoC type |
| Composition | One policy per binding; session policy bundles checks | OR over selected actions, AND within action; argument policies can contain their own Boolean tree | AND across signer and policies | AND caveats; explicit whole-caveat OR wrapper | One manager policy may bundle rules | AND over installed policies for selected frame |
| Runtime witness or state predicate | No common type | Argument predicates inspect supplied operation data | Custom policy | Equality enforcer compares signed terms with runtime args but does not establish their truth | Morpho policies implement application-specific state and oracle checks | Custom frame/account policy |
| Permission-use payment | No common type | No common type | No common type | Native-token payment enforcer triggers a nested allowance-delegation flow | No common type | No common type |
| Administration | Self-call is restricted in the reference session policy | Unsafe account administration needs explicit framework paths | Root and module administration are separate from permission validation | Ownership-transfer enforcer; exact calls may otherwise express privileged actions | Application-specific admin calls | Account-specific |
| Deployment | Account-change system is protocol-level, outside the reference session policy | Account/module installation is lifecycle plumbing | Factory and module installation are lifecycle plumbing | `DeployedEnforcer` performs CREATE2 from the enforcer before execution, not from the account | Policy-specific call plan | Account/client-specific |
| Extension selection | Manager/policy address and opaque config | Policy contract and init data | Policy module and init data | Enforcer address, terms, args | Policy contract/config | Policy module and config |
| Failure | Manager/policy revert rejects | Missing action or failed policy rejects | Failed validation rejects | Caveat failure reverts redemption | Inactive or failed policy rejects | VERIFY failure rejects approval; later execution may revert |

Target-selector pairing is the strongest narrow common action model ([F-POLICY-01](./FINDINGS.md#f-policy-01-exact-target-selector-pairing-is-portable-independent-sets-can-widen-authority)). Exact empty-calldata and one-to-three-byte behaviour still requires adapters in EIP-8130 and Smart Sessions ([F-POLICY-08](./FINDINGS.md#f-policy-08-exact-empty-calldata-semantics-need-adapter-checks-in-current-frameworks)). Asset accounting remains materially different and cannot be labelled one generic spending policy ([F-POLICY-03](./FINDINGS.md#f-policy-03-a-generic-spending-limit-label-would-hide-incompatible-semantics)).

## Request, execution, and transport comparison

| Dimension | EIP-8130 reference | Smart Sessions v1 unless stated | Kernel | MetaMask Delegation | Base policies | EIP-8141 PoC |
| --- | --- | --- | --- | --- | --- | --- |
| Wallet request | None in Core EIP | No complete wallet RPC | None | Smart Accounts Kit and pinned Snap implement ERC-7715 types | None | None |
| Discovery | No semantic profile discovery | Onchain config views | Module-type views | Wallet permission/rule registry | Policy records | Module/account inspection |
| Redemption | Native manager call or `executeFor` | ERC-4337/account validation | ERC-4337 validation and account execution | ERC-7710-style manager redemption | Manager execution | Frame validation then sender execution |
| Account integration | Protocol dispatch plus policy-aware account or trusted executor | ERC-7579 account module | Built into Kernel | Delegator trusts manager | Account trusts manager | EIP-8141-aware account code |
| Final caller | Account when manager/account path is correct | Account | Account | Delegator account | Account | Transaction sender in approved `SENDER` frame |
| Batch model | Account batch atomic; multi-account helper best-effort | ERC-7579 execution mode | ERC-7579 mode | ERC-7710 atomic tuples | Policy-specific | Frame atomic flags and account batch mode |
| Presentation | No common wallet schema | Config decodable with module knowledge | Module-specific | SDK and pinned Snap typed schemas | Application-specific | Account/policy-specific |
| Negative cases | Scope, manager, expiry, commitment, policy failures | Wrong action, signature, policy, lifecycle | Signer/policy/module failures | Authority, revocation, caveat, execution failures | Lifecycle and hook failures | Wrong signer/frame/policy plus appended-frame gap |

Every working execution path needs protocol or account cooperation ([F-POLICY-06](./FINDINGS.md#f-policy-06-account-originated-execution-always-needs-protocol-or-account-cooperation)). ERC-7702 only supplies account-code delegation; ERC-4337 only supplies a validation and execution environment. Neither defines the session grant.

## Displayability and support claims

Typed MetaMask schemas and the pinned [`Permissions Snap`](https://github.com/MetaMask/snap-7715-permissions/tree/bfa810be21d8d98ec123ebfde2848f9fc3bb8fdc) prove that structured permission data can be rendered by one wallet stack. Arbitrary onchain module configuration remains opaque without a shared schema ([F-POLICY-04](./FINDINGS.md#f-policy-04-wallet-display-requires-common-decoded-semantics-not-enforceable-opaque-bytes)).

A future conformance claim should distinguish:

1. request and display support;
2. semantic evaluator support;
3. a complete account execution binding;
4. live revocation and status support; and
5. full profile support combining all four.

No source in this comparison proves that MetaMask, Rabby, Coinbase Wallet, Ambire, or another set of independent external wallets currently completes the target flow for the same existing EOA. The framework evidence supports feasibility and exposes incompatibilities. Product interoperability remains the intended result, not a present fact.

## Comparison result

The evidence supports:

- a separate wallet transport and semantic layer;
- exact action pairing;
- OR over enumerated actions and AND over applicable restrictions;
- finite validity and root-controlled live revocation as candidate common requirements;
- typed, versioned and displayable extensions;
- strict rejection of unknown required content; and
- binding-specific proof of account-originated execution.

It does not yet support:

- one final canonical encoding or commitment;
- treating a framework permission ID as that complete commitment;
- one global type registry;
- one mandatory manager or evaluator ABI;
- generic spending-limit semantics;
- one transport-neutral gas or cost quota;
- portable delegatecall authority or transitive redelegation;
- simultaneous bindings with shared stateful capacity;
- a complete current EIP-8141 adapter; or
- a claim of current cross-wallet deployment.
