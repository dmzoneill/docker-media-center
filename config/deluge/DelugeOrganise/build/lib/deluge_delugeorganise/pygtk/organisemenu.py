# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import logging
import os
import pprint

from gi.repository.Gtk import Menu, MenuItem

import deluge.component as component  # for systray
from deluge.ui.client import client
from deluge.ui.sessionproxy import SessionProxy

log = logging.getLogger(__name__)


class OrganiseMenu(MenuItem):
    def __init__(self):
        MenuItem.__init__(self, _('Organise'))  # noqa: F821

        self.sub_menu = Menu()
        self.set_submenu(self.sub_menu)
        self.items = []

        # attach..
        self.sub_menu.connect('show', self.on_show, None)

    def get_torrent_ids(self):
        return component.get('TorrentView').get_selected_torrents()

    def on_show(self, widget=None, data=None):
        log.debug('organise-on-show')
        for child in self.sub_menu.get_children():
            self.sub_menu.remove(child)
        
        item1 = MenuItem(_('organise'))
        item1.connect('activate', self.on_organise_action)
        self.sub_menu.append(item1)

        item2 = MenuItem(_('organise-again'))
        item2.connect('activate', self.on_organise_again_action)
        self.sub_menu.append(item2)

        self.show_all()       

    def on_organise_action(self, widget=None): 
        log.debug('organise')       
        sp = component.get("SessionProxy")
        for torrent_id in self.get_torrent_ids():
            status = sp.get_torrent_status(torrent_id, ['name', 'download_location'])
            log.debug(torrent_id + "\n")

            log.debug(pprint.pformat(status))

            #log.debug(status['download_location'] + "\n")
            #log.debug(status['name'] + "\n")

            

            #cmd = "docker exec -it deluge sh -c \""
            #cmd += "cd /config/; ./organise " + torrent_id + " " + status['download_location']  + " '" + status['name'] + "'"
            #cmd += "\""
            #os.system(cmd)
            #log.debug(cmd + "\n")
        

    def on_organise_again_action(self, widget=None):        
        #for torrent_id in self.get_torrent_ids():
        #    client.label.set_torrent(torrent_id, action)
        log.debug('organise ')