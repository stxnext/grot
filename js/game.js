// Generated by CoffeeScript 1.7.1
(function() {
  var Board, Field, FieldWidget, Game, Level, Renderer, TWEEN_DURATION, TopBarWidget, delay1s, randomChoice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  TWEEN_DURATION = 0.5;

  delay1s = function(func) {
    return setTimeout(func, 1000);
  };

  randomChoice = function(values) {
    return values[Math.floor(Math.random() * values.length)];
  };

  FieldWidget = (function() {
    FieldWidget.prototype.group = null;

    FieldWidget.prototype.circle = null;

    FieldWidget.prototype.label = null;

    FieldWidget.prototype.field = null;

    FieldWidget.prototype.callback = null;

    FieldWidget.prototype.colors = {
      gray: '#95a5a6',
      blue: '#2980b9',
      green: '#27ae60',
      red: '#e74c3c'
    };

    FieldWidget.prototype.arrows = {
      left: String.fromCharCode(8592),
      right: String.fromCharCode(8594),
      up: String.fromCharCode(8593),
      down: String.fromCharCode(8595),
      none: ' '
    };

    function FieldWidget(field) {
      this.field = field;
      this.group = new Kinetic.Group;
      this.circle = new Kinetic.Circle({
        x: 0,
        y: 0,
        radius: 45,
        fill: this.colors[this.field.value]
      });
      this.label = new Kinetic.Text({
        x: 0,
        y: 0,
        text: this.arrows[this.field.direction],
        align: 'center',
        fontSize: 55,
        fontFamily: 'Calibri',
        fontStyle: 'bold',
        fill: '#333333'
      });
      this.centerLabel();
      this.group.add(this.circle);
      this.group.add(this.label);
    }

    FieldWidget.prototype.centerLabel = function() {
      this.label.offsetX(this.label.width() / 2);
      return this.label.offsetY(this.label.height() / 2);
    };

    FieldWidget.prototype.move = function(x, y) {
      var relativeX, relativeY;
      relativeX = x - this.group.x();
      relativeY = y - this.group.y();
      return this.group.move({
        x: relativeX,
        y: relativeY
      });
    };

    FieldWidget.prototype.scale = function(scale) {
      return this.group.scale({
        x: scale,
        y: scale
      });
    };

    FieldWidget.prototype.reset = function() {
      this.circle.fill(this.colors[this.field.value]);
      this.label.setText(this.arrows[this.field.direction]);
      return this.centerLabel();
    };

    FieldWidget.prototype.setupCallback = function(callback) {
      var widget;
      this.callback = callback;
      widget = this;
      return this.group.on('mousedown touchstart', function(event) {
        return widget.callback(widget.field, event);
      });
    };

    return FieldWidget;

  })();

  Field = (function() {
    Field.prototype.x = null;

    Field.prototype.y = null;

    Field.prototype.id = null;

    Field.prototype.value = null;

    Field.prototype.direction = null;

    Field.prototype.widget = null;

    Field.prototype.board = null;

    Field.prototype.points = {
      gray: 0,
      blue: 1,
      green: 2,
      red: 3
    };

    function Field(board, x, y) {
      this.board = board;
      this.x = x;
      this.y = y;
      this.id = "" + this.x + "-" + this.y;
      this.resetRandoms();
      this.widget = new FieldWidget(this);
    }

    Field.prototype.resetRandoms = function() {
      var k;
      this.value = randomChoice((function() {
        var _results;
        _results = [];
        for (k in this.points) {
          _results.push(k);
        }
        return _results;
      }).call(this));
      this.direction = randomChoice(['left', 'right', 'up', 'down']);
      if (this.widget != null) {
        return this.widget.reset();
      }
    };

    Field.prototype.getPoints = function() {
      return this.points[this.value];
    };

    Field.prototype.updatePosition = function(x, y) {
      this.x = x;
      this.y = y;
      return this.id = "" + this.x + "-" + this.y;
    };

    return Field;

  })();

  Board = (function() {
    Board.prototype.size = 0;

    Board.prototype.fields = [];

    function Board(size) {
      this.size = size != null ? size : 9;
      this.createBoard(this.size);
    }

    Board.prototype.createBoard = function() {
      var x, y, _i, _ref, _results;
      _results = [];
      for (x = _i = 0, _ref = this.size - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.fields.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = 0, _ref1 = this.size - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            _results1.push(new Field(this, x, y));
          }
          return _results1;
        }).call(this)));
      }
      return _results;
    };

    Board.prototype.getNextField = function(field, lastDirection) {
      var direction, nextField;
      if (lastDirection == null) {
        lastDirection = null;
      }
      direction = lastDirection ? lastDirection : field.direction;
      if (direction === 'left') {
        if (field.x === 0) {
          return [field, true];
        }
        nextField = this.fields[field.x - 1][field.y];
      } else if (direction === 'right') {
        if (field.x === (this.size - 1)) {
          return [field, true];
        }
        nextField = this.fields[field.x + 1][field.y];
      } else if (direction === 'up') {
        if (field.y === 0) {
          return [field, true];
        }
        nextField = this.fields[field.x][field.y - 1];
      } else if (direction === 'down') {
        if (field.y === (this.size - 1)) {
          return [field, true];
        }
        nextField = this.fields[field.x][field.y + 1];
      }
      if (nextField.direction === 'none') {
        return this.getNextField(nextField, direction);
      }
      return [nextField, false];
    };

    Board.prototype.lowerField = function(field) {
      var lastMove, newX, newY, nextField, oldX, oldY, _ref;
      oldX = field.x;
      oldY = field.y;
      _ref = this.getNextField(field, 'down'), nextField = _ref[0], lastMove = _ref[1];
      newX = nextField.x;
      newY = nextField.y;
      if (!lastMove) {
        newY = nextField.y - 1;
      }
      if (newY === oldY) {
        return [];
      }
      this.fields[oldX][oldY] = this.fields[newX][newY];
      this.fields[oldX][oldY].updatePosition(oldX, oldY);
      this.fields[newX][newY] = field;
      this.fields[newX][newY].updatePosition(newX, newY);
      return [newX, newY];
    };

    return Board;

  })();

  TopBarWidget = (function() {
    TopBarWidget.prototype.level = null;

    TopBarWidget.prototype.group = null;

    TopBarWidget.prototype.scoreLabel = null;

    TopBarWidget.prototype.score = null;

    TopBarWidget.prototype.movesLabel = null;

    TopBarWidget.prototype.moves = null;

    function TopBarWidget(level) {
      this.level = level;
      this.group = new Kinetic.Group;
      this.scoreLabel = new Kinetic.Text({
        x: 25,
        y: 5,
        text: 'Score',
        align: 'center',
        fontSize: 6,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.score = new Kinetic.Text({
        x: 25,
        y: 15,
        text: this.level.score,
        align: 'center',
        fontSize: 8,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.scoreDiff = new Kinetic.Text({
        x: 25,
        y: 25,
        text: '',
        align: 'center',
        fontSize: 6,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.movesLabel = new Kinetic.Text({
        x: 75,
        y: 5,
        text: 'Moves',
        align: 'center',
        fontSize: 6,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.moves = new Kinetic.Text({
        x: 75,
        y: 15,
        text: this.level.moves,
        align: 'center',
        fontSize: 8,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.movesDiff = new Kinetic.Text({
        x: 75,
        y: 25,
        text: '',
        align: 'center',
        fontSize: 6,
        fontFamily: 'Inconsolata',
        fontVariant: '400',
        fill: '#ecf0f1'
      });
      this.centerText(this.scoreLabel);
      this.centerText(this.score);
      this.centerText(this.scoreDiff);
      this.centerText(this.movesLabel);
      this.centerText(this.moves);
      this.centerText(this.movesDiff);
      this.group.add(this.scoreLabel);
      this.group.add(this.score);
      this.group.add(this.scoreDiff);
      this.group.add(this.movesLabel);
      this.group.add(this.moves);
      this.group.add(this.movesDiff);
    }

    TopBarWidget.prototype.scale = function(scale) {
      return this.group.scale({
        x: scale,
        y: scale
      });
    };

    TopBarWidget.prototype.centerText = function(text) {
      text.offsetX(text.width() / 2);
      return text.offsetY(text.height() / 2);
    };

    TopBarWidget.prototype.update = function() {
      var tween;
      this.score.setText(this.level.score);
      if (this.level.scoreDiff === 0) {
        this.scoreDiff.setText(' ');
      } else {
        this.scoreDiff.setText('+' + this.level.scoreDiff);
        this.scoreDiff.opacity(1);
        delay1s((function(_this) {
          return function() {
            var tween;
            tween = new Kinetic.Tween({
              node: _this.scoreDiff,
              opacity: 0,
              duration: TWEEN_DURATION,
              onFinish: function() {
                return this.destroy();
              }
            });
            return tween.play();
          };
        })(this));
      }
      this.moves.setText(this.level.moves);
      if (this.level.movesDiff === 0) {
        this.movesDiff.setText(' ');
      } else {
        this.movesDiff.setText('+' + this.level.movesDiff);
        this.movesDiff.opacity(1);
        tween = new Kinetic.Tween({
          node: this.movesDiff,
          opacity: 0,
          duration: TWEEN_DURATION * 5
        });
        tween.play();
      }
      this.centerText(this.score);
      this.centerText(this.scoreDiff);
      this.centerText(this.moves);
      this.centerText(this.movesDiff);
      return this.group.getLayer().draw();
    };

    return TopBarWidget;

  })();

  Renderer = (function() {
    Renderer.prototype.board = null;

    Renderer.prototype.stage = null;

    Renderer.prototype.fieldsLayer = null;

    Renderer.prototype.barsLayer = null;

    Renderer.prototype.animLayer = null;

    Renderer.prototype.level = null;

    Renderer.prototype.topBarWidget = null;

    function Renderer(board, level) {
      var height, width, x, y, _i, _j, _ref, _ref1, _ref2;
      this.board = board;
      this.level = level;
      this.startMove = __bind(this.startMove, this);
      _ref = this.getCanvasSize(), width = _ref[0], height = _ref[1];
      this.cavnasWidth = width;
      this.stage = new Kinetic.Stage({
        container: 'wrap',
        width: width,
        height: height
      });
      this.topBarWidget = new TopBarWidget(this.level);
      this.refreshWidgets();
      this.fieldsLayer = new Kinetic.Layer;
      for (x = _i = 0, _ref1 = this.board.size - 1; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = 0 <= _ref1 ? ++_i : --_i) {
        for (y = _j = 0, _ref2 = this.board.size - 1; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; y = 0 <= _ref2 ? ++_j : --_j) {
          this.fieldsLayer.add(this.board.fields[x][y].widget.group);
        }
      }
      this.barsLayer = new Kinetic.Layer;
      this.barsLayer.add(this.topBarWidget.group);
      this.animLayer = new Kinetic.Layer;
      this.stage.add(this.fieldsLayer);
      this.stage.add(this.barsLayer);
      this.stage.add(this.animLayer);
    }

    Renderer.prototype.moveFieldToLayer = function(field, toLayer) {
      var fromLayer;
      fromLayer = field.widget.group.getLayer();
      field.widget.group.moveTo(toLayer);
      fromLayer.draw();
      return toLayer.draw();
    };

    Renderer.prototype.getCanvasSize = function() {
      var height, width;
      if (window.innerHeight < window.innerWidth) {
        height = window.innerHeight - 20;
        width = Math.round(height / 1.5);
      } else {
        width = window.innerWidth - 20;
        height = Math.round(width * 1.5);
      }
      return [width, height];
    };

    Renderer.prototype.resizeCanvas = function() {
      var height, width, _ref;
      _ref = this.getCanvasSize(), width = _ref[0], height = _ref[1];
      this.cavnasWidth = width;
      this.stage.setHeight(height);
      return this.stage.setWidth(width);
    };

    Renderer.prototype.refresh = function() {
      this.resizeCanvas();
      return this.refreshWidgets();
    };

    Renderer.prototype.getFieldCenter = function(x, y) {
      var centerX, centerY, topMargin, unit;
      unit = Math.round(this.cavnasWidth / (this.board.size * 2));
      topMargin = Math.round(this.cavnasWidth * 0.33);
      centerX = 2 * unit + x * 2 * unit;
      centerY = topMargin + 2 * unit + y * 2 * unit;
      return [centerX - unit, centerY - unit];
    };

    Renderer.prototype.refreshWidgets = function() {
      var centerX, centerY, unit, widget, x, y, _i, _j, _ref, _ref1, _ref2;
      unit = Math.round(this.cavnasWidth / (this.board.size * 2));
      for (x = _i = 0, _ref = this.board.size - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = this.board.size - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          _ref2 = this.getFieldCenter(x, y), centerX = _ref2[0], centerY = _ref2[1];
          widget = this.board.fields[x][y].widget;
          widget.scale(unit / 50);
          widget.move(centerX, centerY);
          if (widget.callback == null) {
            widget.setupCallback(this.startMove);
          }
        }
      }
      return this.topBarWidget.scale(this.cavnasWidth / 100);
    };

    Renderer.prototype.listening = function(state) {
      var x, y, _i, _j, _ref, _ref1;
      for (x = _i = 0, _ref = this.board.size - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = this.board.size - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          this.board.fields[x][y].widget.group.listening(state);
        }
      }
      return this.fieldsLayer.drawHit();
    };

    Renderer.prototype.startMove = function(field, event) {
      this.listening(false);
      this.level.moves -= 1;
      this.level.scoreDiff = 0;
      this.level.movesDiff = 0;
      this.topBarWidget.update();
      this.movePoints = 0;
      this.moveLength = 0;
      return this.moveToNextField(field);
    };

    Renderer.prototype.moveToNextField = function(startField) {
      var centerX, centerY, lastMove, nextField, tween, _ref, _ref1;
      _ref = this.board.getNextField(startField), nextField = _ref[0], lastMove = _ref[1];
      _ref1 = this.getFieldCenter(nextField.x, nextField.y), centerX = _ref1[0], centerY = _ref1[1];
      startField.direction = 'none';
      this.movePoints += startField.getPoints();
      this.moveLength += 1;
      this.moveFieldToLayer(startField, this.animLayer);
      tween = new Kinetic.Tween({
        node: startField.widget.group,
        duration: TWEEN_DURATION,
        x: centerX,
        y: centerY,
        opacity: 0,
        onFinish: (function(_this) {
          return function() {
            _this.moveFieldToLayer(startField, _this.fieldsLayer);
            if (lastMove) {
              _this.lowerFields();
            } else {
              _this.moveToNextField(nextField);
            }
            return this.destroy();
          };
        })(this)
      });
      return tween.play();
    };

    Renderer.prototype.lowerFields = function() {
      var centerX, centerY, field, newX, newY, result, tween, tweens, x, y, _i, _j, _k, _len, _ref, _ref1, _ref2, _results;
      tweens = [];
      for (y = _i = _ref = this.board.size - 2; _ref <= 0 ? _i <= 0 : _i >= 0; y = _ref <= 0 ? ++_i : --_i) {
        for (x = _j = 0, _ref1 = this.board.size - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          field = this.board.fields[x][y];
          if (field.direction !== 'none') {
            result = this.board.lowerField(field);
            if (result.length === 2) {
              newX = result[0], newY = result[1];
              _ref2 = this.getFieldCenter(newX, newY), centerX = _ref2[0], centerY = _ref2[1];
              this.moveFieldToLayer(field, this.animLayer);
              tweens.push(new Kinetic.Tween({
                node: field.widget.group,
                easing: Kinetic.Easings.BounceEaseOut,
                duration: TWEEN_DURATION,
                x: centerX,
                y: centerY,
                onFinish: (function(_this) {
                  return function() {
                    _this.moveFieldToLayer(field, _this.fieldsLayer);
                    return this.destroy();
                  };
                })(this)
              }));
            }
          }
        }
      }
      if (tweens.length > 0) {
        tweens[0].onFinish = (function(_this) {
          return function() {
            _this.moveFieldToLayer(field, _this.fieldsLayer);
            _this.fillEmptyFields();
            return this.destroy();
          };
        })(this);
        _results = [];
        for (_k = 0, _len = tweens.length; _k < _len; _k++) {
          tween = tweens[_k];
          _results.push(tween.play());
        }
        return _results;
      } else {
        return this.fillEmptyFields();
      }
    };

    Renderer.prototype.fillEmptyFields = function() {
      var field, tween, tweens, x, y, _i, _j, _k, _len, _ref, _ref1, _results;
      tweens = [];
      for (x = _i = 0, _ref = this.board.size - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = this.board.size - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          field = this.board.fields[x][y];
          if (field.direction === 'none') {
            field.resetRandoms();
            this.moveFieldToLayer(field, this.animLayer);
            tweens.push(new Kinetic.Tween({
              node: field.widget.group,
              opacity: 1,
              duration: TWEEN_DURATION,
              onFinish: (function(_this) {
                return function() {
                  _this.moveFieldToLayer(field, _this.fieldsLayer);
                  return this.destroy();
                };
              })(this)
            }));
          }
        }
      }
      this.refreshWidgets();
      if (tweens.length > 0) {
        tweens[0].onFinish = (function(_this) {
          return function() {
            _this.moveFieldToLayer(field, _this.fieldsLayer);
            _this.finishMove();
            return this.destroy();
          };
        })(this);
        _results = [];
        for (_k = 0, _len = tweens.length; _k < _len; _k++) {
          tween = tweens[_k];
          _results.push(tween.play());
        }
        return _results;
      } else {
        return this.finishMove();
      }
    };

    Renderer.prototype.finishMove = function() {
      this.level.score += this.movePoints;
      this.level.scoreDiff = this.movePoints;
      if (this.moveLength > 2 * this.board.size) {
        this.level.movesDiff = Math.round((this.moveLength - 2 * this.board.size) / 2);
        this.level.moves += this.level.movesDiff;
      }
      this.topBarWidget.update();
      if (this.level.moves > 0) {
        return this.listening(true);
      } else {
        return console.log('total score: ' + this.level.score);
      }
    };

    return Renderer;

  })();

  Level = (function() {
    Level.prototype.board = null;

    Level.prototype.score = 0;

    Level.prototype.scoreDiff = 0;

    Level.prototype.moves = 5;

    Level.prototype.movesDiff = 0;

    function Level(boardSize) {
      if (boardSize == null) {
        boardSize = 9;
      }
      this.board = new Board(boardSize);
      this.renderer = new Renderer(this.board, this);
    }

    return Level;

  })();

  Game = (function() {
    Game.prototype.levels_params = [6, 7, 8];

    Game.prototype.level = null;

    Game.prototype.level_id = null;

    function Game() {
      var boardSize;
      this.level_id = 0;
      boardSize = this.levels_params[this.level_id];
      this.level = new Level(boardSize);
    }

    return Game;

  })();

  window.startGame = function() {
    var game;
    window.game = game = new Game();
    return window.onresize = function(event) {
      return game.level.renderer.refresh(event);
    };
  };

}).call(this);
