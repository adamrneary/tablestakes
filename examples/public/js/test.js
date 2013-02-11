// Generated by CoffeeScript 1.4.0

describe("Tablestakes API ", function() {
  var table;
  table = new window.TableStakes;
  it('window.tablestakes is function', function(done) {
    assert(window.TableStakes);
    assert(typeof window.TableStakes === 'function');
    return done();
  });
  it('constructor', function(done) {
    assert(table);
    return done();
  });
  it('table options', function(done) {
    typeof table.filterCondition === 'object';
    table.filterCondition === 'd3_Map';
    typeof table.core === 'object';
    table.core === 'core';
    typeof table.events === 'object';
    table.events === 'events';
    typeof table.utils === 'object';
    table.utils === 'utils';
    return done();
  });
  it('render', function(done) {
    assert(typeof table.render === 'function');
    assert(table.render);
    return done();
  });
  it('update', function(done) {
    assert(typeof table.update === 'function');
    assert(table.update);
    return done();
  });
  it('update with argument', function(done) {
    var _this = this;
    d3.select(table.get('el')).datum(table.gridFilteredData).call(function(selection) {
      return assert(table.update(selection));
    });
    return done();
  });
  it('dispatchManualEvent', function(done) {
    assert(typeof table.dispatchManualEvent === 'function');
    assert(table.dispatchManualEvent);
    return done();
  });
  return it('setID', function(done) {
    assert(typeof table.setID === 'function');
    assert(table.setID);
    return done();
  });
});

describe("Events", function() {
  var event;
  event = window.TableStakesLib.Events;
  it('window.TableStakesLib.Events is function', function(done) {
    assert(typeof window.TableStakesLib.Events === 'function');
    assert(window.TableStakesLib.Events);
    return done();
  });
  return it('events constructor', function(done) {
    assert(event);
    return done();
  });
});
