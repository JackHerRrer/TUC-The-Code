#! /bin/bash

function disconnect(){

curl "https://leekwars.com/api/farmer/disconnect" -H "Cookie: ${TOKEN}" \
						  --data "token="%"24" >/dev/null 2>&1 
}
