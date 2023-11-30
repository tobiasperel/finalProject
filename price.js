const request = require("request");
request.get("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD", function (error, response, body) {
  if (error) throw error;
  else if (!response) throw new Error("no response");
  else if (response.statusCode != 200) throw new Error("bad response");
  else console.log(JSON.stringify(JSON.parse(body)["USD"]));
});