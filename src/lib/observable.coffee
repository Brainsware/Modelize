if typeof require == 'function'
  ko = require('knockout')

Observable = (self, property, initial_value) ->
  initial_value = self[property] if initial_value == undefined

  self[property] = ko.observable initial_value

ObservableArray = (self, property, initial_value) ->
  initial_value = [] if initial_value == undefined

  self[property] = ko.observableArray initial_value

  # Shortcut for ko.utils.arrayFilter
  #
  #   observable_array.select (item) -> return <boolean>
  #
  self[property].select = (fn) -> ko.utils.arrayFilter self[property].call(), fn

  # Shortcut for ko.utils.arrayMap
  #
  #   observable_array.map (item) -> return item.id
  #
  self[property].map = (fn) -> ko.utils.arrayMap self[property].call(), fn

Computed = (self, property, fn) -> self[property] = ko.computed fn, self
PureComputed = (self, property, fn) -> self[property] = ko.pureComputed fn, self

MappedObservable = (self, property, container, initial_value) ->
  self[property] = ko.pureComputed
    read: ->
      container[property]()
    write: (value) ->
      container[property](value)
    deferEvaluation: true

  if initial_value?
    self[property](initial_value)

LazyObservable = (self, property, callback, params = [], init_value = null, make_array = false) ->
  unless make_array
    _value = ko.observable init_value
  else
    _value = ko.observableArray init_value

  self[property] = ko.computed
    read: ->
      if self[property].loaded() == false
        callback.apply(self, params)
      return _value()
    write: (newValue) ->
      self[property].loaded true
      _value newValue
    deferEvaluation: true

  if make_array == true
    self[property].remove = (e) ->
      return _value.remove e
    self[property].push = (e) ->
      return _value.push e
    self[property].splice = (e, i, args) ->
      return _value.splice e, i, args

  self[property].loaded = ko.observable false
  self[property].refresh = ->
    self[property].loaded(false)

LazyObservableArray = (self, property, callback, params = [], init_value = null) ->
  LazyObservable self, property, callback, params, init_value, true

if module?
  module.exports =
    Observable:      Observable
    ObservableArray: ObservableArray
    Computed:        Computed
    PureComputed:    PureComputed
    LazyObservable:  LazyObservable
