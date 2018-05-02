#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import yaml
import sys

def entry(item, mode="classic"):
    md = "\n# " + item['title'] + '\n'
    for i in item['entrys']:
        if mode == "banking":
            md = md + "\cventry{" + i['date'] + "}{" + i['section'] + "}{" + i['entry'] + "}{" + i['title'] + "}{" + i['major'] + "}{}\n"
        else:
            md = md + "\cventry{" + i['date'] + "}{" + i['entry'] + "}{" + i['section'] + "}{" + i['title'] + "}{" + i['major'] + "}{}\n"
    return md
    
def project(item, mode="classic"):
    md = "\n# " + item['title'] + '\n'
    for i in item['entrys']:
        if mode == "banking":
            md = md + "\cventry{" + i['date'] + "}{" + i['corp'] + "}{" + i['entry'] + "}{" + i['tech'] + "}{}{\n\\begin{itemize}\n"
        else:
            md = md + "\cventry{" + i['date'] + "}{" + i['entry'] + "}{" + i['corp'] + "}{" + i['tech'] + "}{}{\n\\begin{itemize}\n"
        for t in i['items']:
            md = md + '\item ' + t + '\n'
        md = md + '\end{itemize}\n}\n'
    return md
    
def cvitem(item, mode="classic"):
    md = "\n# " + item['title'] + '\n'
    for i in item['entrys']:
        if mode == "banking":
            md = md + "\cvitem{" + i['cvitem'] + "}{" + i['desc'] + "}\n"
        else:
            md = md + "\cvitem{" + i['cvitem'] + "}{" + i['desc'] + "}\n"
    return md
        
def main(spec, mode="classic"):
    md = ""
    for i in spec:
        f = i['type']
        if f == 'entry':
            md = md + entry(i,mode)
        if f == 'project':
            md = md + project(i,mode)
        if f == 'cvitem':
            md = md + cvitem(i,mode)
    return md
    
if __name__ == '__main__':
    with open(sys.argv[1], 'rb')as f:
        yml=yaml.load(f)
    md = "% " + yml['title'] + "\n% " + yml['name'] + '\n'
    if len(sys.argv) == 3:
        md = md + main(yml['spec'],sys.argv[2])
    else:
        md = main(yml['spec'])
    print(md)