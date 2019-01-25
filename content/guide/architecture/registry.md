# Registry

!!! tip
    The registry is being deprecated. CPIs are encouraged to adopt a [newer API](../../cpi-api-v2.md) which does not rely on the registry.

Historically, the registry operated as a key-value store for persisting some VM runtime settings. Keys are a VM identifier and the values contain IaaS-specific settings which the CPI knows the agent will need. For example, when CPI would attach a disk to a VM it would store the device path in the registry for the agent to retrieve and reference.
