# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import logging
import pprint
import os

from gi.repository.Gtk import Menu, MenuItem

import deluge.component as component  # for systray
from deluge.ui.client import client
from deluge.ui.sessionproxy import SessionProxy
import threading

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)


class OrganiseMenu(MenuItem):
    def __init__(self):
        MenuItem.__init__(self, _('Organise'))  # noqa: F821

        self.sub_menu = Menu()
        self.set_submenu(self.sub_menu)
        self.items = []

        self.sub_menu.connect('show', self.on_show, None)


    def get_torrent_ids(self):
        return component.get('TorrentView').get_selected_torrents()


    def on_show(self, widget=None, data=None):
        logging.debug('organise-on-show')
        for child in self.sub_menu.get_children():
            self.sub_menu.remove(child)
        
        item1 = MenuItem(_('Organise'))
        item1.connect('activate', self.on_organise_action)
        self.sub_menu.append(item1)

        item2 = MenuItem(_('Clear logfile'))
        item2.connect('activate', self.on_clear_logfile)
        self.sub_menu.append(item2)

        item3 = MenuItem(_('Open directory'))
        item3.connect('activate', self.on_open_directory)
        self.sub_menu.append(item3)

        item4 = MenuItem(_('Filebot'))
        item4.connect('activate', self.on_filebot)
        self.sub_menu.append(item4)

        self.show_all()       


    def organise(self, hash, name, location):
        cmd = "docker exec -it deluge su default -c \""
        cmd += "cd /config/; ./organise " + hash + " '" + name  + "' '" + location + "'"
        cmd += "\""
        logging.debug(cmd + "\n")
        deluge_cmd = "cd /config/; ./organise '{hash}' '{name}' '{location}'".format(hash=hash, name=name, location=location)
        docker_cmd = r"docker exec -it deluge su default -c \"{deluge_cmd}\"".format(deluge_cmd=deluge_cmd)
        terminal_cmd = "konsole -e \"{docker_cmd}\"".format(docker_cmd=docker_cmd)
        logging.debug(terminal_cmd)
        os.system(terminal_cmd)

    def on_get_torrent(self, torrent):
        logging.debug(pprint.pformat(torrent))
        x = threading.Thread(target=self.organise, args=(torrent['hash'], torrent['name'], torrent['download_location'],))
        x.start()

    def on_organise_action(self, widget=None): 
        logging.debug('organise')       
        session = component.get("SessionProxy")
        for torrent_id in self.get_torrent_ids():
            session.get_torrent_status(torrent_id, ['hash', 'name', 'download_location']).addCallback(self.on_get_torrent)



    def clear_logfile(self, arr):
        logging.debug('truncate log')
        cmd="echo '' > /config/logs/organise-" + arr['hash'] + ".log"
        docker_cmd = r"docker exec -it deluge sh -c \"{cmd}\"".format(cmd=cmd)
        terminal_cmd = "konsole -e  \"{docker_cmd}; sleep 30\"".format(docker_cmd=docker_cmd)
        os.system(terminal_cmd)

    def on_clear_logfile(self, widget=None):
        logging.debug('organise on_clear_logfile')
        session = component.get("SessionProxy")
        for torrent_id in self.get_torrent_ids():
            session.get_torrent_status(torrent_id, ['hash']).addCallback(self.clear_logfile)



    def open_directory(self, arr):
        logging.debug('organise on_open_directory')
        cmd = "nautilus --browser '" + arr['FBLocation'] + "'"
        logging.debug(cmd + "\n")
        os.system(cmd)

    def on_open_directory(self, widget=None):
        logging.debug('organise on_open_directory')
        session = component.get("SessionProxy")
        for torrent_id in self.get_torrent_ids():
            session.get_torrent_status(torrent_id, ['FBLocation']).addCallback(self.open_directory)



    def open_filebot(self, arr):
        logging.debug('organise on_filebot')
        cmd = "filebot \"" + arr['download_location'] + "/" + arr['name'] + "\""
        logging.debug(cmd + "\n")
        os.system(cmd)

    def on_filebot(self, widget=None):
        logging.debug('organise on_filebot')
        session = component.get("SessionProxy")
        for torrent_id in self.get_torrent_ids():
            session.get_torrent_status(torrent_id, ['name', 'download_location']).addCallback(self.open_filebot)
