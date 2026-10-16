#!/usr/bin/env sh
# Talk to the FernTool MCP server with raw JSON-RPC over streamable HTTP.
URL=https://www.ferntool.com/mcp
H='-H Content-Type:application/json -H Accept:application/json,text/event-stream'
curl -s $H "$URL" -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"example","version":"1.0"}}}'
curl -s $H "$URL" -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
curl -s $H "$URL" -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"lookup_ip","arguments":{"ip":"8.8.8.8"}}}'
