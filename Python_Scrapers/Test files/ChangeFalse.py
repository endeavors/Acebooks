import re

wfile = open("./dictfile.json", "w")

file = open("./ParseGoogle.py", 'r')
for line in file:
	line = re.sub("false", "'false'", line)
	wfile.write(line)

file.close()
wfile.close()