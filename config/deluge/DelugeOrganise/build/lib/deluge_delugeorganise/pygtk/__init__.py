# -*- coding: utf-8 -*-
# Copyright (C) 2021 David <dmz.oneill@gmail.com>
#
# Basic plugin template created by the Deluge Team.
#
# This file is part of DelugeOrganise and is licensed under GNU GPL 3.0, or later,
# with the additional special exception to link portions of this program with
# the OpenSSL library. See LICENSE for more details.
from __future__ import unicode_literals

import logging
import sys

import deluge.component as component
from deluge.plugins.pluginbase import Gtk3PluginBase

from . import pref, organisetab, organisemenu

log = logging.getLogger(__name__)

class Gtk3UI(Gtk3PluginBase):
    def enable(self):
        self.plugin = component.get('PluginManager')
        self.torrentmenu = component.get('MenuBar').torrentmenu
        self.DelugeOrganisecfg = None
        self.DelugeOrganiseTab = None
        self.load_interface()

    def load_interface(self):
        component.get('TorrentView').add_text_column(_('FBLocation'), status_field=['FBLocation'])

        # config:
        if not self.DelugeOrganisecfg:
            self.DelugeOrganisecfg = pref.DelugeOrganiseConfig(self.plugin)
        self.DelugeOrganisecfg.load()

        try:
            if not self.DelugeOrganiseTab:
                self.DelugeOrganiseTab = organisetab.DelugeOrganiseTab()
            self.torrent_details = component.get('TorrentDetails')
            self.torrent_details.add_tab(self.DelugeOrganiseTab)
        except:
            #log.debug("DelugeOrganise Unexpected error: " + sys.exc_info()[0])
            pass

        # menu:
        log.debug('add items to torrentview-popup menu.')
        self.organise_menu = organisemenu.OrganiseMenu()
        self.torrentmenu.append(self.organise_menu)
        self.organise_menu.show_all()

        log.debug('Finished loading DelugeOrganise plugin')

    def disable(self):
        component.get('TorrentView').remove_column(_('FBLocation'))
        self.DelugeOrganisecfg.unload()
        self.DelugeOrganiseTab.unload()
        
        log.debug('Finished disabling DelugeOrganise plugin')
