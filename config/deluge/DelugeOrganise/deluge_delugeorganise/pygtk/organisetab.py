# -*- coding: utf-8 -*-
#
# Copyright (C) 2009 Ian Martin <ianmartin@cantab.net>
# Copyright (C) 2008 Martijn Voncken <mvoncken@gmail.com>
#
# Basic plugin template created by:
# Copyright (C) 2008 Martijn Voncken <mvoncken@gmail.com>
# Copyright (C) 2007-2008 Andrew Resch <andrewresch@gmail.com>
#
# This file is part of Deluge and is licensed under GNU General Public License 3.0, or later, with
# the additional special exception to link portions of this program with the OpenSSL library.
# See LICENSE for more details.
#

from __future__ import division, unicode_literals

import logging

from gi.repository import Gtk

import deluge
from deluge import component
from deluge.plugins.pluginbase import Gtk3PluginBase
from deluge.ui.client import client
from deluge.ui.gtk3.torrentdetails import Tab
from gi.repository import Pango
import re

from ..common import get_resource

class DelugeOrganiseTab(Tab):
    def __init__(self):
        super(DelugeOrganiseTab, self).__init__()

        builder = Gtk.Builder()
        builder.add_from_file(get_resource('tabs.ui'))
        self._name = 'DelugeOrganiseTab'
        self._tab_label = builder.get_object('organise_label')
        self.textbuffer1 = builder.get_object('textbuffer1')
        self._child_widget = builder.get_object('organise_tab')
        self._child_widget.unparent()
        self._tab_label.unparent()

        tv = builder.get_object('log_viewer')
        tv.modify_font(Pango.FontDescription('monospace 10'))

        self.show_log()

    def update(self):
        self.show_log()
        pass

    def clear(self):
        self.show_log()
        pass

    def unload(self):
        pass

    def show_log(self):
        logging.debug('updating 1')
        selected = None
        try:
            selected = component.get('TorrentView').get_selected_torrents()
            if selected:
                selected = selected[0]
            else:
                return
        except:
            self.textbuffer1.set_text("eh no!")
            return

        thefile = "/home/dave/src/docker-media-center/config/deluge/logs/organise-" + selected + ".log"

        logging.debug('updating 2')
        all_of_it = ""
        self.textbuffer1.set_text(all_of_it)

        try:
            myfile = open(thefile, "r+")
            all_of_it = myfile.read()
            myfile.close()           
        except IOError:
            self.textbuffer1.set_text("Could not open file! " + thefile)
            return

        logging.debug('updating 3')
        self.textbuffer1.set_text(all_of_it)
