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

from deluge import component
from deluge.ui.gtk3.torrentdetails import Tab
from gi.repository import Pango
import os

from ..common import get_resource

class DelugeOrganiseTab(Tab):
    def __init__(self):
        super(DelugeOrganiseTab, self).__init__()

        builder = Gtk.Builder()
        builder.add_from_file(get_resource('tabs.ui'))
        self._name = 'DelugeOrganiseTab'
        self._tab_label = builder.get_object('organise_label')
        self.textbuffer1 = builder.get_object('textbuffer1')
        self.textbuffer2 = builder.get_object('textbuffer2')
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


    def show_details_log(self, all_of_it):
        logging.debug('updating details')
        self.textbuffer1.set_text(all_of_it)


    def show_filebot_log(self, all_of_it):
        logging.debug('updating filebot')
        parts_start = all_of_it.split("echo -e \"Filebot\\n\"")
        logging.debug(parts_start[1])
        parts_end = parts_start[1].split("echo -e \"\\n\"")
        logging.debug(parts_end[0])
        self.textbuffer2.set_text(parts_end[0])


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
            self.textbuffer2.set_text("eh no!")
            return

        path = os.path.dirname(os.path.realpath(__file__)).replace("/DelugeOrganise/deluge_delugeorganise/pygtk", "")
        thefile = path + "/logs/organise-" + selected + ".log"

        logging.debug('updating 2')
        all_of_it = ""
        self.textbuffer1.set_text(all_of_it)
        self.textbuffer2.set_text(all_of_it)

        try:
            myfile = open(thefile, "r+")
            all_of_it = myfile.read()
            myfile.close()           
        except IOError:
            self.textbuffer1.set_text("Could not open file! " + thefile)
            self.textbuffer2.set_text("Could not open file! " + thefile)
            return

        logging.debug('updating 3')
        self.show_details_log(all_of_it)
        self.show_filebot_log(all_of_it)