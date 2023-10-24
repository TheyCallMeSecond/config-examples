import random
import httpx
import os
import time
import requests

ppkeys = requests.get('https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/24pbgen/base_keys')
pkeys = ppkeys.content.decode('UTF8')
keys = pkeys.split(',')
gkeys = []

value_int = int(input("Please enter the number of WARP+ keys you need to generate:\n> "))
a = 0

while a < value_int:
  a += 1

  try:
    headers = {
      "CF-Client-Version": "a-6.11-2223",
      "Host": "api.cloudflareclient.com",
      "Connection": "Keep-Alive",
      "Accept-Encoding": "gzip",
      "User-Agent": "okhttp/3.12.1",
    }

    with httpx.Client(base_url="https://api.cloudflareclient.com/v0a2223",
                      headers=headers,
                      timeout=30.0) as client:

      r = client.post("/reg")
      id = r.json()["id"]
      license = r.json()["account"]["license"]
      token = r.json()["token"]

      r = client.post("/reg")
      id2 = r.json()["id"]
      token2 = r.json()["token"]

      headers_get = {"Authorization": f"Bearer {token}"}
      headers_get2 = {"Authorization": f"Bearer {token2}"}
      headers_post = {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": f"Bearer {token}",
      }

      json = {"referrer": f"{id2}"}
      client.patch(f"/reg/{id}", headers=headers_post, json=json)

      client.delete(f"/reg/{id2}", headers=headers_get2)

      key = random.choice(keys)

      json = {"license": f"{key}"}
      client.put(f"/reg/{id}/account", headers=headers_post, json=json)

      json = {"license": f"{license}"}
      client.put(f"/reg/{id}/account", headers=headers_post, json=json)

      r = client.get(f"/reg/{id}/account", headers=headers_get)
      account_type = r.json()["account_type"]
      referral_count = r.json()["referral_count"]
      license = r.json()["license"]

      client.delete(f"/reg/{id}", headers=headers_get)
      gkeys.append(license)
      print(f"License Key: {license}\nData Count: {referral_count} of GB(s)")

  except:
    print("Error occurred.")
    time.sleep(15)
  if a % 2 == 0:
    time.sleep(60)

os.system('cls' if os.name == 'nt' else 'clear')
print("Generated Keys : (please copy the Key(s) somewhere for later use!)")
for x in gkeys:
  print(x)

input('\n(Enter) to exit.\n')
