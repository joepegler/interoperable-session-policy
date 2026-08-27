# Framework comparison and observed policy union

## Purpose

This document compares the pinned sources in [SOURCES.md](./SOURCES.md). It is not an ERC draft and does not treat any implementation's ABI as the canonical answer. Its purpose is to identify:

- semantics that can plausibly form one transport-independent baseline;
- capabilities that belong in an extensible observed union but not baseline v1;
- integration details that must remain below the semantic boundary; and
- mismatches that would make a nominal mapping widen or change authority.

The central result is that a **small common semantic core inside an extensible union** is viable, but the union must be bounded to the pinned source set and the baseline cannot be derived by copying one framework's structs.

## Layer model

| Layer | Standardization question | Examples |
| --- | --- | --- |
| 1. Wallet request and discovery | How does a dapp ask, receive the exact grant, discover support, list it, and request revocation? | ERC-7715 and wallet RPCs. |
| 2. Permission semantics | What authority does the granted object mean, how is narrowing determined, what is displayed, and what is committed? | Candidate `SessionGrant`, baseline profile, typed extension policies. |
| 3. Enforcement | Which evaluator or manager checks the grant and its state? | EIP-8130 `PolicyManager`/policy, Smart Sessions policies, Kernel policies, MetaMask caveat enforcers. |
| 4. Account integration and transaction transport | How does a validated action execute as the account, and how is it packaged? | EIP-8130 native calls, EIP-7702 delegated EOA code, ERC-4337 `UserOperation`, EIP-8141 frames, ERC-7579 account execution, ERC-7710 redemption. |

Layer 2 is the proposed ERC's core. Layer 1 should be a binding, most likely ERC-7715. Layers 3 and 4 may have standardized adapters, but their fields must not silently change the semantic grant.

## Classification

The tables use these labels:

- **Common** — substantially the same security meaning can be specified across systems.
- **Analogous** — similar intent, but encoding, boundary, or failure semantics differ materially.
- **System-specific** — useful evidence for the union, not a baseline candidate.
- **Absent** — no native mechanism was found at the pinned revision.
- **Unknown** — the evidence does not resolve the behavior.

## System findings

### EIP-8130 and its reference policies

The current EIP-8130 draft supplies native actor authentication, lifecycle, and a `POLICY` gate. The protocol stores an actor's manager and opaque commitment and restricts that actor's top-level call to the manager. The manager—not the protocol—interprets and enforces the permission vocabulary. The EIP explicitly permits alternative transports such as ERC-4337. See the pinned [actor-policy specification](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#actor-policies).

The reference [`PolicyManager`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L45-L271) is one construction, not the entire Core-EIP semantic surface. It hashes `account`, `policy`, the hash of opaque config, a validity window, and salt. Its native `execute` path depends on EIP-8130 transaction context; `executeFor` derives an external actor from `msg.sender` and can work on other chains if the account trusts the manager.

The reference [`SessionPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L10-L104) combines target-selector scopes, asset limits, recipients, and recurring accounting in one policy because the manager accepts one policy per binding. It is strong evidence for candidate semantics, but it also demonstrates why naïve "spending limit" language is unsafe: only known ERC-20 selectors are decoded and charged; explicit access to other selectors can move value without being charged, and approvals may outlive an accounting period.

### Smart Sessions v1 and v2

Smart Sessions v1 stores a typed session validator and arbitrary validator initialization data, then associates policies with exact target-selector `ActionData` entries. [`PolicyLib`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L27-L78) intersects all policies attached to the selected action. Alternative actions are selected by the paired hash of target and selector; constraints within an action compose conjunctively. This is the clearest precedent for the baseline composition model.

The grant is not simply its `PermissionId`: [`IdLib`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L73-L83) derives that ID from validator, init data, and salt, while the signed digest in [`HashLib`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/HashLib.sol#L141-L213) commits the policies and account context.

V2 must be treated as a different snapshot. Its [`Session`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol#L54-L90) retains validator, salt, action, and message-signing policy concepts, but removes v1's user-operation policy and paymaster fields and introduces claim policies plus emissary/allocator lifecycle. Its enable and disable digests include new nonce, expiry, and lock-tag semantics. A profile based only on v1 would therefore freeze obsolete lifecycle details.

### Kernel

Current Kernel groups one signer and an ordered list of policies under a four-byte `PermissionId`. Installation is account-module lifecycle, and removal is order-sensitive: policies are removed LIFO before the signer. Both user-operation and signature validation intersect every policy result with the signer result in [`ValidationManager`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L328-L425).

Kernel proves that a generic policy/signer enforcement interface can fit inside an account, but it does not define a portable session-grant schema. Its policies receive a `PackedUserOperation` or signature context, and the concrete pinned plugin set primarily demonstrates caller and timelock policies. A future interoperable profile would need a new adapter/policy rather than assuming the existing four-byte permission identifier carries universal meaning.

### MetaMask Delegation Framework

MetaMask's signed [`Delegation`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol#L19-L42) contains delegate, delegator, parent authority, caveats, and salt. Caveats are arbitrary enforcer addresses with signed `terms` and unsigned per-redemption `args`. The [`DelegationManager`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol#L85-L291) validates a chain of authority, checks revocation, runs every caveat hook, and executes through the delegator account.

The enforcer catalog provides the broadest observed union: targets, methods, calldata, exact executions, time, redeemer, call count, native/ERC-20 transfer limits, periodic and streaming limits, balance-delta checks, NFT constraints, exact batches, deployment, and a logical-OR wrapper. These are useful extension precedents, but address-selected enforcers and opaque terms are not portable semantics by themselves.

MetaMask's current Smart Accounts Kit independently defines concrete ERC-7715 permission names and wallet decoders for native/ERC-20 allowance, periodic and streaming permissions plus expiry, payee, and redeemer rules. That is strong evidence that typed policy data can be rendered, but not evidence of ecosystem-wide type governance. See the pinned [`7715-permission-types`](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9/packages/7715-permission-types/src/permissions).

### Base Account Policies

Base Account Policies has a separate wallet-agnostic manager with EIP-712 policy IDs, install/replace/uninstall state, validity windows, signatures, and events. Its [`PolicyManager`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol#L11-L194) is useful lifecycle precedent, but the concrete account execution is Coinbase Smart Wallet-specific and the policy binding is not a session actor model.

[`TransferSettingsPolicy`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol) demonstrates exact recipient/asset/amount semantics and verifies an ERC-20 balance increase after execution. [`RecurringAllowance`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/accounting/RecurringAllowance.sol#L14-L136) demonstrates explicit period bounds and stored accounting. These should inform extension semantics without making the whole manager a baseline dependency.

## Comparison matrix: grant and lifecycle

| Dimension | EIP-8130 reference | Smart Sessions v1/v2 | Kernel | MetaMask Delegation | Base Account Policies |
| --- | --- | --- | --- | --- | --- |
| Session actor | **Analogous:** authenticator returns `bytes32 actorId`; K1 actors can encode an address. [`ActorConfig`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L26-L42) | **Analogous:** typed validator contract plus opaque init data. V1/v2 [`Session`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol#L54-L90) | **Analogous:** signer module plus module config under `PermissionId`. [`Types.sol`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/types/Types.sol#L36-L52) | **Common for address actors:** `delegate` is an address. | **Absent as a common session actor:** individual policies may name an executor. |
| Dapp-to-wallet request | **Absent.** Signed account changes grant actors, but no dapp request RPC. | **Absent as a wallet RPC.** `ERC7715FlowTest` is an account/module enable flow, not a full ERC-7715 wallet implementation. | **Absent.** | **Absent in contracts; analogous in Smart Accounts Kit.** | **Absent.** |
| Account binding | **Common:** account is explicit in actor state and `PolicyBinding`. | **Common:** signed digest and stored configuration are per account. | **Common:** modules are installed by/account-scoped. | **Common:** delegator is explicit. | **Common:** `PolicyBinding.account`. |
| Chain binding | **Analogous:** local and multichain account-change channels; manager binding itself has no chain field. | **Analogous:** chain digests support per-chain and multichain signing. | **Analogous:** standard and replayable validation modes. | **Analogous:** EIP-712 manager domain includes chain; a delegation struct has no chain field. | **Analogous:** EIP-712 manager domain includes chain. |
| Deterministic identity | **Analogous:** actor ID, stored commitment, and reference binding commitment are distinct values. | **Analogous:** `PermissionId` is not the full policy digest. | **System-specific:** four-byte permission identifier is supplied during install. | **Analogous:** EIP-712 delegation hash over authority and caveat terms. | **Analogous:** EIP-712 struct hash is `policyId`. |
| Config storage | **Mixed:** actor/commitment and usage stored; config preimage supplied per use. | **Stored:** validators, enabled actions, policy modules/config state. | **Stored:** signer, policies, hooks, selector access, module state. | **Mixed:** signed delegation can be stateless; revocation and stateful enforcers store state. | **Stored:** lifecycle record and policy-specific state/config hashes. |
| Enable/install | Signed `AuthorizeActor`; reference manager is otherwise commitment-driven. | Direct/inline signed enable, policy install, multichain digest. V2 adds user/allocator signature rules. | Account installs ordered policy modules then signer. | A signed delegation is usable without installation; optional re-enable toggles revoked hash. | Direct or signed manager installation. |
| Expiry/validity | Actor expiry is inclusive (`now <= expiry`); reference binding is `[validAfter, validUntil)`. | Policies return ERC-4337 validity ranges; v2 enable/disable signatures also expire. | Policies/signers intersect ERC-4337 validity data; no universal permission expiry field. | `TimestampEnforcer` supplies a caveat-specific range. | Binding enforces `[validAfter, validUntil)`. |
| Revocation | Delete actor config; signed account-change sequencing/epoch separately cancels pending changes. | Remove session/policies; nonce revokes unused enable signatures. V2 has signed disable plus nonce revocation. | Uninstall policies and signer; order-sensitive. | Delegator toggles `disabledDelegations[hash]`. | Uninstall permanently retires a policy ID; replacement is explicit. |
| Introspection/events | Actor events and Keystore getters, but no common wallet capability API. | Extensive session/action/policy getters and lifecycle events. | ERC-7579 module inspection plus Kernel-specific validation data. | Public disabled mapping and lifecycle events; delegation preimage remains offchain. | Policy record getter and install/replace/uninstall events. |

## Comparison matrix: permission semantics

| Dimension | EIP-8130 reference | Smart Sessions v1/v2 | Kernel | MetaMask Delegation | Base Account Policies |
| --- | --- | --- | --- | --- | --- |
| Target and selector | **Common shape:** `CallScope` pairs one target with selectors. Empty selectors mean wildcard, which is too broad for baseline. | **Common shape:** `ActionData` pairs exact target and selector; alternatives are separate actions. | **Analogous:** Kernel has account-function selector routing; arbitrary targets require policy inspection of the user operation. | **Analogous:** separate target and method caveats apply conjunctively but produce independent sets; exact execution/calldata enforcers can preserve pairing. | **System-specific:** policies construct exact calls rather than expose a generic call-scope vocabulary. |
| Native value | `TokenLimit(token=0)` provides total/period accounting; call scope controls the target. | `ValueLimitPolicy` observes execution value, but its semantics are policy-specific. | Generic policy can inspect value; no pinned canonical value-limit policy. | Per-call value, payment, balance, periodic, and streaming enforcers. | Transfer policy supports an exact one-shot native amount; recurring library is reusable. |
| ERC-20 spend | Direct `transfer`, account-sourced `transferFrom`, and `approve` are decoded and charged; other selectors are untracked. | `ERC20SpendingLimitPolicy` tracks `transfer`, `transferFrom`, `approve`, and `increaseAllowance`; no portable recipient semantics. | Possible through custom policy; absent from pinned canonical plugins. | One-shot, periodic, streaming, balance-change, and multi-operation enforcers. | Exact one-shot transfer and application-specific recurring policies. |
| Recipient/payee | `TokenLimit.recipients`; native recipient is the call target; approval spender is treated as recipient. | Can be expressed through argument policies, but not a common session field. | Custom policy only in pinned sources. | Transfer-specific recipient terms and SDK `payee` rules. | Exact recipient in transfer policy. |
| Call-data arguments | Only hard-coded decoding for tracked asset selectors; other calls use selector gating. | `ArgPolicy` and action policies can inspect calldata. | Generic policies receive the full user operation. | Allowed/exact calldata, equality, exact execution, and specialized enforcers. | Application-specific policy decoding. |
| Time | Binding/actor windows. | `TimeFramePolicy` and validation-data intersection. | Timelock plugin and generic validation-data intersection. | Timestamp, block-number, periodic and streaming time models. | Binding windows, unlock timestamps, recurring windows. |
| Usage/count | Spend usage keyed by commitment. | `UsageLimitPolicy`; policy-specific storage. | Custom policy. | Limited calls and nonce enforcers. | `executed` flag and recurring usage keyed by policy ID. |
| Policy composition | One reference policy per binding; SessionPolicy bundles dimensions in one atomic check. | **Common principle:** AND/intersection within selected action; OR-like selection among paired actions/fallback. | **Common principle:** AND/intersection across installed policies and signer. | **Common principle:** every caveat hook passes; explicit OR wrapper is system-specific. | Manager selects one policy; a policy may combine conditions internally. |
| Extensions | Opaque manager and commitment permit anything, but no interoperable discovery. | Arbitrary policy contract and init bytes; registry/attestation features are implementation-specific. | Arbitrary policy/signer modules. | Arbitrary enforcer address, terms, and args; broad concrete catalog. | Arbitrary policy contract/config. |
| Failure behavior | Unknown scope bits grant nothing; policy/manager reverts reject execution. | Missing required action policy or policy failure rejects; special fallback is explicit. | Nonconforming validator results fail; policy result intersection rejects. | Invalid authority, disabled delegation, or caveat failure reverts the redemption batch. | Invalid/inactive binding or policy hook failure rejects execution. |

## Comparison matrix: redemption and transport

| Dimension | EIP-8130 reference | Smart Sessions v1/v2 | Kernel | MetaMask Delegation | Base Account Policies |
| --- | --- | --- | --- | --- | --- |
| Redemption/validation entry | `PolicyManager.execute` or `executeFor`; not ERC-7710. | ERC-4337 validator/module paths; no ERC-7710 manager. | ERC-4337 `validateUserOp` plus account execution. | `redeemDelegations`, matching ERC-7710's minimal interface. | Manager `execute` after install. |
| Account-side integration | Native EIP-8130 dispatch or an account that trusts the manager/executor. | ERC-7579 account installs Smart Sessions and executes decoded account calls. | Built into Kernel account/module lifecycle. | Delegator account must authorize the manager to execute. | Account must authorize the manager; concrete calls target Coinbase Smart Wallet ABI. |
| Final target caller | Can be the account when protocol dispatch or the account's `execute` performs the call. A bare manager-to-target call would not preserve it. | Account executes, so target can observe the account, subject to account implementation. | Kernel account executes. | Delegation manager calls the delegator, which executes the target call. | Account executes manager-prepared calldata. |
| Transaction transport | Native EIP-8130 or alternative account route such as ERC-4337. | Strong ERC-4337/7579 assumptions in v1; v2 changes integration but remains account-specific. | ERC-4337 today; account/module design can gain other validation bindings. | ERC-7710 manager call; caller can use an EOA transaction or account/relay infrastructure. | Ordinary transaction or relayed call to manager; account integration remains specific. |
| Batch semantics | DefaultAccount batch is atomic; `executeForMany` is explicitly best-effort across accounts. | Each decoded execution is checked; underlying ERC-7579 execution mode determines account batch behavior. | ERC-7579 modes determine execution; policies inspect the packed user operation. | ERC-7710 requires atomicity; framework runs hooks around each execution and reverts on failure. | Policy-specific; no common batch grant. |
| Wallet attenuation | Not defined. | Not defined as a request/grant relationship. | Not defined. | Not defined in contracts; ERC-7715 SDK types can carry adjusted responses. | Not defined. |
| Capability discovery | Absent at wallet-request layer. | Onchain configuration introspection, not wallet profile discovery. | Module-type and install introspection, not semantic profile discovery. | SDK knows selected permission/rule types; contracts do not expose one universal catalog. | Policy records only. |

### EIP-7702's place in the model

EIP-7702 is account integration, not a session-permission schema. It lets an EOA set a delegation indicator pointing to code, and calls to that EOA execute the designated code in the authority account's context. Its motivation explicitly includes privilege de-escalation, but the delegated code still defines the signer, limits, revocation, and policy semantics. See the pinned [abstract, motivation, and delegation behavior](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-7702.md#abstract).

A baseline adapter can therefore live in, or be trusted by, EIP-7702-delegated account code while preserving the existing account address. The EIP-7702 authorization tuple and code-delegation lifecycle remain outside the canonical `SessionGrant`; the wallet must disclose the actual delegated implementation and root-revocation path as binding information.

## ERC-7715 and ERC-7710 fit

ERC-7715 is the closest wallet-facing request/discovery surface, but its current response is not transport-neutral. The pinned specification requires `context`, ERC-4337-style `dependencies`, and `delegationManager`, and redemption is routed through ERC-7710. It also says `isAdjustmentAllowed` permits attenuation that may "reduce or increase" authority, while the response may differ from the request. See [`PermissionRequest` and `PermissionResponse`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#request-specification).

The companion work should therefore define one new ERC-7715 permission type carrying the canonical requested/granted semantic object, not copy ERC-7715's manager/dependency fields into that object. It should also define attenuation as **narrowing only**. An increase is a counter-offer or a new request, not attenuation.

ERC-7710 is a useful redemption-interface precedent, but not a semantic permission format. Its `_permissionContexts` are explicitly manager-specific; delegation acquisition is out of scope; and the delegator need not implement one standard execution ABI because the chosen manager is assumed to know how to call it. See the pinned [obtaining, verification, and execution-interface sections](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md#obtaining-delegations). A conforming profile can have an ERC-7710 binding, but cannot claim semantic interoperability merely because a context is redeemable through that function.

## Observed union taxonomy

This is the **observed union at the pinned source revisions**, not a permanent global registry. Candidate labels are descriptive placeholders, not reserved identifiers.

| Candidate capability | Evidence in the source set | Mapping constraint | Baseline disposition |
| --- | --- | --- | --- |
| Typed session actor | EIP-8130 authenticator/actor ID; Smart Sessions validator; Kernel signer; MetaMask delegate | Validator/module addresses are binding-specific. A K1 address is the strongest common first actor type. | Envelope requirement; baseline actor type `secp256k1-address` only. |
| Exact call scope | EIP-8130 `CallScope`; Smart Sessions `ActionData`; MetaMask exact/allowed execution caveats | Target and selector must remain paired. Independent sets can widen authority. | Mandatory policy type. |
| Per-call native value | MetaMask `ValueLteEnforcer`; EIP-8130 and Smart Sessions expose each call's value to policy evaluation | Must distinguish per-call from cumulative total. | Mandatory supported constraint inside call scope. |
| Cumulative native value | EIP-8130 native `TokenLimit`; Smart Sessions `ValueLimitPolicy`; MetaMask `NativeTokenTransferAmountEnforcer`; Base transfer/allowance precedents | Stateful counter, window, and reset behavior must be explicit. | Simple grant-lifetime total in baseline; periodic/streaming are extensions. |
| Direct ERC-20 transfer total | EIP-8130 and Smart Sessions spending policies; MetaMask transfer enforcers; Base transfer policy | Selector set, source account, fee/rebase behavior, and success check differ. | Narrow direct-transfer type in baseline; approvals and indirect movement excluded. |
| Recipient/payee restriction | EIP-8130 recipients; MetaMask payee/transfer terms; Base exact recipient; Smart Sessions argument policy | Recipient is not the same as call target and is selector-specific. | Embedded in direct-transfer policy; not a free-floating global list. |
| Validity window | All systems have actor, binding, validation-data, caveat, or policy time gates | Inclusive/exclusive endpoints differ. | Envelope requirement, normalized to `[validAfter, validUntil)`. |
| Periodic allowance | EIP-8130, MetaMask, Base recurring library | Start anchor, partial final period, reset, and approvals differ. | Extension. |
| Streaming allowance | MetaMask enforcers and SDK types | Continuous accrual and unused amount semantics need a separate definition. | Extension. |
| Usage/call count | Smart Sessions usage policy; MetaMask limited calls; Base one-shot flag | Does a failed/reverted call consume usage? Ordering matters. | Extension. |
| Calldata/argument constraints | Smart Sessions `ArgPolicy`; Kernel generic policy; MetaMask allowed/exact calldata | ABI-aware decoding cannot be represented as arbitrary offset checks without risk. | Extension, preferably selector-specific typed schemas. |
| Redeemer/caller restriction | Kernel caller policy; MetaMask redeemer rule/enforcer; Base executor gate | Caller may mean transaction submitter, session actor, manager caller, or final target caller. | Extension with an explicit identity domain. |
| Message-signing scope | Smart Sessions ERC-7739/ERC-1271 policies; Kernel signature policies | Distinct risk surface from transaction execution. | Outside baseline v1. |
| Exact execution/batch shape | MetaMask exact execution/batch; ERC-7579 modes; EIP-8141 frames | Atomicity and failure behavior are transport/execution properties as well as permissions. | Outside baseline; binding must disclose actual behavior. |
| Logical OR | MetaMask OR wrapper; alternative Smart Sessions actions | General Boolean graphs complicate display and attenuation. | Outside baseline. Baseline only has OR across enumerated action alternatives and AND within an action. |
| Token approval authority | EIP-8130 and Smart Sessions track some approval selectors; MetaMask has approval/revocation capabilities | Approval persists independently and can outlive a period or session. | Excluded from baseline v1. |
| ERC-721/1155 and balance deltas | MetaMask enforcer catalog | Token ID, operator approval, safe-transfer hooks, and balance semantics are asset-specific. | Extensions. |
| Gas/paymaster authority | EIP-8130 payer scopes; Smart Sessions v1 paymaster flag; ERC-4337 paymasters | Fee payment is not target-call authority and is transport-specific. | Outside semantic baseline. |
| Deployment/state predicates | MetaMask deployment/equality enforcers | Can mutate state or depend on arbitrary external state. | Extensions, if standardized separately. |

## Native-to-union policy mapping

These tables make the mapping direction explicit. “Split” means one native construct carries several semantic capabilities; “binding” means the construct belongs below the portable policy layer. No address-selected module or enforcer becomes a union type merely because it can hold arbitrary bytes.

### EIP-8130 reference

| Native construct | Proposed destination | Fidelity and gap |
| --- | --- | --- |
| Keystore [`ActorConfig` plus policy data](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L26-L42) | Envelope actor/expiry plus EIP-8130 binding | **Split.** Authenticator, actor ID, scope bits, manager, and commitment include protocol/binding details. The baseline K1 actor can map to an address, but generic actor IDs cannot. |
| `PolicyManager.PolicyBinding` | Envelope account, validity, salt; binding evaluator/config/commitment | **Split.** The [reference commitment](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L248-L271) is manager-specific and lacks a semantic profile/version domain. |
| [`SessionPolicy.CallScope`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L77-L89) | `call-scope/1` | **Near match.** Target and selectors stay paired. Empty selectors are a wildcard in the implementation and therefore cannot map to baseline's explicit empty-calldata permission. |
| [`TokenLimit(token == address(0))`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L62-L76) | `native-value-total/1`, recipient restriction, periodic-allowance extension | **Split.** Period zero supplies a grant-lifetime cap; a positive period is an extension. The native recipient is the call target. |
| [`TokenLimit(token != address(0))`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L62-L76) | `erc20-transfer-total/1`, recipient restriction, periodic allowance, approval/`transferFrom` extensions | **Split.** The implementation decodes three selectors and can also allow untracked selectors through an explicit scope. Only its direct `transfer` subset maps to baseline. |

### Smart Sessions v1 and v2

| Native construct | Proposed destination | Fidelity and gap |
| --- | --- | --- |
| [`Session` validator, init data, and salt](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/DataTypes.sol#L66-L83) | Actor plus Smart Sessions binding | **Binding.** Arbitrary validator data is not a portable actor format; a K1 validator can implement the baseline actor. |
| `ActionData(target, selector, actionPolicies)` | `call-scope/1` plus attached typed constraints | **Near match.** [`toActionId`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L13-L30) preserves the pair, and policies on the selected action intersect. |
| [`ValueLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ValueLimitPolicy.sol) | `native-value-total/1`; possible action-value extension | **Near match for a cumulative total.** It aggregates batch value and mutates a stored counter. Baseline's separate per-call maximum needs an additional check/configuration. |
| [`ERC20SpendingLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ERC20SpendingLimitPolicy.sol) | Direct ERC-20 total plus approval and `transferFrom` extensions | **Split.** It combines `transfer`, `transferFrom`, `approve`, and `increaseAllowance`, but has no portable recipient set. |
| [`TimeFramePolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/TimeFramePolicy.sol) | Envelope validity | **Near match.** It returns ERC-4337-style validity data and permits an open-ended upper bound; baseline requires a finite half-open window. |
| [`UsageLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/UsageLimitPolicy.sol) | Usage/call-count extension | **Analogous.** It can run at user-operation or action level, so the counted unit must be fixed by the extension. |
| [`ArgPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ArgPolicy/ArgPolicy.sol) | Selector-specific calldata/argument extension | **Analogous.** Offset/rule encodings and ABI safety must be specified independently. |
| [ERC-7739 policies](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/core/SmartSessionERC7739.sol) | Message-signing extension | **Outside baseline.** Transaction calls and ERC-1271 messages are separate authority surfaces. |
| [V2 claim policies and emissary/allocator data](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol#L38-L118) | Actor authorization and lifecycle binding | **Binding/system-specific.** They change enable/disable trust and hashing, not the baseline call vocabulary. |

### Kernel and Kernel plugins

| Native construct | Proposed destination | Fidelity and gap |
| --- | --- | --- |
| `PermissionId`, signer, and signer init data | Actor plus Kernel binding | **Binding.** [`PermissionId`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/types/Types.sol#L36-L52) is four bytes and cannot be the full grant commitment; [`ECDSASigner`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/signers/ECDSASigner.sol) can authenticate the baseline K1 address. |
| [Ordered `IPolicy[]`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L398-L425) | AND/intersection composition | **Principle match.** Kernel intersects policy and signer results, but their order, install data, and user-operation ABI stay binding-specific. |
| [`CallerPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/CallerPolicy.sol) | Redeemer/requesting-protocol identity extension | **Analogous.** Its caller is the requesting protocol, not the session signer or final dapp target caller. |
| [`TimelockPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/TimelockPolicy.sol) | Valid-after/timelock extension | **Analogous.** It supplies a lower time bound, not the complete finite grant window. |
| Arbitrary [`IPolicy`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/interfaces/IERC7579Modules.sol#L74-L82) | Typed-extension adapter | **Extension mechanism only.** A contract address and opaque configuration do not define shared semantics or display data. |

### MetaMask Delegation Framework

| Native construct | Proposed destination | Fidelity and gap |
| --- | --- | --- |
| [Delegator, delegate, authority, salt](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol#L19-L42) | Account, address actor, salt; delegation-chain binding/extension | **Split.** Parent authority and signatures are framework lifecycle, while delegator/delegate map naturally for an address actor. |
| [`AllowedTargetsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/AllowedTargetsEnforcer.sol) plus [`AllowedMethodsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/AllowedMethodsEnforcer.sol) | Call-scope union only when the Cartesian product is intended | **Potentially widening.** Use `ExactExecutionEnforcer` or another paired compilation when only particular target-method pairs are granted. |
| [`ExactExecutionEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactExecutionEnforcer.sol), allowed/exact calldata, argument equality | Exact call scope plus calldata/value extensions | **Split.** Exact execution can preserve a pair and value; calldata predicates are richer than baseline selector matching. |
| [`ValueLteEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ValueLteEnforcer.sol), native payment/transfer-amount enforcers | Per-call native value, cumulative native total, payee extension | **Analogous.** The enforcers differ in whether they bound one execution, a payment, or accumulated operations. |
| [Native/ERC-20 period and streaming enforcers](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers) | Periodic-allowance and streaming-allowance extensions | **Extension.** Accrual and reset semantics must remain distinct types. |
| [`ERC20TransferAmountEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ERC20TransferAmountEnforcer.sol) and specific-action transfer enforcers | Direct ERC-20 total, recipient/action restrictions | **Near match only after compiling exact token, selector, and recipient semantics.** |
| [`TimestampEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/TimestampEnforcer.sol) and [`BlockNumberEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/BlockNumberEnforcer.sol) | Envelope time validity; block-range extension | **Split.** Baseline chooses timestamps; block-number validity remains a separate type. |
| [`RedeemerEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/RedeemerEnforcer.sol), [`LimitedCallsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/LimitedCallsEnforcer.sol), [`NonceEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/NonceEnforcer.sol) | Redeemer, usage-count, and replay/nonce extensions | **Extensions.** Each uses an identity or counted unit that must be named explicitly. |
| [Balance-change and ERC-721/1155 enforcers](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers) | Balance-delta, NFT, and multi-token extensions | **Extensions.** They cannot be represented as baseline ERC-20 argument totals. |
| [`ExactExecutionBatchEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactExecutionBatchEnforcer.sol), [`ExactCalldataBatchEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactCalldataBatchEnforcer.sol) | Exact-batch-shape extension | **Extension.** Ordered batch content is authority; transaction atomicity is additionally a binding property. |
| [`LogicalOrWrapperEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/LogicalOrWrapperEnforcer.sol) | Boolean-OR extension | **Outside baseline.** Its branch encoding and attenuation require a separate profile/type. |
| [Deployment, ownership-transfer, and approval-revocation enforcers](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers) | Deployment/admin/state-transition extensions | **System-specific extensions.** They deliberately affect lifecycle or external state and need dedicated display/security rules. |

### Base Account Policies

| Native construct | Proposed destination | Fidelity and gap |
| --- | --- | --- |
| [`PolicyBinding` and lifecycle record](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol#L11-L194) | Account, validity, salt; Base-manager binding and revocation | **Split.** The EIP-712 policy ID and install/replace/uninstall state are manager-specific. |
| [`TransferSettingsPolicy`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol) | Exact transfer call, asset, recipient, amount, time, and executor constraints | **Split.** It is one-shot and checks ERC-20 post-balance behavior; baseline uses cumulative requested-amount accounting. |
| [`RecurringAllowance`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/accounting/RecurringAllowance.sol#L4-L138) | Periodic-allowance extension | **Near match as a library precedent.** Start/end, period, and stored usage are explicit, but callers still determine the charged action. |
| [Morpho policies](https://github.com/base/account-policies/tree/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies) | Application-specific call/state-predicate extensions | **System-specific.** They show the value of extensions but are not candidates for a generic baseline vocabulary. |

## Composition result

The evidence supports a restricted composition model, not the blanket rule "every policy in the whole grant passes":

1. A grant enumerates **alternative exact call scopes**. A call is eligible if it matches one scope. This is OR over explicitly listed alternatives.
2. Every constraint attached to the matched scope and every applicable grant-wide constraint must pass. This is AND/intersection.
3. An asset-limit policy applies only to the call shapes whose value movement it can define. It must not claim to cap arbitrary indirect token effects.
4. Duplicate or overlapping entries that cannot be canonicalized without changing meaning are rejected.
5. General OR wrappers, negation, policy graphs, and fallback wildcards are not part of baseline v1.

This avoids two widening bugs:

- Separate target set `{A, B}` and selector set `{x, y}` grants the Cartesian product, even if the requester intended only `(A, x)` and `(B, y)`.
- Treating two allowed-target policies as conjunctive makes both alternatives unusable, because one call cannot target two addresses.

## Requested versus granted authority

None of the implementation contracts defines a portable request-to-grant partial order. The companion profile must do so. For baseline fields, a grant is no broader than a request only when:

- account, chain, actor type/value, and profile version are unchanged after any explicitly permitted account selection;
- every granted call scope is contained in a requested scope;
- granted selector alternatives and empty-calldata permission are subsets;
- per-call and cumulative maxima do not increase;
- an ERC-20 token address does not change, its maximum does not increase, and its recipient set is a subset;
- `validAfter` does not move earlier and `validUntil` does not move later; and
- each extension type supplies its own decidable narrowing relation. Without one, it cannot be wallet-adjusted.

Removing a positive call alternative narrows authority. Removing a restrictive policy usually widens authority. Array length is therefore not itself an attenuation rule.

## Execution identity and binding truthfulness

The target application usually needs the call to originate from the user's account. A standard manager contract cannot manufacture that identity by calling the target directly. The observed working paths all rely on one of:

- protocol dispatch as the account, as EIP-8130 or an approved EIP-8141 `SENDER` frame can provide;
- account code calling the target after manager/module validation; or
- an account-specific trusted-executor hook.

EIP-8141 reinforces the separation: `SENDER` frames run with the account as caller only after a `VERIFY` frame approves execution, while `DEFAULT`/`VERIFY` frames use the entry-point caller. Once execution is approved, validators must have inspected all relevant frames. See the pinned [frame modes and behavior](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md#behavior) and the supporting [ERC-8286 execution discussion](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-8286.md#execution).

A binding can claim baseline conformance only if it documents the actual account integration and ensures the final target observes the account where the grant promises account execution. An opaque `context` or common manager ABI is insufficient.

## Security findings for profile design

1. **Target-selector pairing:** Never flatten action pairs into independent sets unless the requested authority truly includes their Cartesian product.
2. **Indirect asset movement:** A direct-transfer counter does not bound arbitrary dapp calls, token hooks, vault withdrawals, permits, NFT transfers, or custom token methods.
3. **Approvals:** `approve` and allowance-increase authority can survive a session or accounting period. Exclude them from baseline v1 rather than presenting them as ordinary spend.
4. **Recipient semantics:** The call target, ERC-20 recipient, `transferFrom` source, approval spender, redeemer, and transaction submitter are different identities.
5. **Accounting order and reentrancy:** Stateful limits need one specified consume/rollback model and reentrancy protection. Batch totals must be aggregated rather than validated independently against the same pre-batch balance.
6. **Self-calls and admin selectors:** Calls back into the account, manager, session module, or installation/revocation entry points can escalate authority. Baseline adapters must reject them unless a separately reviewed policy expressly permits them.
7. **Replay/domain separation:** The commitment must bind profile/version, chain scope, account, actor, grant contents, and uniqueness. Binding-specific authorization must additionally bind its manager/account integration.
8. **Revocation:** Revoking an unused enable signature is not the same as revoking a live grant. Wallets must distinguish both states.
9. **Unknown policies:** Required unknown types or versions must fail at parsing, grant acceptance, import, validation, and redemption—not only in the initial wallet UI.
10. **Upgradeable enforcement:** A commitment to an evaluator address does not freeze its semantics if the code is upgradeable. Conformance needs code/version trust assumptions or an immutable semantic adapter.
11. **Batch failure:** ERC-7710 mandates atomic redemption, EIP-8130's `executeForMany` is best-effort, and ERC-7579/EIP-8141 expose execution modes. The baseline cannot imply one behavior without the binding declaring it.
12. **Display completeness:** A wallet cannot faithfully render opaque config merely because an onchain module can enforce it. Baseline fields require common decoders; extensions require known schemas.
13. **Binding duplication:** Reinstalling the same semantic grant through another manager or transport can duplicate stateful spending capacity if counters are binding-local. A conforming wallet must expose one live binding or coordinate one usage and revocation state per `grantId`.

## Comparison conclusion

The smallest defensible common standard is not a universal policy interpreter and not a flattened intersection of today's structs. It is:

- a versioned semantic envelope;
- a mandatory baseline containing paired exact calls, bounded validity, narrow value/direct-transfer limits, deterministic commitment requirements, and a revocation binding;
- a bounded, evidence-backed taxonomy of additional typed policy semantics; and
- separate wallet-request and enforcement/transport bindings.

The implementation survey supports this architecture, but does **not** yet support choosing a final ABI, hash encoding, global type-identifier registry, or one mandatory onchain manager. Those remain explicit decisions in [OPEN_QUESTIONS.md](./OPEN_QUESTIONS.md).
