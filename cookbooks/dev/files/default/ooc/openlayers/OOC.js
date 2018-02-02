/**
 * Namespace: Util.OOC
 */
OpenLayers.Util.OOC = {};

/**
 * @requires OpenLayers/Layer/XYZ.js
 *
 * Class: OpenLayers.Layer.NPE
 *
 * Inherits from:
 *  - <OpenLayers.Layer.XYZ>
 */
OpenLayers.Layer.NPE = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    /**
     * Constructor: OpenLayers.Layer.NPE
     *
     * Parameters:
     * name - {String}
     * url - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        var url = [
            "http://a.ooc.openstreetmap.org/npe/${z}/${x}/${y}.png",
            "http://b.ooc.openstreetmap.org/npe/${z}/${x}/${y}.png",
            "http://c.ooc.openstreetmap.org/npe/${z}/${x}/${y}.png"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 16,
            transitionEffect: "resize",
            sphericalMercator: true
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.XYZ.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.NPE"
});

/**
 * @requires OpenLayers/Layer/XYZ.js
 *
 * Class: OpenLayers.Layer.OS7
 *
 * Inherits from:
 *  - <OpenLayers.Layer.XYZ>
 */
OpenLayers.Layer.OS7 = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    /**
     * Constructor: OpenLayers.Layer.OS7
     *
     * Parameters:
     * name - {String}
     * url - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        var url = [
            "http://a.ooc.openstreetmap.org/os7/${z}/${x}/${y}.jpg",
            "http://b.ooc.openstreetmap.org/os7/${z}/${x}/${y}.jpg",
            "http://c.ooc.openstreetmap.org/os7/${z}/${x}/${y}.jpg"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 15,
            transitionEffect: "resize",
            sphericalMercator: true
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.XYZ.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.OS7"
});

/**
 * @requires OpenLayers/Layer/XYZ.js
 *
 * Class: OpenLayers.Layer.OS1
 *
 * Inherits from:
 *  - <OpenLayers.Layer.XYZ>
 */
OpenLayers.Layer.OS1 = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    /**
     * Constructor: OpenLayers.Layer.OS1
     *
     * Parameters:
     * name - {String}
     * url - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        var url = [
            "http://a.ooc.openstreetmap.org/os1/${z}/${x}/${y}.jpg",
            "http://b.ooc.openstreetmap.org/os1/${z}/${x}/${y}.jpg",
            "http://c.ooc.openstreetmap.org/os1/${z}/${x}/${y}.jpg"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 18,
            transitionEffect: "resize",
            sphericalMercator: true
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.XYZ.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.OS1"
});

/**
 * @requires OpenLayers/Layer/XYZ.js
 *
 * Class: OpenLayers.Layer.NPEScotland
 *
 * Inherits from:
 *  - <OpenLayers.Layer.XYZ>
 */
OpenLayers.Layer.NPEScotland = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    /**
     * Constructor: OpenLayers.Layer.NPEScotland
     *
     * Parameters:
     * name - {String}
     * url - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        var url = [
            "http://a.ooc.openstreetmap.org/npescotland/${z}/${x}/${y}.jpg",
            "http://b.ooc.openstreetmap.org/npescotland/${z}/${x}/${y}.jpg",
            "http://c.ooc.openstreetmap.org/npescotland/${z}/${x}/${y}.jpg"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 16,
            transitionEffect: "resize",
            sphericalMercator: true
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.XYZ.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.NPEScotland"
});

