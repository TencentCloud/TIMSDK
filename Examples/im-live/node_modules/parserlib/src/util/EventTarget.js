"use strict";

module.exports = EventTarget;

/**
 * A generic base to inherit from for any object
 * that needs event handling.
 * @class EventTarget
 * @constructor
 */
function EventTarget() {

    /**
     * The array of listeners for various events.
     * @type Object
     * @property _listeners
     * @private
     */
    this._listeners = Object.create(null);
}

EventTarget.prototype = {

    //restore constructor
    constructor: EventTarget,

    /**
     * Adds a listener for a given event type.
     * @param {String} type The type of event to add a listener for.
     * @param {Function} listener The function to call when the event occurs.
     * @return {void}
     * @method addListener
     */
    addListener: function(type, listener) {
        if (!this._listeners[type]) {
            this._listeners[type] = [];
        }

        this._listeners[type].push(listener);
    },

    /**
     * Fires an event based on the passed-in object.
     * @param {Object|String} event An object with at least a 'type' attribute
     *      or a string indicating the event name.
     * @return {void}
     * @method fire
     */
    fire: function(event) {
        if (typeof event === "string") {
            event = { type: event };
        }
        if (typeof event.target !== "undefined") {
            event.target = this;
        }

        if (typeof event.type === "undefined") {
            throw new Error("Event object missing 'type' property.");
        }

        if (this._listeners[event.type]) {

            //create a copy of the array and use that so listeners can't chane
            var listeners = this._listeners[event.type].concat();
            for (var i=0, len=listeners.length; i < len; i++) {
                listeners[i].call(this, event);
            }
        }
    },

    /**
     * Removes a listener for a given event type.
     * @param {String} type The type of event to remove a listener from.
     * @param {Function} listener The function to remove from the event.
     * @return {void}
     * @method removeListener
     */
    removeListener: function(type, listener) {
        if (this._listeners[type]) {
            var listeners = this._listeners[type];
            for (var i=0, len=listeners.length; i < len; i++) {
                if (listeners[i] === listener) {
                    listeners.splice(i, 1);
                    break;
                }
            }


        }
    }
};
