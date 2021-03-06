if typeof require == 'function'
  ko = require('knockout')

  Observables      = require './lib/observable'
  Observable       = Observables.Observable
  ObservableArray  = Observables.ObservableArray
  MappedObservable = Observables.MappedObservable
  Computed     = Observables.Computed
  PureComputed = Observables.PureComputed

  Editable    = require './lib/editable'
  DelayedSave = require './lib/delayedsave'
  HashedSave  = require './lib/hashedsave'

# The container main function
# Returns a container object
# A container is a minimal subset of the modelize functionality
#
# @param [Object] options The main configuration object for container
#
Container = (options = {}) ->
  'use strict'

  # Provide the constructor function for the container object.
  # Enriches the optionally provided object with container functions.
  #
  # @param [Object] self prepopulated data object
  #
  container = (self = {}) ->
    # Stores updated information for external retrieval and subscription
    Observable self, '__updated'

    # Export all model data as an array
    #
    self.export = () =>
      data = {}

      if options.editable?
        for index, name of options.editable
          data[name] = self[name]()

      return data

    # For external access for first_class containers
    self.editables = ->
      editables = []
      editables = options.editable if options.editable?
      return editables

    # Include selectable functions
    if options.selectable? && options.selectable == true
      Selectable self

    # Set observable fields
    #
    if options.observable?
      for index, name of options.observable
        Observable self, name

    # Set editable fields
    #
    if options.editable?
      for index, name of options.editable
        Editable self, name, => self.__updated(self.export())

    # Set computed fields
    #
    if options.computed?
      for name, fn of options.computed
        Computed self, name, fn
    if options.purecomputed?
      for name, fn of options.purecomputed
        PureComputed self, name, fn

    # Add user defined functions
    #
    if options.functions?
      for name, fn of options.functions
        self[name] = fn

    # Add user defined subscriptions
    #
    if options.subscriptions?
      for name, fn of options.subscriptions
        unless ko.isObservable(self[name])
          throw new Error 'No observable to subscribe to found: ' + name

        self[name].subscribe fn

    return self

  return container

module.exports = Container if module?
