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

import deluge.component as component
import deluge.configmanager
from deluge.core.rpcserver import export
from deluge.plugins.pluginbase import CorePluginBase
import re

log = logging.getLogger(__name__)

DEFAULT_PREFS = {
    'test': 'NiNiNi'
}

def cell_data_label(column, cell, model, row, data):
    cell.set_property('text', str(model.get_value(row, data)))

fblocations = {}    

class Core(CorePluginBase):
    def enable(self):
        self.config = deluge.configmanager.ConfigManager('delugeorganise.conf', DEFAULT_PREFS)
        self.plugin = component.get("CorePluginManager")
        self.plugin.register_status_field("FBLocation", self.status_get_FBLocation)

    def disable(self):
        self.plugin.deregister_status_field("FBLocation")

    def update(self):
        pass

    @export
    def set_config(self, config):
        """Sets the config dictionary"""
        for key in config:
            self.config[key] = config[key]
        self.config.save()

    @export
    def get_config(self):
        """Returns the config dictionary"""
        return self.config.config

    def status_get_FBLocation(self, torrentid):  
        if torrentid not in fblocations:
            thefile = "/config/logs/organise-" + torrentid + ".log"

            try:
                myfile = open(thefile, "r+")
                all_of_it = myfile.read()
                myfile.close()   
                match = re.findall('\[COPY\] from \[.*\] to \[(.*)\]', all_of_it)
                if len(match) > 0:
                    fblocations[torrentid] = match[0]
                    return match[0]
                else:
                    return ""
            except IOError:
                return ""

        return fblocations[torrentid]
            

        