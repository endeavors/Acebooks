import json,httplib
connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()
connection.request('POST', '/1/functions/getGoogleImg', json.dumps({
       "isbn": "9780133593495"
     }), {
       "X-Parse-Application-Id": "hyhz1kfEFA1j68kV2DYEwZR97naGoZNLUgTiQECy",
       "X-Parse-REST-API-Key": "YrkJAZjRw3JWvHNZEcFlgwfnTQXRCL8VcHKK01Wy",
       "Content-Type": "application/json"
     })
result = json.loads(connection.getresponse().read())
print result
