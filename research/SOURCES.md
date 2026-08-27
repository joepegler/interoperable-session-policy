# Sources and evidence ledger

## Status and cutoff

This is the source manifest for the first comparative-research milestone. The research cutoff is **2026-08-26 (Europe/Dublin)**. A source described as "current" means current at that cutoff and at the exact revision below; it does not mean that a Draft EIP/ERC or repository branch is stable.

The evidence order used in this milestone is:

1. Normative specification text at a pinned Ethereum EIPs/ERCs commit.
2. Default-branch contracts and interfaces at a pinned commit.
3. Tests and SDK encoders at the same commit.
4. Repository documentation.
5. Unmerged branches and open pull requests, clearly marked as provisional.

Code and tests establish what a particular implementation does. They do not by themselves establish portable semantics. A comparison claim is admitted only when its source identifies the layer being described: request/discovery, semantic grant, enforcement, account integration, or transaction transport.

## Checked-out implementation repositories

All six checked-out repositories were clean and their checked-out default branch matched the corresponding remote head when rechecked on the cutoff date.

The workspace resource directory is `references/`: the local paths are `references/eip-8130`, `references/account-policies`, `references/delegation-framework`, `references/smartsessions`, `references/kernel-7579-plugins`, and `references/kernel`.

| ID | Repository | Default branch | Pinned commit | Role |
| --- | --- | --- | --- | --- |
| `E8130` | [`base/eip-8130`](https://github.com/base/eip-8130) | `main` | [`bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b`](https://github.com/base/eip-8130/tree/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b) | Core-EIP reference contracts plus a non-normative session policy and policy manager. |
| `BASE-POL` | [`base/account-policies`](https://github.com/base/account-policies) | `main` | [`6a834cad1c529181b467b72dbc7efedd3b34a5e6`](https://github.com/base/account-policies/tree/6a834cad1c529181b467b72dbc7efedd3b34a5e6) | Separate wallet-agnostic manager/lifecycle and application-policy precedent. |
| `MM-DF` | [`MetaMask/delegation-framework`](https://github.com/MetaMask/delegation-framework) | `main` | [`9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411`](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411) | Delegation, caveat, redemption, and revocation implementation. |
| `SS-V1` | [`erc7579/smartsessions`](https://github.com/erc7579/smartsessions) | `main` | [`f5aaf867f7e22f3b9d746ce6f404f3a56833757f`](https://github.com/erc7579/smartsessions/tree/f5aaf867f7e22f3b9d746ce6f404f3a56833757f) | ERC-7579/4337 session module, policy composition, and lifecycle. |
| `K-PLUG` | [`zerodevapp/kernel-7579-plugins`](https://github.com/zerodevapp/kernel-7579-plugins) | `master` | [`332deed6eeef3d6279cde50aa1d51eff53728bd4`](https://github.com/zerodevapp/kernel-7579-plugins/tree/332deed6eeef3d6279cde50aa1d51eff53728bd4) | Concrete Kernel-compatible policy and signer modules. |
| `KERNEL` | [`zerodevapp/kernel`](https://github.com/zerodevapp/kernel) | `dev` | [`f2a84a332ec5a722e7e95a0d64601905c3c87fe9`](https://github.com/zerodevapp/kernel/tree/f2a84a332ec5a722e7e95a0d64601905c3c87fe9) | Current permission installation, validation, account execution, and module lifecycle. |

The root repository stores these paths as Git gitlinks but has no `.gitmodules` file. The URLs above and the reproduction commands below are therefore part of the reproducibility record rather than optional documentation.

## Supplemental current implementations

These repositories were inspected at their remote default heads in disposable checkouts. They are required to avoid treating the older Smart Sessions checkout or contract-only MetaMask repository as the whole current design.

| ID | Repository | Branch | Pinned commit | Role |
| --- | --- | --- | --- | --- |
| `SS-V2` | [`rhinestonewtf/smart-sessions-v2`](https://github.com/rhinestonewtf/smart-sessions-v2) | `main` | [`bcf7ce653921a9dab5a79e30e4a85e403cdf24fe`](https://github.com/rhinestonewtf/smart-sessions-v2/tree/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe) | Current Smart Sessions lifecycle, hashing, claim policies, and emissary integration. |
| `MM-KIT` | [`MetaMask/smart-accounts-kit`](https://github.com/MetaMask/smart-accounts-kit) | `main` | [`d042c145660acddd241d6eb9bc27ccab5249d2e9`](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9) | SDK-side ERC-7715 permission types, caveat encoders, decoders, and wallet-display schemas. |
| `VIEM-8130` | [`chunter-cb/viem`](https://github.com/chunter-cb/viem) | `feat/eip-8130` | [`24aa695819c535ca4eac941c34cf8614cc331b05`](https://github.com/chunter-cb/viem/tree/24aa695819c535ca4eac941c34cf8614cc331b05) | Experimental transaction tooling; supporting transport evidence only. |

## Authoritative and supporting specifications

| ID | Specification | Status at cutoff | Pinned source |
| --- | --- | --- | --- |
| `SPEC-7702` | [EIP-7702: Set Code for EOAs](https://eips.ethereum.org/EIPS/eip-7702) | Final | [`ethereum/EIPs@dbfa6be`, `EIPS/eip-7702.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-7702.md) |
| `SPEC-8130` | [EIP-8130: Account Abstraction by Account Configuration](https://eips.ethereum.org/EIPS/eip-8130) | Draft | [`ethereum/EIPs@dbfa6be`, `EIPS/eip-8130.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md) |
| `SPEC-8141` | [EIP-8141: Frame Transactions](https://eips.ethereum.org/EIPS/eip-8141) | Draft | [`ethereum/EIPs@dbfa6be`, `EIPS/eip-8141.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md) |
| `SPEC-7710` | [ERC-7710: Smart Contract Delegation](https://eips.ethereum.org/EIPS/eip-7710) | Draft | [`ethereum/ERCs@98469bc`, `ERCS/erc-7710.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md) |
| `SPEC-7715` | [ERC-7715: Request Permissions from Wallets](https://eips.ethereum.org/EIPS/eip-7715) | Draft | [`ethereum/ERCs@98469bc`, `ERCS/erc-7715.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md) |
| `SPEC-7579` | [ERC-7579: Minimal Modular Smart Accounts](https://eips.ethereum.org/EIPS/eip-7579) | Draft | [`ethereum/ERCs@98469bc`, `ERCS/erc-7579.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7579.md) |
| `SPEC-4337` | [ERC-4337: Account Abstraction Using Alt Mempool](https://eips.ethereum.org/EIPS/eip-4337) | Review | [`ethereum/ERCs@98469bc`, `ERCS/erc-4337.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-4337.md) |
| `SPEC-8286` | [ERC-8286: ERC-7579 Validation for EIP-8141](https://eips.ethereum.org/EIPS/eip-8286) | Draft | [`ethereum/ERCs@98469bc`, `ERCS/erc-8286.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-8286.md) |
| `PR-8340` | [ERC-8340 pull request: Transaction Metadata Encoding](https://github.com/ethereum/ERCs/pull/1883) | Open PR; not merged into the pinned ERCs default branch | [`e496579b`, `ERCS/erc-8340.md`](https://github.com/ethereum/ERCs/blob/e496579b121cf83232abecfa9d5fa88ead367174/ERCS/erc-8340.md) |

`PR-8340` is an encoding and layering precedent only. Its metadata is descriptive and explicitly not an authorization mechanism. It is not evidence that a particular session-policy encoding is settled.

## Evidence index by implementation

### EIP-8130 reference

- **Actor and lifecycle:** [`Keystore.ActorConfig`, `InitialActor`, and `ChangeType`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L26-L57); [`applySignedAccountChanges`, `_applyAuthorize`, and `_applyRevoke`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L579-L759); [`getActorWithPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L960-L1027).
- **Canonical K1 actor path:** [`K1_AUTHENTICATOR` and authenticator namespace](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L189-L224); [`_authenticateK1`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L1463-L1494).
- **Manager binding and execution:** [`PolicyManager.PolicyBinding`, `execute`, `executeFor`, `_enforce`, and `_commitment`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L20-L271).
- **Observed session-policy vocabulary:** [`SessionPolicy` security model and `TokenLimit`/`CallScope`/`Config`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L10-L104); [per-call enforcement](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L321-L404); [configuration validation](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L409-L478).
- **Policy hook boundary:** [`Policy.onExecute` and `onPostExecute`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/Policy.sol#L6-L87).
- **Account dispatch:** [`DefaultAccount.executeBatch` and `execute`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/accounts/DefaultAccount.sol#L63-L95).
- **Tests read:** [`PolicyManager.t.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/test/unit/policies/PolicyManager.t.sol) and [`SessionPolicy.t.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/test/unit/policies/SessionPolicy.t.sol).

### Smart Sessions v1

- **Grant shape:** [`EnableSession`, `Session`, `PolicyData`, and `ActionData`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/DataTypes.sol#L15-L106).
- **Paired target-selector identity:** [`IdLib.toActionId`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L13-L30).
- **Composition and call checks:** [`PolicyLib.check`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L27-L78), [`checkSingle7579Exec`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L160-L240), and [`checkBatch7579Exec`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L243-L303).
- **Hashing:** [`HashLib` typed hashes, session digest, and permission hash](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/HashLib.sol#L14-L263). `PermissionId` itself hashes only validator, validator init data, and salt; the signed session digest commits the policies.
- **Lifecycle and introspection:** [`SmartSessionBase.enableSessions`, `removeSession`, and view methods](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/core/SmartSessionBase.sol#L256-L352); [`NonceManager.revokeEnableSignature`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/core/NonceManager.sol#L13-L34).
- **Concrete policies:** [`ERC20SpendingLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ERC20SpendingLimitPolicy.sol), [`TimeFramePolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/TimeFramePolicy.sol), [`ValueLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ValueLimitPolicy.sol), [`UsageLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/UsageLimitPolicy.sol), and [`ArgPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ArgPolicy/ArgPolicy.sol).
- **Tests read:** [`ERC7715FlowTest.t.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/test/unit/ERC7715FlowTest.t.sol), [`SessionManagementTest.t.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/test/unit/SessionManagementTest.t.sol), [`SpendingLimit.t.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/test/unit/SpendingLimit.t.sol), and the test-only [`MockK1Validator`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/test/mock/MockK1Validator.sol). The latter demonstrates adapter feasibility, not a canonical production validator.

### Smart Sessions v2

- **Current session shape:** [`Session`, enable/disable data, and emissary configuration`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol#L38-L118). Compared with v1, v2 removes `userOpPolicies` and the paymaster flag from `Session` and adds claim policies plus emissary-specific lifecycle data.
- **Enable lifecycle:** [`SmartSessionManager._enableSession` and `_enablePolicies`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/core/SmartSessionManager.sol#L78-L214).
- **Disable and introspection:** [`SmartSessionLens.revokeNonce`, `_disablePolicies`, `_disableSessions`, and `isPermissionEnabled`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/core/SmartSessionLens.sol#L86-L357).
- **Hashing:** [`HashLibV2` session, permission, multichain, and disable digests](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/lib/HashLibV2.sol#L115-L443).

### Kernel and Kernel plugins

- **Permission identity:** [`ValidationMode`, `ValidationId`, and four-byte `PermissionId`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/types/Types.sol#L4-L55).
- **Installation and lifecycle:** [`ValidationManager` policy/signer installation and LIFO uninstallation](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L150-L261).
- **Composition:** [`ValidationManager._verifySignaturePermission` and `_validateUserOpPermission`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L328-L425) intersect every policy result with the signer result.
- **Policy ABI:** [`IPolicy` and `ISigner`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/interfaces/IERC7579Modules.sol#L74-L88).
- **Account execution and selector routing:** [`Kernel.validateUserOp`, `executeUserOp`, `execute`, and module management`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/Kernel.sol#L90-L407).
- **Concrete plugin evidence:** [`ECDSASigner`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/signers/ECDSASigner.sol), [`PolicyBase`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/base/PolicyBase.sol), [`CallerPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/CallerPolicy.sol), and [`TimelockPolicy`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/policies/TimelockPolicy.sol).

### MetaMask Delegation Framework and Smart Accounts Kit

- **Delegation shape:** [`Delegation` and `Caveat`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol#L19-L42).
- **Lifecycle and redemption:** [`DelegationManager.disableDelegation`, `enableDelegation`, and `redeemDelegations`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol#L85-L291). Caveats run before/after hooks; a hook failure reverts the batch.
- **Hashing:** [`EncoderLib`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/libraries/EncoderLib.sol#L11-L53). The signed hash covers enforcer and `terms`, but not per-redemption `args` or the signature.
- **Call restrictions:** [`AllowedTargetsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/AllowedTargetsEnforcer.sol), [`AllowedMethodsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/AllowedMethodsEnforcer.sol), [`AllowedCalldataEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/AllowedCalldataEnforcer.sol), and [`ExactExecutionEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactExecutionEnforcer.sol).
- **Time, caller, and usage:** [`TimestampEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/TimestampEnforcer.sol), [`RedeemerEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/RedeemerEnforcer.sol), [`LimitedCallsEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/LimitedCallsEnforcer.sol), and [`NonceEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/NonceEnforcer.sol).
- **Asset policies:** [`ValueLteEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ValueLteEnforcer.sol), [`ERC20TransferAmountEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ERC20TransferAmountEnforcer.sol), [`NativeTokenTransferAmountEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/NativeTokenTransferAmountEnforcer.sol), [`ERC20PeriodTransferEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ERC20PeriodTransferEnforcer.sol), [`NativeTokenPeriodTransferEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/NativeTokenPeriodTransferEnforcer.sol), streaming and balance-change enforcers in the same [`src/enforcers`](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers) directory.
- **OR and exact-batch precedents:** [`LogicalOrWrapperEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/LogicalOrWrapperEnforcer.sol) and [`ExactExecutionBatchEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactExecutionBatchEnforcer.sol).
- **Current ERC-7715 SDK types:** [`packages/7715-permission-types/src/permissions`](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9/packages/7715-permission-types/src/permissions) includes native/ERC-20 allowance, periodic and streaming permissions, token-approval revocation, and expiry/payee/redeemer rules. [`schema/index.ts`](https://github.com/MetaMask/smart-accounts-kit/blob/d042c145660acddd241d6eb9bc27ccab5249d2e9/packages/7715-permission-types/src/permissions/schema/index.ts) is evidence of wallet-display handling, not a universal registry.

### Base Account Policies

- **Binding and lifecycle:** [`PolicyManager.PolicyBinding`, `PolicyRecord`, type hashes, and events](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol#L11-L194); [`install`, `installWithSignature`, `uninstall`, `replace`, and `getPolicyId`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol#L288-L589).
- **Transfer precedent:** [`TransferSettingsPolicy`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol) defines one-shot native/ERC-20 transfers, recipient and amount, time/executor gates, and a post-call ERC-20 balance check.
- **Recurring accounting:** [`RecurringAllowance`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/accounting/RecurringAllowance.sol#L4-L138) defines bounded periods with start/end and stored usage keyed by policy ID.

## Provisional branch horizon

The following remote heads are **not ancestors of the pinned default branch**. They are recorded because they may affect later research, but no baseline conclusion depends on them.

| Repository | Branch | Commit | Treatment |
| --- | --- | --- | --- |
| `base/eip-8130` | `feat/keystore-cleanable` | `25a56d3a91dc67a55579b2ae74e1ee66512bf5d7` | Possible actor-record garbage collection; provisional storage/lifecycle work. |
| `base/eip-8130` | `feat/per-actor-revoke-delay` | `61535a5940b7a4bbf3196dfcaa8e68e179a3077d` | Commit labels itself `STRAWMAN`; do not treat delayed revocation as EIP-8130 behavior. |
| `base/eip-8130` | `feat/session-policy-tokenlimit-grants` | `3e36b87b730e89c62f5e271a7affaccfc8d744b6` | Earlier feature head related to the current SessionPolicy design; default-branch code remains the source of truth. |
| `zerodevapp/kernel` | `feat/permission-hook-module-type` | `62db9981ab921129be67637df9a5f3095dda2749` | Provisional permission-hook work. |
| `zerodevapp/kernel-7579-plugins` | `feat/batch2` | `3c35b486ad74ca48d6cfba8728f27d7ffe2fa60d` | Provisional batch/security testing work. |

## Reproduction

For a repository not already present, reproduce a pinned checkout without relying on the root repository's absent `.gitmodules`:

```sh
git clone --filter=blob:none --no-checkout <repository-url> <destination>
git -C <destination> fetch origin <commit-sha>
git -C <destination> checkout --detach <commit-sha>
git -C <destination> rev-parse HEAD
git -C <destination> status --short
```

To verify whether a default branch has moved without changing a worktree:

```sh
git ls-remote <repository-url> refs/heads/<default-branch>
```

To retrieve the pinned specification sources:

```sh
git clone --filter=blob:none https://github.com/ethereum/EIPs.git
git -C EIPs checkout dbfa6bee8329650969b95080f23f7059c015c2ba

git clone --filter=blob:none https://github.com/ethereum/ERCs.git
git -C ERCs checkout 98469bc93b6add1e3bc9501dafaa73311071145b
```

## Verification limitations

- The contracts and tests above were read, but test execution is not used as evidence in this pass. The installed Foundry (`0.2.0`, 2024-09-04) rejects EIP-8130's `osaka` EVM target, and the Smart Sessions checkout lacks required Node packages. Populating dependency submodules would change the checked-out resource state, so the reference worktrees were restored clean and left untouched.
- No claim is made that a Draft EIP/ERC will retain the pinned behavior.
- Smart Sessions v1 and v2 are treated as separate snapshots. V2 is not assumed to preserve every v1 field or lifecycle guarantee.
- SDK schemas show what one wallet stack can encode and display. They are not evidence that other wallets use the same semantics.
- An interface name, Solidity struct, or common hash function is not evidence of semantic interoperability without matching enforcement and failure behavior.
