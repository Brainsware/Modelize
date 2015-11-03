var Connector,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Connector = (function() {
  function Connector(base, type) {
    if (base == null) {
      base = '/api/';
    }
    this.type = type != null ? type : 'jquery.rest';
    this.add_apis_to = bind(this.add_apis_to, this);
    this.init = bind(this.init, this);
    this.get = bind(this.get, this);
    this.connector = new $.RestClient(base, {
      stripTrailingSlash: true,
      methodOverride: true
    });
  }

  Connector.prototype.get = function(main_api) {
    return this.connector[main_api];
  };

  Connector.prototype.init = function(resource) {
    if (this.connector[resource] == null) {
      return this.connector.add(resource);
    }
  };

  Connector.prototype.add_apis_to = function(sub_apis, main_api) {
    var data, name, results;
    results = [];
    for (name in sub_apis) {
      data = sub_apis[name];
      if (!this.connector[main_api][name + 's']) {
        results.push(this.connector[main_api].add(name + 's'));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return Connector;

})();

if (typeof module !== "undefined" && module !== null) {
  module.exports = Connector;
}

//# sourceMappingURL=connector.js.map