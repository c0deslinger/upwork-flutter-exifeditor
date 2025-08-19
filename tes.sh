curl -X POST https://jlp.yahooapis.jp/MAService/V2/parse \
  -H "Content-Type: application/json" \
  -H "User-Agent: Yahoo AppID: dj00aiZpPVdmNG55V05vQkt2cCZzPWNvbnN1bWVyc2VjcmV0Jng9OGE-" \
  -d '{
        "id": "1234-1",
        "jsonrpc": "2.0",
        "method": "jlp.furiganaservice.furigana",
        "params": {
          "q": "漢字かな交じり文にふりがなを振ること"
        }
      }'
