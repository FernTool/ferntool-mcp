import json, urllib.request

def lookup(ip: str) -> dict:
    with urllib.request.urlopen(f"https://www.ferntool.com/api/ip/{ip}") as r:
        return json.load(r)

if __name__ == "__main__":
    print(json.dumps(lookup("8.8.8.8"), indent=2))
