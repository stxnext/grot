# GROT - html5 canvas game

TWEEN_DURATION = cfg.tweenDuration

delay1s = (func) -> setTimeout func, 1000

randomChoice = (values) ->
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


class FieldWidget extends GrotEngine.Widget
    # A cirlcle with label. Circle color depends on field value (points), label shows
    # an arrow. Widget is resized and moved be Renderer.

    circle: null
    label: null
    field: null
    callback: null
    relativeScale: null

    # based on: http://flatuicolors.com/

    colors:
        gray: cfg.circleColor1
        blue: cfg.circleColor2
        green: cfg.circleColor3
        red: cfg.circleColor4

    arrows:
        left: 270
        right: 90
        up: 0
        down: 180
        none: 0

    constructor: (config) ->
        super

        @relativeScale = @field.relativeScale
        @circle = new Kinetic.Circle
            x: 0
            y: 0
            radius: cfg.circleRadius
            fill: @colors[@field.value]
            transformsEnabled: 'position'

        @arrow = arrow.clone()
        @arrow.rotate(@arrows[@field.direction])

        @add @circle
        @add @arrow

        @scale @relativeScale

    relativeMove: (x, y) ->
        # to move widget to absolute position we have to calculate relative position
        # from current position
        @move {x: x - @x(), y: y - @y()}

    reset: () ->
        # update color and arrow after field reset
        @circle.fill(@colors[@field.value])
        angle = @arrows[@field.direction] - @arrow.rotation()
        @arrow.rotate(angle)

    setupCallback: (@callback) ->
        # setup 'onClick'
        widget = @
        @on 'mousedown touchstart', (event) ->
            widget.callback(widget.field, event)


class Field
    # State of field on a board.

    x: null
    y: null
    id: null
    value: null
    direction: null
    widget: null
    board: null
    renderManager: null
    relativeScale: null

    points:
        gray: 1
        blue: 2
        green: 3
        red: 4

    constructor: (@board, @x, @y) ->
        @id = "#{@x}-#{@y}"
        @renderManager = @board.renderManager
        @relativeScale = @board.fieldRelativeScale
        @relativeRadius = 2 * cfg.circleRadius * @relativeScale
        @resetRandoms()
        @widget = new FieldWidget
            field: @

    resetRandoms: () ->
        # choose random value and random direction
        # most common is gray field, most rare is red one.
        points = [
            'gray', 'gray', 'gray', 'gray',
            'blue', 'blue', 'blue',
            'green', 'green',
            'red'
        ]
        @value = randomChoice(points)
        @direction = randomChoice(['left', 'right', 'up', 'down'])
        if @widget?
            @widget.reset()

    getPoints: () ->
        # get points of field
        return @points[@value]

    getFieldCenter: ()->
        # calculate positions of a field widget
        relativeRadius = 2 * cfg.circleRadius * @relativeScale
        fieldSpacing = relativeRadius + cfg.spaceBetweenFields * @renderManager.currentScale
        return [@x * fieldSpacing + relativeRadius,  (@y) * fieldSpacing + relativeRadius]

    updatePosition: (@x, @y) ->
        # update field position
        @id = "#{@x}-#{@y}"


class Board extends GrotEngine.Layer
    # Grid of fields.

    size: 9
    fields: []
    fieldRelativeScale: 0
    renderManager: null

    constructor: (config) ->
        super

        @fieldRelativeScale = 5 / @size
        @createBoard @size

    createBoard: () ->
        # create size x size board, calculate initial value of fields
        for x in [0..@size-1]
            @fields.push (
                new Field @, x, y for y in [0..@size-1]
            )

    getNextField: (field, lastDirection=null) ->
        # returns next field in chain reaction and information is it last step in this chain reaction
        direction = if lastDirection then lastDirection else field.direction

        if direction == 'left'
            if field.x == 0
                return [field, true]
            nextField = @fields[field.x - 1][field.y]

        else if direction == 'right'
            if field.x == (@size-1)
                return [field, true]
            nextField = @fields[field.x + 1][field.y]

        else if direction == 'up'
            if field.y == 0
                return [field, true]
            nextField = @fields[field.x][field.y - 1]

        else if direction == 'down'
            if field.y == (@size-1)
                return [field, true]
            nextField = @fields[field.x][field.y + 1]

        if nextField.direction == 'none'
            # if next was alread cleared than go further in the same direction
            return @getNextField(nextField, direction)

        return [nextField, false]

    lowerField: (field) ->
        # when chain reaction is over fields that are 'flying' should be lowered
        oldX = field.x
        oldY = field.y
        [nextField, lastMove] = @getNextField(field, 'down')
        newX = nextField.x
        newY = nextField.y

        if not lastMove
            # if not last move, than we have to take one field above
            newY = nextField.y - 1

        if newY == oldY
            # no move
            return []

        # move empty field in old place
        @fields[oldX][oldY] = @fields[newX][newY]
        @fields[oldX][oldY].updatePosition(oldX, oldY)

        # move field to new place
        @fields[newX][newY] = field
        @fields[newX][newY].updatePosition(newX, newY)

        return [newX, newY]


class TopBarWidget extends GrotEngine.Widget
    # Top bar which displays current game stats

    game: null
    scoreLabel: null
    score: null
    movesLabel: null
    moves: null

    constructor: (config) ->
        super

        @scoreLabel = new Kinetic.Text
            x: 150
            y: 50
            text: 'Score'
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @score = new Kinetic.Text
            x: 150
            y: 100
            text: @game.score
            align: 'center'
            fontSize: cfg.fontScoMovSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @scoreDiff = new Kinetic.Text
            x: 150
            y: 150
            text: ''
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @movesLabel = new Kinetic.Text
            x: 450
            y: 50
            text: 'Moves'
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @moves = new Kinetic.Text
            x: 450
            y: 100
            text: @game.moves
            align: 'center'
            fontSize: cfg.fontScoMovSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @movesDiff = new Kinetic.Text
            x: 450
            y: 150
            text: ''
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @centerElement(@scoreLabel)
        @centerElement(@score)
        @centerElement(@scoreDiff)
        @centerElement(@movesLabel)
        @centerElement(@moves)
        @centerElement(@movesDiff)

        @add @scoreLabel
        @add @score
        @add @scoreDiff
        @add @movesLabel
        @add @moves
        @add @movesDiff

    update: () ->
        # update game stats
        @score.setText(@game.score)
        if @game.scoreDiff == 0
            @scoreDiff.setText(' ')
        else
            # if new value of scoreDiff than show it and after that fade it out
            @scoreDiff.setText('+'+@game.scoreDiff)
            @scoreDiff.opacity(1)

            delay1s =>
                tween = new Kinetic.Tween
                    node: @scoreDiff
                    opacity: 0
                    duration: TWEEN_DURATION
                    onFinish: ->
                        @destroy()

                tween.play()

        @moves.setText(@game.moves)
        if @game.movesDiff == 0
            @movesDiff.setText(' ')
        else
            # if new value of movesDiff than show it and after that fade it out
            @movesDiff.setText('+'+@game.movesDiff)
            @movesDiff.opacity(1)

            delay1s =>
                tween = new Kinetic.Tween
                    node: @movesDiff
                    opacity: 0
                    duration: TWEEN_DURATION
                    onFinish: ->
                        @destroy()

                tween.play()

        @centerElement(@score)
        @centerElement(@scoreDiff)
        @centerElement(@moves)
        @centerElement(@movesDiff)
        @getLayer().draw()


class BottomBarWidget extends GrotEngine.Widget
    # Bottom bar which displays help button

    label: null
    game: null
    help: null

    constructor: (config) ->
        super

        @label = new Kinetic.Text
            x: 294
            y: 860
            text: 'Help'
            align: 'center'
            fontSize: cfg.fontRestSize
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @centerElement(@label)
        @add @label

        imageObj = new Image()
        imageObj.onload = () =>
            @help = new Kinetic.Image
                x: 90
                y: 100
                image: imageObj
                width: 410
                height: 730

            @help.hide()
            @help.on 'mousedown touchstart', (event) =>
                @help.hide()
                @getLayer().draw()

            @add(@help)

        imageObj.src = 'img/help.png'

        @label.on 'mousedown touchstart', (event) =>
            @help.moveToTop()
            @help.show()
            @getLayer().draw()

class GameOverWidget extends GrotEngine.Widget
    # Bottom bar which displays help button

    gameOverLayer: null
    game: null

    constructor: (config) ->
        super

        @gameOverLayer = new Kinetic.Group

        background = new Kinetic.Rect
            width: 82
            height: 146
            x: 10
            y: 2
            fill: cfg.gameOverMessageColor
            opacity: 0.75

        @gameOverMsg = new Kinetic.Text
            x: 50
            y: 50
            text: ''
            align: 'center'
            fontSize: 8
            fontFamily: cfg.fontFamily
            fill: cfg.fontColor

        @scoreBoardLink = new Kinetic.Text
            x: 50
            y: 100
            text: 'GO TO\nSCORE BOARD'
            align: 'center'
            fontSize: 8
            fontFamily: cfg.fontFamily
            fill: 'red'

        @resetGame = new Kinetic.Text
            x: 24
            y: 6
            text: 'NEW GAME'
            align: 'center'
            fontSize: 5
            fontStyle: 'Bold'
            fontFamily: cfg.fontFamily
            fill: 'blue'

        @scoreBoardLink.on 'mousedown touchstart', (event) =>
            window.location.replace(cfg.scoreBoardLink)

        @resetGame.on 'mousedown touchstart', (event) =>
            window.location.replace(window.location.href)

        @centerElement(@scoreBoardLink)
        @centerElement(@gameOverMsg)
        @centerElement(@resetGame)

        @gameOverLayer.add(background)
        @gameOverLayer.add(@gameOverMsg)
        @gameOverLayer.add(@scoreBoardLink)
        @gameOverLayer.add(@resetGame)

    draw: () =>
        @add(@gameOverLayer)
        @getLayer().draw()

    update: () ->
        # update result for game over message
        @gameOverMsg.setText('GAME OVER\nResult:\n' + @game.score)
        @centerElement(@gameOverMsg)


class RenderManager extends GrotEngine.RenderManager
    # Manage canvas and widgets

    board: null
    stage: null
    barsLayer: null
    animLayer: null
    game: null
    topBarWidget: null
    gameOverWidget: null

    constructor: (@boardSize, @game) ->
        [width, height] = @getWindowSize()
        @currentScale = @calculateScaleUnit()

        @addLayers()
        @addWidgets()

        @stage = new Kinetic.Stage
            container: 'wrap'
            width: width
            height: height - 8

        @stage.on('onStageUpdated', @onStageUpdated.bind(@))
        @stage.fire('onStageUpdated')

        @stage.add @board
        @stage.add @animLayer
        @stage.add @barsLayer

        super

        layers = @stage.getLayers()
        for layer in layers
            layer.fire('update')

    addLayers: ->
        @barsLayer = new GrotEngine.Layer
            width: 600
            height: 900
            renderManager: @

        @board = new Board
            size: @boardSize
            renderManager: @
            initPos: {x: 0, y: 180}
            width: 600
            height: 600

        @game.board = @board

        # create next layers only for animations (better performance)
        @animLayer = new GrotEngine.Layer
            hitGraphEnabled: false
            initPos: {x: 0, y: 180}
            width: 600
            height: 600
            renderManager: @

    addWidgets: ->
        @topBarWidget = new TopBarWidget
            game: @game
        @bottomBarWidget = new BottomBarWidget
            game: @game
        @gameOverWidget = new GameOverWidget
            game: @game

        # add board fields to the layer
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @board.add @board.fields[x][y].widget

        # add bar widgets to a barsLayer

        @barsLayer.add @topBarWidget
        @barsLayer.add @bottomBarWidget
        @barsLayer.add @gameOverWidget


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

        @board.y(@board.initPos.y * @currentScale)
        @board.centerLayer()
        @animLayer.y(@animLayer.initPos.y * @currentScale)
        @animLayer.centerLayer()
        @barsLayer.centerLayer()

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
        @gameOverWidget.draw()

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
            console.log 'total score: ' + @game.score
            @gameOverWidget.update()
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
