from .server import mcp, register_tools
import argparse
import uvicorn

def main():
    parser = argparse.ArgumentParser(description="MCP SecOps Server")
    parser.add_argument("--transport", choices=["stdio", "http"], default="stdio")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=6277)
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--tools", nargs="+", default=[
        "nmap", "sqlmap", "ffuf", "wfuzz", "nuclei", "httpx", "hashcat",
        "subfinder", "tlsx", "xsstrike", "amass", "dirsearch", "ipinfo"
    ])
    args = parser.parse_args()

    register_tools(mcp, args.tools, args.verbose)

    if args.transport == "http":
        if args.verbose:
            print(f"🚀 MCP Server listening on http://{args.host}:{args.port}")
        uvicorn.run(mcp.app, host=args.host, port=args.port)
    else:
        if args.verbose:
            print("[INFO] Iniciando MCP en stdio...")
        mcp.run(transport="stdio")

if __name__ == "__main__":
    main()