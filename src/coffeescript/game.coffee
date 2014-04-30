# GROT - html5 canvas game

TWEEN_DURATION = 0.5


randomChoice = (values) ->
    # http://rosettacode.org/wiki/Pick_random_element#CoffeeScript
    return values[Math.floor(Math.random() * values.length)]


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
        yellow: '#e67e22'
        red: '#e74c3c'

    arrows:
        left: String.fromCharCode(8592)
        right: String.fromCharCode(8594)
        up: String.fromCharCode(8593)
        down: String.fromCharCode(8595)
        none: ' '

    constructor: (@field) ->
        # create elements of widget
        @group = new Kinetic.Group

        @circle = new Kinetic.Circle
            x: 0
            y: 0
            radius: 45
            fill: @colors[@field.value]

        @label = new Kinetic.Text
            x: 0
            y: 0
            text: @arrows[@field.direction]
            align: 'center'
            fontSize: 55
            fontFamily: 'Calibri'
            fontStyle: 'bold'
            fill: '#333333'

        @centerLabel()

        @group.add @circle
        @group.add @label

    centerLabel: () ->
        # place label in center of widget
        @label.offsetX(@label.width()/2)
        @label.offsetY(@label.height()/2)

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
        @label.setText(@arrows[@field.direction])
        @centerLabel()

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
        gray: 0
        blue: 1
        green: 2
        yellow: 3
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

class Renderer
    # Manage canvas and widgets

    board: null
    stage: null
    layer: null

    constructor: (@board) ->
        @cavnasSize = Math.min(window.innerHeight, window.innerWidth) - 20

        @stage = new Kinetic.Stage
            container: 'wrap'
            width: @cavnasSize
            height: @cavnasSize

        @refreshWidgets()

        # add fields widgets to a layer
        @layer = new Kinetic.Layer
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @layer.add @board.fields[x][y].widget.group
        @stage.add @layer

    resizeCanvas: () ->
        # adjust canvas size to window size
        @cavnasSize = Math.min(window.innerHeight, window.innerWidth) - 20
        @stage.setHeight @cavnasSize
        @stage.setWidth @cavnasSize

    refresh: () ->
        # called after windows resize
        @resizeCanvas()
        @refreshWidgets()

    getFieldCenter: (x, y) ->
        # calculate positions of a field widget
        unit = Math.round(@cavnasSize / (@board.size*2))
        centerX = 2*unit + x*2*unit
        centerY = 2*unit + y*2*unit
        return [centerX-unit, centerY-unit]

    refreshWidgets: () ->
        # Resize and set positions of widgets
        unit = Math.round(@cavnasSize / (@board.size*2))

        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                [centerX, centerY] = @getFieldCenter x, y
                widget = @board.fields[x][y].widget
                widget.scale unit / 50
                widget.move centerX, centerY
                if not widget.callback?
                    # set 'onClick' callback
                    widget.setupCallback(@startMove)

    listening: (state) ->
        # toggle listening for event on all field widgets
        for x in [0..@board.size-1]
            for y in [0..@board.size-1]
                @board.fields[x][y].widget.group.listening(state)
        @layer.drawHit()

    startMove: (field, event) =>
        # deactivate listening until animation is finished
        @listening(false)
        @movePoints = 0
        # start chain reaction
        @moveToNextField(field)

    moveToNextField: (startField) ->
        # one step in chain reaction
        [nextField, lastMove] = @board.getNextField(startField)
        [centerX, centerY] = @getFieldCenter nextField.x, nextField.y
        startField.direction = 'none'
        @movePoints += startField.getPoints()

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

        tween.play()

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
                        [centerX, centerY] = @getFieldCenter newX, newY

                        tweens.push new Kinetic.Tween
                            node: field.widget.group
                            easing: Kinetic.Easings.BounceEaseOut,
                            duration: TWEEN_DURATION
                            x: centerX
                            y: centerY

        if tweens.length > 0
            tweens[0].onFinish = () =>
                @fillEmptyFields()

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

                    tweens.push new Kinetic.Tween
                        node: field.widget.group
                        opacity: 1
                        duration: TWEEN_DURATION

        @refreshWidgets()

        if tweens.length > 0
            tweens[0].onFinish = () =>
                @finishMove()

            for tween in tweens
                tween.play()
        else
            @finishMove()


    finishMove: () ->
        # reactivate listening
        @listening(true)


class Level
    board: null

    constructor: (boardSize=9) ->
        @board = new Board boardSize
        @renderer = new Renderer @board


class Game
    levels_params: [5, 6, 7, 8]
    level: null
    level_id: null

    constructor: () ->
        # TODO: get active level id from local storage
        @level_id = 0
        boardSize = @levels_params[@level_id]
        @level = new Level boardSize

window.game = game = new Game()
window.onresize = (event) -> game.level.renderer.refresh(event)
