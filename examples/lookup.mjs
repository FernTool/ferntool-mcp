// Node 18+ / browsers (CORS is open)
const res = await fetch("https://www.ferntool.com/api/ip/8.8.8.8");
console.log(await res.json());
