# GROT - html5 canvas game

TWEEN_DURATION = cfg.tweenDuration

delay1s = (func) -> setTimeout func, 1000

window.randomChoice = (values) ->
    # http://rosettacode.org/wiki/Pick_random_element#CoffeeScript
    return values[Math.floor(Math.random() * values.length)]


class QueryString
    # Provide easy access to QueryString data
    # https://gist.github.com/greystate/1274961

    constructor: (@queryString) ->
        @queryString or= window.document.location.search?.substr 1
        @variables = @queryString.split '&'
        @pairs = ([key, value] = pair.split '=' for pair in @variables)

    get: (name) ->
        for [key, value] in @pairs
            return value if key is name


class RenderManager extends GrotEngine.RenderManager
    # Manage canvas and widgets

    board: null
    stage: null
    barsLayer: null
    animLayer: null
    game: null
    topBarWidget: null
    menuOverlay: null

    constructor: (@boardSize, @game) ->
        [width, height] = @getWindowSize()
        @currentScale = @calculateScaleUnit()

        @addLayers()
        @addWidgets()

        @stage = new Kinetic.Stage
            container: 'wrap'
            width: width
            height: height - 4

        @stage.on 'onStageUpdated', @onStageUpdated.bind(@)
        @stage.on 'blurBoardStuff', @blurBoardStuff.bind(@)
        @stage.on 'normalizeBoardStuff', @normalizeBoardStuff.bind(@)

        @stage.fire 'onStageUpdated'

        @stage.add @board
        @stage.add @barsLayer
        @stage.add @animLayer
        @stage.add @menuOverlay

        @barsLayer.filters [Kinetic.Filters.Blur]
        @board.filters [Kinetic.Filters.Blur]

        super

        layers = @stage.getLayers()
        for layer in layers
            layer.fire('update')

    addLayers: ->
        @barsLayer = new GrotEngine.Layer
            width: 600
            height: 900
            margins: {x: '50%', y: 0}
            renderManager: @

        @board = new Grot.Board
            size: @boardSize
            renderManager: @
            margins: {x: '50%', y: 180}
            width: 600
            height: 600

        @game.board = @board

        # create next layers only for animations (better performance)
        @animLayer = new GrotEngine.Layer
            hitGraphEnabled: false
            margins: {x: '50%', y: 180}
            width: 600
            height: 600
            renderManager: @

        #create overlay for menu/gameover/help view
        @menuOverlay = new Grot.MenuOverlay
            renderManager: @

    addWidgets: ->
        @topBarWidget = new Grot.TopBarWidget
            game: @game
        @bottomBarWidget = new Grot.BottomBarWidget
            game: @game

        # add board fields to the layer
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @board.add @board.fields[x][y].widget

        # add bar widgets to a barsLayer

        @barsLayer.add @topBarWidget
        @barsLayer.add @bottomBarWidget

    normalizeBoardStuff: ->
        @barsLayer.blurRadius 0
        @board.blurRadius 0
        @board.clearCache()
        @barsLayer.clearCache()
        @barsLayer.batchDraw()
        @board.batchDraw()

    blurBoardStuff: ->
        @barsLayer.cache()
        @board.cache()
        @barsLayer.blurRadius 10
        @board.blurRadius 10;
        @barsLayer.batchDraw()
        @board.batchDraw()

    moveFieldToLayer: (field, toLayer) ->
        # moves field to new layer
        fromLayer = field.widget.getLayer()
        field.widget.moveTo(toLayer)
        # refresh layers cache
        fromLayer.draw()
        toLayer.draw()

    onStageUpdated: () ->
        # Resize and set positions of widgets

        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                field = @board.fields[x][y]
                [centerX, centerY] = field.getFieldCenter()
                widget = field.widget
                widget.relativeMove centerX, centerY
                if not widget.callback?
                    # set 'onClick' callback
                    widget.setupCallback(@startMove)

        return

    listening: (state) ->
        # toggle listening for event on all field widgets
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @board.fields[x][y].widget.listening(state)
        @board.drawHit()

    startMove: (field, event) =>
        # deactivate listening until animation is finished
        @listening(false)
        @game.moves -= 1
        @game.scoreDiff = 0
        @game.movesDiff = 0
        @topBarWidget.update()

        @movePoints = 0
        @moveLength = 0
        # start chain reaction
        @moveToNextField(field)

    moveToNextField: (startField) ->
        # one step in chain reaction
        [nextField, lastMove] = @board.getNextField(startField)
        [centerX, centerY] = nextField.getFieldCenter()
        startField.direction = 'none'
        @movePoints += startField.getPoints()
        @moveLength += 1

        # move field to animLayer until animation is finished
        @moveFieldToLayer(startField, @animLayer)

        tween = new Kinetic.Tween
            node: startField.widget
            duration: TWEEN_DURATION
            x: centerX
            y: centerY
            opacity: 0

            onFinish: =>
                if lastMove
                    @checkEmptyLines()
                else
                    @moveToNextField(nextField)

                `this.destroy()`

        tween.play()

    checkEmptyLines: () ->
        # count empty rows and columns and give extra points
        for x in [0..@board.size-1]
            isEmptyColumn = true
            for y in [0..@board.size-1]
                if @board.fields[x][y].direction != 'none'
                    isEmptyColumn = false

            if isEmptyColumn
                @movePoints += @board.size * 10

        for y in [0..@board.size-1]
            isEmptyRow = true
            for x in [0..@board.size-1]
                if @board.fields[x][y].direction != 'none'
                    isEmptyRow = false

            if isEmptyRow
                @movePoints += @board.size * 10

        @lowerFields()

    lowerFields: () ->
        # lower fields (gravity)
        tweens = []
        for y in [@board.size-2..0]
            for x in [0..@board.size-1]
                field = @board.fields[x][y]
                if field.direction != 'none'
                    result = @board.lowerField(field)
                    if result.length == 2
                        [newX, newY] = result
                        [centerX, centerY] = field.getFieldCenter()
                        # move field to animLayer until animation is finished
                        @moveFieldToLayer(field, @animLayer)

                        tweens.push new Kinetic.Tween
                            node: field.widget
                            easing: Kinetic.Easings.BounceEaseOut,
                            duration: TWEEN_DURATION
                            x: centerX
                            y: centerY
                            onFinish: =>
                                `this.destroy()`

        if tweens.length > 0
            tweens[0].onFinish = () =>
                @fillEmptyFields()
                `this.destroy()`

            for tween in tweens
                tween.play()
        else
            @fillEmptyFields()

    fillEmptyFields: () ->
        # reset fields in empty places and show them
        tweens = []
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                field = @board.fields[x][y]
                if field.direction == 'none'
                    field.resetRandoms()

                    # move field to animLayer until animation is finished
                    @moveFieldToLayer(field, @animLayer)

                    tweens.push new Kinetic.Tween
                        node: field.widget
                        opacity: 1
                        duration: TWEEN_DURATION
                        onFinish: =>
                            `this.destroy()`

        @stage.fire 'onStageUpdated'

        if tweens.length > 0
            tweens[0].onFinish = () =>
                @finishMove()
                `this.destroy()`

            for tween in tweens
                tween.play()
        else
            @finishMove()

    gameOver: () ->
        # return message with scored result
        @menuOverlay.fire 'showGameOver', @game.score

    finishMove: () ->
        # update game score

        @game.score += @movePoints
        @game.scoreDiff = @movePoints

        # threshold depends on current score, so more points you have -> longer path
        # you have to create to get moves bonus
        threshold = Math.floor(@game.score / (5*@board.size*@board.size)) + @board.size - 1
        if @moveLength >= threshold
            @game.movesDiff = @moveLength - threshold
            @game.moves += @game.movesDiff
        @topBarWidget.update()

        fields = (attrs.field for attrs in @animLayer.children)
        for field in fields
            @moveFieldToLayer(field, @board)

        if @game.moves > 0
            # reactivate listening
            @listening(true)
        else
            # game over
            @gameOver(@game)


class Game extends GrotEngine.Game
    board: null
    score: 0
    scoreDiff: 0
    moves: 5
    movesDiff: 0
    renderManager: null

    constructor: () ->
        super

        qs = (new QueryString).get('size')

        boardSize = if cfg.customBoardSize and qs
        then qs else cfg.defaultBoardSize

        @renderManager = new RenderManager boardSize, @


document.body.style.cssText = 'background-color: ' + cfg.bodyColor + '; margin: 0; padding: 0;'
window.game = game = new Game()
