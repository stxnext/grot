# GROT - html5 canvas game

TWEEN_DURATION = 0.5

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


class FieldWidget
    # A cirlcle with label. Circle color depends on field value (points), label shows
    # an arrow. Widget is resized and moved be Renderer.

    group: null
    circle: null
    label: null
    field: null
    callback: null

    # based on: http://flatuicolors.com/
    colors:
        gray: '#95a5a6'
        blue: '#2980b9'
        green: '#27ae60'
        red: '#e74c3c'

    arrows:
        left: 270
        right: 90
        up: 0
        down: 180
        none: 0

    constructor: (@field) ->
        # create elements of widget
        @group = new Kinetic.Group
            field: @field

        @circle = new Kinetic.Circle
            x: 0
            y: 0
            radius: 45
            fill: @colors[@field.value]
            transformsEnabled: 'position'

        @arrow = arrow.clone()
        @arrow.rotate(@arrows[@field.direction])

        @group.add @circle
        @group.add @arrow

    move: (x, y) ->
        # to move widget to absolute position we have to calculate relative position
        # from current position
        relativeX = x - @group.x()
        relativeY = y - @group.y()
        @group.move {x: relativeX, y: relativeY}

    scale: (scale) ->
        # always scale with ration=1 (the same in both dimensions)
        @group.scale {x: scale, y: scale}

    reset: () ->
        # update color and arrow after field reset
        @circle.fill(@colors[@field.value])
        angle = @arrows[@field.direction] - @arrow.rotation()
        @arrow.rotate(angle)

    setupCallback: (@callback) ->
        # setup 'onClick'
        widget = @
        @group.on 'mousedown touchstart', (event) ->
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

    points:
        gray: 1
        blue: 2
        green: 3
        red: 4

    constructor: (@board, @x, @y) ->
        @id = "#{@x}-#{@y}"
        @resetRandoms()
        @widget = new FieldWidget @

    resetRandoms: () ->
        # choose random value and random direction
        @value = randomChoice((k for k of @points))
        @direction = randomChoice(['left', 'right', 'up', 'down'])
        if @widget?
            @widget.reset()

    getPoints: () ->
        # get points of field
        return @points[@value]

    updatePosition: (@x, @y) ->
        # update field position
        @id = "#{@x}-#{@y}"


class Board
    # Grid of fields.

    size: 0
    fields: []

    constructor: (@size=9) ->
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


class TopBarWidget
    # Top bar which displays current game stats

    level: null
    group: null
    scoreLabel: null
    score: null
    movesLabel: null
    moves: null

    constructor: (@level) ->
        @group = new Kinetic.Group

        @scoreLabel = new Kinetic.Text
            x: 25
            y: 5
            text: 'Score'
            align: 'center'
            fontSize: 6
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @score = new Kinetic.Text
            x: 25
            y: 15
            text: @level.score
            align: 'center'
            fontSize: 8
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @scoreDiff = new Kinetic.Text
            x: 25
            y: 25
            text: ''
            align: 'center'
            fontSize: 6
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @movesLabel = new Kinetic.Text
            x: 75
            y: 5
            text: 'Moves'
            align: 'center'
            fontSize: 6
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @moves = new Kinetic.Text
            x: 75
            y: 15
            text: @level.moves
            align: 'center'
            fontSize: 8
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @movesDiff = new Kinetic.Text
            x: 75
            y: 25
            text: ''
            align: 'center'
            fontSize: 6
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @centerText(@scoreLabel)
        @centerText(@score)
        @centerText(@scoreDiff)
        @centerText(@movesLabel)
        @centerText(@moves)
        @centerText(@movesDiff)

        @group.add @scoreLabel
        @group.add @score
        @group.add @scoreDiff
        @group.add @movesLabel
        @group.add @moves
        @group.add @movesDiff

    scale: (scale) ->
        @group.scale {x: scale, y: scale}

    centerText: (text) ->
        # place label in center of widget
        text.offsetX(text.width()/2)
        text.offsetY(text.height()/2)

    update: () ->
        # update game stats
        @score.setText(@level.score)
        if @level.scoreDiff == 0
            @scoreDiff.setText(' ')
        else
            # if new value of scoreDiff than show it and after that fade it out
            @scoreDiff.setText('+'+@level.scoreDiff)
            @scoreDiff.opacity(1)

            delay1s =>
                tween = new Kinetic.Tween
                    node: @scoreDiff
                    opacity: 0
                    duration: TWEEN_DURATION
                    onFinish: ->
                        @destroy()

                tween.play()

        @moves.setText(@level.moves)
        if @level.movesDiff == 0
            @movesDiff.setText(' ')
        else
            # if new value of movesDiff than show it and after that fade it out
            @movesDiff.setText('+'+@level.movesDiff)
            @movesDiff.opacity(1)

            delay1s =>
                tween = new Kinetic.Tween
                    node: @movesDiff
                    opacity: 0
                    duration: TWEEN_DURATION
                    onFinish: ->
                        @destroy()

                tween.play()

        @centerText(@score)
        @centerText(@scoreDiff)
        @centerText(@moves)
        @centerText(@movesDiff)
        @group.getLayer().draw()


class BottomBarWidget
    # Bottom bar which displays help button

    group: null
    label: null
    help: null

    constructor: (@level) ->
        @group = new Kinetic.Group

        @label = new Kinetic.Text
            x: 50
            y: 145
            text: 'Help'
            align: 'center'
            fontSize: 6
            fontFamily: 'Courier New'
            fill: '#ecf0f1'

        @centerText(@label)
        @group.add @label

        imageObj = new Image()
        imageObj.onload = () =>
            @help = new Kinetic.Image
                x: 10
                y: 2
                image: imageObj
                width: 82
                height: 146

            @help.hide()
            @help.on 'mousedown touchstart', (event) =>
                @help.hide()
                @group.getLayer().draw()

            @group.add(@help)

        imageObj.src = 'img/help.png'

        @label.on 'mousedown touchstart', (event) =>
            @help.moveToTop()
            @help.show()
            @group.getLayer().draw()

    centerText: (text) ->
        # place label in center of widget
        text.offsetX(text.width()/2)
        text.offsetY(text.height()/2)

    scale: (scale) ->
        @group.scale {x: scale, y: scale}

class Renderer
    # Manage canvas and widgets

    board: null
    stage: null
    fieldsLayer: null
    barsLayer: null
    animLayer: null
    level: null
    topBarWidget: null

    constructor: (@board, @level) ->
        [width, height] = @getCanvasSize()
        @cavnasWidth = width

        @stage = new Kinetic.Stage
            container: 'wrap'
            width: width
            height: height

        @topBarWidget = new TopBarWidget @level
        @bottomBarWidget = new BottomBarWidget @level

        @refreshWidgets()

        # add fields widgets to a layer
        @fieldsLayer = new Kinetic.Layer
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @fieldsLayer.add @board.fields[x][y].widget.group

        # add bars to separated layer
        @barsLayer = new Kinetic.Layer
        @barsLayer.add @topBarWidget.group
        @barsLayer.add @bottomBarWidget.group

        # create next layers only for animations (better performance)
        @animLayer = new Kinetic.Layer
            hitGraphEnabled: false

        @stage.add @fieldsLayer
        @stage.add @animLayer
        @stage.add @barsLayer

    moveFieldToLayer: (field, toLayer) ->
        # moves field to new layer
        fromLayer = field.widget.group.getLayer()
        field.widget.group.moveTo(toLayer)
        # refresh layers cache
        fromLayer.draw()
        toLayer.draw()

    getCanvasSize: () ->
        # calculate canvas size
        if window.innerHeight < window.innerWidth
            # landscape
            height = window.innerHeight - 20
            width = Math.round(height / 1.5)
        else
            # portrait
            width = window.innerWidth - 20
            height = Math.round(width * 1.5)

        return [width, height]

    resizeCanvas: () ->
        [width, height] = @getCanvasSize()
        @cavnasWidth = width
        @stage.setHeight height
        @stage.setWidth width

    refresh: () ->
        # called after windows resize
        @resizeCanvas()
        @refreshWidgets()

    getFieldCenter: (x, y) ->
        # calculate positions of a field widget
        unit = Math.round(@cavnasWidth / (@board.size*2))
        topMargin = Math.round(@cavnasWidth * 0.33)
        centerX = 2*unit + x*2*unit
        centerY = topMargin + 2*unit + y*2*unit
        return [centerX-unit, centerY-unit]

    refreshWidgets: () ->
        # Resize and set positions of widgets
        unit = Math.round(@cavnasWidth / (@board.size*2))

        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                [centerX, centerY] = @getFieldCenter x, y
                widget = @board.fields[x][y].widget
                widget.scale unit / 50
                widget.move centerX, centerY
                if not widget.callback?
                    # set 'onClick' callback
                    widget.setupCallback(@startMove)

        @topBarWidget.scale @cavnasWidth / 100
        @bottomBarWidget.scale @cavnasWidth / 100

    listening: (state) ->
        # toggle listening for event on all field widgets
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @board.fields[x][y].widget.group.listening(state)
        @fieldsLayer.drawHit()

    startMove: (field, event) =>
        # deactivate listening until animation is finished
        @listening(false)
        @level.moves -= 1
        @level.scoreDiff = 0
        @level.movesDiff = 0
        @topBarWidget.update()

        @movePoints = 0
        @moveLength = 0
        # start chain reaction
        @moveToNextField(field)

    moveToNextField: (startField) ->
        # one step in chain reaction
        [nextField, lastMove] = @board.getNextField(startField)
        [centerX, centerY] = @getFieldCenter nextField.x, nextField.y
        startField.direction = 'none'
        @movePoints += startField.getPoints()
        @moveLength += 1

        # move field to animLayer until animation is finished
        @moveFieldToLayer(startField, @animLayer)

        tween = new Kinetic.Tween
            node: startField.widget.group
            duration: TWEEN_DURATION
            x: centerX
            y: centerY
            opacity: 0

            onFinish: =>
                if lastMove
                    @lowerFields()
                else
                    @moveToNextField(nextField)

                `this.destroy()`

        tween.play()

    lowerFields: () ->
        for x in [0..@board.size-1]
            isEmptyColumn = true
            for y in [0..@board.size-1]
                if @board.fields[x][y].direction != 'none'
                    isEmptyColumn = false

            if isEmptyColumn
                @movePoints += 10

        for y in [0..@board.size-1]
            isEmptyRow = true
            for x in [0..@board.size-1]
                if @board.fields[x][y].direction != 'none'
                    isEmptyRow = false

            if isEmptyRow
                @movePoints += 10

        # lower fields (gravity)
        tweens = []
        for y in [@board.size-2..0]
            for x in [0..@board.size-1]
                field = @board.fields[x][y]
                if field.direction != 'none'
                    result = @board.lowerField(field)
                    if result.length == 2
                        [newX, newY] = result
                        [centerX, centerY] = @getFieldCenter newX, newY

                        # move field to animLayer until animation is finished
                        @moveFieldToLayer(field, @animLayer)

                        tweens.push new Kinetic.Tween
                            node: field.widget.group
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
                        node: field.widget.group
                        opacity: 1
                        duration: TWEEN_DURATION
                        onFinish: =>
                            `this.destroy()`

        @refreshWidgets()

        if tweens.length > 0
            tweens[0].onFinish = () =>
                @finishMove()
                `this.destroy()`

            for tween in tweens
                tween.play()
        else
            @finishMove()


    finishMove: () ->
        # update level score

        @level.score += @movePoints
        @level.scoreDiff = @movePoints
        # console.log @moveLength
        boardQuarter = Math.round((@board.size*@board.size)/4)
        if @moveLength >= boardQuarter
            @level.movesDiff = Math.round((@moveLength - boardQuarter)/2) + 1
            @level.moves += @level.movesDiff
        @topBarWidget.update()

        fields = (group.attrs.field for group in @animLayer.children)
        for field in fields
            @moveFieldToLayer(field, @fieldsLayer)

        if @level.moves > 0
            # reactivate listening
            @listening(true)
        else
            # game over
            console.log 'total score: ' + @level.score


class Level
    board: null

    score: 0
    scoreDiff: 0
    moves: 5
    movesDiff: 0

    constructor: (boardSize=9) ->
        @board = new Board boardSize
        @renderer = new Renderer @board, @


class Game
    level: null

    constructor: () ->
        qs = new QueryString
        boardSize = qs.get('size')
        if not boardSize?
            boardSize = 4

        @level = new Level boardSize


window.game = game = new Game()
# window.onresize = (event) -> game.level.renderer.refresh(event)
