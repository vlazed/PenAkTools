#!/usr/bin/env python3

# Written by Awsum N00b for PenolAkushari
# And we made some edits to make it work for JSON as of 07.09.2021 (7th of september)

import re, sys

def main():

    try:
        mapname = sys.argv[1]
    except:
        mapname = input("Please enter map name: ")

    try:
        inFile = open(mapname, "r")
        ourFile = open(mapname[:-4] + "_props.txt", "w")
    except FileNotFoundError:
        print("Unable to open", mapname)
        exit()

    loopingProp = 0

    mapdata = inFile.readlines()

    ourFile.write('{"PropTable":[\n')
    i = 0
    len_mapdata = len(mapdata)
    firstline = True
    while i < len_mapdata:

        if re.search("\"classname\" \"prop_static\"", mapdata[i]):
            # This block do be lookin kinda spaghetti lmao
            i += 1
            startline = ""

            if not firstline:
                startline += ',\n\t{"Pos":"['
            else:
                startline += '\t{"Pos":"['

            ints = mapdata[i][11:-2]
            ints = ints.split()
            startline += ints[0] + " " + ints[1] + " " + ints[2]
            startline += ']", "Ang":"{'
            i += 1
            ints = mapdata[i][11:-2]
            ints = ints.split()
            startline += ints[0] + " " + ints[1] + " " + ints[2]
            startline += '}", "Skin":'
            i += 1
            startline += mapdata[i][9:-2] + '.0, "Model":'
            i += 4
            startline += mapdata[i][9:-1] + "}"

            ourFile.write(startline)
            firstline = False

        i += 1


    print()
    ourFile.write("\n]}\n")
    inFile.close()
    ourFile.close()

if __name__ == '__main__':
    main()
