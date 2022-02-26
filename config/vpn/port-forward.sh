#!/bin/bash

iptables -I INPUT -p tcp --dport 25403 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT -p tcp --dport 25407 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT -p tcp --dport 25749 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT -p tcp --dport 42232 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

