# FernTool — network toolbox MCP server & free IP API

[![Listed on mcpservers.org](https://mcpservers.org/badge.svg)](https://mcpservers.org/servers/ferntool/ferntool-mcp)

<!-- mcp-name: com.ferntool/ip -->

[![MCP](https://img.shields.io/badge/MCP-streamable--http-0b7a4b)](https://www.ferntool.com/mcp)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Website](https://img.shields.io/badge/web-ferntool.com-2f855a)](https://www.ferntool.com)

**[FernTool](https://www.ferntool.com)** is a fast, clean "what is my IP" and IP lookup tool. This repo documents its **hosted, remote MCP server** so AI assistants and agents (Claude, Cursor, VS Code Copilot and others) can:

- get the caller's public IP, ISP, ASN, location and timezone
- look up the country, ASN and network owner of **any** IPv4/IPv6 address
- detect **Tor exit nodes, VPN/datacenter and cloud IPs** (AWS, Google Cloud, Azure, Cloudflare, DigitalOcean, Oracle, Hetzner, OVH and more)
- **batch** look up to 100 IPs in one call
- run **WHOIS (RDAP)** for domains, IPs and ASNs, **DNS** lookups (A/AAAA/MX/TXT/NS/CNAME/SOA), **reverse DNS** and **IPv4/IPv6 subnet** math
- validate and classify IP addresses (public, private, loopback, documentation and so on)

No API key, no install, no sign-up. It's just a URL:

```
https://www.ferntool.com/mcp
```

Transport: MCP **streamable HTTP** (JSON-RPC 2.0, protocol `2025-06-18`).

## Connect

**Claude Code**

```sh
claude mcp add --transport http ferntool https://www.ferntool.com/mcp
```

**Claude Desktop** (`claude_desktop_config.json`). Use Settings → Connectors → *Add custom connector* with the URL above, or bridge with `mcp-remote`:

```json
{ "mcpServers": { "ferntool": { "command": "npx", "args": ["-y", "mcp-remote", "https://www.ferntool.com/mcp"] } } }
```

**Cursor** (`~/.cursor/mcp.json` or `.cursor/mcp.json`)

```json
{ "mcpServers": { "ferntool": { "url": "https://www.ferntool.com/mcp" } } }
```

**VS Code** (`.vscode/mcp.json`)

```json
{ "servers": { "ferntool": { "type": "http", "url": "https://www.ferntool.com/mcp" } } }
```

Ready-made files are in [`examples/`](examples).

## Tools

| Tool | Input | What it returns |
|---|---|---|
| `get_my_ip` | none | Public IP of the caller (IPv4 or IPv6) with ISP, ASN, city/region/country, coordinates, timezone and `is_tor` / `is_datacenter` / `provider`. For remote agents, this is the IP of the machine calling the server. |
| `lookup_ip` | `ip` (string, IPv4 or IPv6) | Validity, version, scope, country, timezone, ASN, network owner and `flags` (`is_tor`, `is_datacenter`, `provider`). |
| `batch_lookup_ip` | `ips` (array of 1–100 strings) | `lookup_ip` results for every address, plus `complete` / `retry`. |
| `validate_ip` | `ip` (string) | Whether it's a valid IPv4/IPv6, the expanded form and the scope (public/private/loopback/link-local/documentation/...). |
| `whois_lookup` | `query` (domain, IP or ASN like `AS13335`) | RDAP record: registrar, created/expiry/updated dates, status, nameservers, DNSSEC; for IPs/ASNs the network name, range/CIDR, owner org, country and abuse contact. |
| `dns_lookup` | `domain`, optional `types` (A, AAAA, MX, TXT, NS, CNAME, SOA) | Records with TTLs via Cloudflare 1.1.1.1 DNS-over-HTTPS, response status and DNSSEC validation flag. |
| `reverse_dns` | `ip` | PTR hostname(s) and whether the hostname resolves back to the IP (forward-confirmed). |
| `subnet_calc` | `cidr` (e.g. `192.168.1.0/24`, `2001:db8::/48`) | Network, netmask, wildcard, broadcast, first/last usable, total and usable addresses, block type. |

Example `lookup_ip` result for `8.8.8.8`:

```json
{
  "valid": true, "version": 4, "ip": "8.8.8.8", "scope": "public",
  "source": "dbip-lite+iptoasn",
  "geo": { "country": "US", "country_name": "United States", "asn": 15169, "isp": "GOOGLE",
           "timezone": "America/New_York", "timezones": ["America/New_York", "..."] },
  "flags": { "is_tor": false, "is_datacenter": true, "provider": "Google Cloud" }
}
```

Example `validate_ip` result for `2001:db8::1`:

```json
{ "valid": true, "version": 6, "ip": "2001:db8::1",
  "expanded": "2001:0db8:0000:0000:0000:0000:0000:0001", "scope": "documentation" }
```

### Raw JSON-RPC

```sh
curl -s https://www.ferntool.com/mcp \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"lookup_ip","arguments":{"ip":"8.8.8.8"}}}'
```

## Plain HTTP API

The same data is available without MCP. There's no key, and CORS is `*`. Full spec: [`/openapi.json`](https://www.ferntool.com/openapi.json).

```sh
curl https://www.ferntool.com/ip              # 203.0.113.7  (plain text)
curl https://www.ferntool.com/json            # your IP + ISP, ASN, city, timezone
curl https://www.ferntool.com/api/ip/1.1.1.1  # any IPv4/IPv6 (+ timezone, Tor/datacenter flags)
curl -X POST https://www.ferntool.com/api/batch -H 'Content-Type: application/json' -d '{"ips":["8.8.8.8","1.1.1.1"]}'
curl https://www.ferntool.com/api/whois/example.com          # RDAP WHOIS (domain, IP or ASN)
curl "https://www.ferntool.com/api/dns/example.com?type=A,MX" # DNS via Cloudflare DoH
curl https://www.ferntool.com/api/reverse-dns/1.1.1.1        # PTR
curl "https://www.ferntool.com/api/subnet?cidr=10.0.0.0/22"   # subnet calculator
```

Python:

```python
import json, urllib.request
print(json.load(urllib.request.urlopen("https://www.ferntool.com/api/ip/8.8.8.8")))
```

JavaScript:

```js
const r = await fetch("https://www.ferntool.com/api/ip/8.8.8.8");
console.log(await r.json());
```

## Fair use

This is a free service on a shared edge network. Please cache results and keep traffic reasonable. Network lookups (WHOIS, DNS, reverse DNS, batch) are limited to roughly 40 per minute per IP; heavy or abusive traffic may be rate-limited further.

## Data attribution

- IP geolocation by **[DB-IP](https://db-ip.com)**, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- ASN data from **[IPtoASN](https://iptoasn.com)** (PDDL).
- The caller's own location in `get_my_ip` comes from the Cloudflare edge.
- Tor exit list from the [Tor Project](https://check.torproject.org/torbulkexitlist); cloud ranges published by AWS, Google Cloud, Microsoft Azure, Cloudflare, DigitalOcean and Oracle; plus a list of well-known hosting ASNs. Refreshed regularly.
- WHOIS from registry RDAP services (IANA bootstrap); DNS from Cloudflare 1.1.1.1. Timezones for other IPs are the country's main IANA zone (tzdata).

## Links

- Website: <https://www.ferntool.com>
- What is my IP: <https://www.ferntool.com/>
- IP lookup: <https://www.ferntool.com/ip-lookup>
- VPN leak test: <https://www.ferntool.com/vpn-leak-test>
- WHOIS lookup: <https://www.ferntool.com/whois-lookup>
- DNS lookup: <https://www.ferntool.com/dns-lookup>
- Reverse DNS: <https://www.ferntool.com/reverse-dns>
- Subnet calculator: <https://www.ferntool.com/subnet-calculator>
- MCP registry name: `com.ferntool/ip`

## License

The contents of this repository (docs, examples, `server.json`) are under the [MIT License](LICENSE). The hosted service and its data are subject to the attributions above.
