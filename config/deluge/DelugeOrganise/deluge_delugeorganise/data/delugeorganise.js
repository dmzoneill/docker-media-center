/**
 * Script: delugeorganise.js
 *     The client-side javascript code for the DelugeOrganise plugin.
 *
 * Copyright:
 *     (C) David 2021 <dmz.oneill@gmail.com>
 *
 *     This file is part of DelugeOrganise and is licensed under GNU GPL 3.0, or
 *     later, with the additional special exception to link portions of this
 *     program with the OpenSSL library. See LICENSE for more details.
 */

DelugeOrganisePlugin = Ext.extend(Deluge.Plugin, {
    constructor: function(config) {
        config = Ext.apply({
            name: 'DelugeOrganise'
        }, config);
        DelugeOrganisePlugin.superclass.constructor.call(this, config);
    },

    onDisable: function() {
        deluge.preferences.removePage(this.prefsPage);
    },

    onEnable: function() {
        this.prefsPage = deluge.preferences.addPage(
            new Deluge.ux.preferences.DelugeOrganisePage());
    }
});
new DelugeOrganisePlugin();
