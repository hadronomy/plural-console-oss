# Open Source Standalone Console Image

This fork keeps Plural Console source-available under the upstream license terms
and adds one narrow runtime switch for self-hosted, no-Plural-Cloud operation.

When `PLURAL_CONSOLE_OSS_STANDALONE=true` is present, `Console.Features` returns
a local account named `Open Source Standalone` with the same local feature set
that the source tree already exposes through `Console.Plural.Features`.

This switch does not bypass authentication, RBAC, Git credentials, Kubernetes
credentials, namespace credentials, or any operator/controller permissions. It
only prevents an otherwise detached self-hosted deployment from failing closed
because no Plural Cloud account or enterprise license is available.

Images are published from this repository to:

```text
ghcr.io/hadronomy/plural-console-oss:<upstream-app-version>-oss.<patch>
```

Each image tag should correspond to an upstream Plural Console app version plus
the smallest possible fork patch.
