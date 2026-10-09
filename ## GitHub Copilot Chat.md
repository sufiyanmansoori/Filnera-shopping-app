## GitHub Copilot Chat

- Extension: 0.63.0 (prod)
- VS Code: 1.135.0 (08d4889f9ec4a1685d257b9b95de036c8e1ce1e5)
- OS: win32 10.0.26200 x64
- GitHub Account: civilengineerimran786-max

## Network

User Settings:
```json
  "http.systemCertificatesNode": true,
  "telemetry.telemetryLevel": "all",
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:
- DNS ipv4 Lookup: 20.207.73.85 (51 ms)
- DNS ipv6 Lookup: Error (29 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (47 ms)
- Electron fetch (configured): HTTP 200 (233 ms)
- Node.js https: HTTP 200 (435 ms)
- Node.js fetch: HTTP 200 (389 ms)

Connecting to https://api.individual.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 140.82.114.22 (64 ms)
- DNS ipv6 Lookup: Error (18 ms): getaddrinfo ENOTFOUND api.individual.githubcopilot.com
- Proxy URL: None (10 ms)
- Electron fetch (configured): HTTP 200 (318 ms)
- Node.js https: HTTP 200 (1018 ms)
- Node.js fetch: HTTP 200 (889 ms)

Connecting to https://proxy.individual.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 20.199.39.224 (51 ms)
- DNS ipv6 Lookup: Error (17 ms): getaddrinfo ENOTFOUND proxy.individual.githubcopilot.com
- Proxy URL: None (10 ms)
- Electron fetch (configured): HTTP 200 (164 ms)
- Node.js https: HTTP 200 (691 ms)
- Node.js fetch: HTTP 200 (593 ms)

Connecting to https://mobile.events.data.microsoft.com/OneCollector/1.0?cors=true&content-type=application/x-json-stream (Electron fetch): HTTP 200 (294 ms)
Connecting to https://telemetry.individual.githubcopilot.com/telemetry (Node.js https): HTTP 200 (870 ms)
Connecting to https://default.exp-tas.com/vscode/ab (Node.js fetch): HTTP 200 (521 ms)

Number of system certificates: 94

## Notes

- Active fetcher: Electron fetch.
- For corporate networks also see: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).