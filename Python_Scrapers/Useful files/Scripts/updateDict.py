import json
import os
import io

ImgUrlJsonFile = open('./Results/filledisbnData.json', 'r')
ImgUrlData = json.load(ImgUrlJsonFile)

filledJsonFile = open('./Results/diffisbnData.json', 'r')
filledData = json.load(filledJsonFile)

ImgUrlData.update(filledData)


curr_dir = os.getcwd()
curr_dir = curr_dir + '/Results'
with open(curr_dir + '/filledisbnData.json', 'w') as ofile:
    json.dump(ImgUrlData, ofile, sort_keys = True, indent = 4)